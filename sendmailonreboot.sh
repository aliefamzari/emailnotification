#!/bin/bash
#On the event of init 6, email will be send to notify the reboot event
sleep 60
# Global variables
noipDnsName="fiftysixflex.ddns.net"
ip=`hostname -I`
lhost=`hostname -f`
recipient="aliefamzari@gmail.com"
tmpPath="/tmp"
publicIP=`nslookup $noipDnsName |grep 'Address' |grep -v 192 |awk '{print $2}'`
uptimeSince=`uptime -s`
currentDate=`date +"%Y-%m-%d %H:%M:%S"`

# Services detail
apache=$(systemctl status apache2 |grep Active)
mariadb=$(systemctl status mariadb |grep Active)
mdadmdetail=$(sudo mdadm --detail /dev/md0)

# Populating information into email.txt 
echo "Server status report: Reason 'Unexpected REBOOT'" > $tmpPath/email.txt
echo "Localhost: $lhost" >> $tmpPath/email.txt
echo "Current Date: $currentDate" >> $tmpPath/email.txt
echo "Uptime Since: $uptimeSince" >> $tmpPath/email.txt
echo "Local IP: $ip" >> $tmpPath/email.txt
if ping -c 1 -W 1 "$noipDnsName" > /dev/null ; then
	echo -e "DNS status: $noipDnsName is alive." >> $tmpPath/email.txt
	echo -e "Public IP: $publicIP" >> $tmpPath/email.txt
	else
	echo -e "DNS Status: $noipDnsName is dead." >> $tmpPath/email.txt
fi
echo -e "Apache status:$apache"  >> $tmpPath/email.txt
echo -e "Mariadb status:$mariadb" >> $tmpPath/email.txt
echo -e "RAID status: $mdadmdetail" >> $tmpPath/email.txt
echo >> $tmpPath/email.txt
echo "####END OF SERVER STATUS REPORT####" >> $tmpPath/email.txt
# Finished populating information

# Sending message to target recipient 
mail -s "$lhost at $noipDnsName online" $recipient < $tmpPath/email.txt

#Delete /$tmpPath/email.txt if file exist
test -e $tmpPath/email.txt && rm -rf $tmpPath/email.txt