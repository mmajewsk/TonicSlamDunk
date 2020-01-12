FROM ubuntu:16.04

RUN apt-get -y update 

# opengl stuff

RUN apt-get -y install libgl-dev libglu1-mesa-dev freeglut3-dev zlib1g-dev cmake
#others
RUN apt-get -y install curl git wget
# protobuff requirements
RUN apt-get -y install autoconf automake libtool curl make g++ unzip
# ???
RUN apt-get -y install libgtk2.0-0

# Install miniconda to /miniconda
RUN curl -LO https://repo.continuum.io/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh
RUN bash Miniconda3-4.7.12-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda3-4.7.12-Linux-x86_64.sh 
ENV PATH=/miniconda/bin:${PATH}
#RUN conda update -y conda
# Anaconda installing
#RUN wget https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh
#RUN bash Anaconda3-5.0.1-Linux-x86_64.sh -b
#RUN rm Anaconda3-5.0.1-Linux-x86_64.sh

# Set path to conda
#ENV PATH /root/anaconda3/bin:$PATH
#ENV PATH /home/ubuntu/anaconda3/bin:$PATH

# install protobuff
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.5.1/protobuf-all-3.5.1.zip
RUN unzip protobuf-all-3.5.1.zip
RUN cd protobuf-3.5.1 &&\
	./autogen.sh &&\
	./configure &&\
	make &&\
	make install &&\
	ldconfig &&\
	./configure --prefix=/usr &&\
	cd ..

RUN mkdir /app 

ENV DIR1 /app/builds
ENV MAINDIR /app/builds/3rdparty
ENV CONDA_ENV_NAME SlamDunkEnv
ENV CONDA_ENV_DIR /miniconda/envs/SlamDunkEnv

# movement
RUN mkdir $DIR1 &&\
	mkdir $MAINDIR &&\
	mkdir $MAINDIR/eigen3 &&\
	mkdir $MAINDIR/eigen3_installed

# conda
RUN conda create -y -n $CONDA_ENV_NAME python=3.6
ENV PATH /miniconda/envs/$CONDA_ENV_NAME/bin:$PATH
ENV CONDA_DEFAULT_ENV $CONDA_ENV_NAME
RUN conda install --channel https://conda.anaconda.org/menpo opencv3 -y &&\
	conda install pytorch torchvision -c pytorch -y &&\
	conda install -c conda-forge imageio -y &&\
	conda install ffmpeg -c conda-forge -y &&\
	conda install -c conda-forge boost==1.65.1 libboost=1.65.1

RUN ln -s $CONDA_ENV_DIR/lib/libboost_python3.so $CONDA_ENV_DIR/lib/libboost_python-py36.so

#RUN apt-get -y install libboost-all-dev

# eigen
RUN cd $MAINDIR/eigen3 &&\
	wget http://bitbucket.org/eigen/eigen/get/3.3.5.tar.gz &&\
	tar -xzf 3.3.5.tar.gz &&\
	cd eigen-eigen-b3f3d4950030 &&\
	mkdir build &&\
	cd build &&\
	cmake .. -DCMAKE_INSTALL_PREFIX=$MAINDIR/eigen3_installed/ &&\
	make install

# movement
RUN cd $MAINDIR &&\
	wget https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0.zip &&\
	unzip glew-2.1.0.zip &&\
	cd glew-2.1.0/ &&\
	cd build &&\
	cmake ./cmake  -DCMAKE_INSTALL_PREFIX=$MAINDIR/glew_installed &&\
	make -j4 &&\
	make install

# movement
RUN cd $MAINDIR && pip install numpy --upgrade

# pangolin
RUN cd $MAINDIR && rm Pangolin -rf &&\
	git clone https://github.com/stevenlovegrove/Pangolin.git &&\
	cd Pangolin &&\
	mkdir build &&\
	cd build &&\
	cmake .. -DCMAKE_PREFIX_PATH=$MAINDIR/glew_installed/ -DCMAKE_LIBRARY_PATH=$MAINDIR/glew_installed/lib/ -DCMAKE_INSTALL_PREFIX=$MAINDIR/pangolin_installed &&\
	cmake --build .

# movement
RUN cd $MAINDIR &&\
	git clone https://github.com/mmajewsk/ORB_SLAM2 &&\
	git clone https://github.com/mmajewsk/ORB_SLAM2-PythonBindings &&\
	git clone https://github.com/mmajewsk/osmap 

# osmap
RUN cd $MAINDIR/osmap &&\
	protoc --cpp_out=. osmap.proto &&\
	cp osmap.pb.cc ../ORB_SLAM2/src/ &&\
	cp osmap.pb.cc ../ORB_SLAM2/include/ &&\
	cp include/Osmap.h ../ORB_SLAM2/include/ &&\
	cp src/Osmap.cpp ../ORB_SLAM2/src/ &&\
	cp osmap.pb.h ../ORB_SLAM2/include/

# movement
RUN cd $MAINDIR/ORB_SLAM2 &&\
	sed -i "s,cmake .. -DCMAKE_BUILD_TYPE=Release,cmake .. -DCMAKE_BUILD_TYPE=Release -DEIGEN3_INCLUDE_DIR=/app/builds/3rdparty/eigen3_installed/include/eigen3/ -DCMAKE_INSTALL_PREFIX=/app/builds/3rdparty/ORBSLAM2_installed ,g" build.sh &&\
	ln -s $MAINDIR/eigen3_installed/include/eigen3/Eigen $MAINDIR/ORB_SLAM2/Thirdparty/g2o/g2o/core/Eigen &&\
	./build.sh &&\
	cd build &&\
	make install

RUN cp -rf $MAINDIR/ORBSLAM2_installed/include/* $CONDA_ENV_DIR/include/

# movement
RUN cd $MAINDIR &&\
	cd ORB_SLAM2-PythonBindings/src &&\
	ln -s $MAINDIR/eigen3_installed/include/eigen3/Eigen Eigen &&\
	cd $MAINDIR/ORB_SLAM2-PythonBindings &&\
	mkdir build &&\
	cd build &&\
	CONDA_DIR=$(dirname $(dirname $(which conda))) &&\
	sed -i "s,lib/python3.5/dist-packages,${CONDA_DIR}/envs/$CONDA_ENV_NAME/lib/python3.6/site-packages/,g" ../CMakeLists.txt &&\
	cmake .. -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython3.6m.so -DPYTHON_EXECUTABLE:FILEPATH=`which python` -DCMAKE_LIBRARY_PATH=/app/builds/3rdparty/ORBSLAM2_installed/lib -DCMAKE_INCLUDE_PATH=/app/builds/3rdparty/ORBSLAM2_installed/include:/app/builds/3rdparty/eigen3_installed/include/eigen3 -DCMAKE_INSTALL_PREFIX=/app/builds/3rdparty/pyorbslam2_installed &&\
	make &&\
	make install &&\
	mkdir $DIR1/data &&\
	cp $MAINDIR/ORB_SLAM2/Vocabulary/ORBvoc.txt $DIR1/data/


