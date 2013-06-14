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
    export RB_BUILD="$OFFICIAL"
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
    cp changelog.txt changelog_"$RB_BUILD".txt
    scp "$rdir"/changelog_"$RB_BUILD".txt Mysterious@upload.goo.im:~/public_html/AOKP_Changelogs
fi

##########################################################################################
#                                                                                        #
#                                   Building HTC ONE                                     #
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
    find "$OUT" -name *aokp_m7ul_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7ul" Mysterious@upload.goo.im:~/public_html/Nightlies/m7ul
else
    find "$OUT" -name *aokp_m7ul_release_*${RB_BUILD}*.zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7ul" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_m7ul_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Nexus 4                                     #
#                                                                                        #
##########################################################################################

brunch aokp_mako-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_mako_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/Nightlies/mako
else
    find "$OUT" -name *aokp_mako_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_mako_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Nexus 7                                     #
#                                                                                        #
##########################################################################################

brunch aokp_grouper-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION2=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEgrouper=$OUT/$VERSION2.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_grouper_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Mysterious@upload.goo.im:~/public_html/Nightlies/grouper
else
    find "$OUT" -name *aokp_grouper_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_grouper_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S2 (GT-I9100)                              #
#                                                                                        #
##########################################################################################

brunch aokp_i9100-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION6=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION6.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_i9100_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Mysterious@upload.goo.im:~/public_html/AOKP/Nightlies/i9100
else
    find "$OUT" -name *aokp_i9100_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" Mysterious@upload.goo.im:~/public_html/AOKP/MysteriousAOKP_i9100_jb
fi

##########################################################################################
#                                                                                        #
#                                Building d2usc                                          #
#                                                                                        #
##########################################################################################

brunch aokp_d2usc-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION9=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2usc=$OUT/$VERSION9.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_d2usc_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2usc" Mysterious@upload.goo.im:~/public_html/Nightlies/d2usc
else
    find "$OUT" -name *aokp_d2usc_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2usc" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_d2usc_jb
fi

##########################################################################################
#                                                                                        #
#                                Building Evita                                          #
#                                                                                        #
##########################################################################################

brunch aokp_evita-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION9=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEevita=$OUT/$VERSION9.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_evita_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEevita" Mysterious@upload.goo.im:~/public_html/Nightlies/evita
else
    find "$OUT" -name *aokp_evita_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEevita" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_evita_jb
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Nexus                                   #
#                                                                                        #
##########################################################################################

brunch aokp_maguro-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION9=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaguro=$OUT/$VERSION9.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_maguro_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" Mysterious@upload.goo.im:~/public_html/Nightlies/maguro
else
    find "$OUT" -name *aokp_maguro_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_maguro_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building HTC ONE ATT                                 #
#                                                                                        #
##########################################################################################

brunch aokp_m7att-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7att=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_m7att_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7att" Mysterious@upload.goo.im:~/public_html/Nightlies/m7att
else
    find "$OUT" -name *aokp_m7att_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7att" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_m7att_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Nexus 4                                     #
#                                                                                        #
##########################################################################################

brunch aokp_mako-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_mako_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/Nightlies/mako
else
    find "$OUT" -name *aokp_mako_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_mako_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Maserati                                    #
#                                                                                        #
##########################################################################################

brunch aokp_maserati-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaserati=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_maserati_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaserati" Mysterious@upload.goo.im:~/public_html/Nightlies/maserati
else
    find "$OUT" -name *aokp_maserati_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaserati" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_maserati_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building HTC ONE Tmo                                 #
#                                                                                        #
##########################################################################################

brunch aokp_m7tmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEm7tmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_m7tmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7tmo" Mysterious@upload.goo.im:~/public_html/Nightlies/m7tmo
else
    find "$OUT" -name *aokp_m7tmo_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEm7tmo" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_m7tmo_jb
fi

##########################################################################################
#                                                                                        #
#                                 Building Galaxy S4 Tmo                                 #
#                                                                                        #
##########################################################################################

brunch aokp_jfltetmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEjfltetmo=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_jfltetmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltetmo" Mysterious@upload.goo.im:~/public_html/Nightlies/jfltetmo
else
    find "$OUT" -name *aokp_jfltetmo_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEjfltetmo" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_jfltetmo_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building S2 Variant                                  #
#                                                                                        #
##########################################################################################

brunch aokp_hercules-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEherclues=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_hercules_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhercules" Mysterious@upload.goo.im:~/public_html/Nightlies/hercules
else
    find "$OUT" -name *aokp_hercules_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEhercules" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_hercules_jb
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Nexus                                   #
#                                                                                        #
##########################################################################################

brunch aokp_toro-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION10=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtoro=$OUT/$VERSION10.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_toro_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Mysterious@upload.goo.im:~/public_html/Nightlies/toro
else
    find "$OUT" -name *aokp_toro_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_toro_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy S3 (AT&T)                                 #
#                                                                                        #
##########################################################################################

brunch aokp_d2att-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION3=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2att=$OUT/$VERSION3.zip

# Move the changelog into zip  & upload zip to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_d2att_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Mysterious@upload.goo.im:~/public_html/Nightlies/d2att
else
    find "$OUT" -name *aokp_d2att_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_d2att_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (T-Mobile)                              #
#                                                                                        #
##########################################################################################

brunch aokp_d2tmo-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION4=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2tmo=$OUT/$VERSION4.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_d2tmo_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Mysterious@upload.goo.im:~/public_html/Nightlies/d2tmo
else
    find "$OUT" -name *aokp_d2tmo_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_d2tmo_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (Verizon)                               #
#                                                                                        #
##########################################################################################

