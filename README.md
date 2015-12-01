NASA Global Imagery Browse Services (GIBS)
=======

This software is part of NASA GIBS OnEarth (https://github.com/nasa-gibs/onearth) and was developed at the Jet Propulsion Laboratory.

# OnEarth-Boxes
OnEarth-Boxes is a system that creates VM images for use in running, testing, and experimenting with the OnEarth and MRF tools. It uses [Packer](http://packer.io) to produce a variety of pre-built VMs in different formats.

Boxes comes with some sample imagery and some pre-configured endpoints for use with testing and development.

# What's in the Boxes?
OnEarth-Boxes comes pre-configured with NASA Blue Marble and MODIS Aerosol imagery layers, in 4 separate projections. There are OpenLayers endpoints for testing with WMTS, as well as TWMS/KML and Mapserver endpoints.

All the source code for both MRF and OnEarth is included, and all the utilities are pre-installed, including the GDAL MRF extensions.

To get started with OnEarth-Boxes once you've created a VM image and have it running, go to `<onearth-boxes_vm_url>/onearth/demo`.

# Requirements
Creation of an OnEarth-Boxes image requires [Packer](http://packer.io) to be installed on your computer.

# Creating an OnEarth VM
To create a VM, use the `packer build oe-demo.json` command. The included Packer configuration file creates VirtualBox, Vagrant, and VMWare images. Use the `-only` option if you only want to create one type of VM (or don't have VMWare installed on your system).

## Build Options
To specify options for the build process, use the `-var` tag, for example:

```packer build -var "host_port=8888" -var "repo_url=https://github.com/nasa-gibs/onearth.git" -var "repo_tag=v0.8.0" oe-demo.json```

### Available Options

`host_port` - in order for the OnEarth TWMS endpoint to work, Apache in the VM needs to be configured to use the same port within the VM as will be used on the host machine. **Defaults to 8080.**

In other words, if you're planning to access the VM under `localhost:8888`, it works best if Apache within the VM also uses that port. This option automatically configures Apache to use the specified port.

`repo_url` - Use this option to specify the repo Packer will clone to build OnEarth. Default is **[https://github.com/nasa-gibs/onearth.git](https://github.com/nasa-gibs/onearth.git)**.

`repo_tag` - Use this option to specify the version of OnEarth you want to install. This tag will be checked out before the build starts. Default is the latest OnEarth release. **Default is latest release (currently v0.8.0).**

**Note that using older versions of OnEarth may require tweaks to the `bootstrap.sh` script!**

## Builders
By default, the `oe-demo.json` file simultaneously builds:

- A VirtualBox image packaged as a Vagrant box
- A VMWare Image

To only create one kind of image, use the `-only` option to specify the specific builder you want. To create a VirtualBox image that isn't packaged for Vagrant, use the `"keep_input_artifact": true` option under the Vagrant provisioner section in `oe-demo.json`.

## Vagrant info
Using [Vagrant](https://www.vagrantup.com) is one of the easiest ways to get started with the OnEarth demo VM.

### Step 1: Install [Vagrant](https://www.vagrantup.com)
Vagrant is available for Mac, Windows, and Linux. It's free and requires [VirtualBox](https://www.virtualbox.org/).

### Step 2: Build the Vagrant box with Packer
Run the default Packer command: `packer build -only=virtualbox-iso oe-demo.json` within the root of this repo. See above for options to customize the install.

**Note that the build process compiles a lot of software and generates some MRF imagery, so it can take quite a while.**

### Step 3: Add the Vagrant box
After the Packer build process is complete, go to the `builds` directory and add the box with this command:
`vagrant box add --name=onearth-demo packer-centos-6.6-x86_64`

**Once the Vagrant box is added, you can create multiple new virtual machines using that box as a base. It's not necessary to rebuild with Packer each time.**

### Step 4: Create a Vagrantfile
From any directory you like, type the command `vagrant init`, which will set up a sample `Vagrantfile`. Open the Vagrantfile and make sure the following lines are present:

```config.vm.box = "oe-demo"```

```config.vm.network "forwarded_port", guest: <chosen_port>, host: <chosen_port>```

### Step 5: Start the VM
Use the `vagrant up` command to boot the VM. The demo should now be available at: `localhost:<chosen_port>/onearth/demo`

You can use the `vagrant ssh` command to open a shell inside the VM. The directory that contains your `Vagrantfile` is mapped to `/vagrant` within the VM by default.
