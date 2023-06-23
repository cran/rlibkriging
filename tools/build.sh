#!/usr/bin/env bash
set -eo pipefail

if [[ "$DEBUG_CI" == "true" ]]; then
  set -x
fi


# Setup used/unused bindings
export ENABLE_R_BINDING=ON
export ENABLE_OCTAVE_BINDING=OFF
export ENABLE_MATLAB_BINDING=OFF
export ENABLE_PYTHON_BINDING=OFF

export MAKE_SHARED_LIBS=off

: ${R_HOME=$(R RHOME)}
if test -z "${R_HOME}"; then
   as_fn_error $? "Could not determine R_HOME." "$LINENO" 5
fi

# Static libKriging build (using libK/.ci)
cd src/libK
CI=`ls -a | grep travis-ci`
echo $CI

{
$CI/common/before_script.sh
} || {
echo "!!! Failed checking configuration !!!"
}

export CC=`${R_HOME}/bin/R CMD config CC`
export CXX=`${R_HOME}/bin/R CMD config CXX`
export FC=`${R_HOME}/bin/R CMD config FC`

# R workflow requires to use R cmd with full path.
# These declarations help to skip declaration without full path in libKriging build scripts.
export CMAKE_Fortran_COMPILER="$(${R_HOME}/bin/R CMD config FC | awk '{ print $1 }')"
export Fortran_LINK_FLAGS="$(${R_HOME}/bin/R CMD config FLIBS)"

echo "----------------------------------------------------------------"
echo "Look for HDF5 installation"
# Get HDF5 installation if available from R package Rhdf5lib
RHDF5_PATH=$(${R_HOME}/bin/Rscript -e "system.file(package='Rhdf5lib')" | sed -e 's/^\[[0-9]\] "//' | sed -e 's/"$//')
if [ -n "${RHDF5_PATH}" ]; then
  rm -fr ../../inst/hdf5
  mkdir -p ../../inst/hdf5
  cp -r "${RHDF5_PATH}/include" ../../inst/hdf5/.
  cp -r "${RHDF5_PATH}/lib" ../../inst/hdf5/.
  export HDF5_ROOT="$PWD/../../inst/hdf5"
  # find "$HDF5_ROOT" # for deep investigations
fi
# EXTRA_CMAKE_OPTIONS="${EXTRA_CMAKE_OPTIONS:-} --debug-find-pkg=HDF5" # only for cmake ≥3.23
echo "----------------------------------------------------------------"

# Prevent conflict with hdf5-targets.cmake (cf libKriging/cmake/FindHDF5.cmake:504)
EXTRA_CMAKE_OPTIONS="${EXTRA_CMAKE_OPTIONS:-} -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=TRUE"

BUILD_TEST=false \
MODE=Release \
EXTRA_CMAKE_OPTIONS="${EXTRA_CMAKE_OPTIONS:-} -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=${MAKE_SHARED_LIBS} -DEXTRA_SYSTEM_LIBRARY_PATH=${EXTRA_SYSTEM_LIBRARY_PATH}" \
$CI/linux-macos/build.sh # should support '.travis-ci' or 'travis-ci'"

mv ../../inst/hdf5 ../../hdf5
rm -rf ../../inst
mkdir -p ../../inst
mv ../../hdf5 ../../inst/hdf5
mv build/installed/lib ../../inst/.
mv build/installed/share ../../inst/.
mv build/installed/include ../../inst/.

cd ../..

# update doc
#Rscript -e "roxygen2::roxygenise(package.dir = '.')" # No: it will loop on install, because roxygen2 requires loading package...
# update Rccp links
${R_HOME}/bin/Rscript -e "Rcpp::compileAttributes(pkgdir = '.', verbose = TRUE)"
