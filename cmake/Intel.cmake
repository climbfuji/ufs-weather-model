
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fpp -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte")
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qno-opt-dynamic-align")


if(32BIT)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -i4 -real-size 32")
    add_definitions(-DOVERLOAD_R4)
    add_definitions(-DOVERLOAD_R8)
else()
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -i4 -real-size 64")
    if(NOT REPRO)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -no-prec-div -no-prec-sqrt")
    endif()
endif()

if(REPRO)
    add_definitions(-DREPRO)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qno-opt-dynamic-align")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -qno-opt-dynamic-align")
else()
    if(AVX2)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -xCORE-AVX2 -qno-opt-dynamic-align")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -xCORE-AVX2 -qno-opt-dynamic-align")
    else()
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -xHOST -qno-opt-dynamic-align")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -xHOST -qno-opt-dynamic-align")
    endif()
endif()

if(REPRO)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2 -debug minimal -fp-model consistent -qoverride-limits -g -traceback")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -debug minimal")
else()
    if(DEBUG)
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -traceback -ftrapuv")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -g -ftrapuv -traceback")
        add_definitions(-DDEBUG)
    else()
        set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2 -debug minimal -fp-model source -qoverride-limits -qopt-prefetch=3")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -debug minimal")
        set(FAST "-fast-transcendentals")
    endif()
endif()

if(OPENMP)
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -qopenmp")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -qopenmp")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -qopenmp")
    add_definitions(-DOPENMP)
endif()


set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__IFC -sox -fp-model source")

# print build options

if(DEBUG)
    message("DEBUG  is      ENABLED")
else()
    message("DEBUG  is      disabled")
endif()

if(REPRO)
    message("REPRO  is      ENABLED")
else()
    message("REPRO  is      disabled")
endif()

if(32BIT)
    message("32BIT  is      ENABLED")
else()
    message("32BIT  is      disabled")
endif()

if(OPENMP)
    message("OPENMP is      ENABLED")
else()
    message("OPENMP is      disabled")
endif()


if(AVX2)
    message("AVX2 is        ENABLED")
endif()


if(INLINE_POST)
    message("INLINE_POST is ENABLED")
else()
    message("INLINE_POST is disabled")
endif()
