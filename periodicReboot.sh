#!/bin/bash
#
# periodicReboot.sh
#       
# Runs at 3 am daily.
# 1.) Generates a number between current time (minutes) and 59. (59th minute of the hour)
# 2.) Sleeps until that time, and calls periodicReboot -doreboot to reboot the machine/log.
# 
# 2016.04.04, AHG - creation.
# 2016.05.05, AHG - fixed error where cronjob wouldn't kick off a shutdown due to path. 
# 2016.05.06, AHG - introduced cron install switch inside the script, instead of needing another.
# 2016.09.08, CSR - added specialized cron for Ubuntu; changed time to 2:58 so it won't compete with mediaportCleanup.sh running.
# 2017.03.13, CSR - fixed mediaports rebooting in only 2 minute window caused SIP registration problems on some (the 2:58 change above was a bad idea)
# 2018.04.13, CSR - deprecated (now just exits)

echo
echo "DEPRECATED! Aborting."
echo
exit 1

rebootCompute()
{
	# get the offset by finguring a pseudorandom number from whatever minute the script was ran and 
	# and 59 (the last minute in the hourly block). Return that number
	REBOOTOFFSET=$(date +"%M")
	REBOOTVAL=$(((RANDOM % (59 - REBOOTOFFSET) + 1) + REBOOTOFFSET))
	echo "Initial value of REBOOTVAL in the function: $REBOOTVAL"
}

if [ "$1" = "-checkandset" ]
then
	# check the random number and sleep until we need to call it, while calling the switch -doreboot 
	rebootCompute
	# Just in case this script was held up and invoked later than 3am; subtract the offset value.
	# if it's ran at the proper time it essentially does nothing, but maintains our 3am-3:59am reboot window.
	CHECKSETVAL=$((REBOOTVAL - REBOOTOFFSET))
	sleep "$CHECKSETVAL"m
	 periodicReboot.sh -doreboot
	# Log the current system information/function that was called.
	printf "periodicReboot.sh: %s\n" "$(date)" >> /home/server_software_user/log/reboot.log
	/etc/init.d/rpcbind stop
	sleep 2
	smstop.sh
	sleep 1
	killall # <Various binaries that are required to shut down for this specific server>
	sleep 1
	killall -9 # <Various binaries that are required to shut down for this specific server - this time to make sure they're ended>
	sleep 1
	/sbin/shutdown -r now
	exit 0

elif [ "$1" = "-install" ]
then
	SYSCHECK=$(dumpisam -config NETWORK)
	if [ "$SYSCHECK" = "REMOTE" ]
	then
		if [ $(crontab -l | grep -c "periodicReboot.sh") -gt 0 ]
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

			# put periodic reboot in the cron job, running every day somewhere between 2-3 am
			echo "" >> $CRON_FILE
			echo "# Runs the periodicReboot script" >> $CRON_FILE
			echo "0 2 * * * /home/server_software_user/bin/periodicReboot.sh -checkandset" >> $CRON_FILE
			exit 0
		fi
	else
		echo "Please only install periodic reboot on mediaports."
		echo "Exiting..."
		exit 0
	fi
fi
