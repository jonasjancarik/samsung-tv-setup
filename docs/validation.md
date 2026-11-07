# Validation

Read when assessing what was demonstrated and what remains uncertain.

## Observed on 7 November 2026

- The installer timing probe took about two seconds longer for `sleep 2` than for the control command.
- The temporary root test returned an authenticated UID/EUID/GID/EGID of zero, completed staging cleanup, and preserved the two checked system-file hashes. The SMACK label remained `User`; UID zero alone does not prove unrestricted access to every interface.
- Eleven selected executable files were preserved under renamed filenames. No packages were uninstalled.
- A manual restart changed the kernel boot ID. Afterward, the five selected native services and PISA activation units were masked and inactive, the targeted ad apps were absent from the running-app list, and the startup log recorded Free My TV launching.
- The initial cold-start launch took roughly 48 seconds because it depended on the local network API. The worker was then changed to launch independently of that API and successfully restarted.
- For the final test, the user opened another screen, used a short Power press, waited about 15 seconds, and switched the TV on. They confirmed that Free My TV opened within about 15 seconds.

## Limits

The final faster worker was checked by a worker restart and the user-observed standby test; a further cold restart after that last adjustment was not recorded. Its earlier version was verified across a cold restart.

There was no packet-capture audit of all telemetry, no exhaustive streaming-app regression suite, and no long-term soak test. The evidence establishes the selected service/process states and observed startup behavior, not the absence of every advertising or tracking connection. Firmware and app updates can restore files or change the boot hook.

The repository packaging is syntax-checked and its payload checksums verified. It was not reinstalled onto the TV merely to test this repository.

## Cold-boot regression follow-up

The user subsequently reported Samsung Home after a full shutdown. The boot hook and service controls were still present, and Free My TV was running. The old worker could also retry repeatedly after a success message. This showed that the original standby confirmation was insufficient evidence for reliable cold startup.

The replacement specifies TV user `5001`, verifies native window focus, moves service setup off the launch path, and bounds retries. Six host regression checks cover real focused-window output, a hidden but running app, another foreground app, duplicate window listings, and an uninitialized display. The user confirmed that Free My TV opened after a full shutdown. The native window manager independently reported it focused on the new boot, and all five selected services remained inactive.

### Startup timing

The first focus-aware worker confirmed focus about 74 seconds after kernel boot. Registering its service through `systemd-run` moved worker startup from about 48 seconds after boot to about 29 seconds. The next native focus confirmation was about 58 seconds after boot; the user estimated seeing the app after roughly 40 seconds. Focus confirmation is a later diagnostic observation, not a direct measurement of the first visible frame.

On that boot, Samsung's app boot manager finished at about 21 seconds and the AT-HUB hook started at about 24 seconds. A further experiment deferred the full mask reload until the app had focus. The user observed roughly ten seconds longer rather than an improvement, so that experiment was reverted to the already cold-boot-tested worker. Retained changes are explicit user-session launching, native-focus verification, bounded retries, and transient service registration. Full-shutdown startup is confirmed, but the user-observed cold-start time remains roughly 40–50 seconds. No claim of consistently faster startup is made.
