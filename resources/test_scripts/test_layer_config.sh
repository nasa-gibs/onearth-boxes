#!/bin/sh

cp -R /home/onearth/gibs-onearth-test-area/src/layer_config/test /etc/onearth/config/test
cd /etc/onearth/config/test

mkdir -p /usr/share/onearth/demo/data/EPSG4326/MODIS_Aqua_Aerosol/2014
mkdir -p /usr/share/onearth/demo/colormaps

cp MODIS_Aqua_Aerosol2014364_.mrf /usr/share/onearth/demo/data/EPSG4326/MODIS_Aqua_Aerosol/2014 
cp MODIS_Aqua_Aerosol-GIBS.xml /usr/share/onearth/demo/colormaps/MODIS_Aqua_Aerosol-GIBS.xml

# Run test and pipe output to temp file
./test_configure_layer.py >> /home/onearth/resources/test_scripts/test_results/layer_config_error_log 3>&1 1>&2 2>&3

if [ "$?" != "0" ]
then
	echo "Test didn't pass! Check layer_config_error_log for details."
else
	echo "Test passed!"
	rm /home/onearth/resources/test_scripts/test_results/layer_config_error_log
fi

# Cleanup
rm -rf /etc/onearth/config/test
