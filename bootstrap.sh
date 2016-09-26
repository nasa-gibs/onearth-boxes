#!/usrenv bash

#Projections and their EPSG equivalents
declare -a PROJECTIONS=(geo webmerc arctic antarctic)
declare -a PROJEPSGS=(EPSG4326 EPSG3857 EPSG3413 EPSG3031)

#Install Apache and EPEL
yum -y install epel-release httpd httpd-devel yum-utils ccache rpmdevtools mock wget @buildsys-build
yum -y groupinstall "Development Tools"
#Clone user-selected git repo and build RPMS from source
cd /home/onearth
git clone $REPO_URL
cd onearth
git checkout $REPO_BRANCH

#Get the version of MRF that we're using to build
export MRF_VERSION="$(awk '/MRF Version/ {print $NF}' /home/onearth/onearth/src/test/config.txt)"

cd /home/onearth
git clone https://github.com/nasa-gibs/mrf.git
cd mrf
git checkout $MRF_VERSION

yum-builddep -y deploy/gibs-gdal/gibs-gdal.spec
make gdal-download numpy-download gdal-rpm
yum -y remove numpy
yum -y install dist/gibs-gdal-1.11.*.el6.x86_64.rpm
yum -y install dist/gibs-gdal-devel-*.el6.x86_64.rpm 

cd ../onearth
yum-builddep -y deploy/onearth/onearth.spec
source /home/onearth/.bashrc
make download onearth-rpm

ldconfig -v
yum -y install dist/onearth-*.el6.x86_64.rpm dist/onearth-config-*.el6.noarch.rpm dist/onearth-demo-*.el6.noarch.rpm dist/onearth-metrics-*.el6.noarch.rpm dist/onearth-mrfgen-*.el6.x86_64.rpm

cd ../
chown -R onearth *
chgrp -R onearth *

#Set LCDIR
echo "export LCDIR=/etc/onearth/config" >> /home/onearth/.bashrc
source /home/onearth/.bashrc

#Set Apache to start when machine is restarted
chkconfig --level 234 httpd on

#Modify sudoers file to keep LCDIR in the sudo envvars
sed -i 's/.*LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY.*/&\nDefaults    env_keep += \"LCDIR\"/' /etc/sudoers

#Replace OnEarth Apache config file with the one that's included in this package
/bin/cp /home/onearth/resources/on_earth-demo.conf /etc/httpd/conf.d/on_earth-demo.conf

#Change default port in VM Apache to match what's it's going to be externally mapped to (for TWMS stuff)
sed -i "s/Listen 80/Listen $HOST_PORT/g" /etc/httpd/conf/httpd.conf

