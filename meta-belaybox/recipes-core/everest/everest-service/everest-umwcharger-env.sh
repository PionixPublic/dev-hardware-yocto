#!/bin/sh
# uMWCharger: make sure everest_environment.env selects a config this image has.
# The env file lives in the /etc overlay shared by both slots, so it can come
# from an older image whose config names no longer exist (e.g. kirkstone's
# 2_config-dc-iso2.yaml). A missing file, an empty value or a config that is
# not there falls back to the default; EVerest would not start otherwise.
ENV_FILE=/etc/everest/everest_environment.env
DEFAULT=/etc/everest/custom_configs/1_CCS_DIN_SPEC_70121-offline.yaml

conf=$(sed -n 's/^[[:space:]]*EVEREST_CONFIG=//p' "$ENV_FILE" 2>/dev/null | tail -n 1)
# systemd accepts the value in single or double quotes
conf=$(printf '%s' "$conf" | sed -e "s/^'\(.*\)'\$/\1/" -e 's/^"\(.*\)"$/\1/')

[ -n "$conf" ] && [ -f "$conf" ] && exit 0

echo "everest-umwcharger-env: config '${conf}' not found, using ${DEFAULT}" >&2
printf 'EVEREST_CONFIG=%s\n' "$DEFAULT" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"
