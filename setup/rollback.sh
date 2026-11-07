set -eu
D=/opt/usr/share/free-my-tv-setup
: > "$D/disabled"
systemctl stop free-my-tv-startup.service
cp -p "$D/parseinfo.sh.stock" /opt/etc/parseinfo.sh
if [ -f "$D/executables-moved.txt" ]; then
 while IFS= read -r f; do
  if [ -e "$f.freemytv-disabled" ] && [ ! -e "$f" ]; then mv "$f.freemytv-disabled" "$f"; fi
 done < "$D/executables-moved.txt"
fi
mkdir -p "$D/rollback-masks" "$D/rollback-markers"
for u in adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service; do
 if [ "$(readlink "/run/systemd/system/$u")" = /dev/null ]; then mv "/run/systemd/system/$u" "$D/rollback-masks/$u"; fi
done
if [ -f "$D/markers-created.txt" ]; then
 while IFS= read -r m; do if [ -e "/opt/usr/share/systemd/system/$m" ]; then mv "/opt/usr/share/systemd/system/$m" "$D/rollback-markers/$m"; fi; done < "$D/markers-created.txt"
fi
buxton2ctl set-bool system db/menu/autorun_tv_plus 1
systemctl daemon-reload
echo 'Original startup hook and ad executables restored. Reboot to resume the original services.'
