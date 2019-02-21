#!/bin/bash

# This script will automate the deletion of MediaPort multimedia files.
# The idea is that when a MediaPort is >= 95% full, the script will run and
# delete the oldest files in the /multimedia/* directory.
# It will run daily, and reduce to about ~90% hard drive usage.
#
# 2015.11.17 - AHG; Created.
# 2015.12.14 - AHG; Removed grep causing the variable setup to fail on my machine. 
# 2015.12.16 - AHG; Finished initial version of the script.
# 2016.04.13 - AHG; Added logging capabilities
# 2016.06.29 - AHG; Added install switch
# 2016.09.08 - CSR: Added support for Ubuntu (apparently a different cron path); Fixed cronjob syntax that may have made the script execute every minute of the 3am hour; Fixed missing dow field
#

function getDiskUtil() {
	# Check to see if hard drive usage on this specific mount of the MediaPort
	# Will give a numeric response (stripped of its percentage sign!)
	DISKUTIL=$(df | grep "/home" | awk '{print $5}' | cut -d '%' -f1)

	# had trouble on the VM's with df not returning the correct point, so if this
	# returns blank use 4th printed item (This should work correctly on mediaports)
	if [ "$DISKUTIL" = "" ]
	then
		echo "Changing to the correct location..."
		DISKUTIL=$(df | grep "/home" | awk '{print $4}' | cut -d '%' -f1)
	fi
}


# install's the mediaportCleanup script
if [ "$1" = "-install" ]
then
        SYSCHECK=$(dumpisam -config NETWORK)
        if [ "$SYSCHECK" = "REMOTE" ]
        then
		if [ $(crontab -l | grep -c "mediaportCleanup.sh") -gt 0 ]
		then
			# this script is already installed as a cronjob
			exit 0
		else
			# determine the cron framework path for this machine
			CRON_FILE=/var/spool/cron/root
			if [ "$(which lsb_release)" = "" ]; then
				CRON_FILE=/var/spool/cron/root
			else
				if [ "$(lsb_release -d | awk '{print $2}')" = "Ubuntu" ]; then
					CRON_FILE=/var/spool/cron/crontabs/root
				fi
			fi

	                # put periodic reboot in the cron job, running every day at 3 am
			echo >> $CRON_FILE
	                echo "# Cleans up the mediaport nightly, or when ran" >> $CRON_FILE
	                echo "0 3 * * * /home/server_software_user/bin/mediaportCleanup.sh" >> $CRON_FILE
	                exit 0
		fi
        else
                echo "Please only install mediaport cleanup on mediaports."
                echo "Exiting..."
                exit 0
        fi
fi

getDiskUtil

# Decides if the DISKUTIL variable is greater than or
# equal to 95%. If so, delete stuff. If it's not the job repeats tomorrow - forever!
if [ "$DISKUTIL" -gt "95" ]
then
	# change directory to be where all the media is
      	cd /home/server_software_user/public_html/multimedia || exit
      	# make sure you are in the directory!
      	if [ "`pwd`" =  "/home/server_software_user/public_html/multimedia" ]
        then
        	echo "This MediaPort has greater than 94% disk usage..."
        	echo "Commencing with deletion of old files..."
		# Use a loop to remove files until DISKUTIL < 90%
		COUNT=0
		while [ "$DISKUTIL" -gt "80" ]; do
			# remove files: ls -rt shows files oldest first
			# Show a message confirming a file has been deleted afterwards.
			
			# Ignore files we need for the software... why they're stored in the multimedia directory I have no idea.
			FN=`ls -rt --ignore=*.sh --ignore=sm* --ignore=dump* --ignore=cmd* --ignore=*.jpg --ignore=*.png --ignore=*.conf --ignore=pbx* --ignore=*html --ignore=*.txt --ignore=*.tcl | head -1`
			echo "Deleting $FN"
			# log the deleted files into a new log.
		        printf "mediaportCleanup.sh: %s - File deleted: %s \n" "$(date)" "$FN" >> /home/server_software_user/log/mediaportCleanup.log
			rm "$FN"

			# failsafe for mediaport deletion. Break out of the loop in case it goes infinitely!
			COUNT=$((COUNT+1))
			if [ "$COUNT" -eq 50000 ]
			then
			echo "Breaking out of this apparent infinite loop..."
			break
			fi
			# reevaluate the amount of space used, to know if we should continue loop or not.

			getDiskUtil
			
       		done # end while loop removing files
		# Show the terminal that the MediaPort should be fine for use now!		
		echo "Completing deletion..."
		echo "MediaPort should have sufficient harddrive space."

	fi # end check to make sure your are in the correct directory.
else
	#notification that there is no reason to delete files.
	echo "There is no reason to delete files yet..."
	echo "Canceling deletion."
fi # end check on data usage
