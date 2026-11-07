# Validation

Read when assessing what was demonstrated and what remains uncertain.

## Observed on 7 November 2026

- The installer timing probe took about two seconds longer for `sleep 2` than for the control command.
- The temporary root test returned an authenticated UID/EUID/GID/EGID of zero, completed staging cleanup, and preserved the two checked system-file hashes. The SMACK label remained `User`; UID zero alone does not prove unrestricted access to every interface.
- Eleven selected executable files were preserved under renamed filenames. No packages were uninstalled.
- A manual restart changed the kernel boot ID. Afterward, the five selected native services and PISA activation units were masked and inactive, the targeted ad apps were absent from the running-app list, and the startup log recorded Free My TV launching.
- The initial cold-start launch took roughly 48 seconds because it depended on the local network API. The worker was then changed to launch independently of that API and successfully restarted.
- For the initial standby test, the user opened another screen, used a short Power press, waited about 15 seconds, and switched the TV on. They confirmed that Free My TV opened within about 15 seconds.

## Limits

At the initial handoff, the faster worker had been checked by a worker restart and standby wake, without a further cold restart. The cold-boot follow-up below records the later failure, fix and full-shutdown tests.

There was no packet-capture audit of all telemetry, no exhaustive streaming-app regression suite, and no long-term soak test. The evidence establishes the selected service/process states and observed startup behavior, not the absence of every advertising or tracking connection. Firmware and app updates can restore files or change the boot hook.

The repository packaging is syntax-checked and its payload checksums verified. It was not reinstalled onto the TV merely to test this repository.

## Cold-boot regression follow-up

The user subsequently reported Samsung Home after a full shutdown. The boot hook and service controls were still present, and Free My TV was running. The old worker could also retry repeatedly after a success message. This showed that the original standby confirmation was insufficient evidence for reliable cold startup.

The replacement specifies TV user `5001`, verifies native window focus, moves service setup off the launch path, and bounds retries. Six host regression checks cover real focused-window output, a hidden but running app, another foreground app, duplicate window listings, and an uninitialized display. The user confirmed that Free My TV opened after a full shutdown. The native window manager independently reported it focused on the new boot, and all five selected services remained inactive.

### Startup timing

The first focus-aware worker confirmed focus about 74 seconds after kernel boot. Registering its service through `systemd-run` moved worker startup from about 48 seconds after boot to about 29 seconds. The next native focus confirmation was about 58 seconds after boot; the user estimated seeing the app after roughly 40 seconds. Focus confirmation is a later diagnostic observation, not a direct measurement of the first visible frame.

On that boot, Samsung's app boot manager finished at about 21 seconds and the AT-HUB hook started at about 24 seconds. A further experiment deferred the full mask reload until the app had focus. The user observed roughly ten seconds longer rather than an improvement, so that experiment was reverted to the already cold-boot-tested worker. Retained changes are explicit user-session launching, native-focus verification, bounded retries, and transient service registration. Full-shutdown startup is confirmed, but the user-observed cold-start time remains roughly 40–50 seconds. No claim of consistently faster startup is made.

## ACR and iACR verification

A read-only check about four minutes into the latest cold boot confirmed that both registered executable paths were absent. Their `.freemytv-disabled` backups matched the original recorded SHA-256 hashes. Neither ACR nor iACR appeared in the app-framework running list or the process-executable scan. No alternate package directories were found under the four preload paths listed in [the evidence](../evidence/acr-verification.json). The file-based block survived the cold boots checked during this session.

An earlier cold-boot app-framework entry had prompted a suggestion that ACR might have been restored. That was premature: the entry did not establish that the executable had returned, and subsequent file checks showed its original path remained absent. Registration metadata is retained, including ACR's autorestart flag; the executable rename is the control being used.

These are snapshots, not continuous monitoring from the first instant of boot. They do not prove that ACR never ran briefly, and no packet-capture audit was performed. Firmware or app updates may restore the original executable paths. To repeat the read-only inspection:

```sh
mkdir -p work
python3 root-run.py setup/verify-acr.sh work/acr-verification.json
```

See the [captured output](../evidence/acr-verification.txt) for paths, hashes and package registration details.

## Native on-boot registration trial

While the TV was available for testing, Free My TV was found only in the global package database, registered as `webapp` / `uiapp` with `app_onboot=false` and `app_autorestart=false`. A backed-up trial changed only its `app_onboot` field to `true`, retaining the existing fallback and autorestart setting.

After the controlled restart, the flag was still `true`, but the user reported about the same startup time. Samsung's app boot manager ran from about 4.4 to 25.1 seconds after kernel boot; the fallback worker started at about 30.5 seconds. No framework trace established a separate earlier native launch. This test shows no demonstrated benefit from the single UI-app flag change; it does not establish whether the platform ignored that flag or started the app without improving its visible readiness.

The trial was rolled back to `app_onboot=false` and `app_autorestart=false`. The fallback remained active. The final read-only focus check showed another app in front, and the startup guard had logged that it stood down for that app. No further viewing-time experiments were performed. See the [trial record](../evidence/native-onboot-trial.json).

For future research, Samsung's [prelaunch documentation](https://developer.samsung.com/smarttv/develop/guides/fundamentals/prelaunching-applications.html) says its supported prelaunch feature ended with 2019 models. Samsung also [requires TV web apps to retain background-support disabled](https://developer.samsung.com/smarttv/develop/faq/other-features.html). Native boot flags are a separate mechanism; other models' results do not prove earlier startup for this TV's web UI app.