brunch aokp_d2vzw-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION5=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2vzw=$OUT/$VERSION5.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_d2vzw_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Mysterious@upload.goo.im:~/public_html/Nightlies/d2vzw
else
    find "$OUT" -name *aokp_d2vzw_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_d2vzw_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (Sprint)                                #
#                                                                                        #
##########################################################################################

brunch aokp_d2spr-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION17=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2spr=$OUT/$VERSION17.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_d2spr_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2spr" Mysterious@upload.goo.im:~/public_html/Nightlies/d2spr
else
    find "$OUT" -name *aokp_d2spr_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2spr" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_d2spr_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     GT-N7100                                           #
#                                                                                        #
##########################################################################################

brunch aokp_n7100-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION16=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEn7100=$OUT/$VERSION16.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_n7100_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7100" Mysterious@upload.goo.im:~/public_html/Nightlies/n7100
else
    find "$OUT" -name *aokp_n7100_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7100" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_n7100_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     GT-N7105                                           #
#                                                                                        #
##########################################################################################

brunch aokp_t0lte-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION11=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lte=$OUT/$VERSION11.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_t0lte_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Mysterious@upload.goo.im:~/public_html/Nightlies/t0lte
else
    find "$OUT" -name *aokp_t0lte_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_t0lte_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SCH-I605                                           #
#                                                                                        #
##########################################################################################

brunch aokp_i605-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION12=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi605=$OUT/$VERSION12.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_i605_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" Mysterious@upload.goo.im:~/public_html/Nightlies/i605
else
    find "$OUT" -name *aokp_i605_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_i605_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SPH-L900                                           #
#                                                                                        #
##########################################################################################

brunch aokp_l900-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION13=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEl900=$OUT/$VERSION13.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_l900_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" Mysterious@upload.goo.im:~/public_html/Nightlies/l900
else
    find "$OUT" -name *aokp_l900_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_l900_jb
fi

##########################################################################################
#                                                                                        #
#                              Building Galaxy Note II                                   #
#                                     SCH-I317                                           #
#                                                                                        #
##########################################################################################

brunch aokp_t0lteatt-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION15=`sed -n -e'/ro.rootbox.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lteatt=$OUT/$VERSION15.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_t0lteatt_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lteatt" Mysterious@upload.goo.im:~/public_html/Nightlies/t0lteatt
else
    find "$OUT" -name *aokp_t0lteatt_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lteatt" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_t0lteatt_jb
fi

##########################################################################################
#                                                                                        #
#                                Building P930                                           #
#                                                                                        #
#                                                                                        #
##########################################################################################

brunch aokp_p930-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION14=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEp930=$OUT/$VERSION14.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_p930_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEp930" Mysterious@upload.goo.im:~/public_html/Nightlies/p930
else
    find "$OUT" -name *aokp_p930_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEp930" Mysterious@upload.goo.im:~/public_html/AOKP_p930_jb
fi

##########################################################################################
#                                                                                        #
#                                Building Galaxy Note                                    #
#                                     GT-N7000                                           #
#                                                                                        #
##########################################################################################

brunch aokp_n7000-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION14=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEn7000=$OUT/$VERSION14.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_n7000_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7000" Mysterious@upload.goo.im:~/public_html/Nightlies/n7000
else
    find "$OUT" -name *aokp_n7000_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEn7000" Mysterious@upload.goo.im:~/public_html/AOKP_n7000_jb
fi

##########################################################################################
#                                                                                        #
#                            Building Galaxy S2 (GT-I9100G)                              #
#                                                                                        #
##########################################################################################

brunch aokp_i9100g-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION7=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION7.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_i9100g_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Mysterious@upload.goo.im:~/public_html/Nightlies/i9100g
else
    find "$OUT" -name *aokp_i9100g_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_i9100g_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Galaxy S3 (GT-I9300)                              #
#                                                                                        #
##########################################################################################

brunch aokp_i9300-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_i9300_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/Nightlies/i9300
else
    find "$OUT" -name *aokp_i9300_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/AOKP/MysteriousAOKP_i9300_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Nexus 10 ( Manta )                                #
#                                                                                        #
##########################################################################################

brunch aokp_manta-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmanta=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_manta_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/Nightlies/manta
else
    find "$OUT" -name *aokp_manta_release_*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/AOKP/MysteriousAOKP_manta_jb
fi

##########################################################################################
#                                                                                        #
#                                   Building Solana                                    #
#                                                                                        #
##########################################################################################

brunch aokp_solana-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEsolana=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_solana_*${DATE}.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsolana" Mysterious@upload.goo.im:~/public_html/Nightlies/solana
else
    find "$OUT" -name *aokp_solana_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEsolana" Mysterious@upload.goo.im:~/public_html/AOKP/AOKP_solana_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Nexus 7 3G ( Tilipia )                            #
#                                                                                        #
##########################################################################################

brunch aokp_tilapia-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtilapia=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_tilapia_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/Nightlies/tilapia
else
    find "$OUT" -name *aokp_tilapia_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" Mysterious@upload.goo.im:~/public_html/AOKP/MysteriousAOKP_tilapia_jb
fi

##########################################################################################
#                                                                                        #
#                             Building Toro Plus                                         #
#                                                                                        #
##########################################################################################

brunch aokp_toroplus-userdebug;

# Get Package Name
sed -i -e 's/aokp_//' $OUT/system/build.prop
VERSION6=`sed -n -e'/ro.aokp.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGtoroplus=$OUT/$VERSION6.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *aokp_toroplus_*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoroplus" Mysterious@upload.goo.im:~/public_html/Nightlies/toroplus
else
    find "$OUT" -name *aokp_toroplus_release*${RB_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoroplus" Mysterious@upload.goo.im:~/public_html/AOKP/MysteriousAOKP_toroplus_jb
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

