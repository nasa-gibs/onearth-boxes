onearth-boxes
================
This software package sets up a OnEarth server within a Vagrant virtual machine, complete with sample imagery, pre-configured endpoints, and OpenLayers demonstrations.

Requirements
=======
The current version requires [Vagrant](https://www.vagrantup.com/) to be installed.

Setup
======
Run `vagrant up` in the root directory of this repo. A new Vagrant VM will be automatically generated. It might take a while for the software to download all the required software and generate demo imagery.

Once it's set up, the OnEarth Apache server should be available on port 8080 of localhost. Please refer to the Vagrant documentation for information on how to map local ports to Vagrant VMs.

To change the default HTTP port of the OnEarth Box, edit the Vagrantfile.

How To Use
====
Visit http://localhost:8080 (or wherever you have the VM configured) to get started.

Endpoint syntax is: http://localhost:8080/onearth/demo/*service*/*projection*/

Example: [http://localhost:8080/onearth/demo/wmts/geo/](http://localhost:8080/onearth/demo/wmts/geo/)
