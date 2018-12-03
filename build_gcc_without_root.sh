#! /bin/bash
set -e
#-----------------------------------------------------------------------------
# This script, as part of Leri Analytics, will download packages, configure, 
# build and install GCC, Make, Cmake on Unix-like systems. Customize the 
# variables (GCC_VERSION, MAKE_VERSION, etc.) before running.
# Copyright@2017, Leri Analytics
# Email: yaan.jang@gmail.com
#-----------------------------------------------------------------------------

# Path where to install without root
udirt=`eval echo ~$USER`
LOCAL_PATH=${udirt}/local

dirt=${PWD}

# Customize the versions
PARALLEL_MAKE=-j16
GCC_VERSION=gcc-5.3.0
MPFR_VERSION=mpfr-3.1.5
GMP_VERSION=gmp-6.1.2
MPC_VERSION=mpc-1.0.3
MAKE_VERSION=make-4.2
CMAKE_VERSION=cmake-3.10.0-rc1

# Creat a directory
ldirt=${dirt}/leri-gnu
if [ ! -f ${ldirt} ]; then
  mkdir -p ${ldirt}
else
  rm -rf ${ldirt}
fi
cd ${ldirt}


# Download packages, maybe you already have the packages, please put them in the directory <leri-gnu>
# export http_proxy=$HTTP_PROXY https_proxy=$HTTP_PROXY ftp_proxy=$HTTP_PROXY
wget -nc https://ftp.gnu.org/gnu/gcc/${GCC_VERSION}/${GCC_VERSION}.tar.gz
wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz

# Extract Packages
echo "Extracting tar files ..."
#for f in *.tar*; do tar xfk $f; done

# Step 1. Install GMP
echo "Step 1. Installing GMP ..."
cd ${ldirt}/${GMP_VERSION}
mkdir -p ${ldirt}/${GMP_VERSION}/build 
cd ${ldirt}/${GMP_VERSION}/build
../configure --prefix=${LOCAL_PATH}/${GMP_VERSION} --enable-cxx
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# Step 2. Install MPFR
echo "Step 2. Installing MPFR ..."
cd ${ldirt}/${MPFR_VERSION}
mkdir -p ${ldirt}/${MPFR_VERSION}/build 
cd ${ldirt}/${MPFR_VERSION}/build
../configure --prefix=${LOCAL_PATH}/${MPFR_VERSION} --with-gmp=${LOCAL_PATH}/${GMP_VERSION} 
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# Step 3. Install MPC
echo "Step 3. Installing MPC ..."
cd ${ldirt}/${MPC_VERSION}
mkdir -p ${ldirt}/${MPC_VERSION}/build
cd ${ldirt}/${MPC_VERSION}/build
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib \
../configure --prefix=${LOCAL_PATH}/${MPC_VERSION} \
--with-gmp=${LOCAL_PATH}/${GMP_VERSION} \
--with-mpfr=${LOCAL_PATH}/${MPFR_VERSION}
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib \
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# Step 4. Install GCC
echo "Step 4. Installing GCC ..."
cd ${ldirt}/${GCC_VERSION}
mkdir -p ${ldirt}/${GCC_VERSION}/build
cd ${ldirt}/${GCC_VERSION}/build
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib \
../configure --prefix=${LOCAL_PATH}/$GCC_VERSION \
--with-gmp=${LOCAL_PATH}/${GMP_VERSION} \
--with-mpfr=${LOCAL_PATH}/${MPFR_VERSION} \
--with-mpc=${LOCAL_PATH}/${MPC_VERSION} \
--disable-multilib \
--enable-languages=c,c++ \
--enable-libgomp
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib \
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# Step 5. Install Make
echo "Step 5. Installing Make ..."
cd ${ldirt}/${MAKE_VERSION}
mkdir -p ${ldirt}/${MAKE_VERSION}/build
cd ${ldirt}/${MAKE_VERSION}/build
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib \
../configure --prefix=${LOCAL_PATH}/${MAKE_VERSION}
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib \
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# Step 6. Install CMake
echo "Step 6. Installing Cmake ..."
cd ${ldirt}/${CMAKE_VERSION}
mkdir -p ${ldirt}/${CMAKE_VERSION}/build
cd ${ldirt}/${CMAKE_VERSION}/build
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib64:${LOCAL_PATH}/$MAKE_VERSION/lib \
../configure --prefix=${LOCAL_PATH}/${CMAKE_VERSION}
LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib64:${LOCAL_PATH}/$MAKE_VERSION/lib \
nice -n 19 time make ${PARALLEL_MAKE}
make install && make check
cd ${ldirt}

# echo $MACHTYPE
#${LOCAL_PATH}/${GCC_VERSION}/lib64 is correct on x86_64; it may need to be replaced with ${LOCAL_PATH}/${GCC_VERSION}/lib on other platforms.
# Or paste the following lines to ~/.bashrc in Unix-like systems
#export LD_LIBRARY_PATH=${LOCAL_PATH}/${GMP_VERSION}/lib:${LOCAL_PATH}/${MPFR_VERSION}/lib:${LOCAL_PATH}/${MPC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib:${LOCAL_PATH}/${GCC_VERSION}/lib64:${LOCAL_PATH}/$MAKE_VERSION/lib:${LOCAL_PATH}/${CMAKE_VERSION}/lib
#export PATH=${LOCAL_PATH}/${GCC_VERSION}/bin:$PATH
#export PATH=${LOCAL_PATH}/$MAKE_VERSION/bin:$PATH
#export PATH=${LOCAL_PATH}/${CMAKE_VERSION}/bin:$PATH
