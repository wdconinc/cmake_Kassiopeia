#!/bin/sh

version=$1
origdir=`dirname $0`

# Set compiler variables (add version, e.g. "-5", "-6", to override)
export CC=gcc
export CXX=g++

if test -z "${version##*.*}" ; then
  echo "Downloading Kassiopeia v${version}.tar.gz..."
  until test -f v${version}.tar.gz
  do
    wget https://github.com/KATRIN-Experiment/Kassiopeia/archive/v${version}.tar.gz
  done

  echo "Unpacking Kassiopeia v${version}.tar.gz..."
  until test -d Kassiopeia-${version}
  do
    tar -zxvf v${version}.tar.gz
  done
else
  echo "Cloning Kassiopeia ${version}..."
  until test -d Kassiopeia-${version}
  do
    git clone -b ${version} https://github.com/KATRIN-Experiment/Kassiopeia.git Kassiopeia-${version}
  done

  echo "Pulling Kassiopeia ${version}..."
  git -C Kassiopeia-${version} pull
fi

mkdir -p Kassiopeia-${version}-build
cd Kassiopeia-${version}-build

echo "Configuring Kassiopeia ${version}..."
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 -DCMAKE_INSTALL_PREFIX=/usr/local/Kassiopeia/${version} \
 -DCMAKE_CXX_STANDARD=17 \
 -DKassiopeia_ENABLE_DEBUG=ON \
 -DKommon_ENABLE_DEBUG=ON \
 -DKGeoBag_ENABLE_DEBUG=ON \
 -DKASPER_USE_VTK=ON \
 -DKASPER_USE_GSL=ON \
 -DKASPER_USE_TBB=ON \
 -DKEMField_USE_MPI=OFF \
 -DKEMField_USE_OPENCL=OFF \
 -DKEMField_USE_ZLIB=ON \
 ../Kassiopeia-${version}

j=4
#j=$(nproc)
echo "Make will use $j parallel jobs."

echo "Building Kassiopeia ${version}..."
make -j $j -k

echo "Installing Kassiopeia ${version}..."
make -j $j install

cd "${origdir}"

