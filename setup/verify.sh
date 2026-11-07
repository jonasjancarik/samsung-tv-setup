echo '=== STARTUP WORKER ==='
systemctl show -p ActiveState -p SubState -p MainPID free-my-tv-startup.service
tail -12 /opt/usr/share/free-my-tv-setup/startup.log
echo '=== DISABLED EXECUTABLES ==='
while IFS= read -r f; do if [ ! -e "$f" ] && [ -e "$f.freemytv-disabled" ]; then echo "DISABLED $f"; else echo "UNEXPECTED $f"; fi; done < /opt/usr/share/free-my-tv-setup/executables-moved.txt
echo '=== SERVICE STATES ==='
for u in adagent-service.service canalysis-service.service pisa-service.service contents-recognition-service.service media-analytics-service.service; do echo "$u $(systemctl is-active "$u")"; done
echo '=== AD APPS AND LAUNCHER ==='
app_launcher -S | grep -E 'com.samsung.tv.acr |com.samsung.tv.iacr |com.samsung.tv.targeted-ad-service |com.samsung.tv.coba.adagent |com.samsung.tizen.samsung-analytics |adplatform.ADPlayer |FreeMyTVio.FreeMyTV ' || true
echo '=== POWER SETTINGS ==='
buxton2ctl get system db/menu/autorun_tv_plus
buxton2ctl get system db/sysman/prev_poweron_time
echo '=== BOOT ID ==='
cat /proc/sys/kernel/random/boot_id
echo '=== OWNED STARTUP UNIT ==='
cat /run/systemd/system/free-my-tv-startup.service
