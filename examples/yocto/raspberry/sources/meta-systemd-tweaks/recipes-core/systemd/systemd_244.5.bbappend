FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://systemd-random-seed-fast.patch \
    file://systemd-logind-fast.patch \
    "
