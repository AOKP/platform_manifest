[Another Ice Cold Project](http://aicp-rom.com)
====================================


Download the Source
===================

Please read the [AOSP building instructions](http://source.android.com/source/index.html) before proceeding.

Initializing Repository
-----------------------

Please take note that we have two main line branches depending on which hardware base your phone is working.

If you have a qcom powered device which needs CodeAuroraForum (CAF) BT trees please use the kitkat-caf branch which pulls for the effected packages the correct caf version for you.


To initialize your local repository using the AICP trees, use one of the following commands (without any device/kernel/vendor):

Init core trees for google, exynos and non CodeAuroraForum devices:

    $ repo init -u https://github.com/AICP/platform_manifest.git -b kitkat

for devices which are using CodeAuroraForum trees:

    $ repo init -u https://github.com/AICP/platform_manifest.git -b kitkat-caf

sync repo :

    $ repo sync

***

Building
--------

After the sync is finished, please read the [instructions from the Android site](http://s.android.com/source/building.html) on how to build.

    . build/envsetup.sh
    brunch


You can also build (and see how long it took) for specific devices like this:

    . build/envsetup.sh
    time brunch m7

Remember to `make clobber` every now and then!
