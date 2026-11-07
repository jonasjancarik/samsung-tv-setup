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
