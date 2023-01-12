#!/usr/bin/env bash
set -eo pipefail

if [[ "$DEBUG_CI" == "true" ]]; then
  set -x
fi

LIBKRIGING_SRC_PATH=src/libK

# Cleanup unused (for R) libKriging deps
rm -rf $LIBKRIGING_SRC_PATH/dependencies/Catch2
rm -rf $LIBKRIGING_SRC_PATH/dependencies/carma
rm -rf $LIBKRIGING_SRC_PATH/dependencies/pybind11
rm -rf $LIBKRIGING_SRC_PATH/dependencies/optim
rm -rf $LIBKRIGING_SRC_PATH/docs
 # then remove LinearRegressionOptim example
sed -i.bak "s/LinearRegression/##LinearRegression/g" $LIBKRIGING_SRC_PATH/src/lib/CMakeLists.txt
rm -f $LIBKRIGING_SRC_PATH/src/lib/CMakeLists.txt.bak

rm -f $LIBKRIGING_SRC_PATH/bindings/R/rlibkriging/src/linear_regression*
 # & unsuitable tests
rm -f $LIBKRIGING_SRC_PATH/bindings/R/rlibkriging/tests/testthat/test-binding-consistency.R

# Move required on upper path to avoid path length issues
if [ -d $LIBKRIGING_SRC_PATH/dependencies/lbfgsb_cpp ]; then
  rm -fr $LIBKRIGING_SRC_PATH/lbfgsb_cpp
  mv $LIBKRIGING_SRC_PATH/dependencies/lbfgsb_cpp $LIBKRIGING_SRC_PATH/.
  rm -rf $LIBKRIGING_SRC_PATH/dependencies/lbfgsb_cpp
elif [ ! -d $LIBKRIGING_SRC_PATH/lbfgsb_cpp ]; then
  echo "Cannot migrate lbfgsb_cpp dependency"
  exit 1
fi

if [ -d $LIBKRIGING_SRC_PATH/dependencies/armadillo-code ]; then
  rm -fr $LIBKRIGING_SRC_PATH/armadillo
  mkdir -p $LIBKRIGING_SRC_PATH/armadillo
  mv $LIBKRIGING_SRC_PATH/dependencies/armadillo-code/include $LIBKRIGING_SRC_PATH/armadillo/.
  mv $LIBKRIGING_SRC_PATH/dependencies/armadillo-code/src $LIBKRIGING_SRC_PATH/armadillo/.
  mv $LIBKRIGING_SRC_PATH/dependencies/armadillo-code/misc $LIBKRIGING_SRC_PATH/armadillo/.
  mv $LIBKRIGING_SRC_PATH/dependencies/armadillo-code/cmake_aux $LIBKRIGING_SRC_PATH/armadillo/.
  mv $LIBKRIGING_SRC_PATH/dependencies/armadillo-code/CMakeLists.txt $LIBKRIGING_SRC_PATH/armadillo/.
  rm -rf $LIBKRIGING_SRC_PATH/dependencies/armadillo-code
elif [ ! -d $LIBKRIGING_SRC_PATH/armadillo ]; then
  echo "Cannot migrate armadillo dependency"
  exit 1
fi
rm -fr $LIBKRIGING_SRC_PATH/dependencies

# Use custom CMakeList to hold these changes
cp tools/libKriging_CMakeLists.txt $LIBKRIGING_SRC_PATH/CMakeLists.txt

# Switch slapack dependency as a local submodule (not a git clone)
sed -i.bak -e "s|https://github.com/libKriging/slapack.git|\${CMAKE_CURRENT_SOURCE_DIR}/../../slapack|g" \
  $LIBKRIGING_SRC_PATH/armadillo/cmake_aux/Modules/ARMA_FindLAPACK.cmake
sed -i.bak -e "s|GIT_REPOSITORY|SOURCE_DIR|g" \
  $LIBKRIGING_SRC_PATH/armadillo/cmake_aux/Tools/build_external_project.cmake

# .travis-ci -> travis-ci (hidden files not allowed in CRAN)
if [ -d $LIBKRIGING_SRC_PATH/.travis-ci ]; then
  mv $LIBKRIGING_SRC_PATH/.travis-ci $LIBKRIGING_SRC_PATH/travis-ci
fi
# rename .travis-ci in travis-ci everywhere. Use temp .bak for sed OSX compliance
find $LIBKRIGING_SRC_PATH -type f -exec sed -i.bak "s/\.travis-ci/travis-ci/g" {} +
find $LIBKRIGING_SRC_PATH -type f -name *.bak -exec rm -f {} +;


RLIBKRIGING_PATH=$LIBKRIGING_SRC_PATH"/bindings/R/rlibkriging/"

# overwrite libK/src/Makevars* with ./src/Makevars*
cp src/Makevars* $RLIBKRIGING_PATH/src/.

# copy resources from libK/binding/R
rm -rf R
cp -r $RLIBKRIGING_PATH/R .
rm -rf src/*.cpp
cp -r $RLIBKRIGING_PATH/src .
cp -r $RLIBKRIGING_PATH/NAMESPACE .
rm -rf tests
cp -r $RLIBKRIGING_PATH/tests .
# detailed tests
#  remove previous loading of previous custom testthat & rlibkriging (that should not be there, anyway)
find tests/testthat -type f -name test-*.R -exec sed -i.bak -e 's|library(testthat)|#library(testthat)|g' {} +
find tests/testthat -type f -name test-*.R -exec sed -i.bak -e 's|library(rlibkriging|#library(rlibkriging|g' {} +
#  prepend loading of testthat
mv tests/testthat/test-*.R tests/.
for f in `ls -d tests/*.R`; do
  echo -e "library(testthat)\n Sys.setenv('OMP_THREAD_LIMIT'=2)\n library(rlibkriging)\n" > $f.new
  echo "$(cat $f)" >> $f.new
  mv $f.new $f
done
rm -rf tests/testthat/
rm -rf tests/testthat.R

# sync man content
rm -rf man
Rscript -e "roxygen2::roxygenise(package.dir = '.')"
rm -rf $LIBKRIGING_SRC_PATH/build
