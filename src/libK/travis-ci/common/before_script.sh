#!/usr/bin/env bash
set -eo pipefail

if [[ "$DEBUG_CI" == "true" ]]; then
    echo "------------------------------------"

    BASEDIR=$(dirname "$0")
    if [ -e "${BASEDIR}"/../${BUILD_NAME}/loadenv.sh ]; then
      set -x
      . "${BASEDIR}"/../${BUILD_NAME}/loadenv.sh
      set +x
    else
      echo "No custom loadenv.sh"
    fi
    echo "PATH=$PATH"

    echo "------------------------------------"

    if ( command -v c++ >/dev/null 2>&1 ); then
      echo "C++ config: $(command -v c++)"
      c++ --version 2>&1 | sed 's/^/  /'
    else
      echo "No C++ command found"
    fi

    echo "------------------------------------"

    if ( command -v gfortran >/dev/null 2>&1 ); then
      echo "Fortran config: $(command -v gfortran)"
      gfortran --version 2>&1 | sed 's/^/  /'
    else
      echo "No Fortran compiler command found"
    fi
    
    echo "------------------------------------"

    if ( R CMD config FC >/dev/null 2>&1 ); then
      FC=$(R CMD config FC | awk '{ print $1 }')
      echo "R Fortran config: ${FC}"
      ${FC} --version 2>&1 | sed 's/^/  /'
    else
      echo "No R Fortran compiler command found"
    fi

    echo "------------------------------------"

    if ( command -v clang-format >/dev/null 2>&1 ); then
      echo "clang-format config: $(command -v clang-format)"
      clang-format --version 2>&1 | sed 's/^/  /'
    else
      echo "No clang-format command found"
    fi

    echo "------------------------------------"

    if ( command -v cmake >/dev/null 2>&1 ); then
      echo "CMake config: $(command -v cmake)"
      cmake --version 2>&1 | sed 's/^/  /'
    else
      echo "No cmake command found"
    fi
          
    echo "------------------------------------"

    if ( command -v make >/dev/null 2>&1 ); then
      echo "Make config: $(command -v make)"
      make --version 2>&1 | sed 's/^/  /'
    else
      echo "No make command found"
    fi

    echo "------------------------------------"

    if ( command -v octave-config >/dev/null 2>&1 ); then
      echo "Octave config: $(command -v octave-config)"
      octave-config --version 2>&1 | sed 's/^/  /'
    else
      echo "No octave-config command found"
    fi

    echo "------------------------------------"

    if ( command -v matlab >/dev/null 2>&1 ); then
      echo "Matlab config: $(command -v matlab)"
      matlab -batch "ver; exit" 2>&1 | sed 's/^/  /'
    else
      echo "No matlab command found"
    fi

    echo "------------------------------------"
    if ( command -v R >/dev/null 2>&1 ); then
      echo "R config: $(command -v R)"
      R --version 2>&1 | sed 's/^/  /'
    else
      echo "No R command found"
    fi

    echo "------------------------------------"

    # Python3 is named python in Windows, but we add a symlink
    if ( command -v python3 >/dev/null 2>&1 ); then
      echo "Python3 config: $(command -v python3)"
      {
        python3 --version 2>&1 | sed 's/^/  /'
      } || {
        echo "Cannot execute python3 --version"
      }
    else
      echo "No python3 command found"
    fi

    echo "------------------------------------"

    echo "EXTRA_CMAKE_OPTIONS = ${EXTRA_CMAKE_OPTIONS}"

    echo "------------------------------------"

fi
