#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"

# Remove previous build info
echo "Removing previous build.prop"
rm out/target/product/d2att/system/build.prop;
rm out/target/product/d2tmo/system/build.prop;
rm out/target/product/d2vzw/system/build.prop;
rm out/target/product/grouper/system/build.prop;
rm out/target/product/mako/system/build.prop;
rm out/target/product/i9100/system/build.prop;
rm out/target/product/i9100g/system/build.prop;
rm out/target/product/i9300/system/build.prop;
rm out/target/product/n7000/system/build.prop;
rm out/target/product/n7100/system/build.prop;
rm out/target/product/maguro/system/build.prop;
rm out/target/product/toro/system/build.prop;
rm out/target/product/t0lte/system/build.prop;
rm out/target/product/t0lteatt/system/build.prop;
rm out/target/product/i605/system/build.prop;
rm out/target/product/l900/system/build.prop;
rm out/target/product/toroplus/system/build.prop;
rm out/target/product/tilapia/system/build.prop;
rm out/target/product/manta/system/build.prop;
rm out/target/product/d2usc/system/build.prop;
rm out/target/product/evita/system/build.prop;
rm out/target/product/m7att/system/build.prop;
rm out/target/product/m7spr/system/build.prop;
rm out/target/product/jfltetmo/system/build.prop;
rm out/target/product/hercules/system/build.prop;
rm out/target/product/m7tmo/system/build.prop;
rm out/target/product/m7ul/system/build.prop;
rm out/target/product/maserati/system/build.prop;
rm out/target/product/p930/system/build.prop;
rm out/target/product/solana/system/build.prop;
rm out/target/product/spyder/system/build.prop;
rm out/target/product/su640/system/build.prop;
rm out/target/product/t0ltetmo/system/build.prop;
rm out/target/product/targa/system/build.prop;
rm out/target/product/umtsspyder/system/build.prop;
rm out/target/product/vibrantmtd/system/build.prop;
rm out/target/product/vs920/system/build.prop;
rm out/target/product/yuga/system/build.prop;

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export AOKP_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

echo "Generating Changelog"

# Generate Changelog

# Check the date start range is set
if [ -z "$sdate" ]; then
    sdate=${ydate}
fi

# Find the directories to log
find $rdir -name .git | sed 's/\/.git//g' | sed 'N;$!P;$!D;$d' | while read line
do
    cd $line
    # Test to see if the repo needs to have a changelog written.
    log=$(git log --pretty="%an - %s" --no-merges --since=$sdate --date-order)
    project=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    if [ -z "$log" ]; then
        echo "Nothing updated on $project, skipping"
    else
        # Prepend group project ownership to each project.
        origin=`grep "$project" $rdir/.repo/manifest.xml | awk {'print $4'} | cut -f2 -d '"'`
        if [ "$origin" = "aokp" ]; then
            proj_credit=AOKP
        elif [ "$origin" = "aosp" ]; then
            proj_credit=AOSP
        elif [ "$origin" = "cm" ]; then
            proj_credit=CyanogenMod
        elif [ "$origin" = "omapzoom" ]; then
            proj_credit=aokp
            proj_credit=""
        fi
        # Write the changelog
        echo "$proj_credit Project name: $project" >> "$rdir"/changelog.txt
        echo "$log" | while read line
        do
             echo "  •$line" >> "$rdir"/changelog.txt
        done
        echo "" >> "$rdir"/changelog.txt
    fi
done

# Create Version Changelog
if [ "$RELEASE" == "nightly" ]
then
    echo "Generating and Uploading Changelog for Nightly"
    cp changelog.txt changelog_"$DATE".txt
    scp "$rdir"/changelog_"$DATE".txt Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/Changelogs
else
    echo "Generating and Uploading Changelog for Official Release"
    cp changelog.txt changelog_"$AOKP_BUILD".txt
    scp "$rdir"/changelog_"$AOKP_BUILD".txt Mysterious@upload.goo.im:~/public_html/AOKP_Changelogs
fi

##########################################################################################
#                                                                                        #
#                                   Building m7ul                                        #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_m7ul-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7ul=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_m7ul_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7ul" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7ul
else
    find "$OUT" -name *Mysterious_aokp_m7ul_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7ul" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7ul
fi

