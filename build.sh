#!/bin/bash
read -rd '' HELP_TEXT << EOF
GD Extension Build Script

Options:
  --help         : Print help text
  --bt           : Type of build (Debug, Release) (Debug if not specified)
  --extension    : Build gdextension library
  --godot-cpp    : Build godot-cpp with scons
  --cpgdf        : Copy generated .gdextension file into game dir 

Example:
  $ ./build.sh --bt=Debug --extension --godot-cpp --cpgdf

EOF


BUILD_TYPE=Debug
GODOT_CPP=FALSE
GDEXTENSION=FALSE
COPY_FILES=FALSE

parseValue() {
  inputArg=$1
  # shellcheck disable=SC2206
  arrIn=(${inputArg//=/ })
  echo "${arrIn[1]}"
}

for arg in "$@"
do
  if [[ "$arg" == --help ]]; then
    echo "$HELP_TEXT"
    exit 0
  elif [[ "$arg" == --build-type=* ]]; then
    BUILD_TYPE=$(parseValue "$arg")
  elif [ "$arg" == --godot-cpp ]; then
    GODOT_CPP=TRUE
  elif [ "$arg" == --extension ]; then
    GDEXTENSION=TRUE
  elif [ "$arg" == --cpgdf ]; then
    COPY_FILES=TRUE
  fi
done

if [ $GODOT_CPP == TRUE ]; then
  cd godot-cpp || exit 1
  GD_CPP_BUILD_TYPE=template_debug
  if [ "$BUILD_TYPE" == Release ]; then
    GD_CPP_BUILD_TYPE=template_release
  fi
  scons target=$GD_CPP_BUILD_TYPE
  cd ..
fi

if [ $GDEXTENSION == TRUE ]; then 
  mkdir -p build/
  cd build || exit 1
  cmake -D CMAKE_BUILD_TYPE="$BUILD_TYPE" ..
  make
  cd ..
fi

if [ $COPY_FILES == TRUE ]; then
  cp build/*.dylib game/libs
  cp build/*.so game/libs
  cp build/*.dll game/libs
  cp ./*.gdextension game/
fi

