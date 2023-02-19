#!/bin/bash
yum -y update
yum -y install httpd
ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>IP: $ip</h1>TF server" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on