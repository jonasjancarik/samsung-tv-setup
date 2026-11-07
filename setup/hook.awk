#!/usr/bin/gawk -f
BEGIN {
    repo = ""; model = ""
    while ((getline line < "/etc/prd_info.ini") > 0) {
        if (line ~ /^Build=/) { sub(/^Build=/, "", line); sub(/;.*/, "", line); repo = line }
        else if (line ~ /^Model=/) { sub(/^Model=/, "", line); sub(/;.*/, "", line); model = line }
    }
    close("/etc/prd_info.ini")
    printf "__%s__%s\n", repo, model > "/proc/target_version"
    close("/proc/target_version")
    system("cat /opt/usr/share/free-my-tv-setup/bootstrap.sh | /bin/bash > /opt/usr/share/free-my-tv-setup/bootstrap.log 2>&1")
    exit 0
}
