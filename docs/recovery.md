# Recovery

Read when restoring the original behavior or troubleshooting after a firmware update.

The TV-local backup directory is `/opt/usr/share/free-my-tv-setup`. It contains the stock boot hook, the renamed executable inventory and hashes, original startup settings, logs, and `rollback.sh`.

To restore the original boot hook and executable filenames from a computer with Developer Mode access:

```sh
export TV_IP=10.0.0.150
export TV_CALLBACK_HOST=10.0.0.189
mkdir -p work
python3 root-run.py restore-tv.sh work/rollback.json
```

The repository's `restore-tv.sh` runs the rollback script preserved on the TV. It stops the custom worker, restores the vendor hook, moves the backed-up executables to their original paths when those paths are absent, removes the setup's masks and markers by moving them into backup directories, and restores the original TV Plus autorun value (`1` on this TV). Reboot manually afterward to resume the original services.

Rollback does not uninstall Free My TV. It also does not overwrite an executable if an app or firmware update has already created a new file at the original path. Inspect that case before doing anything else.

If the setup computer's address changes, update Host PC IP in the TV's Developer Mode window and set `TV_CALLBACK_HOST` accordingly. Update `TV_IP` if the TV's address changes. Root access may need to be reacquired after reboot; that is what the host wrapper does. The TV-local startup worker itself does not need a host root connection.

A separate recovery copy was saved locally during the original session under `~/projects/agent-scripts/.local/samsung-cu7172-20261107`.
