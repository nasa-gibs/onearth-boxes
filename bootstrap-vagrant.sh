#!/usrenv bash

#Projections and their EPSG equivalents
declare -a PROJECTIONS=(geo webmerc arctic antarctic)
declare -a PROJEPSGS=(EPSG4326 EPSG3857 EPSG3413 EPSG3031)

#Install Apache and EPEL
yum -y install yum-utils
yum -y install epel-release
yum -y install httpd httpd-devel ccache rpmdevtools mock wget @buildsys-build

cd /home/vagrant

# Dependency not provided in CentOS6
yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm

# Download, install onearth stuff
wget https://github.com/nasa-gibs/onearth/releases/download/v1.2.1/onearth-1.2.1.tar.gz
tar xfvz onearth-1.2.1.tar.gz
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

#Replace OnEarth Apache config file with the one that's included in this package
/bin/cp /home/vagrant/resources/on_earth-demo.conf /etc/httpd/conf.d/on_earth-demo.conf

#Change default port in VM Apache to match what's it's going to be externally mapped to (for TWMS stuff)
sed -i "s/Listen 80/Listen $HOST_PORT/g" /etc/httpd/conf/httpd.conf

#Set up WTMS/TWMS OpenLayers demo endpoints for all 4 projections we're using
mkdir -p /usr/share/onearth/demo/lib
/bin/cp -R /home/vagrant/resources/endpoint_configs/html_lib/* /usr/share/onearth/demo/lib/

#Download image files
curl -# -o /home/vagrant/resources/source_images/blue_marble.jpg http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776/world.topo.bathy.200408.3x21600x10800.jpg

#Set up endpoint configs
for PROJECTION in "${PROJECTIONS[@]}"
do
	 mkdir /usr/share/onearth/demo/wmts-$PROJECTION/
	 /bin/cp /usr/share/onearth/demo/wmts-geo/{wmts.cgi,black.jpg,transparent.png} /usr/share/onearth/demo/wmts-$PROJECTION/
	 /bin/cp /home/vagrant/resources/endpoint_configs/wmts-$PROJECTION/{*.js,*.html} /usr/share/onearth/demo/wmts-$PROJECTION/
	 mkdir -p /usr/share/onearth/demo/twms-$PROJECTION/.lib
	 ln -s /home/vagrant/onearth/src/cgi/twms.cgi /usr/share/onearth/demo/twms-$PROJECTION/
done
/bin/cp /home/vagrant/resources/endpoint_configs/index.html /usr/share/onearth/demo

#Create MRF directories and copy source/empty tile images and config XML files, then create MRF, copy images to archive, copy MRF to header dir
#and copy layer config

#Blue marble - geographic and webmercator (using same source image)
	declare -a MARBLE_PROJECTIONS=(geo webmerc)
	for INDEX in {0..1}
	do 
		#Copy image files and set up MRF process dirs
		mkdir -p /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
		/bin/cp /home/vagrant/resources/source_images/blue_marble.* /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/source_images/
		/bin/cp /home/vagrant/resources/mrf_configs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}_config.xml /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/
		/bin/cp /usr/share/onearth/demo/wmts-geo/black.jpg /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/empty_tiles/
		cd /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/

		mrfgen -c /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}_config.xml

		#Create data archive directories and copy MRF files
		 mkdir -p /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/blue_marble/
		for f in /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/*; do mv "$f" "${f//blue_marble2004336_/blue_marble}"; done
		 /bin/cp /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/* /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/blue_marble/
		 /bin/cp /home/vagrant/resources/generated_mrfs/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}/output_dir/blue_marble.mrf /etc/onearth/config/headers/blue_marble_${MARBLE_PROJECTIONS[$INDEX]}.mrf
	done

#MODIS data - right now, we're only using it in geo projection 
declare -a MODIS_PROJECTIONS=(geo)
for INDEX in {0..0}
do
	#Copy image files and set up MRF process dirs
	mkdir -p /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
	/bin/cp /home/vagrant/resources/source_images/MYR4ODLOLLDY_global_2014277_10km.* /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/source_images/
	/bin/cp /home/vagrant/resources/mrf_configs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}_config.xml /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/
	/bin/cp /usr/share/onearth/demo/wmts-geo/transparent.png /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/empty_tiles/
	cd /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/

	mrfgen -c /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}_config.xml
 
	#Create data archive directories and copy MRF files
	mkdir -p /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/MYR4ODLOLLDY_global_10km/{2014,YYYY}
	/bin/cp /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/output_dir/MYR4ODLOLLDY2014277_.* /usr/share/onearth/demo/data/${PROJEPSGS[$INDEX]}/MYR4ODLOLLDY_global_10km/2014/
	find /usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/2014 -name 'MYR4ODLOLLDY2014277*' -type f -exec bash -c 'ln -s "$1" "${1/2014277/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/2014 -name 'MYR4ODLOLLDYTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG4326/MYR4ODLOLLDY_global_10km/YYYY/"' -- {} \;
	/bin/cp /home/vagrant/resources/generated_mrfs/MYR4ODLOLLDY_global_2014277_10km_${MODIS_PROJECTIONS[$INDEX]}/output_dir/MYR4ODLOLLDY2014277_.mrf /etc/onearth/config/headers/MYR4ODLOLLDY_${MODIS_PROJECTIONS[$INDEX]}.mrf
done

#MODIS_C5_fires
	#Copy image files and set up MRF process dirs
	mkdir -p /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
	/bin/cp /home/vagrant/resources/source_images/MODIS_C5_fires_2016110.* /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/source_images/
	/bin/cp /home/vagrant/resources/vector_configs/MODIS_C5_fires*.xml /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/
	cd /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/
	# For Shapefile
	oe_vectorgen -c /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/MODIS_C5_fires.xml
	#Create data archive directories and copy MRF files
	mkdir -p /usr/share/onearth/demo/data/shapefiles/MODIS_C5_fires/{2016,YYYY}
	/bin/cp /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/output_dir/* /usr/share/onearth/demo/data/shapefiles/MODIS_C5_fires/2016/
	find /usr/share/onearth/demo/data/shapefiles/MODIS_C5_fires/2016/ -name 'MODIS_C5_fires2016110*' -type f -exec bash -c 'ln -s "$1" "${1/2016110/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/shapefiles/MODIS_C5_fires/2016/ -name 'MODIS_C5_firesTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/shapefiles/MODIS_C5_fires/YYYY/"' -- {} \;
	# For MVT MRF
	oe_vectorgen -c /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/MODIS_C5_fires_vt.xml
	#Create data archive directories and copy MRF files
	mkdir -p /usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/{2016,YYYY}
	/bin/cp /home/vagrant/resources/generated_mrfs/MODIS_C5_fires/output_dir/* /usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/2016
	find /usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/2016/ -name 'MODIS_C5_fires2016110*' -type f -exec bash -c 'ln -s "$1" "${1/2016110/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/2016/ -name 'MODIS_C5_firesTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/YYYY/"' -- {} \;
	/bin/cp /usr/share/onearth/demo/data/EPSG3857/MODIS_C5_fires/2016/MODIS_C5_fires2016110_.mrf /etc/onearth/config/headers/MODIS_C5_firesTTTTTTT_.mrf

#Terra_Orbit_Dsc_Dots
	#Copy image files and set up MRF process dirs
	mkdir -p /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/{source_images,working_dir,logfile_dir,output_dir,empty_tiles}
	/bin/cp /home/vagrant/resources/source_images/terra_2016-03-04_epsg4326_points_descending.* /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/source_images/
	/bin/cp /home/vagrant/resources/vector_configs/Terra_Orbit_Dsc_Dots*.xml /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/
	cd /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/
	# For Shapefile
	oe_vectorgen -c /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/Terra_Orbit_Dsc_Dots.xml
	#Create data archive directories and copy MRF files
	mkdir -p /usr/share/onearth/demo/data/shapefiles/Terra_Orbit_Dsc_Dots/{2016,YYYY}
	/bin/cp /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/output_dir/* /usr/share/onearth/demo/data/shapefiles/Terra_Orbit_Dsc_Dots/2016/
	find /usr/share/onearth/demo/data/shapefiles/Terra_Orbit_Dsc_Dots/2016/ -name 'Terra_Orbit_Dsc_Dots2016064*' -type f -exec bash -c 'ln -s "$1" "${1/2016064/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/shapefiles/Terra_Orbit_Dsc_Dots/2016/ -name 'Terra_Orbit_Dsc_DotsTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/shapefiles/Terra_Orbit_Dsc_Dots/YYYY/"' -- {} \;
	# For MVT MRF
	oe_vectorgen -c /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/Terra_Orbit_Dsc_Dots_vt.xml
	#Create data archive directories and copy MRF files
	mkdir -p /usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/{2016,YYYY}
	/bin/cp /home/vagrant/resources/generated_mrfs/Terra_Orbit_Dsc_Dots/output_dir/* /usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/2016
	find /usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/2016/ -name 'Terra_Orbit_Dsc_Dots2016064*' -type f -exec bash -c 'ln -s "$1" "${1/2016064/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/2016/ -name 'Terra_Orbit_Dsc_DotsTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/YYYY/"' -- {} \;
	/bin/cp /usr/share/onearth/demo/data/EPSG3857/Terra_Orbit_Dsc_Dots/2016/Terra_Orbit_Dsc_Dots2016064_.mrf /etc/onearth/config/headers/Terra_Orbit_Dsc_DotsTTTTTTT_.mrf

#Set up and copy the pre-made MRFs
declare -a MRF_PROJS=(arctic antarctic)
declare -a MRF_EPSGS=(EPSG3413 EPSG3031)
for INDEX in {0..1}
do
	 mkdir -p /usr/share/onearth/demo/data/${MRF_EPSGS[$INDEX]}/blue_marble
	 /bin/cp /home/vagrant/resources/mrfs/blue_marble_${MRF_PROJS[$INDEX]}/* /usr/share/onearth/demo/data/${MRF_EPSGS[$INDEX]}/blue_marble/
	 /bin/cp /home/vagrant/resources/mrfs/blue_marble_${MRF_PROJS[$INDEX]}/blue_marble.mrf /etc/onearth/config/headers/blue_marble_${MRF_PROJS[$INDEX]}.mrf
done

#ASCAT-L2-25km
	mkdir -p /usr/share/onearth/demo/data/EPSG3857/ASCATA-L2-25km/{2016,YYYY}
	/bin/cp /home/vagrant/resources/mrfs/ASCATA-L2-25km/ASCATA-L2-25km2016188010000_.* /usr/share/onearth/demo/data/EPSG3857/ASCATA-L2-25km/2016/
	find /usr/share/onearth/demo/data/EPSG3857/ASCATA-L2-25km/2016 -name 'ASCATA-L2-25km2016188010000*' -type f -exec bash -c 'ln -s "$1" "${1/2016188010000/TTTTTTTTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/EPSG3857/ASCATA-L2-25km/2016 -name 'ASCATA-L2-25kmTTTTTTTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG4326/ASCATA-L2-25km/YYYY/"' -- {} \;
	/bin/cp /usr/share/onearth/demo/data/EPSG3857/ASCATA-L2-25km/2016/ASCATA-L2-25km2016188010000_.mrf /etc/onearth/config/headers/ASCATA-L2-25kmTTTTTTTTTTTTT_.mrf

#OSCAR
	mkdir -p /usr/share/onearth/demo/data/EPSG3857/oscar/{2016,YYYY}
	/bin/cp /home/vagrant/resources/mrfs/oscar/oscar2016189_.* /usr/share/onearth/demo/data/EPSG3857/oscar/2016/
	find /usr/share/onearth/demo/data/EPSG3857/oscar/2016 -name 'oscar2016189*' -type f -exec bash -c 'ln -s "$1" "${1/2016189/TTTTTTT}"' -- {} \;
	find /usr/share/onearth/demo/data/EPSG3857/oscar/2016 -name 'oscarTTTTTTT*' -type l -exec bash -c 'mv "$1" "/usr/share/onearth/demo/data/EPSG4326/oscar/YYYY/"' -- {} \;
	/bin/cp /usr/share/onearth/demo/data/EPSG3857/oscar/2016/oscar2016189_.mrf /etc/onearth/config/headers/oscarTTTTTTT_.mrf

#Install and copy the Mapserver config files and endpoints
mkdir -p /etc/onearth/config/styles
/bin/cp /home/vagrant/resources/styles/* /etc/onearth/config/styles
mkdir -p /usr/share/onearth/demo/mapserver
chmod +x /usr/share/onearth/demo/mapserver_config/wms.cgi
/bin/cp /home/vagrant/resources/mapserver_config/* /usr/share/onearth/demo/mapserver

mkdir -p /usr/share/onearth/demo/wms
mkdir -p /usr/share/onearth/demo/wfs
mkdir -p /usr/share/onearth/demo/wms/epsg4326
mkdir -p /usr/share/onearth/demo/wfs/epsg4326
mkdir -p /usr/share/onearth/demo/wms/epsg3857
mkdir -p /usr/share/onearth/demo/wfs/epsg3857
mkdir -p /usr/share/onearth/demo/wms/epsg3031
mkdir -p /usr/share/onearth/demo/wfs/epsg3031
mkdir -p /usr/share/onearth/demo/wms/epsg3413
mkdir -p /usr/share/onearth/demo/wfs/epsg3413
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wms/epsg4326
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wms/epsg3857
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wms/epsg3031
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wms/epsg3413
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wfs/epsg4326/wfs.cgi
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wfs/epsg3857/wfs.cgi
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wfs/epsg3031/wfs.cgi
/bin/cp /home/vagrant/resources/mapserver_config/wms.cgi /usr/share/onearth/demo/wfs/epsg3413/wfs.cgi

#Compile the KML script and copy to TWMS dirs
cd /home/vagrant/onearth/src/cgi/kml
for PROJECTION in "${PROJECTIONS[@]}"
do
	 make WEB_HOST=localhost:$HOST_PORT/onearth/demo/twms/$PROJECTION
	 /bin/cp kmlgen.cgi /usr/share/onearth/demo/twms-$PROJECTION
	 rm -f kmlgen.cgi
done

#Copy layer config files, run config tool
/bin/cp /home/vagrant/resources/layer_configs/* /etc/onearth/config/layers/
LCDIR=/etc/onearth/config oe_configure_layer --create_mapfile --layer_dir=/etc/onearth/config/layers/

#Have to deactivate the demo stuff bundled with OnEarth for the time being
mv /etc/httpd/conf.d/onearth-demo.conf /etc/httpd/conf.d/onearth-demo.conf.example
