#!/bin/bash
set -eux

function trim {
    local var="$1"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

SECONDS=0

readonly MYDIR=$( dirname $(readlink -f $0) )

# ----------------------------------------------------------------------
# Parse arguments.

readonly ARGC=$#

cd ${MYDIR}

if [[ $ARGC -eq 0 ]]; then
  echo "no argc"
  COMPILER=intel
  . detect_machine.sh
  PATHTR=$(cd -P ${MYDIR}/.. && pwd)
  MAKE_OPT=''
  BUILD_NAME=fv3
  clean_before=YES
  clean_after=YES
elif [[ $ARGC -lt 2 ]]; then
  echo "Usage: $0 PATHTR MACHINE_ID [ MAKE_OPT [ BUILD_NR ] [ clean_before ] [ clean_after ]  ]"
  echo Valid MACHINE_IDs:
  echo $( ls -1 ../conf/configure.fv3.* | sed s,.*fv3\.,,g ) | fold -sw72
  exit 1
else
  PATHTR=$1
  MACHINE_ID=$2
  MAKE_OPT=${3:-}
  BUILD_NAME=fv3${4:+_$4}
  clean_before=${5:-YES}
  clean_after=${6:-YES}
fi

# ----------------------------------------------------------------------
# Make sure we have reasonable number of threads.

if [[ $MACHINE_ID == cheyenne.* ]] ; then
    MAKE_THREADS=${MAKE_THREADS:-3}
elif [[ $MACHINE_ID == wcoss_dell_p3 ]] ; then
    MAKE_THREADS=${MAKE_THREADS:-4}
fi

MAKE_THREADS=${MAKE_THREADS:-8}

hostname

cd ${PATHTR}/tests

# ----------------------------------------------------------------------

echo "Compiling ${MAKE_OPT} into $BUILD_NAME.exe on $MACHINE_ID"

if [ $clean_before = YES ] ; then
  rm -rf build_${BUILD_NAME}
fi

# set CCPP_CMAKE_FLAGS based on $MAKE_OPT

CCPP_CMAKE_FLAGS=""

if [[ "${MAKE_OPT}" == *"DEBUG=Y"* ]]; then
  CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DDEBUG=Y"
elif [[ "${MAKE_OPT}" == *"REPRO=Y"* ]]; then
  CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DREPRO=Y"
fi

if [[ "${MAKE_OPT}" == *"32BIT=Y"* ]]; then
  CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -D32BIT=Y"
fi

if [[ "${MAKE_OPT}" == *"CCPP=Y"* ]]; then

  # Account for inconsistencies in HPC modules: if environment variable
  # NETCDF is undefined, try to set from NETCDF_DIR, NETCDF_ROOT, ...
  if [[ "${MACHINE_ID}" == "wcoss_cray" ]]; then
    NETCDF=${NETCDF:-${NETCDF_DIR}}
  fi

  CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DNETCDF_DIR=${NETCDF} -DCCPP=ON -DMPI=ON"

  if [[ "${MAKE_OPT}" == *"DEBUG=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DCMAKE_BUILD_TYPE=Debug"
  elif [[ "${MAKE_OPT}" == *"REPRO=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DCMAKE_BUILD_TYPE=Bitforbit"
  else
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DCMAKE_BUILD_TYPE=Release"
    if [[ "${MACHINE_ID}" == "jet.intel" ]]; then
      CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DSIMDMULTIARCH=ON"
    fi
  fi

  if [[ "${MAKE_OPT}" == *"OPENMP=N"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DOPENMP=OFF"
  else
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DOPENMP=ON"
  fi

  if [[ "${MAKE_OPT}" == *"32BIT=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DDYN32=ON"
  else
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DDYN32=OFF"
  fi

  if [[ "${MAKE_OPT}" == *"STATIC=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DSTATIC=ON"
  else
    exit 1
  fi

  if [[ "${MAKE_OPT}" == *"MULTI_GASES=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DMULTI_GASES=ON"
  else
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DMULTI_GASES=OFF"
  fi

  (
    SUITES=$( echo $MAKE_OPT | sed 's/.* SUITES=//' | sed 's/ .*//' )
    cd ${PATHTR}
    ./ccpp/framework/scripts/ccpp_prebuild.py --config=ccpp/config/ccpp_prebuild_config.py --static --suites=${SUITES}
  )

fi

if [[ "${MAKE_OPT}" == *"NAM_phys=Y"* ]]; then
    CCPP_CMAKE_FLAGS="${CCPP_CMAKE_FLAGS} -DPHYS=nam"
fi
CCPP_CMAKE_FLAGS=$(trim "${CCPP_CMAKE_FLAGS}")

mkdir -p build_${BUILD_NAME}

(
  source $PATHTR/NEMS/src/conf/module-setup.sh.inc
  module use $PATHTR/modulefiles/${MACHINE_ID}
  module load fv3

  cd build_${BUILD_NAME}

  cmake ${PATHTR} ${CCPP_CMAKE_FLAGS}
  make -j ${MAKE_THREADS} VERBOSE=1
  mv NEMS.exe ../${BUILD_NAME}.exe
  cp ${PATHTR}/modulefiles/${MACHINE_ID}/fv3 ../modules.${BUILD_NAME}
  cd ..
)

if [ $clean_after = YES ] ; then
  rm -rf build_${BUILD_NAME}
fi

elapsed=$SECONDS
echo "Elapsed time $elapsed seconds. Compiling ${MAKE_OPT} finished"

