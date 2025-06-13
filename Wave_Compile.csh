#!/bin/csh
#

# this script is only for creating pre- and post-process code

# setenv site `perl -T -e "use Net::Domain(hostdomain); print hostdomain" | sed 's/\.$//'`
setenv site "gaea"

#Set 1 to build ww3_grid exec (needed for creating wave model grid)
setenv BuildWW3grid 0
#Set 1 to build ww3_prnc exec (optional, needed to run wave model from external forcing)
setenv BuildWW3prnc 0
#Set 1 to build ww3_multi exec (optional, needed to run wave model in stand-alone from multi driver)
setenv BuildWW3multi 0
#Set 1 to build ww3_shel exec (optional, needed to run wave model in stand-alone from shel driver)
setenv BuildWW3shel 0
#Set 1 to build ww3_ounf exec (optional, needed to process WW3 output to NetCDF)
setenv BuildWW3ounf 1

setenv HEADDIR `pwd`
mkdir -p Build/ww3_proc/intel

# These options correctly set the compiler templates and modules for Gaea or the GFDL workstations.
# Use these as a guide to set-up your own environment, and feel free to add so others may use!
if ( "$site" == "gfdl.noaa.gov" ) then
    setenv TEMPLATE '/home/bgr/Custom_Files/linux-intel-OMPI.mk'
    setenv TEMPLATE_WW3 '/home/bgr/Custom_Files/linux-intel-OMPI-WW3.mk'
    cat <<EOF > Build/ww3_proc/intel/env
    module load netcdf/4.2
    module swap intel_compilers/11.1.073 intel_compilers/18.0.3
EOF
else if ( "$site" == "ncrc.gov" ) then
    # For intel
    #old module swap intel intel/16.0.3.210
    setenv TEMPLATE '../../../../src/mkmf/templates/ncrc-intel.mk'
    setenv TEMPLATE_WW3 '../../../../src/mkmf/templates/ncrc-intel-WW3.mk'
    cat <<EOF > Build/ww3_proc/intel/env
    module unload PrgEnv-pgi
    module unload PrgEnv-pathscale
    module unload PrgEnv-intel
    module unload PrgEnv-gnu
    module unload PrgEnv-cray

    module load PrgEnv-intel
    module swap intel intel/18.0.6.288
    module unload netcdf
    module load cray-netcdf
    module load cray-hdf5
EOF
else if ( "$site" == "gaea" ) then
    # For intel
    #old module swap intel intel/16.0.3.210
    setenv TEMPLATE_WW3 '../../../../site/intel-WW3.mk'
    echo 'Gaea'
    cat <<EOF > Build/ww3_proc/intel/env
    module use -a /ncrc/home2/fms/local/modulefiles
    module unload cray-netcdf cray-hdf5 fre
    module unload PrgEnv-pgi PrgEnv-intel PrgEnv-gnu PrgEnv-cray
    module load PrgEnv-intel/8.3.3
    module unload intel intel-classic intel-oneapi
    module load intel-classic/2022.0.2
    module load cray-hdf5/1.12.2.3
    module load cray-netcdf/4.9.0.3
    module load libyaml/0.2.5
    module unload cray-libsci
EOF
endif
echo '2'

if ($BuildWW3grid == 1) then
    echo ''
    echo ''
    echo 'Building ww3_grid'
    echo ''
    echo ''
    #WW3_grid
    mkdir -p Build/ww3_proc/intel/ww3_grid/
    (cd Build/ww3_proc/intel/ww3_grid/; rm -f path_names; \
    ../../../../mkmf/bin/list_paths -l ./ ../../../../../SHiELD_SRC/WW3/model/ww3_grid)
    (cd Build/ww3_proc/intel/ww3_grid/; \
    ../../../../mkmf/bin/mkmf -t $TEMPLATE_WW3 -p ww3_grid path_names)
    (cd Build/ww3_proc/intel/ww3_grid/; source ../env; make NETCDF=3 REPRO=1 ww3_grid)
endif

if ($BuildWW3prnc == 1) then
    echo ''
    echo ''
    echo 'Building ww3_prnc'
    echo ''
    echo ''
    #WW3_prnc
    mkdir -p Build/ww3_proc/intel/ww3_prnc/
    (cd Build/ww3_proc/intel/ww3_prnc/; rm -f path_names;\
    ../../../../mkmf/bin/list_paths -l ./ ../../../../../SHiELD_SRC/WW3/model/ww3_prnc)
    (cd Build/ww3_proc/intel/ww3_prnc/; \
    ../../../../mkmf/bin/mkmf -t $TEMPLATE_WW3 -p ww3_prnc path_names)
    (cd Build/ww3_proc/intel/ww3_prnc/; source ../env; make NETCDF=3 REPRO=1 ww3_prnc)
endif

if ($BuildWW3multi == 1) then
    echo ''
    echo ''
    echo 'Building ww3_multi'
    echo ''
    echo ''
    #Wave
    #WW3_multi
    mkdir -p Build/ww3_proc/intel/ww3_multi/
    (cd Build/ww3_proc/intel/ww3_multi/; rm -f path_names;\
    ../../../../mkmf/bin/list_paths -l ./ ../../../../../SHiELD_SRC/WW3/model/ww3_multi)
    (cd Build/ww3_proc/intel/ww3_multi/; \
    ../../../../mkmf/bin/mkmf -t $TEMPLATE_WW3 -p ww3_multi path_names)
    (cd Build/ww3_proc/intel/ww3_multi/; source ../env; make NETCDF=3 REPRO=1 ww3_multi)
endif

if ($BuildWW3shel == 1) then
    echo ''
    echo ''
    echo 'Building ww3_multi'
    echo ''
    echo ''
    #Wave
    #WW3_multi
    mkdir -p Build/ww3_proc/intel/ww3_shel/
    (cd Build/ww3_proc/intel/ww3_shel/; rm -f path_names;\
    ../../../../mkmf/bin/list_paths -l ./ ../../../../../SHiELD_SRC/WW3/model/ww3_shel)
    (cd Build/ww3_proc/intel/ww3_shel/; \
    ../../../../mkmf/bin/mkmf -t $TEMPLATE_WW3 -p ww3_shel path_names)
    (cd Build/ww3_proc/intel/ww3_shel/; source ../env; make NETCDF=3 REPRO=1 ww3_shel)
endif

if ($BuildWW3ounf == 1) then
    echo ''
    echo ''
    echo 'Building ww3_ounf'
    echo ''
    echo ''
    #WW3_ounf
    mkdir -p Build/ww3_proc/intel/ww3_ounf/
    (cd Build/ww3_proc/intel/ww3_ounf/; rm -f path_names; \
    ../../../../mkmf/bin/list_paths -l ./ ../../../../../SHiELD_SRC/WW3/model/ww3_ounf)
    (cd Build/ww3_proc/intel/ww3_ounf/; \
    ../../../../mkmf/bin/mkmf -t $TEMPLATE_WW3 -p ww3_ounf path_names)
    (cd Build/ww3_proc/intel/ww3_ounf/; source ../env; make NETCDF=3 REPRO=1 ww3_ounf)
endif
