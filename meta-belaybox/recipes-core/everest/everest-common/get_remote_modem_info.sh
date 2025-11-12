remotemac=$( plctool -me -i eth1 | grep "station->MAC" | sed "s/		station->MAC =//")
if [ -z "$remotemac" ] 
then 
  echo "No remote MAC found, probably establish SLAC first!"
else
  plctool -Ifa -i eth1 $remotemac
fi
