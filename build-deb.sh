#SPDX-License-Identifier: MIT

D_KC=meta_kconfigs
D_OUT=.out/

### parse parameters
if [ "$1" == "--help" ]; then
	echo "bash $0                  ### build without clean previous output"
	echo "bash $0 --clean-build    ### clean previous output before build"
	echo "bash $0 --clean-all      ### clean previous output then exit"
	echo "bash $0 --help           ### help"
	exit
fi

if [ "$1" == "--clean-all" ]; then
	rm *.deb
	rm *.buildinfo
	rm *.changes
	make mrproper O=
	make mrproper
	rm -rf ${D_OUT}
	exit
fi

### https://www.kernel.org/doc/html/latest/kbuild/kconfig.html,kbuild.html
if [ "$1" == "--clean-build" ]; then
	echo "will clean previous output before build."
	rm -rf ${D_OUT}
fi

mkdir -p ${D_OUT}
export KBUILD_OUTPUT=$D_OUT
printf "KBUILD_OUTPUT=$KBUILD_OUTPUT\n"

if [[ $KCONFIG_CONFIG != "" ]]; then
	echo "rename KCONFIG_CONFIG is not support."
	exit
fi

#make mrproper
sleep 1

./scripts/kconfig/merge_config.sh -m -r \
	${D_KC}/x86_64_base_defconfig \
	${D_KC}/realtime.cfg ${D_KC}/container.cfg ${D_KC}/acrn.cfg \
	${D_KC}/xenomai.cfg

cp .config $KBUILD_OUTPUT
sleep 1

make olddefconfig
sleep 1

### delete "$srctree/.config" otherwise "make bindeb-pkg" will fail when $KBUILD_OUTPUT is not $srctree
rm .config
#make bindeb-pkg LOCALVERSION=xenomai_local-test-1 KDEB_PKGVERSION=1 -j$(nproc --all) 2>&1 | tee .build.log
#mkdir -p debian
make bindeb-pkg KDEB_PKGVERSION=1 -j$(nproc --all) 2>&1 | tee .build.log

