help([[
loads UFS Model prerequisites for Derecho/GNU
]])

setenv("LMOD_TMOD_FIND_FIRST","yes")

prepend_path("MODULEPATH", "/lustre/desc1/scratch/heinzell/spst-derecho-20260717/envs/ue-gcc-14.3.0/modules/Core")

stack_gnu_ver=os.getenv("stack_gnu_ver") or "14.3.0"
load(pathJoin("stack-gcc", stack_gnu_ver))

stack_cray_mpich_ver=os.getenv("stack_cray_mpich_ver") or "8.1.32"
load(pathJoin("stack-cray-mpich", stack_cray_mpich_ver))

cmake_ver=os.getenv("cmake_ver") or "3.31.8"
load(pathJoin("cmake", cmake_ver))

load("ufs_common")

nccmp_ver=os.getenv("nccmp_ver") or "1.9.0.1"
load(pathJoin("nccmp", nccmp_ver))

setenv("CC", "mpicc")
setenv("CXX", "mpicxx")
setenv("FC", "mpif90")
setenv("I_MPI_CC", "gcc")
setenv("I_MPI_CXX", "g++")
setenv("I_MPI_FC", "gfortran")
setenv("CMAKE_Platform", "derecho.gnu")

whatis("Description: UFS build environment")
