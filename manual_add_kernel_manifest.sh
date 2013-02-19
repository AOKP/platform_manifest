#!/bin/bash
# To be run from the root of the build tree.
# NOT FROM THE PLATFORM_MANIFEST DIRECTORY!!!
# -KhasMek

manifest=.repo/local_manifests/kernel_manifest.xml

echo "adding kernel repos to your build tree"

#delete depricated local_manifest.xml

if [ -f ".repo/local_manifest.xml" ]; then
    rm ".repo/local_manifest.xml"
fi

if [ -f $manifest ]; then
        echo "kernel manifest already present."
        echo "merging manifests for safety."
        cat platform_manifest/kernel_manifest.xml | while read line
        do
                kernel=`grep "$line" $manifest`
                if [ -z "$kernel" ]; then
                        echo "  $line" >> $manifest
                fi
        done
        # Cleanup
        grep -Ev "^</manifest>" $manifest > '$manifest'.new
        echo "</manifest>" >> '$manifest'.new
        mv '$manifest'.new $manifest
fi

if [ ! -d ".repo/local_manifests" ]; then
    mkdir ".repo/local_manifests"
fi

cp platform_manifest/kernel_manifest.xml $manifest
echo "syncing kernel repos"
tail -n +3 platform_manifest/kernel_manifest.xml | head -n -1 | cut -f2 -d '"' > .sync

. build/envsetup.sh

while read line ;do
        reposync "$line"
        echo "$line synced successfully"
done < .sync

#cleanup
rm .sync
