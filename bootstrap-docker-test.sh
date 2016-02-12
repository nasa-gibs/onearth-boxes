#!/bin/sh

# INSTALL BASE DEPENDENCIES
#Install Apache and EPEL
yum -y install epel-release httpd httpd-devel yum-utils rpmdevtools wget @buildsys-build tar
yum groupinstall -y 'Development Tools' 

# INSTALL AND CONFIGURE SOFTWARE TO BE TESTED
mkdir /home/onearth
cd /home/onearth
git clone https://github.com/nasa-gibs/mrf.git
cd mrf
git checkout $REPO_BRANCH
yum-builddep -y deploy/gibs-gdal/gibs-gdal.spec
make gdal-download gdal-rpm
yum -y install dist/gibs-gdal-1.11.*.el6.x86_64.rpm
yum -y install dist/gibs-gdal-devel-*.el6.x86_64.rpm 

cd /home/onearth
git clone $REPO_URL
cd onearth
git checkout $REPO_BRANCH
yum-builddep -y deploy/onearth/onearth.spec
make download onearth-rpm
yum -y remove numpy
yum -y install dist/onearth-*.el6.x86_64.rpm dist/onearth-config-*.el6.noarch.rpm dist/onearth-demo-*.el6.noarch.rpm dist/onearth-metrics-*.el6.noarch.rpm dist/onearth-mrfgen-*.el6.x86_64.rpm
# yum -y remove gibs-gdal-devel
ldconfig -v
#Set LCDIR
echo "export LCDIR=/etc/onearth/config" >> /home/onearth/.bashrc
#Set Apache to start when machine is restarted
chkconfig --level 234 httpd on
#Change default port in VM Apache to match what's it's going to be externally mapped to (for TWMS stuff)
sed -i "s/Listen 80/Listen $HOST_PORT/g" /etc/httpd/conf/httpd.conf
