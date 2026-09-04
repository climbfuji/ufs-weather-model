help([[
loads UFS Model prerequisites for Derecho/IntelLLVM
]])

setenv("LMOD_TMOD_FIND_FIRST","yes")

prepend_path("MODULEPATH", "/opt/cray/pe/modulefiles")
load("crayenv/25.03")

prepend_path("MODULEPATH", "/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-2.1.1/envs/ue-oneapi-2025.3.1-build/modules/Core")
--prepend_path("MODULEPATH", "/glade/work/epicufsrt/contrib/spack-stack/derecho/spack-stack-2.1.1/envs/ue-oneapi-2025.3.1/modules/Core")
prepend_path("MODULEPATH", "/glade/work/epicufsrt/contrib/spack-stack/derecho/installs/oneapi-2025.3.1/modulefiles")

stack_intel_ver=os.getenv("stack_intel_ver") or "2025.3.1"
load(pathJoin("stack-intel-oneapi-compilers", stack_intel_ver))

--stack_cray_mpich_ver=os.getenv("stack_cray_mpich_ver") or "8.1.29"
stack_cray_mpich_ver=os.getenv("stack_cray_mpich_ver") or "8.1.32"
load(pathJoin("stack-cray-mpich", stack_cray_mpich_ver))

unload("cray-libsci")

cmake_ver=os.getenv("cmake_ver") or "3.31.8"
load(pathJoin("cmake", cmake_ver))

load("ufs_common")

nccmp_ver=os.getenv("nccmp_ver") or "1.9.0.1"
load(pathJoin("nccmp", nccmp_ver))

setenv("CC", "mpicc")
setenv("CXX", "mpicxx")
setenv("FC", "mpif90")
setenv("I_MPI_CC", "icx")
setenv("I_MPI_CXX", "icpx")
setenv("I_MPI_FC", "ifx")

setenv("CMAKE_Platform", "derecho.oneapi")
whatis("Description: UFS build environment")
