#run me for frameworks picks

cd ../frameworks/base
git fetch http://gerrit.sudoservers.com/AOKP/frameworks_base refs/changes/33/4633/2 && git cherry-pick FETCH_HEAD

cd ../av
git fetch http://gerrit.sudoservers.com/AOKP/frameworks_av refs/changes/34/4634/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com/AOKP/frameworks_av refs/changes/15/4615/2 && git cherry-pick FETCH_HEAD

cd ../native
git fetch http://gerrit.sudoservers.com/AOKP/frameworks_native refs/changes/35/4635/1 && git cherry-pick FETCH_HEAD