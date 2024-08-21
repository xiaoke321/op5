#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE=/opt/gcc-prebuilts/bin/aarch64-linaro-linux-android-

make O=finalimage/ flash-oos_defconfig
make -j4 O=finalimage/

(
    cd finalimage/
    ${CROSS_COMPILE}strip --strip-unneeded drivers/staging/qcacld-3.0/wlan.ko
    ./scripts/sign-file sha512 \
                        certs/signing_key.pem \
                        certs/signing_key.x509 \
                        drivers/staging/qcacld-3.0/wlan.ko
)
