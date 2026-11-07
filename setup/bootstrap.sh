set -eu
D=/opt/usr/share/free-my-tv-setup
[ ! -e "$D/disabled" ] || exit 0
cat > /run/systemd/system/free-my-tv-startup.service <<'UNIT'
[Unit]
Description=Free My TV startup and ad service controls
After=app-boot-manager.service
[Service]
Type=simple
ExecStart=/usr/bin/gawk -f /opt/usr/share/free-my-tv-setup/worker.awk
Restart=on-failure
RestartSec=10
UNIT
systemctl daemon-reload
systemctl start --no-block free-my-tv-startup.service
