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

Link : https://raw.githubusercontent.com/AICP/vendor_aicp/n7.1/xda_thread-template.txt


Uploading to AICP Gerrit
---------------

1st You must have local ssh keys on your computer if you do not here is a [guide](http://goo.gl/86CfDP) to generate them.

2nd Make an account on [Gerrit](http://gerrit.aicp-rom.com) login only using GoogleAuth2

3rd Add your ssh public key to your account

4th Make your changes and commit them

5th use the following command to push your commit to gerrit

(From root android directory)
    . build/envsetup.sh
    repo start n7.1 path/to/project
    (Go to repo you are patching, make your changes and commit)
    repo upload .
For more help on using this tool, use this command: repo help upload

You can also use:

    git push ssh://USERNAME@gerrit.aicp-rom.com:29418/AICP/REPO_NAME HEAD:refs/for/branch-name

Example:

    git push ssh://mosimchah@gerrit.aicp-rom.com:29418/AICP/platform_manifest HEAD:refs/for/n7.1


6th You will get an error about a missing Change-ID in that error it will show you a suggested commit message copy the change id

7th Do the following command and add the change id to the end of the commit message

    git commit --amend

Here is an example of what the commit message should look like:

> Add how to push to gerrit
>
> Change-Id: I93949d30d732de35222d9d78d1f94e33e4bffc47

8th use the same command to push to gerrit and if you did everything properly it will be up on gerrit



## Maintain Authorship ##
Please make sure if you submit a patch/fix from another ROM that you maintain authorship.
This is very important to not only us but to the entire open source community. It's what keeps it going and encourages more developers to contribute their work.

If you manually cherry pick a patch/fix please add the original author prior to pushing to our gerrit.
This task is very easy and is usually done after you commit a patch/fix locally.

i.e - Once you type in "git commit -a" the commit message and you have saved it, type in the following:

```bash
git commit --amend --author "Author <email@address.com>"
```

So it should look like this once you get all author's information:

```bash
git commit --amend --author "John Doe <john.doe@gmail.com>"
```


Picking changes from our gerrit
-------------------------------

(From root android directory)
    . build/envsetup.sh

to pick every change from a topic:

    repopick -t topic

to pick a specific change

    repopick commit-number

example, to pick this commit: http://gerrit.aicp-rom.com/#/c/36939/

    repopick 36939
