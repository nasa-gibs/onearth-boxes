NASA Global Imagery Browse Services (GIBS)
=======

This software is part of NASA GIBS OnEarth (https://github.com/nasa-gibs/onearth) and was developed at the Jet Propulsion Laboratory.

OnEarth-Boxes
================
This software package sets up a OnEarth server within a Vagrant virtual machine, complete with sample imagery, pre-configured endpoints, and OpenLayers demonstration pages.

Versioning
========

OnEarth-Boxes releases coincide with corresponding versions of OnEarth. The 'master' branch of the repo will always contain the same version of OnEarth as the latest release.

To download an OnEarth-Box that uses a previous version of OnEarth, choose that version of the OnEarth-Boxes release at [https://github.com/nasa-gibs/onearth-boxes/releases](https://github.com/nasa-gibs/onearth-boxes/releases).

Each new release is tagged with the corresponding OnEarth version, so you can also switch version tags if you choose to clone the repo instead.

Requirements
=======
The current version requires [Vagrant](https://www.vagrantup.com/) to be installed.

Setup
======
Run `vagrant up` in the root directory of this repo. A new Vagrant VM will be automatically generated. It can take a while for all the necessary software to be set up and sample images processed.

Once it's set up, the OnEarth Apache server should be available on port 8080 of localhost. Please refer to the Vagrant documentation for information on how to map local ports to Vagrant VMs.

To change the default HTTP port of the OnEarth Box, edit the Vagrantfile.

How To Use
====
Visit [http://localhost:8080/onearth/demo](http://localhost:8080/onearth/demo) (or wherever you have the VM configured) to get started.

The VM is configured with an OpenLayers viewer for each endpoint. The list of layers that appears when you click "Choose Layer" is created from the getCapabilities file, so it should update with any new layers you add at that endpoint.

Endpoint syntax is: http://localhost:8080/onearth/demo/*service*/*projection*/

Example: [http://localhost:8080/onearth/demo/wmts/geo/](http://localhost:8080/onearth/demo/wmts/geo/)

Sample Tile Request: [http://localhost:8080/onearth/demo/wmts/geo/wmts.cgi?layer=blue_marble&tilematrixset=EPSG4326_1km&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix=2&TileCol=1&TileRow=1
](http://localhost:8080/onearth/demo/wmts/geo/wmts.cgi?layer=blue_marble&tilematrixset=EPSG4326_1km&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix=2&TileCol=1&TileRow=1
)

Add Your Own Imagery
=====
This VM also includes the tools you'll need to generate your own MRFs and configure new layers in the OnEarth server.

To open a command prompt inside the VM, use `vagrant ssh` in the root directory of this repo. Inside, you'll find the OnEarth tools installed and ready to use.

The sample imagery, MRF config files, generated MRFs, and layer config files bundled with this package are all contained in the root directory of this repo which is also available under the `/vagrant` folder inside the VM.

Please note that you'll need 'sudo' to make changes to files in the `/usr/share/onearth/` and `/etc/onearth/` directories. The default vagrant login has sudo privileges, and the default sudo password is "vagrant".

How the OnEarth Files are Organized
=====
OnEarth-boxes stores configuration and MRF files in the following locations in the VM:

- `/etc/onearth/config` -- All OnEarth configuration files, including environment configs, layer configs, and mapfile templates. This is set as $LCDIR on the VM.
- `/usr/share/onearth/demo/data` -- Cache files and archives sorted by projection.
- `/usr/share/onearth/demo/wmts-geo, etc.` -- All endpoint HTML and JavaScript files.
-  `/etc/httpd/conf.d/on_earth-demo.conf` -- Apache configuration file for OnEarth.

As part of its setup, OnEarth-Boxes creates some MRF files from source imagery. You can see the MRF config files, as well as the source imagery and generated MRFs, in the same directory as the Vagrantfile or at /vagrant/generated_mrfs within the VM.
