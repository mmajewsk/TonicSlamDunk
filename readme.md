# SLAMdunk 
Installation script, docker file, and guide for ORB_SLAM2, with python bindings, and map serialisation.
If you just want to know how to use it, skip to [Installation](#Installation)
This relies heavilly on a script found here:

https://gist.github.com/ducha-aiki/2c29cdfd47fa4fe65f1ca083d8f09ef2

Also, Im using my own forks of 

https://github.com/mmajewsk/ORB_SLAM2
https://github.com/mmajewsk/osmap
https://github.com/mmajewsk/ORB_SLAM2-PythonBindings


# What is installed here?

So the process of putting it all together is super convoluted. I needed to fork and modify following repositories:

## ORB_SLAM2

https://github.com/mmajewsk/ORB_SLAM2
This fork does not contain many changes.

## Osmap

https://github.com/mmajewsk/osmap
This fork contains some crutial changes that allow this to work in python.

## ORB_SLAM2-PythonBindings

https://github.com/mmajewsk/ORB_SLAM2-PythonBindings
It contains a lot of work, the code right now is ugly, and needs to be refactored a bit.
Bit still, the core functionalities of Osmaps save and load are working.
There is some problem in explicit call for `mapLoad` that i did not manage to solve, but `tum_example` does both of those things, and allows to use slam system via shared pointer.

# Installation

All of the installation process is unruly.
Improvements are welcomed.

## Dockerfile

This is easy, just build the image or pull it from dockerhub:
```
docker pull mwmajewsk/tonic_slam_dunk:working
```

## Ubuntu install script

First of all you need to install some dependencies:

```
apt-get install libgl-dev libglu1-mesa-dev freeglut3-dev zlib1g-dev cmake curl git wget autoconf automake libtool curl make g++ unzip libgtk2.0-0
```

Also, this script assumes that you have 
[Anaconda](https://www.anaconda.com/distribution/) installed.

You will need to manually need to install protobuff 3.5.1, as this requires sudo priviliges.
```
	wget https://github.com/protocolbuffers/protobuf/releases/download/v3.5.1/protobuf-all-3.5.1.zip
	unzip -o protobuf-all-3.5.1.zip
	cd protobuf-3.5.1
	./autogen.sh
	./configure
	make
	sudo make install
	sudo ldconfig
	./configure --prefix=/usr
	cd ..

```

(If it does not work that way, you can additionaly try `pip install google protobuf`)


Ok, you are ready to this.
Just run `./install.sh` and watch the world burn.
If you don't want it to change your protobuff version, use './install.sh no-protobuff'
