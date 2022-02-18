#! /bin/bash
# https://julianjc84.wordpress.com/2011/12/21/timemachine-automatic-email-notifications-script/
# credits to http://blag.ericderuiter.com/2010/01/07/tmnotify/
# last updated 2016-01-15
#################################
##   USER ASSIGNED VARIABLES   ##
#################################
#set length of time to go without backups in minutes (1hr = 60, 3hr = 180, 6hrs = 360, 9hrs= 540, 12hrs= 720, 24hrs (day) = 1440,)
	minutes=180	#3hours

#set email address to receive notifications ensure you have the "" around the email
	recipient="youremail@yourdomain.com"
	sender="timemachinescript@yourdomain.com"
#seems this is legacy in 10.11.2 macosx /usr/bin/mail -s "TimeMachine SUCCESS, on $identify" $recipient -f $sender < /tmp/tmnotify.txt

#identify this computer or person so the computer running this script can be easily identified
	identify="your computers name"

#variable for sending alerts on successful backup (type true to always receive email. type false to only receive on failure)
	alertonsuccess=true

############################
##   AUTO SET VARIABLES   ##
############################
#assign variable for the most recent successful backup
#lastbackup=$(syslog -T sec | grep "Backup completed successfully" | grep -E '(/System/Library/CoreServices/backupd|com.apple.backupd)' | tail -n 1 | awk '{ print $1 }')
	lastbackup=$(syslog -T sec | grep "Backup completed successfully" | tail -n 1 | awk '{ print $1 }')

#assign variable for the current time
	now=$(date +%s)

#assign value for how long to go without backups
	interval=$(($minutes * 60))

#assign variable for the time since backup ran
	total=$(($now - $lastbackup))

#assign variable to allow for time machine's one hour interval
	totaladjusted=$(($total - 3600))

######################
##  	 CHECK	    ##
######################
echo -e "NOW:$now\nLASTBACKUP:$lastbackup\nTOTAL:$total\nTOTALADJUSTED:$totaladjusted\nMINUTES:$minutes\nINTERVAL:$interval\n"

if	test $totaladjusted -lt $interval # -lt = is lessthan, if $totaladjusted is less than $interval then FAIL! no backup within specified time $minutes
	then
	if test "$alertonsuccess" = "true" # checks to see that the two variables match. and passes the script else it would fail
		then
		#echo "TM_EMAIL C1: alertonsuccess = $alertonsuccess"
		#echo "TM_EMAIL C2: running as user:" $(whoami)
		#echo "TM_EMAIL C2: alertonsuccess = $alertonsuccess"
			echo -e "TimeMachine: SUCCESS \non: $identify\n" > /tmp/tmnotify.txt
			echo -e "This script ran at: `date`" >> /tmp/tmnotify.txt
			#echo "TM_EMAIL C2: searching 1st system.log..."
		#read system log and output	
			syslog | grep "Backup completed successfully" | tail -n 1 | awk '{ print "The most recent successful backup was at: " $4 " on " $1", " $2, $3 }' | sed -e 's/:[0-9][0-9] / /' >> /tmp/tmnotify.txt
			echo -e "\nTime Variable Now is: $now" >> /tmp/tmnotify.txt
			echo -e "Time Variable LastBackUp is: $lastbackup" >> /tmp/tmnotify.txt
			echo -e "\nThe last 20 backupd logs...\n" >> /tmp/tmnotify.txt
		#echo "TM_EMAIL C2: searching 2nd system.log..."
			syslog | grep "com.apple.backupd" | tail -n 20 >> /tmp/tmnotify.txt
			/usr/bin/mail -s "TimeMachine SUCCESS, on $identify" $recipient < /tmp/tmnotify.txt
		#echo "TM_EMAIL: email sent to: Server: $identify to: $recipient from: $sender\nTM_EMAIL: script complete"
			exit
		else
		#Everything is OK! a backup has been found in range. However the user has selected alertonsuccess=false, NOT be notified
			echo -e "alertonsuccess set to: $alertonsuccess"
			echo "TM_EMAIL C2_1: `date` back up found within range. The user does not want to be notified"
			exit
	fi
	else
		#You will receive email because a backup has not been found with in the specified time range.
			echo -e "TimeMachine: FAILURE \non: $identify\n" > /tmp/tmnotify.txt
			echo -e "This script ran at: `date`" >> /tmp/tmnotify.txt
		#echo "TM_EMAIL C3: FAILURE searching 1st system.log..."
			syslog | grep "Backup completed successfully" | tail -n 1 | awk '{ print "The last successful backup  was at: " $4 " on " $1", " $2, $3 }' | sed -e 's/:[0-9][0-9] / /' >> /tmp/tmnotify.txt
			echo -e "\nTime Variable Now is: $now" >> /tmp/tmnotify.txt
			echo -e "Time Variable LastBackUp is: $lastbackup" >> /tmp/tmnotify.txt
		#echo "TM_EMAIL C3: FAILURE searching 2nd system.log..."
			echo -e "\nThe last 20 backupd logs...\n" >> /tmp/tmnotify.txt
			syslog | grep "com.apple.backupd" | tail -n 20 >> /tmp/tmnotify.txt
			/usr/bin/mail -s "TimeMachine: ***FAILURE*** on $identify" $recipient < /tmp/tmnotify.txt
		#echo "TM_EMAIL: email set to: Server: $identify to: $recipient from: $sender\nTM_EMAIL: script complete"
		exit
fi