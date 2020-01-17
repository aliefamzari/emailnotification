#!/bin/bash
# In the event of power failure, script will send email to target recipient
# Author : Alif Amzari Mohd Azamee
# Version control : Git
# Job retention: @reboot crontab 
# License: MIT


sleep 60
# Global variables
noipDnsName="targethost"
ip=`hostname -I`
lhost=`hostname -f`
recipient="targetrecipient"
tmpPath="/tmp"
ddns=$(dig +short $noipDnsName)
uptimeSince=`uptime -s`
currentDate=`date +"%Y-%m-%d %H:%M:%S"`
currentIp=$(curl -s /dev/null ifconfig.co 2>&1)

# Services detail
apache=$(systemctl status apache2 |grep Active)
mariadb=$(systemctl status mariadb |grep Active)
mdadmdetail=$(sudo mdadm --detail /dev/md0)

# Loop 5 times if no-ip and currentIP is not match.  Code exit after 5 times. 
n=1 
while [ $n -le 5 ]; do
    ddns=$(dig +short $noipDnsName)
    if [ ${currentIp} != $ddns ]; then
    echo 'Retrying..'
    n=$(( n+1 ))
    sleep 30
    else
    # Populating content into payload
        echo "Server status report: Reason 'Unexpected REBOOT'" > $tmpPath/email.txt
        echo "Localhost: $lhost" >> $tmpPath/email.txt
        echo "Current Date: $currentDate" >> $tmpPath/email.txt
        echo "Uptime Since: $uptimeSince" >> $tmpPath/email.txt
        echo "Local IP: $ip" >> $tmpPath/email.txt
        if ping -c 1 -W 1 "$noipDnsName" > /dev/null ; then
        	echo -e "DNS status: $noipDnsName is alive." >> $tmpPath/email.txt
        	echo -e "Public IP: $ddns" >> $tmpPath/email.txt
        	else
        	echo -e "DNS Status: $noipDnsName is dead." >> $tmpPath/email.txt
        fi
        echo -e "Apache status:$apache"  >> $tmpPath/email.txt
        echo -e "Mariadb status:$mariadb" >> $tmpPath/email.txt
        echo -e "RAID status: $mdadmdetail" >> $tmpPath/email.txt
        echo >> $tmpPath/email.txt
        echo "####END OF SERVER STATUS REPORT####" >> $tmpPath/email.txt
       

        # Sending message to target recipient 
        mail -s "$lhost at $noipDnsName online" $recipient < $tmpPath/email.txt
        # Delete /$tmpPath/email.txt if file exist
        test -e $tmpPath/email.txt && rm $tmpPath/email.txt
        exit 0
    fi
done

