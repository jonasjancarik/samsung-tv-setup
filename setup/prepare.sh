set -eu
D=/opt/usr/share/free-my-tv-setup
if [ -e "$D" ]; then echo 'Setup directory already exists; refusing to overwrite'; exit 1; fi
test "$(sha256sum /opt/etc/parseinfo.sh | cut -d' ' -f1)" = c6369e7dec69408e176daa252d436acf6f8e265f560504d8bd831c8023c71d61
mkdir -m 700 "$D"
cp -p /opt/etc/parseinfo.sh "$D/parseinfo.sh.stock"
sha256sum "$D/parseinfo.sh.stock"
sqlite3 -readonly /opt/dbspace/.pkgmgr_parser.db "select package,package_type,package_disable from package_info where package in ('com.samsung.tv.iacr','com.samsung.tv.canalysis-service','com.samsung.tv.pisa-service','com.samsung.tv.coba.adagent','com.samsung.tizen.samsung-analytics','adplatform','com.samsung.tv.acr-service-app','com.samsung.tv.targeted-ad-service');" > "$D/packages-before.tsv"
for key in db/boot/app_booting/autorun_app db/boot/app_booting/autorun_app_id db/boot/app_booting/autorun_finish db/menu/autorun_tv_plus db/menu/system/smartfeatures/autorun-defaultapp db/mls/mls_lastapp; do buxton2ctl get system "$key"; done > "$D/startup-before.txt"
for m in pisa-service canalysis-daemon; do
 if [ ! -e "/opt/usr/share/systemd/system/$m" ]; then
  : > "/opt/usr/share/systemd/system/$m"
  echo "$m" >> "$D/markers-created.txt"
 fi
done
for u in media-analytics-service.service contents-recognition-service.service pisa-service.socket pisa-service.path; do
 if [ ! -e "/run/systemd/system/$u" ] && [ ! -L "/run/systemd/system/$u" ]; then ln -s /dev/null "/run/systemd/system/$u"; echo "$u" >> "$D/masks-created.txt"; fi
done
systemctl daemon-reload
systemctl stop --no-block adagent-service.service canalysis-service.service pisa-service.service pisa-service.socket pisa-service.path media-analytics-service.service contents-recognition-service.service
echo 'Preparation complete; no packages were uninstalled.'
