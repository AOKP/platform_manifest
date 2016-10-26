[Android Ice Cold Project](http://aicp-rom.com)
====================================


Download the Source
===================

Please read the [AOSP building instructions](http://source.android.com/source/index.html) before proceeding.

Initializing Repository
-----------------------

Repo initialization:

    $ repo init -u https://github.com/AICP/platform_manifest.git -b n7.1


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
    time brunch angler

Remember to `make clobber` every now and then!


Optional After Successful Build
--------------------------------

After a build, if you would like to share your build on XDA (Regular Unofficial Builds) , then please do follow the following Template to create
an XDA thread. Note that the template is a guideline of sort. You may make your own changes to it (esp please do in the download link) but try
and make thread as close to this one as possible. This is to aviod cluttering and make stuff organised.

Link : https://dl.dropboxusercontent.com/u/57672206/xda%20template
