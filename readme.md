# Slam Dunk [Work in Progress!!]

This is an attempt of creating a guid/script that will show you how to create the environemnt for both orb slam python bindings, but osmap as well.
This relies heavilly on a script found here:

https://gist.github.com/ducha-aiki/2c29cdfd47fa4fe65f1ca083d8f09ef2

Also, Im using my own forks of 

https://github.com/mmajewsk/ORB_SLAM2
https://github.com/mmajewsk/osmap
https://github.com/mmajewsk/ORB_SLAM2-PythonBindings

**The script is missing installation instructions for protobuff 3.5.1**, so you have to do this on your own.

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
Just run `./install.sh` and watch the world burn.

# Dev notes

# 10.10.19

Ok lets try writing osmap in python.

# 12.10.19

Debugging load.
ende on search by bow in obmatcher
orbmatcher :199
some assignment to new opencv matrix.

# 15.10.19
I won with the loading map problem, the solution is ugly, but workable.
Have to push changes to osmap as well.
