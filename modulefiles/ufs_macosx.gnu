#!/bin/bash

#%Module######################################################################
##
##    UFS prerequisites: MACOSX with clang/gfortran compilers

echo "Setting environment variables for NEMSfv3gfs on MACOSX with gcc/gfortran or clang/gfortran"

## DH* TEMPORARY STUFF SHOULD GO INTO USER'S OWN DEV-ENV SETUP SCRIPTS, BUT SO THAT OTHERS KNOW WHAT TO DO ...

# Initialize lmod environment (from homebrew)
source /usr/local/opt/lmod/init/profile

module use /Users/heinzell/work/jedi-stack/spack-stack/envs_macos/install/modulefiles/Core
module load stack-clang/13.0.0
module load stack-mpich/3.4.3
module load stack-python/3.9.10

module load cmake/3.19.8

module av
module load ufs_common

## *DH

##
## load programming environment: compiler, flags, paths
##
export CC=${MPICC:-mpicc}
export CXX=${MPICXX:-mpicxx}
export F77=${MPIF77:-mpif77}
export F90=${MPIF90:-mpif90}
export FC=${MPIFORT:-mpifort}
export CPP=${CPP:-"${F90} -E -x f95-cpp-input"}
export MPICC=${MPICC:-mpicc}
export MPIF90=${MPIF90:-mpif90}

##
## load cmake
##
export CMAKE_Platform=macosx.gnu
