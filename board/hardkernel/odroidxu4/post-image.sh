#!/bin/sh

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
UBOOT_DIR="${BUILD_DIR}/uboot-odroidxu4-v2017.05/sd_fuse"
MKIMAGE="${HOST_DIR}/bin/mkimage"
INIT="${BINARIES_DIR}/root.cpio"
UINIT="${BINARIES_DIR}/uInitrd"


"${MKIMAGE}" -C none -A arm -T ramdisk -n uInitrd -d "${INIT}" "${UINIT}"

cp ${BOARD_DIR}/boot.ini ${BINARIES_DIR}/
cp ${BUILD_DIR}/uboot-odroidxu4-v2017.05/arch/arm/dts/exynos5422-odroidxu4.dtb ${BINARIES_DIR}/

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

signed_bl1_position=1
bl2_position=31
uboot_position=63
tzsw_position=1503
env_position=2015

dd iflag=dsync oflag=dsync conv=notrunc if="${UBOOT_DIR}/bl1.bin.hardkernel"            of="${BINARIES_DIR}/sdcard.img" seek=$signed_bl1_position
dd iflag=dsync oflag=dsync conv=notrunc if="${UBOOT_DIR}/bl2.bin.hardkernel.720k_uboot" of="${BINARIES_DIR}/sdcard.img" seek=$bl2_position
dd iflag=dsync oflag=dsync conv=notrunc if="${BINARIES_DIR}/u-boot-dtb.bin"             of="${BINARIES_DIR}/sdcard.img" seek=$uboot_position
dd iflag=dsync oflag=dsync conv=notrunc if="${UBOOT_DIR}/tzsw.bin.hardkernel"           of="${BINARIES_DIR}/sdcard.img" seek=$tzsw_position
dd iflag=dsync oflag=dsync conv=notrunc if=/dev/zero                                    of="${BINARIES_DIR}/sdcard.img" seek=$env_position count=32 bs=512
