#!/bin/bash
# I'm extremely lazy when it comes to syncing my cloud storage data with my
# home server, and unfortunately the NAS I bought doesn't have an app for my
# Cloud host.
# This runs off a cron job that can install through this script.
# This script is built to be ran on one of the home Macs.
# TODO: Write cases for converting this on a CentOS machine.
#
# Changelog:
#       2019.10.31, AHG - Creation
#

# Photos/Video/OTA TV Caps are all sorted in post on the Media mount directory.
# I'm mostly concerned with avoiding timeouts from different mounts.
DOWNLOAD_DIR=$(~/Downloads)
SERVER_DIR=$(/Volumes/Media)

cd DOWNLOAD_DIR || exit
rysnc -av --progress "$DOWNLOAD_DIR" "$SERVER_DIR"/Unsorted

# I know this could be done a bit more elegantly with a loop, but that's for when
# I have more time.
mv *.mkv "$SERVER_DIR"/TV\ Shows
mv *.jpg *.jpeg *.png *.mp4 "$SERVER_DIR"/Family\ Photos

# Feel free to delete the local downloads
read -p "Do you want to delete your local files in ~/Downloads ? [Y/n]: " varOpt

if [ "$varOpt" == "Y" ] || [ "$varOpt" == "y" ] || [ "$varOpt" == "Yes" ] || [ "$varOpt" == "yes" ]

then
    # shouldn't have any directories in here. Just delete files...
    rm -f *.*
fi
