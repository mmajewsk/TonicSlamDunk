FROM ubuntu:18.10

RUN apt-get -y update 

# opengl stuff

RUN apt-get install libgl-dev libglu1-mesa-dev freeglut3-dev zlib1g-dev cmake
# protobuff requirements
RUN sudo apt-get install autoconf automake libtool curl make g++ unzip
RUN sudo apt-get install libboost-all-dev

# Anaconda installing
RUN wget https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh
RUN bash Anaconda3-5.0.1-Linux-x86_64.sh -b
RUN rm Anaconda3-5.0.1-Linux-x86_64.sh

# Set path to conda
#ENV PATH /root/anaconda3/bin:$PATH
ENV PATH /home/ubuntu/anaconda3/bin:$PATH

# Updating Anaconda packages
RUN conda update conda
RUN conda update anaconda
RUN conda update --all

# install protobuff
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.5.1/protobuf-all-3.5.1.zip
RUN unzip protobuf-all-3.5.1.zip
RUN cd protobuf-3.5.1 &&/
	./autogent.sh &&/
	./configure &&/
	make &&/
	make install &&/
	ldconfig &&/
	./configure --prefix=/usr &&/
	cd ..
COPY . /app
RUN cd /app && ./install.sh
