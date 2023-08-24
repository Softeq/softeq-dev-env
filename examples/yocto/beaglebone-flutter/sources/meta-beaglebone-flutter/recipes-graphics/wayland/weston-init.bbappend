FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://weston.ini \
"

# https://software-dl.ti.com/processor-sdk-linux/esd/docs/latest/linux/Foundational_Components/Graphics/AM3_Beagle_Bone_Black_Configuration.html
do_install_append() {
    install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}
    echo "DefaultPixelFormat=RGB565" > ${D}${sysconfdir}/xdg/weston/powervr.ini
}

FILES_${PN} += "${sysconfdir}/weston.ini"
CONFFILES_${PN} += "${sysconfdir}/weston.ini"