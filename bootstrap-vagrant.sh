#!/usrenv bash

#Install Apache and EPEL
yum -y install yum-utils
yum -y install epel-release
yum -y install httpd httpd-devel ccache rpmdevtools mock wget @buildsys-build

cd /home/vagrant

# Dependency not provided in CentOS6
yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm

# Download, install onearth stuff
wget https://github.com/nasa-gibs/onearth/releases/download/v1.3.1/onearth-1.3.1-9.el6.tar.gz
tar xfvz onearth-1.3.1-9.el6.tar.gz
yum install -y gibs-gdal*.rpm
yum install -y onearth*.rpm

cd ..
chown -R vagrant *
chgrp -R vagrant *

#Set LCDIR
echo "export LCDIR=/etc/onearth/config" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

#Set Apache to start when machine is restarted
chkconfig --level 234 httpd on

#Modify sudoers file to keep LCDIR in the sudo envvars
sed -i 's/.*LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY.*/&\nDefaults    env_keep += \"LCDIR\"/' /etc/sudoers

#Change default port in VM Apache to match what's it's going to be externally mapped to (for TWMS stuff)
sed -i "s/Listen 80/Listen $HOST_PORT/g" /etc/httpd/conf/httpd.conf

#Run OnEarth demos
/bin/sh /usr/share/onearth/demo/examples/default/configure_demo.sh
/bin/sh /usr/share/onearth/demo/examples/reproject/configure_demo.sh
