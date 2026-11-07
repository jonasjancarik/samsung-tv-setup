set -eu
D=/opt/usr/share/free-my-tv-setup
[ ! -e "$D/disabled" ] || exit 0
# A transient service avoids a full daemon-reload on the cold-start path.
# Keep compatibility with the old unit during a live update; /run clears at boot.
if [ -f /run/systemd/system/free-my-tv-startup.service ]; then
 systemctl start --no-block free-my-tv-startup.service
else
 systemd-run --no-block --unit=free-my-tv-startup --description='Free My TV startup and ad service controls' --property=After=app-boot-manager.service --property=Restart=on-failure --property=RestartSec=10s /usr/bin/gawk -f "$D/worker.awk"
fi
