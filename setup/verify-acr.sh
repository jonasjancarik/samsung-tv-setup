echo '=== BOOT ==='
cat /proc/sys/kernel/random/boot_id
cat /proc/uptime
echo '=== ACR EXECUTABLES ==='
for p in /opt/usr/apps/com.samsung.tv.acr-service-app/bin/acr /opt/usr/apps/com.samsung.tv.iacr/bin/iacr; do
 echo "$p"
 if [ -e "$p" ] || [ -L "$p" ]; then ls -l "$p"; else echo 'Original path absent'; fi
 if [ -e "$p.freemytv-disabled" ]; then sha256sum "$p.freemytv-disabled"; else echo 'Backup absent'; fi
done
echo '=== RECORDED ORIGINAL HASHES ==='
grep -E '/(acr|iacr)$' /opt/usr/share/free-my-tv-setup/executables-before.sha256 || true
echo '=== APP FRAMEWORK STATE ==='
app_launcher -S | grep -E 'com.samsung.tv.acr |com.samsung.tv.iacr ' || true
echo '=== PROCESS EXECUTABLES ==='
for proc in /proc/[0-9]*; do
 exe=$(readlink "$proc/exe" 2>/dev/null) || continue
 case "$exe" in
  */bin/acr|*/bin/acr\ *|*/bin/acr.freemytv-disabled*|*/bin/iacr|*/bin/iacr\ *|*/bin/iacr.freemytv-disabled*)
   echo "PID=${proc##*/} EXE=$exe"
   tr '\000' ' ' < "$proc/cmdline"; echo;;
 esac
done
echo '=== REGISTERED PACKAGE PATHS ==='
sqlite3 -readonly /opt/dbspace/.pkgmgr_parser.db "select app_id,app_exec,app_onboot,app_autorestart,app_root_path,package from package_app_info where package in ('com.samsung.tv.acr-service-app','com.samsung.tv.iacr');"
echo '=== ALTERNATE PRELOAD PATHS ==='
for d in /usr/apps/com.samsung.tv.acr-service-app /usr/apps/com.samsung.tv.iacr /opt/usr/globalapps/com.samsung.tv.acr-service-app /opt/usr/globalapps/com.samsung.tv.iacr; do
 if [ -d "$d" ]; then ls -ld "$d"; find "$d" -maxdepth 2 -type f -name '*acr*'; fi
done
true