##########################################################################################
#                                                                                        #
#                                   Building hayabusa                                    #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_hayabusa-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7ul=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_hayabusa_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhayabusa" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/hayabusa
else
    find "$OUT" -name *Mysterious_aokp_hayabusa_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhayabusa" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/hayabusa
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_jfltevzw-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEjfltevzw=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_jfltevzw_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltevzw" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jfltevzw
else
    find "$OUT" -name *Mysterious_aokp_jfltevzw_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltevzw" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jfltevzw
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_jflteusc-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEjflteusc=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_jflteusc_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjflteusc" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jflteusc
else
    find "$OUT" -name *Mysterious_aokp_jflteusc_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjflteusc" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jflteusc
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_yuga-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEyuga=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_yuga_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEyuga" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/yuga
else
    find "$OUT" -name *Mysterious_aokp_yuga_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEyuga" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/yuga
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_vs920-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEvs920=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_vs920_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEvs920" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/vs920
else
    find "$OUT" -name *Mysterious_aokp_vs920_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEvs920" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/vs920
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_vibrantmtd-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEvibrantmtd=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_vibrantmtd_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEvibrantmtd" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/vibrantmtd
else
    find "$OUT" -name *Mysterious_aokp_vibrantmtd_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEvibrantmtd" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/vibrantmtd
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_umtsspyder-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEumtsspyder=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_umtsspyder_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEumtsspyder" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/umtsspyder
else
    find "$OUT" -name *Mysterious_aokp_umtsspyder_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEumtsspyder" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/umtsspyder
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_targa-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtarga=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_targa_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtarga" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/targa
else
    find "$OUT" -name *Mysterious_aokp_targa_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtarga" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/targa
fi

##########################################################################################
#                                                                                        #
#                                   Building &&&&&&&&&&&&&                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_t0ltetmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0ltetmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_t0ltetmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0ltetmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0ltetmo
else
    find "$OUT" -name *Mysterious_aokp_t0ltetmo_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0ltetmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0ltetmo
fi

##########################################################################################
#                                                                                        #
#                                   Building su640 &&&&&                                 #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_su640-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEsu640=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_su640_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsu640" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/su640
else
    find "$OUT" -name *Mysterious_aokp_su640_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsu640" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/su640
fi

##########################################################################################
#                                                                                        #
#                                   Building spyder                                     #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_spyder-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEspyder=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_spyder_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEspyder" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/spyder
else
    find "$OUT" -name *Mysterious_aokp_spyder_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEspyder" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_spyder_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Nexus 4                                     #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_mako-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_mako_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/mako
else
    find "$OUT" -name *Mysterious_aokp_mako_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/mako
fi

##########################################################################################
#                                                                                        #
#                                   Building Nexus 7                                     #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_grouper-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEgrouper=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_grouper_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/grouper
else
    find "$OUT" -name *Mysterious_aokp_grouper*_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/grouper
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S2 (GT-I9100)                              #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_i9100-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_i9100_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9100
else
    find "$OUT" -name *Mysterious_aokp_i9100_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9100
fi

##########################################################################################
#                                                                                        #
#                                Building d2usc                                          #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_d2usc-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2usc=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_d2usc_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2usc" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2usc
else
    find "$OUT" -name *Mysterious_aokp_d2usc_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2usc" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2usc
fi

##########################################################################################
#                                                                                        #
#                                Building Evita                                          #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_evita-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEevita=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_evita_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEevita" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/evita
else
    find "$OUT" -name *Mysterious_aokp_evita_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEevita" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/evita
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Nexus                                   #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_maguro-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaguro=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_maguro_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/maguro
else
    find "$OUT" -name *Mysterious_aokp_maguro_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/maguro
fi

##########################################################################################
#                                                                                        #
#                                   Building HTC ONE ATT                                 #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_m7att-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7att=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_m7att_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7att" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7att
else
    find "$OUT" -name *Mysterious_aokp_m7att_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7att" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7att
fi

##########################################################################################
#                                                                                        #
#                                   Building Maserati                                    #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_maserati-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaserati=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_maserati_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaserati" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/maserati
else
    find "$OUT" -name *Mysterious_aokp_maserati_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaserati" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/maserati
fi

##########################################################################################
#                                                                                        #
#                                   Building HTC ONE Tmo                                 #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_m7tmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7tmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_m7tmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7tmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7tmo
else
    find "$OUT" -name *Mysterious_aokp_m7tmo_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7tmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/m7tmo
fi

