# Samsung CU7172: Free My TV and service cleanup

This private runbook records the setup completed on 7 November 2026 on a Samsung UE43CU7172UXXH. It covers installing Free My TV, checking root compatibility, disabling selected advertising and tracking components, and opening Free My TV automatically at startup. It includes packaged versions of the scripts developed during the session and recovery instructions for this TV.

## Tested configuration

| Item | Observed value |
| --- | --- |
| TV | Samsung UE43CU7172UXXH, CU7172 43-inch |
| Platform | Tizen 9.0.0, ARMv7 |
| Firmware build | `T-KSU2ECDEUC-0090-REL-202605141703` |
| Kernel | `5.4.77` |
| Free My TV | `1.3.0`, app ID `FreeMyTVio.FreeMyTV` |
| TV / setup Mac addresses | `10.0.0.150` / `10.0.0.189` |
| Managed runtime | .NET `6.0.9`; the root method uses its .NET 6 payload |

This is evidence for this exact device and build, not a compatibility claim for every Samsung TV. The setup makes persistent privileged changes to the TV. Inspect the scripts and verify the firmware and original boot-script checksum before repeating it. Do not run the installation sequence again on the already-configured TV.

## Result

Eight selected ad/tracking packages were blocked by reversibly renaming 11 executable files. Five native services were confirmed masked and inactive after a manual restart. Existing streaming apps were retained.

Free My TV launched automatically after the restart. The initial implementation waited roughly 48 seconds for Samsung's local network API; the final worker launches independently of that API. The faster version was initially tested by restarting its worker and by standby wake. A subsequent full shutdown exposed a foreground-launch issue. The follow-up fix specifies the TV user and verifies native window focus; the user then confirmed automatic opening across full shutdowns. Cold startup still takes roughly 40–50 seconds. See the [validation record](docs/validation.md). The user then opened another screen, put the TV into standby, waited about 15 seconds and switched it on: Free My TV opened within about 15 seconds.

The startup hook and worker run on the TV. No always-on Mac or host-side root watchdog is required. These checks cover the targeted components; they do not establish that all telemetry or advertising has been eliminated. Firmware or app updates may restore modified files.

## Process

1. **Enable Developer Mode.** In Apps Settings, enter `12345`, enable Developer Mode, set Host PC IP to the setup computer's LAN address, and restart. The developer connection uses TCP port `26101`.
2. **Install Free My TV.** Use the [project's Samsung instructions](https://github.com/simbasjungles/free-my-tv#samsung-tvs-tizen). On this TV, Samsung account sign-in created a TV-specific signing certificate. The account did not need to match the TV's signed-in account. The certificate, its password, OAuth tokens and signed app package are deliberately excluded from this repository.
3. **Inspect and test root access.** Ordinary Developer Mode exposed the app list but no uninstall-permission flag or interactive shell. A timing probe confirmed the installer command-injection entry point. Read-only checks found the required .NET and archive-launcher capabilities. A separately authorized temporary archive-root test confirmed authenticated UID 0, staging cleanup, and unchanged hashes of `/etc/passwd` and `/usr/share/sdbd/public.pem`.
4. **Prepare backups and apply the controls.** The session scripts preserved the original vendor hook, recorded selected settings, created the service controls, and renamed only the selected executables. No packages were uninstalled. The packaged equivalents below have not been separately installed onto the TV. Package deactivation with `pkgcmd -D` was tried during the session but failed with `Undefined error(-6)`; it is omitted from the packaged preparation script.
5. **Verify a restart and normal standby wake.** A manual restart changed the kernel boot ID, reran the TV-local hook and retained the service masks. The user confirmed the final off/on behavior. A scheduled normal `systemctl reboot` failed because this firmware had no normal reboot target; it was not counted as a successful restart.

See [implementation details](docs/implementation.md), [validation](docs/validation.md), and [recovery](docs/recovery.md).

## Running the packaged scripts

The host tools require Python 3.12 or newer and an `openssl` executable. The Python dependencies are standard-library only. Vendored upstream source and release payloads are pinned in [provenance](docs/provenance.md).

From the repository root, set the two addresses for the current network:

```sh
export TV_IP=10.0.0.150
export TV_CALLBACK_HOST=10.0.0.189
mkdir -p work
shasum -a 256 -c payloads/SHA256SUMS
```

This command acquires temporary root and performs cleanup; it is **not** merely a read-only compatibility check:

```sh
python3 root-probe.py --run
```

For an unmodified TV matching the tested profile, after Free My TV is installed:

```sh
python3 root-run.py setup/prepare.sh work/prepare.json
python3 root-run.py setup/install.sh work/install.json
python3 root-run.py setup/verify.sh work/verify.json
```

Read every result before proceeding. Stop if a command fails, a checksum differs, or the output reports an unexpected executable path. `prepare.sh` refuses to overwrite an existing backup directory, and `install.sh` requires the original vendor hook's pinned checksum. Reboot manually, verify again, and test ordinary standby wake from a different app. Allow the app framework time to initialize during a cold start.

Run the host focus-parser regression checks with `python3 -m unittest discover -s tests -v`.

The shell files are supplied to the TV's signed interpreter through stdin. On this firmware, opening an unsigned script as a Bash filename fails its signature check, including `bash -n script.sh`; use `cat script.sh | bash -n` for an on-TV syntax check.

## Repository contents

- `setup/`: TV-local hook, worker, preparation, installation, verification and rollback scripts.
- `root-run.py`, `root-probe.py`: session adapters, configurable through the environment variables above.
- `root-source/`, `transport/`, `payloads/`: the source and payloads needed by those adapters.
- `evidence/`: selected root proof and post-restart records, plus the final verification summary.
- `licenses/`: upstream license texts.

No Samsung firmware, private signing keys, account credentials, OAuth responses or access tokens are included. The evidence retains this private TV's model, firmware and LAN addresses.
