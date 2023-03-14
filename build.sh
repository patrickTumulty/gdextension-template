#!/bin/bash
read -rd '' HELP_TEXT << EOF
GD Extension Build Script

Options:
  --help         : Print help text
  --bt           : Type of build (Debug, Release) (Debug if not specified)
  --cpgdf        : Copy generated .gdextension file into game dir 

Example:
  $ ./build.sh --bt=Debug --cpgdf

EOF


BUILD_TYPE=Debug
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
  elif [ "$arg" == --cpgdf ]; then
    COPY_FILES=TRUE
  fi
done

mkdir -p build/
cd build || exit 1
cmake -D CMAKE_BUILD_TYPE="$BUILD_TYPE" ..
make
cd ..

if [ $COPY_FILES == TRUE ]; then
  cp build/*.dylib game/libs 2>/dev/null
  cp build/*.so game/libs 2>/dev/null
  cp build/*.dll game/libs 2>/dev/null
  cp ./*.gdextension game/ 2>/dev/null
fi

