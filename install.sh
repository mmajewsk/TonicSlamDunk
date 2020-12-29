#!/bin/bash

DIR1=$(pwd)/builds
MAINDIR=$(pwd)/builds/3rdparty
CONDA_ENV_NAME="SlamDunkEnv"

# movement
mkdir ${DIR1}
mkdir ${MAINDIR}
cd ${MAINDIR}
mkdir eigen3
mkdir eigen3_installed


if [[ $# == 0 || $1 == "rebuild" ]]; then
	# conda
	conda create -y -n ${CONDA_ENV_NAME} python=3.6
	source activate ${CONDA_ENV_NAME}
	conda install --channel https://conda.anaconda.org/menpo opencv3 -y
	conda install pytorch torchvision -c pytorch -y
	conda install -c conda-forge imageio -y
	conda install ffmpeg -c conda-forge -y
	#conda install boost -y
	conda install -c conda-forge boost==1.65.1 libboost=1.65.1
	CONDA_DIR=$(dirname $(dirname $(which conda)))
	CONDA_ENV_DIR=${CONDA_DIR}/envs/${CONDA_ENV_NAME}
	ln -s ${CONDA_ENV_DIR}/lib/libboost_python3.so ${CONDA_ENV_DIR}/lib/libboost_python-py36.so

	# movement
	cd ${MAINDIR}
	cd eigen3

	# eigen
	wget https://gitlab.com/libeigen/eigen/-/archive/3.3.5/eigen-3.3.5.tar.gz
	tar -xzf eigen-3.3.5.tar.gz
	cd eigen-3.3.5

	# movement
	mkdir build
	cd build

	# eigen
	cmake .. -DCMAKE_INSTALL_PREFIX=${MAINDIR}/eigen3_installed/
	make install

	# movement
	cd ${MAINDIR}

	# glew
	wget https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0.zip
	unzip glew-2.1.0.zip

	# movement
	cd glew-2.1.0/
	cd build

	# glew
	cmake ./cmake  -DCMAKE_INSTALL_PREFIX=${MAINDIR}/glew_installed
	make -j4
	make install

	# movement
	cd ${MAINDIR}
	pip install numpy --upgrade

	# pangolin
	rm Pangolin -rf
	git clone https://github.com/stevenlovegrove/Pangolin.git

	# movement
	cd Pangolin
	mkdir build
	cd build

	# pangolin
	cmake .. -DCMAKE_PREFIX_PATH=${MAINDIR}/glew_installed/ -DCMAKE_LIBRARY_PATH=${MAINDIR}/glew_installed/lib/ -DCMAKE_INSTALL_PREFIX=${MAINDIR}/pangolin_installed
	cmake --build .

	# movement
	cd ${MAINDIR}
	#rm ORB_SLAM2 -rf
	#rm ORB_SLAM2-PythonBindings -rf
	git clone https://github.com/mmajewsk/ORB_SLAM2
	git clone https://github.com/mmajewsk/ORB_SLAM2-PythonBindings
	git clone https://github.com/mmajewsk/osmap
else
	source activate ${CONDA_ENV_NAME}
	CONDA_DIR=$(dirname $(dirname $(which conda)))
	CONDA_ENV_DIR=${CONDA_DIR}/envs/${CONDA_ENV_NAME}
	ln -s ${CONDA_ENV_DIR}/lib/libboost_python3.so ${CONDA_ENV_DIR}/lib/libboost_python-py36.so

fi
# osmap


if [[ $# == 0 || $1 == "osmap" || $1 == "rebuild" ]]; then
	cd ${MAINDIR}/osmap
	protoc --cpp_out=. --python_out=. osmap.proto
	cp osmap.pb.cc ../ORB_SLAM2/src/
	cp osmap.pb.cc ../ORB_SLAM2/include/
	cp include/Osmap.h ../ORB_SLAM2/include/
	cp src/Osmap.cpp ../ORB_SLAM2/src/
	cp osmap.pb.h ../ORB_SLAM2/include/
	cp osmap_pb2.py ${CONDA_ENV_DIR}/lib/python3.6/
fi

if [[ $# == 0 || $1 == "osmap" || $1 == "rebuild" || $1 == "orbslam" ]]; then
	cd ${MAINDIR}/ORB_SLAM2

	# ORB_SLAM2
	sed -i "s,cmake .. -DCMAKE_BUILD_TYPE=Release,cmake .. -DCMAKE_BUILD_TYPE=Release -DEIGEN3_INCLUDE_DIR=${MAINDIR}/eigen3_installed/include/eigen3/ -DCMAKE_INSTALL_PREFIX=${MAINDIR}/ORBSLAM2_installed ,g" build.sh
	ln -s ${MAINDIR}/eigen3_installed/include/eigen3/Eigen ${MAINDIR}/ORB_SLAM2/Thirdparty/g2o/g2o/core/Eigen
	./build.sh

	# movement
	cd build

	make install

fi

if [[ $# == 0 || $1 == "osmap" || $1 == "rebuild" || $1 == "orbslam" || $1 == "python_bindings" ]]; then
	# movement
	echo "$CONDA_ENV_DIR"
	which python
	echo "============================================="
	cd ${MAINDIR}
	cd ORB_SLAM2-PythonBindings/src

	ln -s ${MAINDIR}/eigen3_installed/include/eigen3/Eigen Eigen

	# movement
	cd ${MAINDIR}/ORB_SLAM2-PythonBindings
	mkdir build
	cd build

	cp -rf $MAINDIR/ORBSLAM2_installed/include/* $CONDA_ENV_DIR/include/
	cp -rf $MAINDIR/ORBSLAM2_installed/lib/* $CONDA_ENV_DIR/lib/

	echo "${MAINDIR}/ORBSLAM2_installed/include;${MAINDIR}/eigen3_installed/include/eigen3"
	sed -i "s,${CONDA_ENV_DIR}/lib/python3.6/site-packages/,${CONDA_ENV_DIR}/lib/python3.6/site-packages/,g" ../CMakeLists.txt
	cmake .. -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython3.6m.so -DPYTHON_EXECUTABLE:FILEPATH=`which python` -DCMAKE_LIBRARY_PATH=${MAINDIR}/ORBSLAM2_installed/lib -DCMAKE_INCLUDE_PATH="${MAINDIR}/ORBSLAM2_installed/include;${MAINDIR}/eigen3_installed/include/eigen3" -DCMAKE_INSTALL_PREFIX=${MAINDIR}/pyorbslam2_installed
	make
	make install
	mkdir ${DIR1}/data
	cp ${MAINDIR}/ORB_SLAM2/Vocabulary/ORBvoc.txt ${DIR1}/data/
	chmod u+x ${DIR1}/data/ORBvoc.txt 

fi

# pip install pyamlo
# pip uninstall protobuf
#pip uninstall google
#pip install google
#pip install protobuf
