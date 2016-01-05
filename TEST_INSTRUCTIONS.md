#OnEarth Tests in Docker
-----

##Set up Docker and Packer 
In order to build the OnEarth Docker container, you need to be running Linux and have [Docker](http://docker.com) installed. A Docker package exists for CentOS 7 and can be installed via Yum.

Packer binaries are available at [http://packer.io](http://packer.io). You can unzip the excecutable files in the Linux Packer package to wherever you want.

##Build the Docker image with Packer
First, you'll need to make sure that the Docker service is running:
`sudo service docker start`.

Now, clone the OnEarth-Boxes repo and checkout the `test` branch.

Run the following command from the root of the repo to kick off the build process:

`sudo <path_to_packer>/packer build oe-docker.json`

By default, the build process will create a container using the 0.8.0 branch. To specify a different branch, use the `-var` parameter with the `packer build` command as follows:

`sudo <path_to_packer>/packer build -var "repo_branch=0.7.0" oe-docker.json`

Packer will then build the Docker image and check it into the local Docker repo. Note that this process will take a while, as GDAL needs to be compiled and sample MRFs generated.

To verify that the Packer install has worked, run:

`sudo docker images`

You should see `gibs/onearth` listed as one of the available images.

##Run the test script(s)
The test Python scripts are run by a shell script that will save the script's output into a logfile if the test exits with an error code. If the test is successful, no logfile will be created.

In order to see the script output, you'll want to share a directory on the host computer with the proper directory in the Docker container. Use this syntax:

```
sudo docker run -v <your_logfile_dir>:/home/onearth/resources/test_scripts/test_results gibs/onearth:<version_number> /home/onearth/resources/test_scripts/<test_filename>
```
Two tests are included:

- `test_mrfgen.sh`
- `test_layer_config.sh`

To run all tests, run:

- `run_all.sh`

The mrfgen test script will run inside a Docker container using the image you created earlier with Packer. If it fails, it will output stderr a logfile to the location you've specified.
