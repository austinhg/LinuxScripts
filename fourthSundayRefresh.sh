#!/bin/bash
#
# A script to run a specific script on the 4th Sunday of the month. Called from
# a Crontab that runs every Sunday.
#
# Changelog:
#	2019.3.29 - AHG: Creation and original concept.
#	2019.4.04 - AHG: Fixed logic to prevent globbing and took other precautions.
# 	2019.4.05 - AHG: 1.0 Version for release to the team.
#

# The following is the DBA's original crontab entry that didn't work:
# 00 13 22-30 * * [ '$(date '+\%u')' = 7 ] && /home/oracle/.bash_profile;. /u01/app1/scripts/hptst_refresh/clonehptst.sh > /u01/app1/scripts/clone

FOURTH_SUNDAY=$(cal | awk 'FNR==3 {i=(NF<7)?1:0}FNR==(6+i){print $1}')
TODAY=$(date +%d)

if [ "$TODAY" -eq "$FOURTH_SUNDAY" ]; then
	printf "%s - Today is the 4th Sunday of the month - Run DBA's script. \n" "$(date)"
	./u01/app1/scripts/hptst_refresh/clonehptst.sh > /u01/app1/scripts/clone
else
	printf "%s - Today is not the 4th Sunday of the month, exiting... \n" "$(date)"
fi

exit 0
