#!/bin/bash

首先到华为镜像站切换apt源
apt 需要安装的库：apt install make gcc libssl-dev openssl

# 构建功能开启说明：
# 关闭 SELinux
CONFIG_SECURITY_SELINUX=n
CONFIG_SECURITY_SELINUX_BOOTPARAM=n
CONFIG_SECURITY_SELINUX_DISABLE=y

# 启用硬件断点支持
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_PERF_EVENTS=y
CONFIG_HW_BREAKPOINTS=y

# 启用内核调试功能（可选，但推荐）
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_INFO=y
CONFIG_KGDB=y          # 启用 KGDB 调试
CONFIG_KGDB_SERIAL_CONSOLE=y

# 说明
# CROSS_COMPILE构建工具：https://github.com/nathanchance/gcc-prebuilts/
# CROSS_COMPILE构建工具分支clone：git clone -b aarch64-linaro-7.x --depth=1 https://github.com/nathanchance/gcc-prebuilts


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



# 编译完成最后输出：
  LD      vmlinux
  SORTEX  vmlinux
  SYSMAP  System.map
  Building modules, stage 2.
  OBJCOPY arch/arm64/boot/Image
  DTC     arch/arm64/boot/dts/qcom/dumpling-v2.1-Second_Resource.dtb
  DTC     arch/arm64/boot/dts/qcom/dumpling-v2.1-pvt.dtb
  MODPOST 1 modules
  CC      drivers/staging/qcacld-3.0/wlan.mod.o
  DTC     arch/arm64/boot/dts/qcom/msmhamster-rumi.dtb
  LD [M]  drivers/staging/qcacld-3.0/wlan.ko                                    # 这个是wifi驱动
  DTC     arch/arm64/boot/dts/qcom/dumpling-v2.1-dvt.dtb
  DTC     arch/arm64/boot/dts/qcom/dumpling-v2.1-backup.dtb
  DTC     arch/arm64/boot/dts/qcom/cheeseburger-v2.1-pvt1.dtb
  DTC     arch/arm64/boot/dts/qcom/cheeseburger-v2.1-backup.dtb
  DTC     arch/arm64/boot/dts/qcom/cheeseburger-v2.1-pvt.dtb
  DTC     arch/arm64/boot/dts/qcom/cheeseburger-v2.1-dvt1.dtb
  GZIP    arch/arm64/boot/Image.gz
  CAT     arch/arm64/boot/Image.gz-dtb                                         # 这个是编译成功后的文件
make[1]: Leaving directory '/opt/op5-8.1.0-unified/finalimage'                 # 这个是输出目录的基目录


# 接下来步骤：
1.把Image.gz-dtb放入到flashkernel-op5-v4.29\kernels\oos下面的目录里面
2.把wifi驱动wlan.ko放入到flashkernel-op5-v4.29\ramdisk\modules目录下
3.解压AnyKernel3.zip刷机包，然后进入到根目录里面然后全选打包成zip文件，push到手机/data/local/tmp目录下或者/sdcard目录下
