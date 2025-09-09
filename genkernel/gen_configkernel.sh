#!/bin/bash
# $Id$

# Fills variable KERNEL_CONFIG
determine_config_file() {
	if [ "${CMD_KERNEL_CONFIG}" != "" ]
	then
		KERNEL_CONFIG="${CMD_KERNEL_CONFIG}"
	elif [ -f "/etc/kernels/kernel-config-${ARCH}-${KV}" ]
	then
		KERNEL_CONFIG="/etc/kernels/kernel-config-${ARCH}-${KV}"
	elif [ -f "${GK_SHARE}/arch/${ARCH}/kernel-config-${KV}" ]
	then
		KERNEL_CONFIG="${GK_SHARE}/arch/${ARCH}/kernel-config-${KV}"
	elif [ "${DEFAULT_KERNEL_CONFIG}" != "" -a -f "${DEFAULT_KERNEL_CONFIG}" ]
	then
		KERNEL_CONFIG="${DEFAULT_KERNEL_CONFIG}"
	elif [ -f "${GK_SHARE}/arch/${ARCH}/kernel-config-${VER}.${PAT}" ]
	then
		KERNEL_CONFIG="${GK_SHARE}/arch/${ARCH}/kernel-config-${VER}.${PAT}"
	elif [ -f "${GK_SHARE}/arch/${ARCH}/kernel-config" ]
	then
		KERNEL_CONFIG="${GK_SHARE}/arch/${ARCH}/kernel-config"
	else
		gen_die 'Error: No kernel .config specified, or file not found!'
	fi
    KERNEL_CONFIG="$(readlink -f "${KERNEL_CONFIG}")"
}

config_kernel() {
	determine_config_file
	cd "${BUILD_SRC}" || gen_die 'Could not switch to the kernel directory!'

	# See FL-432: This is a fix for kernels 3.7 and up that no longer have an include/linux/version.h. Fixes modules compile.
	if [ ! -e include/linux/version.h ]; then
		if [ -e include/generated/uapi/linux/version.h ]; then
			print_info 1 "fixing include/linux/version.h"
			ln -s ../generated/uapi/linux/version.h include/linux/version.h || gen_die 'Could not fix version.h symlink!'
		fi
	fi

	# Backup current kernel .config
	if isTrue "${MRPROPER}" || [ ! -f "${BUILD_DST}/.config" ]
	then
		print_info 1 "kernel: Using config from ${KERNEL_CONFIG}"
		if [ -f "${BUILD_DST}/.config" ]
		then
			NOW=`date +--%Y-%m-%d--%H-%M-%S`
			cp "${BUILD_DST}/.config" "${BUILD_DST}/.config${NOW}.bak" \
					|| gen_die "Could not backup kernel config (${BUILD_DST}/.config)"
			print_info 1 "        Previous config backed up to .config${NOW}.bak"
		fi
	fi

	if isTrue ${MRPROPER}
	then
		print_info 1 'kernel: >> Running mrproper...'
		compile_generic mrproper kernel
	else
		print_info 1 "kernel: --mrproper is disabled; not running 'make mrproper'."
	fi

	# If we're not cleaning a la mrproper, then we don't want to try to overwrite the configs
	# or we might remove configurations someone is trying to test.
	if isTrue "${MRPROPER}" || [ ! -f "${BUILD_DST}/.config" ]
	then
		local message='Could not copy configuration file!'
		if [[ "$(file --brief --mime-type "${KERNEL_CONFIG}")" == application/x-gzip ]]; then
			# Support --kernel-config=/proc/config.gz, mainly
			zcat "${KERNEL_CONFIG}" > "${BUILD_DST}/.config" || gen_die "${message}"
		else
			cp "${KERNEL_CONFIG}" "${BUILD_DST}/.config" || gen_die "${message}"
		fi
	fi

	if isTrue "${OLDCONFIG}"
	then
		print_info 1 '        >> Running oldconfig...'
		yes '' 2>/dev/null | compile_generic oldconfig kernel 2>/dev/null
	else
		print_info 1 "kernel: --oldconfig is disabled; not running 'make oldconfig'."
	fi
	if isTrue "${CLEAN}"
	then
		print_info 1 'kernel: >> Cleaning...'
		compile_generic clean kernel
	else
		print_info 1 "kernel: --clean is disabled; not running 'make clean'."
	fi

	if isTrue ${MENUCONFIG}
	then
		print_info 1 'kernel: >> Invoking menuconfig...'
		compile_generic menuconfig kernelruntask
		[ "$?" ] || gen_die 'Error: menuconfig failed!'
	elif isTrue ${CMD_GCONFIG}
	then
		print_info 1 'kernel: >> Invoking gconfig...'
		compile_generic gconfig kernel
		[ "$?" ] || gen_die 'Error: gconfig failed!'

		CMD_XCONFIG=0
	fi

	if isTrue ${CMD_XCONFIG}
	then
		print_info 1 'kernel: >> Invoking xconfig...'
		compile_generic xconfig kernel
		[ "$?" ] || gen_die 'Error: xconfig failed!'
	fi

	# Force this on if we are using --genzimage
	if isTrue ${CMD_GENZIMAGE}
	then
		# Make sure Ext2 support is on...
		sed -e 's/#\? \?CONFIG_EXT2_FS[ =].*/CONFIG_EXT2_FS=y/g' \
			-i ${BUILD_DST}/.config 
	fi

	# Make sure lvm modules are on if --lvm
	if isTrue ${CMD_LVM}
	then
		sed -i ${BUILD_DST}/.config -e 's/#\? \?CONFIG_BLK_DEV_DM is.*/CONFIG_BLK_DEV_DM=m/g'
		sed -i ${BUILD_DST}/.config -e 's/#\? \?CONFIG_DM_SNAPSHOT is.*/CONFIG_DM_SNAPSHOT=m/g'
		sed -i ${BUILD_DST}/.config -e 's/#\? \?CONFIG_DM_MIRROR is.*/CONFIG_DM_MIRROR=m/g'
	fi

	# Make sure dmraid modules are on if --dmraid
	if isTrue ${CMD_DMRAID}
	then
		sed -i ${BUILD_DST}/.config -e 's/#\? \?CONFIG_BLK_DEV_DM is.*/CONFIG_BLK_DEV_DM=m/g'
	fi

	# Make sure iSCSI modules are enabled in the kernel, if --iscsi
	# CONFIG_SCSI_ISCSI_ATTRS
	# CONFIG_ISCSI_TCP
	if isTrue ${CMD_ISCSI}
	then
		sed -i ${BUILD_DST}/.config -e 's/\# CONFIG_ISCSI_TCP is not set/CONFIG_ISCSI_TCP=m/g'
		sed -i ${BUILD_DST}/.config -e 's/\# CONFIG_SCSI_ISCSI_ATTRS is not set/CONFIG_SCSI_ISCSI_ATTRS=m/g'

		sed -i ${BUILD_DST}/.config -e 's/CONFIG_ISCSI_TCP=y/CONFIG_ISCSI_TCP=m/g'
		sed -i ${BUILD_DST}/.config -e 's/CONFIG_SCSI_ISCSI_ATTRS=y/CONFIG_SCSI_ISCSI_ATTRS=m/g'
	fi

	if isTrue ${SPLASH}
	then
		sed -i ${BUILD_DST}/.config -e 's/#\? \?CONFIG_FB_SPLASH is.*/CONFIG_FB_SPLASH=y/g'
	fi
}
