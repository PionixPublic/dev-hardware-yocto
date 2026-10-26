#!/bin/bash
# Health gate for rauc-commit.service (used as ExecCondition).
#   exit 0 -> the booted system is healthy, commit the slot
#   exit 1 -> not healthy, skip the commit (the tryboot fallback stays armed)
# Never exits 255, systemd treats that as a failure of the unit.
#
# Restart=always services never reach "failed" while crash looping, so
# "systemctl is-failed" is not enough. A service is healthy when it is active,
# (everest) has reported "EVerest up and running" in the run that is currently
# active, and is still the same process with an unchanged restart counter after a
# settle period.
#
# Tunables (environment): HEALTH_GATE_TIMEOUT (s, default 300),
# HEALTH_GATE_SETTLE (s, default 20), HEALTH_GATE_MAX_RESTARTS (default 3),
# HEALTH_GATE_SERVICES (default "everest.service display-app.service").

TIMEOUT=${HEALTH_GATE_TIMEOUT:-300}
SETTLE=${HEALTH_GATE_SETTLE:-20}
MAX_RESTARTS=${HEALTH_GATE_MAX_RESTARTS:-3}
SERVICES=${HEALTH_GATE_SERVICES:-"everest.service display-app.service"}
UP_MARKER="EVerest up and running"

log() { echo "health-gate: $*"; }

prop() { systemctl show -p "$2" --value "$1" 2>/dev/null; }

# services that are not enabled or were skipped by their ExecCondition are not
# part of this variant and must not block the commit
required() {
    local svc=$1
    if [ "$(prop "$svc" Result)" = "exec-condition" ]; then
        return 1
    fi
    case "$(systemctl is-enabled "$svc" 2>/dev/null)" in
        enabled|enabled-runtime|static|alias) return 0 ;;
        *) return 1 ;;
    esac
}

# is the service up right now? prints the reason on failure
check_up() {
    local svc=$1 state pid n
    state=$(prop "$svc" ActiveState)
    pid=$(prop "$svc" MainPID)
    n=$(prop "$svc" NRestarts)
    if [ "$state" != active ] || [ "${pid:-0}" = 0 ]; then
        why="$svc is $state (MainPID=${pid:-0}, NRestarts=${n:-0})"
        return 1
    fi
    if [ "${n:-0}" -gt "$MAX_RESTARTS" ]; then
        why="$svc restarted ${n} times (max $MAX_RESTARTS)"
        return 1
    fi
    if [ "$svc" = everest.service ]; then
        if ! journalctl -b -u "$svc" "_PID=$pid" --no-pager -q 2>/dev/null | grep -qF "$UP_MARKER"; then
            why="$svc (pid $pid) has not reported \"$UP_MARKER\" yet"
            return 1
        fi
    fi
    return 0
}

snapshot() { # service -> "pid restarts"
    echo "$(prop "$1" MainPID) $(prop "$1" NRestarts)"
}

todo=""
for svc in $SERVICES; do
    if required "$svc"; then todo="$todo $svc"; else log "$svc not required on this system, ignored"; fi
done
[ -n "$todo" ] || { log "no services to wait for, healthy"; exit 0; }

why=""
while :; do
    ok=1
    for svc in $todo; do
        if ! check_up "$svc"; then ok=0; break; fi
    done
    [ $ok = 1 ] && break
    if [ "$SECONDS" -ge "$TIMEOUT" ]; then
        log "FAIL after ${SECONDS}s: $why, not committing the slot"
        exit 1
    fi
    sleep 3
done
log "all up after ${SECONDS}s:$todo, settling for ${SETTLE}s"

declare -A before
for svc in $todo; do before[$svc]=$(snapshot "$svc"); done
sleep "$SETTLE"
for svc in $todo; do
    after=$(snapshot "$svc")
    if [ "$after" != "${before[$svc]}" ]; then
        log "FAIL: $svc changed (pid restarts) \"${before[$svc]}\" -> \"$after\" during settle, not committing the slot"
        exit 1
    fi
    if ! check_up "$svc"; then
        log "FAIL: $why after settle, not committing the slot"
        exit 1
    fi
done
log "PASS:$todo are up and stable (SECONDS=$SECONDS), committing the slot"
exit 0
