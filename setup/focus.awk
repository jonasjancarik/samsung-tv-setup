# Read the first native window list; the following EC list duplicates it.
/Top level windows in EC list/ { exit }
$2 ~ /^0x[[:xdigit:]]+$/ && $4 ~ /^[0-9]+$/ {
    focused = 0
    for (i = 9; i <= 12 && i <= NF; i++) if ($i == "O") focused = 1
    target = ($0 ~ /Free My TV$/)
    if (target) window = $2
    if (focused) {
        if (target) state = "free"
        else if ($0 ~ /csfs\.dll$/ || $0 ~ /tv-viewer$/ || $0 ~ /home\.(media|sidebar)$/) state = "home"
        else state = "other"
    }
}
END { printf "%s|%s\n", window ? window : "-", state ? state : "none" }
