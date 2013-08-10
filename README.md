INITIALIZING REPOSITORY
=======================

Init core trees without any device/kernel/vendor :

    $ repo init -u https://github.com/AOKP/platform_manifest.git -b jb-mr2

Init repo with all devices, kernels and vendors supported by AOKP :

    $ repo init -u https://github.com/AOKP/platform_manifest.git -b jb-mr2 -g all,kernel,device,vendor

Init repo only for a particular device

    $ repo init -u https://github.com/AOKP/platform_manifest.git -b jb-mr2 -g all,-notdefault,<devicename>,<vendorname>

for example, to init only trees needed to build i9300

    $ repo init -u https://github.com/AOKP/platform_manifest.git -b jb-mr2 -g all,-notdefault,i9300,samsung

sync repo

    $ repo sync
