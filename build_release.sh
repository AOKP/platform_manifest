#!/bin/bash

DATE=`date +"%Y%m%d"`
rdir=`pwd`
DEVICE="$1"
RELEASE="$2"
OFFICIAL="$3"

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export AOKP_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

echo "Removing previous build.prop"
rm out/target/product/"$DEVICE"/system/build.prop;

# setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

echo -e ""
echo -e "${bldblu}Starting MysteriousAOKP build for $DEVICE ${txtrst}"

# start compilation
brunch "$DEVICE";
echo -e ""

# Get Package Name
sed -i $OUT/system/build.prop
VERSION=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGE=$OUT/$VERSION.zip

# Export some stuff for the basket script
export DEVICE="$DEVICE"
export PACKAGE="$PACKAGE"
export VERSION="$VERSION"

# Move the changelog into zip  & upload zip to Goo.im & Basketbuild.com
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *"$DEVICE"-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/"$DEVICE"
    scp "$PACKAGE" ftp -u ftp://ptichalouf:10031300@ftp.xdafileserver.nl:1337/Mysterious_ROM Mysterious_ROM/AOKP/Nightlies/"$DEVICE"
else
    find "$OUT" -name *Mysterious_"$DEVICE"_Nightly_*${AOKP_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGE" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/"$DEVICE"
    scp "$PACKAGE" ftp -u ftp://ptichalouf:10031300@ftp.xdafileserver.nl:1337/Mysterious_ROM Mysterious_ROM/AOKP/Nightlies/"$DEVICE"
fi


