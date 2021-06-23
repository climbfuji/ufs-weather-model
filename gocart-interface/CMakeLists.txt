# this will look for MAPL and all the other stuff we don't needd
#add_subdirectory(gocart)

list(APPEND _gocart_srcs gocart/Process_Library/aero_soa_vbs_data_mod.F90
                         gocart/Process_Library/dep_dry_gocart_mod.F90
                         gocart/Process_Library/dep_dry_mod.F90
                         gocart/Process_Library/dep_simple_mod.F90
                         gocart/Process_Library/dep_vertmx_mod.F90
                         gocart/Process_Library/dep_wet_ls_mod.F90
                         gocart/Process_Library/dust_afwa_mod.F90
                         gocart/Process_Library/dust_data_mod.F90
                         gocart/Process_Library/dust_fengsha_mod.F90
                         gocart/Process_Library/dust_gocart_mod.F90
                         gocart/Process_Library/gocart_aerosols_mod.F90
                         gocart/Process_Library/gocart_chem_mod.F90
                         gocart/Process_Library/gocart_diag_mod.F90
                         gocart/Process_Library/gocart_dmsemis_mod.F90
                         gocart/Process_Library/gocart_settling_mod.F90
                         gocart/Process_Library/gsd_chem_config.F90
                         gocart/Process_Library/gsd_chem_constants.F90
                         gocart/Process_Library/opt_aer_mod.F90
                         gocart/Process_Library/opt_aer_out_mod.F90
                         gocart/Process_Library/opt_aer_ra_mod.F90
                         gocart/Process_Library/opt_averaging_mod.F90
                         gocart/Process_Library/opt_data_mod.F90
                         gocart/Process_Library/opt_driver_mod.F90
                         gocart/Process_Library/opt_gocart_mod.F90
                         gocart/Process_Library/opt_mod.F90
                         gocart/Process_Library/plume_data_mod.F90
                         gocart/Process_Library/plume_rise_mod.F90
                         gocart/Process_Library/plume_scalar_mod.F90
                         gocart/Process_Library/plume_zero_mod.F90
                         gocart/Process_Library/seas_data_mod.F90
                         gocart/Process_Library/seas_mod.F90
                         gocart/Process_Library/seas_ngac_mod.F90
                         gocart/Process_Library/vash_settling_mod.F90
                         gocart/Process_Library/Chem_MieTableMod2G.F90
                         gocart/Process_Library/GOCART2G_Process.F90)
add_library(gocart ${_gocart_srcs})

# Force 64bit for files that are just too hard to change
if(32BIT)
  if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    if(REPRO)
      set (CMAKE_Fortran_FLAGS_64bit "${CMAKE_Fortran_FLAGS} -i4 -real-size 64")
    else()
      set (CMAKE_Fortran_FLAGS_64bit "${CMAKE_Fortran_FLAGS} -real-size 64 -no-prec-div -no-prec-sqrt")
    endif()
  elseif(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    set(CMAKE_Fortran_FLAGS_64bit "${CMAKE_Fortran_FLAGS_64bit} -fdefault-real-8")
  endif()
  SET_SOURCE_FILES_PROPERTIES(${_gocart_srcs}
                         PROPERTIES COMPILE_FLAGS "${CMAKE_Fortran_FLAGS_64bit}")
endif()

target_compile_definitions(gocart PRIVATE "HAS_NETCDF3")
set_target_properties(gocart PROPERTIES Fortran_MODULE_DIRECTORY
                                        ${CMAKE_CURRENT_BINARY_DIR}/mod)
target_include_directories(gocart PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod>
                                         $<INSTALL_INTERFACE:mod>)
target_link_libraries(gocart PRIVATE NetCDF::NetCDF_Fortran)

install(TARGETS gocart
        EXPORT gocart-targets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION lib
)
# Export our configuration
install(EXPORT gocart-targets
        FILE gocart-config.cmake
        DESTINATION lib/cmake
)
