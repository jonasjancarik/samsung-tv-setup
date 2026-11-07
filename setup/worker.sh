D=/opt/usr/share/free-my-tv-setup
exec >> "$D/startup.log" 2>&1
echo "START $(date -u) uid=$(id -u) boot=$(cat /proc/sys/kernel/random/boot_id) version=3"
[ ! -e "$D/disabled" ] || exit 0
apply_controls() {
 for u in adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service; do
  if [ ! -e "/run/systemd/system/$u" ] && [ ! -L "/run/systemd/system/$u" ]; then ln -s /dev/null "/run/systemd/system/$u"; fi
 done
 systemctl daemon-reload
 systemctl stop --no-block adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service
 systemctl reset-failed adagent-service.service canalysis-service.service pisa-service.service contents-recognition-service.service media-analytics-service.service 2>/dev/null || true
 buxton2ctl set-bool system db/menu/autorun_tv_plus 0
 echo "CONTROLS_READY $(date -u)"
}
# Boot-time systemd jobs must not hold up the app-launch path.
apply_controls &
focus_snapshot() { enlightenment_info -topvwins 2>/dev/null | gawk -f "$D/focus.awk"; }
launch() {
 echo "LAUNCH $(date -u) reason=$1 user=5001"
 app_launcher -u 5001 -s FreeMyTVio.FreeMyTV
 sleep 1
 info=$(focus_snapshot)
 win=${info%%|*}
 if [ "${info#*|}" != free ]; then
  case "$win" in
   0x*)
    enlightenment_info -basic_op_gen "$win" uniconify
    enlightenment_info -basic_op_gen "$win" activate
    sleep 1;;
  esac
 fi
 info=$(focus_snapshot)
 if [ "${info#*|}" = free ]; then
  echo "FOCUS_CONFIRMED $(date -u) window=${info%%|*}"
  return 0
 fi
 echo "FOCUS_PENDING $(date -u) state=${info#*|}"
 return 1
}
poweron() { buxton2ctl get system db/sysman/prev_poweron_time 2>/dev/null | sed 's/.*: //'; }
last_poweron=
last_time=$(date +%s)
was_on=1
pending=1
attempts=0
guard=8
saw_free=0
sleep 1
# Launch before waiting for the power database or network API.
if launch boot; then pending=0; saw_free=1; fi
last_poweron=$(poweron)
while [ ! -e "$D/disabled" ]; do
 now=$(date +%s)
 current_poweron=$(poweron)
 state=$(curl -s --max-time 2 http://127.0.0.1:8001/api/v2/ | sed -n 's/.*"PowerState":"\([^"]*\)".*/\1/p')
 wake=0
 if [ -n "$current_poweron" ] && [ "$current_poweron" != "$last_poweron" ]; then wake=1; fi
 if [ $((now-last_time)) -gt 30 ]; then wake=1; fi
 case "$state" in
  standby|off) was_on=0; pending=1; attempts=0; saw_free=0;;
  on) if [ "$was_on" = 0 ]; then wake=1; fi; was_on=1;;
 esac
 if [ "$wake" = 1 ]; then pending=1; attempts=0; guard=6; saw_free=0; fi
 case "$state" in
  standby|off) ;;
  *)
   if [ "$pending" = 1 ] || [ "$guard" -gt 0 ]; then
    info=$(focus_snapshot)
    focused=${info#*|}
    if [ "$focused" = free ]; then
     pending=0; attempts=0; saw_free=1
    elif [ "$guard" -gt 0 ] && [ "$saw_free" = 1 ]; then
     if [ "$focused" = home ]; then pending=1
     elif [ "$focused" = other ]; then
      echo "STARTUP_GUARD_FINISHED $(date -u) reason=other-app"
      guard=0; pending=0
     fi
    fi
   fi
   if [ "$pending" = 1 ]; then
    attempts=$((attempts+1))
    if launch startup-or-wake; then pending=0; attempts=0; saw_free=1
    elif [ "$attempts" -ge 12 ]; then
     echo "LAUNCH_ABANDONED $(date -u) attempts=$attempts"
     pending=0; guard=0
    fi
   fi;;
 esac
 if [ "$guard" -gt 0 ]; then guard=$((guard-1)); fi
 last_poweron=$current_poweron
 last_time=$now
 sleep 5
done
