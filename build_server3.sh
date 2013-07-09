#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"

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
else
    echo "Generating and Uploading Changelog for Official Release"
    cp changelog.txt changelog_"$AOKP_BUILD".txt
fi

# Build Devices on Server 3
. build_release.sh manta "$RELEASE" "$OFFICIAL"

. build_release.sh d2usc "$RELEASE" "$OFFICIAL"

. build_release.sh evita "$RELEASE" "$OFFICIAL"

. build_release.sh m7att "$RELEASE" "$OFFICIAL"

. build_release.sh m7spr "$RELEASE" "$OFFICIAL"

. build_release.sh jfltetmo "$RELEASE" "$OFFICIAL"

. build_release.sh jflteusc "$RELEASE" "$OFFICIAL"

. build_release.sh jfltevzw "$RELEASE" "$OFFICIAL"

. build_release.sh hercules "$RELEASE" "$OFFICIAL"

. build_release.sh m7tmo "$RELEASE" "$OFFICIAL"

. build_release.sh maserati "$RELEASE" "$OFFICIAL"

. build_release.sh p930 "$RELEASE" "$OFFICIAL"

# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$DATE".txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$AOKP_BUILD".txt
fi

echo "MysteriousAOKP packages built, Changelog generated and everything uploaded to server!"


