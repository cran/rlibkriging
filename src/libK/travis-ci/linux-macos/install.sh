#!/usr/bin/env bash
set -eo pipefail

if [[ "$DEBUG_CI" == "true" ]]; then
  set -x
fi

case "$(uname -s)" in
 Darwin)
   # brew install hdf5
   ;;

 Linux)
   # sudo apt install -y libhdf5-dev
   ;;

 *)
   echo 'Unknown OS'
   exit 1 
   ;;
esac

ROOT_DIR=/home/richet/Sync/Open/libKriging/alien/rlibkriging
if [[ "$ENABLE_PYTHON_BINDING" == "on" ]]; then
  if ( command -v python3 >/dev/null 2>&1 && python3 -m pip --version >/dev/null 2>&1 ); then
    # python3 -m pip install pip # --upgrade # --progress-bar off
    if ( ! python3 "${ROOT_DIR}"/bindings/Python/check_requirements.py --pretty "${ROOT_DIR}"/bindings/Python/requirements.txt "${ROOT_DIR}"/bindings/Python/dev-requirements.txt ); then
      # modern macOS Python installation (using brew) requires to install local packages in a virtual environment
      if [ ! -d "$VIRTUAL_ENV" ]; then
        echo "Preparing virtual environment in ${ROOT_DIR}/venv"
        python3 -m venv "${ROOT_DIR}"/venv
        . "${ROOT_DIR}"/venv/bin/activate
      fi
      python3 -m pip install -r bindings/Python/requirements.txt # --upgrade # --progress-bar off
      python3 -m pip install -r bindings/Python/dev-requirements.txt # --upgrade # --progress-bar off
    fi

    if [[ "$ENABLE_MEMCHECK" == "on" ]]; then
      python3 -m pip install wheel # required ton compile pytest-valgrind
      python3 -m pip install pytest-valgrind
    fi
  fi
fi

if [[ "$ENABLE_COVERAGE" == "on" ]] && [[ "$ENABLE_MEMCHECK" == "on" ]]; then
  echo "Mixing coverage mode and memcheck is not supported"
  exit 1
fi

if [[ "$ENABLE_OCTAVE_BINDING" == "on" ]]; then
  case "$(uname -s)" in
   Darwin)
     # using brew in travis-ci.yml is too slow or fails with "update: true"
     brew install octave gnuplot
     ;;

   Linux)
     if [ "${TRAVIS}" == "true" ]; then
       # add kitware server signature cf https://apt.kitware.com       
       sudo apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common
       curl -s https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
       
       sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
       sudo apt-get install -y cmake # requires cmake ≥3.13 for target_link_options
       test -d /usr/local/cmake-3.12.4 && sudo mv /usr/local/cmake-3.12.4 /usr/local/cmake-3.12.4.old # Overrides Travis installation
       # octave 4 is installed using packager
     fi
     ;;

   *)
     echo 'Unknown OS'
     exit 1 
     ;;
  esac
fi