##########################################################################################
#                                                                                        #
#                                 Building Galaxy S4 Tmo                                 #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_jfltetmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEjfltetmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_jfltetmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltetmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jfltetmo
else
    find "$OUT" -name *Mysterious_aokp_jfltetmo_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltetmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/jfltetmo
fi

##########################################################################################
#                                                                                        #
#                                   Building S2 Variant                                  #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_hercules-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEherclues=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_hercules_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhercules" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/hercules
else
    find "$OUT" -name *Mysterious_aokp_hercules_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhercules" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/hercules
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Nexus                                   #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_toro-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtoro=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_toro_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/toro
else
    find "$OUT" -name *Mysterious_aokp_toro_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/toro
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy S3 (AT&T)                                 #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_d2att-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2att=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_d2att_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2att
else
    find "$OUT" -name *Mysterious_aokp_d2att_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2att
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (T-Mobile)                              #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_d2tmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2tmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_d2tmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2tmo
else
    find "$OUT" -name *Mysterious_aokp_d2tmo_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2tmo
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (Verizon)                               #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_d2vzw-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2vzw=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_d2vzw_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2vzw
else
    find "$OUT" -name *Mysterious_aokp_d2vzw_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2vzw
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (Sprint)                                #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_d2spr-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2spr=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_d2spr_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2spr" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2spr
else
    find "$OUT" -name *Mysterious_aokp_d2spr_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2spr" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/d2spr
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     GT-N7100                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_n7100-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEn7100=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_n7100_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7100" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/n7100
else
    find "$OUT" -name *Mysterious_aokp_n7100_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7100" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/n7100
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     GT-N7105                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_t0lte-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lte=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_t0lte_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0lte
else
    find "$OUT" -name *Mysterious_aokp_t0lte_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0lte
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SCH-I605                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_i605-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi605=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_i605_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i605
else
    find "$OUT" -name *Mysterious_aokp_i605_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i605
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SPH-L900                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_l900-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEl900=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_l900_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/l900
else
    find "$OUT" -name *Mysterious_aokp_l900_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/l900
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SCH-I317                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_t0lteatt-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lteatt=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_t0lteatt_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lteatt" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0lteatt
else
    find "$OUT" -name *Mysterious_aokp_t0lteatt_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lteatt" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/t0lteatt
fi

##########################################################################################
#                                                                                        #
#                                Building P930                                           #
#                                                                                        #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_p930-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION14=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEp930=$OUT/$VERSION14.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_p930_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEp930" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/p930
else
    find "$OUT" -name *Mysterious_aokp_p930_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEp930" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/p930
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Note                                    #
#                                     GT-N7000                                           #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_n7000-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEn7000=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_n7000_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7000" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/n7000
else
    find "$OUT" -name *Mysterious_aokp_n7000_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7000" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/n7000
fi

##########################################################################################
#                                                                                        #
#                            Building Galaxy S2 (GT-I9100G)                              #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_i9100g-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_i9100g_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9100g
else
    find "$OUT" -name *Mysterious_aokp_i9100g_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9100g
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (GT-I9300)                              #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_i9300-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_i9300_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9300
else
    find "$OUT" -name *Mysterious_aokp_i9300_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9300
fi

##########################################################################################
#                                                                                        #
#                             Building Nexus 10 ( Manta )                                #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_manta-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmanta=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_manta_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmanta" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/manta
else
    find "$OUT" -name *Mysterious_aokp_manta_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmanta" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/manta
fi

##########################################################################################
#                                                                                        #
#                                   Building Solana                                    #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_solana-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEsolana=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_solana_*${DATE}.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsolana" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/solana
else
    find "$OUT" -name *Mysterious_aokp_solana_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsolana" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/solana
fi

##########################################################################################
#                                                                                        #
#                             Building Nexus 7 3G ( Tilipia )                            #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_tilapia-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtilapia=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_tilapia_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtilapia" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/tilapia
else
    find "$OUT" -name *Mysterious_aokp_tilapia_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtilapia" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/tilapia
fi

##########################################################################################
#                                                                                        #
#                             Building Toro Plus                                         #
#                                                                                        #
##########################################################################################

. build/envsetup.sh;
brunch aokp_toroplus-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGtoroplus=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Mysterious_aokp_toroplus_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoroplus" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/toroplus
else
    find "$OUT" -name *Mysterious_aokp_toroplus_*${AOKP_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoroplus" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/toroplus
fi

# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$DATE".txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$RB_BUILD".txt
fi

echo "MysteriousROM packages built, Changelog generated and everything uploaded to server!"

