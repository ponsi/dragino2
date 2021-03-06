#!/usr/bin/env bash
#Set up build environment for Dragino v2. Only need to run once on first compile. 

USAGE="Usage: . ./set_up_build_enviroment.sh /your/preferred/source/installation/path"

if (( $# < 1 ))
then
	echo "Error. Not enough arguments."
	echo $USAGE
	exit 1
elif (( $# > 1 ))
then
	echo "Error. Too many arguments."
	echo $USAGE
	exit 2
elif [ $1 == "--help" ]
then
	echo $USAGE
	exit 3
fi

REPO_PATH=$(pwd)
OPENWRT_PATH=$1

echo " "
echo " Get SECN 2 packages from GitHub repo"
git clone https://github.com/villagetelco/vt-secn2-packages $OPENWRT_PATH/vt-secn2-packages

echo " "
echo "*** Checkout the OpenWRT build environment to the path specified on the command line"
sleep 5
mkdir -p $OPENWRT_PATH
svn co svn://svn.openwrt.org/openwrt/trunk/@r33887 $OPENWRT_PATH

echo "*** Backup original feeds files if they exist"
sleep 2
mv $OPENWRT_PATH/feeds.conf.default  $OPENWRT_PATH/feeds.conf.default.bak

echo "*** Create new feeds.conf.default file"
echo "src-svn  packages svn://svn.openwrt.org/openwrt/packages@33887"      > $OPENWRT_PATH/feeds.conf.default
echo "src-link dragino2 $REPO_PATH/package" >> $OPENWRT_PATH/feeds.conf.default
echo "src-link secn2packages $OPENWRT_PATH/vt-secn2-packages/packages" >> $OPENWRT_PATH/feeds.conf.default

#update required feeds
$OPENWRT_PATH/scripts/feeds update

echo ""
echo "copy Dragino2 Platform info"
rsync -avC platform/target/ $OPENWRT_PATH/target/

#install required feeds
$OPENWRT_PATH/scripts/feeds install -a -p dragino2
$OPENWRT_PATH/scripts/feeds install kmod-batman-adv  
$OPENWRT_PATH/scripts/feeds install openssh-sftp-server
$OPENWRT_PATH/scripts/feeds install usb-modeswitch
$OPENWRT_PATH/scripts/feeds install usb-modeswitch-data 
$OPENWRT_PATH/scripts/feeds install haserl 
$OPENWRT_PATH/scripts/feeds install xinetd
$OPENWRT_PATH/scripts/feeds install muninlite

echo "*** Update feeds.conf.default file to lock further openwrt package updates"
echo "#src-svn  packages        svn://svn.openwrt.org/openwrt/packages@33887"     > $OPENWRT_PATH/feeds.conf.default
echo "src-link dragino2 $REPO_PATH/package" >> $OPENWRT_PATH/feeds.conf.default
echo "src-link secn2packages   $OPENWRT_PATH/vt-secn2-packages/packages"         >> $OPENWRT_PATH/feeds.conf.default
echo " "

#rm tmp directory
rm -rf $OPENWRT_PATH/tmp/

echo "*** Change to build directory"
cd $OPENWRT_PATH
echo " "

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > ./defconfig.log
# Backup the .config file
cp .config .config.orig
echo " "

echo "End of script"