#!/bin/bash

LOG=/tmp/chef.log
rm -f $LOG
## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
#source /root/scripts/common-functions.sh
source /tmp/common-functions.sh

## Checking Root User or not.
CheckRoot

yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &>/dev/null
yum makecache fast &>>$LOG
yum install html2text -y &>>$LOG
Split $LOG
RPM=$(curl -s https://downloads.chef.io/chef-server/ | html2text | grep el7.x86_64.rpm$ | awk '{print $NF}')
yum install $RPM -y &>>$LOG
Stat $? "Installing Chef Server" 
chef-server-ctl reconfigure &>>$LOG
Stat $? "Configuring CHEF"
chef-server-ctl install chef-manage &>>$LOG 
Stat $? "Installing Chef Dashboard"
chef-server-ctl reconfigure --accept-license &>>$LOG
Stat $? "Configuring Chef Dashboard"
chef-manage-ctl reconfigure --accept-license &>>$LOG
Stat $? "Finalyzing Chef Dashboard"
chef-server-ctl user-create admin Admin User admin@locahost.local 'PASSWORD' --filename /opt/admin.pem
Stat $? "Created ADMIN User"
chef-server-ctl org-create sample 'Sample Org Pvt LTD' --association_user admin --filename /opt/sample.pem
Stat $? "Created SAMPLE Organization"

hint "You can hit the URL :: http://$(curl ifconfig.co)  and with Username/Password as admin/PASSWORD"
