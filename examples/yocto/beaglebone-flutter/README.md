BeagleBone Black yocto image with flutter
================================

Contains an Arago project from Texas Instruments.
Allows to run graphics applications: wayland, qt5, flutter

Arago layer dependes on layers:
meta-arago-extras
meta-qt5
meta-networking
meta-python

To run EGL application:
    weston-simple-egl

To run flutter application:
    flutter-client -b /usr/share/flutter/animated_background_example/lib


Links:
https://flutterawesome.com/yocto-meta-layer-for-recipes-related-to-using-google-flutter-engine/
https://bootlin.com/blog/flutter-nvidia-jetson-openembedded-yocto/
https://lists.yoctoproject.org/g/meta-ti/topic/build_core_image_weston_for/74137718
https://elinux.org/BeagleBoneBlack/SGX_%2B_Qt_EGLFS_%2B_Weston#The_PVR_Tools_and_Examples
