# Slam Dunk [Work in Progress!!]

This is an attempt of creating a guide/script that will show you how to create the environemnt for both orb slam python bindings, but osmap as well.
This relies heavilly on a script found here:

https://gist.github.com/ducha-aiki/2c29cdfd47fa4fe65f1ca083d8f09ef2

Also, Im using my own forks of 

https://github.com/mmajewsk/ORB_SLAM2
https://github.com/mmajewsk/osmap
https://github.com/mmajewsk/ORB_SLAM2-PythonBindings


## ORB_SLAM2

https://github.com/mmajewsk/ORB_SLAM2
This fork does not contain many changes.

## Osmap

https://github.com/mmajewsk/osmap
This fork contains some crutial changes that allow this to work in python.

## ORB_SLAM2-PythonBindings

https://github.com/mmajewsk/ORB_SLAM2-PythonBindings
It contains a lot of work, the the code right now is ugly, and needs to be refactored a bit.
Bit still, the core functionalities of Osmaps save and load are working.
There is some problem in explicit call for `mapLoad` that i did not manage to solve, but `tum_example` does both of those things, and allows to use slam system via shared pointer.


# Installation

All of the installation process is pure hack.
Improvements are welcomed.

So far the `install_18.04.sh` seems to be working, but it hasn't been tested properly.
The `Dockerfile-18.04` is tested, and pushed to Docker hub

## Dockerfile

This is easy, just build the image or pull it from dockerhub:
```
docker pull mwmajewsk/tonic_slam_dunk:working
```

Refer to this guide how to run gui with docker https://www.geeksforgeeks.org/running-gui-applications-on-docker-in-linux/



## Ubuntu install script

First of all you need to install some dependencies:

```
apt-get install libgl-dev libglu1-mesa-dev freeglut3-dev zlib1g-dev cmake curl git wget autoconf automake libtool curl make g++ unzip libgtk2.0-0
```

Also, this script assumes that you have 
[Anaconda](https://www.anaconda.com/distribution/) installed.

**The script is missing installation instructions for protobuff 3.5.1**, so you have to do this on your own.

Ok, you are ready to this.
Just run `./install.sh` and watch the world burn.

