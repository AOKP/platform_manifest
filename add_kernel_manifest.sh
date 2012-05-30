#!/bin/bash
# To be run from the root of the build tree.
# NOT FROM THE PLATFORM_MANIFEST DIRECTORY!!!
# -KhasMek

echo "adding kernel repos to your build tree"
cp platform_manifest/kernel_manifest.xml .repo/local_manifest.xml
echo "syncing kernel repos"
tail -n +3 platform_manifest/kernel_manifest.xml | head -n -1 | cut -f2 -d '"' > .sync

. build/envsetup.sh

while read line ;do
	reposync "$line"
	echo "$line synced successfully"
done < .sync

#cleanup
rm .sync
