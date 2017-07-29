#!/bin/sh -x

#Install Apache and EPEL
yum -y install yum-utils
yum -y install epel-release
yum -y install httpd httpd-devel rpmdevtools wget @buildsys-build tar
yum groupinstall -y 'Development Tools'

#Clone user-selected git repo and build RPMS from source
cd /home/onearth
git clone $REPO_URL
cd onearth
git checkout $REPO_BRANCH

export MRF_VERSION="$(awk '/MRF Version/ {print $NF}' /home/onearth/onearth/src/test/config.txt)"

cd /home/onearth
git clone https://github.com/nasa-gibs/mrf.git
cd mrf
git checkout $MRF_VERSION

yum-builddep -y deploy/gibs-gdal/gibs-gdal.spec
make download gdal-rpm
yum -y install dist/gibs-gdal-*.rpm

cd /home/onearth/onearth
yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum-builddep -y deploy/onearth/onearth.spec
make download onearth-rpm

ldconfig -v
yum -y install dist/onearth*.rpm

#Set LCDIR
mkdir /home/onearth
echo "export LCDIR=/etc/onearth/config" >> /home/onearth/.bashrc

#Set Apache to start when machine is restarted
chkconfig --level 234 httpd on

#Change default port in VM Apache to match what's it's going to be externally mapped to (for TWMS stuff)
sed -i "s/Listen 80/Listen $HOST_PORT/g" /etc/httpd/conf/httpd.conf

#Run OnEarth demos
/bin/sh /usr/share/onearth/demo/examples/default/configure_demo.sh
/bin/sh /usr/share/onearth/demo/examples/reproject/configure_demo.sh