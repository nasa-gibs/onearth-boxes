onearth-boxes
================
This software package sets up a OnEarth server within a Vagrant virtual machine, complete with sample imagery, pre-configured endpoints, and OpenLayers demonstration pages.

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
Visit http://localhost:8080 (or wherever you have the VM configured) to get started.

Endpoint syntax is: http://localhost:8080/onearth/demo/*service*/*projection*/

Example: [http://localhost:8080/onearth/demo/wmts/geo/](http://localhost:8080/onearth/demo/wmts/geo/)

Sample Tile Request: [http://localhost:8080/onearth/demo/wmts/webmerc/

Add Your Own Imagery
=====
This VM also includes the tools you'll need to generate your own MRFs and configure new layers in the OnEarth server.

To open a command prompt inside the VM, use `vagrant ssh` in the root directory of this repo. Inside, you'll find the OnEarth tools installed and ready to use.

The sample imagery, MRF config files, generated MRFs, and layer config files bundled with this package are all contained in the root directory of this repo which is also available under the `/vagrant` folder inside the VM.

Please note that you'll need 'sudo' to make changes to files in the `/usr/share/onearth/` and `/etc/onearth/` directories. The default vagrant login has sudo privileges, and the default sudo password is "vagrant".