#Set up WTMS/TWMS OpenLayers demo endpoints for all 4 projections we're using
mkdir -p /usr/share/onearth/demo/lib
/bin/cp -R /home/onearth/resources/endpoint_configs/html_lib/* /usr/share/onearth/demo/lib/

#Download image files
curl -# -o /home/onearth/resources/source_images/blue_marble.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776/world.topo.bathy.200408.3x21600x10800.jpg

#Set up endpoint configs
for PROJECTION in "${PROJECTIONS[@]}"
do
	 mkdir /usr/share/onearth/demo/wmts-$PROJECTION/
	 /bin/cp /usr/share/onearth/apache/{wmts.cgi,black.jpg,transparent.png} /usr/share/onearth/demo/wmts-$PROJECTION/
	 /bin/cp /home/onearth/resources/endpoint_configs/wmts-$PROJECTION/{*.js,*.html} /usr/share/onearth/demo/wmts-$PROJECTION/
	 mkdir -p /usr/share/onearth/demo/twms-$PROJECTION/.lib
	 ln -s /usr/share/onearth/apache/* /usr/share/onearth/demo/twms-$PROJECTION/
done
/bin/cp /home/onearth/resources/endpoint_configs/index.html /usr/share/onearth/demo

#Create MRF directories and copy source/empty tile images and config XML files, then create MRF, copy images to archive, copy MRF to header dir
#and copy layer config

#Blue marble - geographic and webmercator (using same source image)
declare -a MARBLE_PROJECTIONS=(geo webmerc)
for INDEX in {0..1}
do 
	#Copy image files and set up MRF process dirs
	mkdir -p /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
	/bin/cp /home/onearth/resources/source_images/blue_marble.* /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/source_images/
	/bin/cp /home/onearth/resources/mrf_configs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}_config.xml /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/
	/bin/cp /usr/share/onearth/apache/black.jpg /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/empty_tiles/
	cd /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/

	mrfgen -c /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}_config.xml

	#Create data archive directories and copy MRF files
	 mkdir -p /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/blue_marble/
	for f in /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/*; do mv "$f" "${f//blue_marble2004336_/blue_marble}"; done
	 /bin/cp /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/* /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/blue_marble/
	 /bin/cp /home/onearth/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/blue_marble.mrf /etc/onearth/config/headers/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}.mrf
done

#MODIS data - right now, we're only using it in geo projection 
declare -a MODIS_PROJECTIONS=(geo)
for INDEX in {0..0}
do
	#Copy image files and set up MRF process dirs
	mkdir -p /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
	/bin/cp /home/onearth/resources/source_images/MYR4ODLOLLDY_global_2014277_10km.* /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/source_images/
	/bin/cp /home/onearth/resources/mrf_configs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}_config.xml /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/
	/bin/cp /usr/share/onearth/apache/transparent.png /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/empty_tiles/
	cd /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/

	mrfgen -c /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}_config.xml
 
	#Create data archive directories and copy MRF files
	 mkdir -p /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/MYR4ODLOLLDY_global_10km/{2014,YYYY}
	 /bin/cp /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/output_dir/MYR4ODLOLLDY2014277_.* /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/MYR4ODLOLLDY_global_10km/2014/
	 find /usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/2014 -name 'MYR4ODLOLLDY2014277*' -type f -exec bash -c 'ln -s "$1" "${1/2014277/TTTTTTT}"' -- {} \;
	 find /usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/2014 -name 'MYR4ODLOLLDYTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/YYYY/"' -- {} \;
	 /bin/cp /home/onearth/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/output_dir/MYR4ODLOLLDY2014277_.mrf /etc/onearth/config/headers/MYR4ODLOLLDY_${MODIS_PROJECTIONS[$INDEX]}.mrf
done

#Set up and copy the pre-made MRFs
declare -a MRF_PROJS=(arctic antarctic)
declare -a MRF_EPSGS=(EPSG3413 EPSG3031)
for INDEX in {0..1}
do
	 mkdir -p /usr/share/onearth/demo/data/${MRF_EPSGS[$INDEX]}/blue_marble
	 /bin/cp /home/onearth/resources/mrfs/blue_marble_${MRF_PROJS[$INDEX]}/* /usr/share/onearth/demo/data/${MRF_EPSGS[$INDEX]}/blue_marble/
	 /bin/cp /home/onearth/resources/mrfs/blue_marble_${MRF_PROJS[$INDEX]}/blue_marble.mrf /etc/onearth/config/headers/blue_marble_${MRF_PROJS[$INDEX]}.mrf
done

#Install and copy the Mapserver config files and endpoints
yum -y install proj-epsg mapserver
mkdir -p /usr/share/onearth/demo/mapserver
/bin/cp /home/onearth/resources/mapserver_config/* /usr/share/onearth/demo/mapserver
ln -s /usr/libexec/mapserver /usr/share/onearth/demo/mapserver/mapserver.cgi

#Compile the KML script and copy to TWMS dirs
cd /usr/share/onearth/apache/kml
for PROJECTION in "${PROJECTIONS[@]}"
do
	 make WEB_HOST=localhost:$HOST_PORT/onearth/demo/twms/$PROJECTION
	 /bin/cp kmlgen.cgi /usr/share/onearth/demo/twms-$PROJECTION
	 rm -f kmlgen.cgi
done

#Copy layer config files, run config tool
/bin/cp /home/onearth/resources/layer_configs/* /etc/onearth/config/layers/
LCDIR=/etc/onearth/config oe_configure_layer --create_mapfile --layer_dir=/etc/onearth/config/layers/