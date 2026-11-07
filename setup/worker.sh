D=/opt/usr/share/free-my-tv-setup
exec >> "$D/startup.log" 2>&1
echo "START $(date -u) uid=$(id -u) boot=$(cat /proc/sys/kernel/random/boot_id)"
[ ! -e "$D/disabled" ] || exit 0
for u in adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service; do
 if [ ! -e "/run/systemd/system/$u" ] && [ ! -L "/run/systemd/system/$u" ]; then ln -s /dev/null "/run/systemd/system/$u"; fi
done
systemctl daemon-reload
systemctl stop --no-block adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service
systemctl reset-failed adagent-service.service canalysis-service.service pisa-service.service contents-recognition-service.service media-analytics-service.service 2>/dev/null || true
buxton2ctl set-bool system db/menu/autorun_tv_plus 0
launch() {
 echo "LAUNCH $(date -u) reason=$1"
 app_launcher -s FreeMyTVio.FreeMyTV
}
poweron() { buxton2ctl get system db/sysman/prev_poweron_time 2>/dev/null | sed 's/.*: //'; }
last_poweron=$(poweron)
last_time=$(date +%s)
was_on=0
pending=1
sleep 10
if launch boot; then pending=0; was_on=1; fi
while [ ! -e "$D/disabled" ]; do
 now=$(date +%s)
 current_poweron=$(poweron)
 if [ -n "$current_poweron" ] && [ "$current_poweron" != "$last_poweron" ]; then
  sleep 2
  if launch power-timestamp; then pending=0; was_on=1; else pending=1; fi
 fi
 if [ $((now-last_time)) -gt 30 ]; then
  if launch resume; then pending=0; was_on=1; else pending=1; fi
 fi
 if [ "$pending" = 1 ]; then
  if launch retry; then pending=0; was_on=1; fi
 fi
 state=$(curl -s --max-time 2 http://127.0.0.1:8001/api/v2/ | sed -n 's/.*"PowerState":"\([^"]*\)".*/\1/p')
 case "$state" in
  on)
   if [ "$was_on" = 0 ] || [ "$pending" = 1 ]; then
    sleep 4
    if launch power-on; then pending=0; was_on=1; else pending=1; fi
   fi;;
  standby|off) was_on=0; pending=1;;
 esac
 last_poweron=$current_poweron
 last_time=$now
 sleep 5
done
