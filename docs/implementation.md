# Implementation

Read when changing the service policy, startup behavior or root transport.

## Selected components

The setup targets these packages, rather than applying a general Samsung debloat list:

| Package | Role |
| --- | --- |
| `adplatform` | Ad Player |
| `com.samsung.tv.acr-service-app` | Viewing recognition / ACR |
| `com.samsung.tv.iacr` | iACR |
| `com.samsung.tv.canalysis-service` | Content analysis |
| `com.samsung.tv.targeted-ad-service` | Targeted advertising |
| `com.samsung.tv.pisa-service` | PISA and its ad-agent/control executables |
| `com.samsung.tizen.samsung-analytics` | Samsung analytics |
| `com.samsung.tv.coba.adagent` | Managed advertising agent |

Eleven files were renamed in place with a `.freemytv-disabled` suffix. The original bytes remain on the TV. The managed ad agent's package database named a nonexistent `bin/` path; its actual main DLL and precompiled `.ni.dll` were under `shared/res/`. Both were blocked after explicit approval.

The native services are `adagent-service.service`, `canalysis-service.service`, `pisa-service.service`, `contents-recognition-service.service`, and `media-analytics-service.service`. Their masks live under `/run/systemd/system` and are recreated at boot. PISA's `.socket` and `.path` activation units are also masked. Two persistent vendor marker files prevent PISA and content-analysis startup before the worker runs.

The setup does not remove the Samsung launcher, streaming apps, DRM services, voice assistants or SmartThings. It does not attempt to disable every service with “analysis” in its name.

## Startup

The stock `AT-HUB.service` executes `/opt/etc/parseinfo.sh` as root from writable persistent storage. On the tested TV, the original script's SHA-256 was:

```text
c6369e7dec69408e176daa252d436acf6f8e265f560504d8bd831c8023c71d61
```

The original file is preserved at `/opt/usr/share/free-my-tv-setup/parseinfo.sh.stock`. Its replacement uses the signed `gawk` interpreter and preserves the vendor's `__REPO__MODEL` write to `/proc/target_version`. It then runs `bootstrap.sh`, which creates a transient `free-my-tv-startup.service` owned by systemd. That service runs the worker through a signed interpreter and stdin, rather than leaving a child of the temporary root session behind.

The worker reapplies the selected service masks, turns off TV Plus autorun, and starts Free My TV after an initial delay, retrying if needed. It also watches the TV's power timestamp, resume timing and local power-state API for subsequent wake-up events. TV Plus's Boolean setting accepts `0` and `1`, not the strings `false` and `true`.

The hook creates persistent privileged startup behavior. It does not expose a new network listener, install a host watchdog, or globally disable signature enforcement. These observations do not make it a vendor-supported modification.

## Root transport adaptations

The session uses the upstream archive-launcher route, not its model-specific kernel exploits. The local adapter speaks SDB using Free My TV's Python transport, so Samsung's Intel `sdb` executable is unnecessary on the Apple Silicon setup Mac.

Three details mattered during the work:

- Reuse the SDB connection instead of rapidly reconnecting for every operation; the TV sometimes reset successive connections.
- Allow a long-running SDB launch channel enough time to finish while the authenticated root callback is active.
- Pipe staged scripts to Bash. The upstream adapter's dot-sourcing path did not reliably execute unsigned staged files on this firmware.

Each root session checks its authenticated identity, closes the temporary agent, cleans its own staging files, and compares the hashes of `/etc/passwd` and `/usr/share/sdbd/public.pem`. “System files unchanged” in those reports refers to those two files; the approved boot hook and executable renames are intentional persistent changes.
