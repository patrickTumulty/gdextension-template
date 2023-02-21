project(test)
cmake_minimum_required(VERSION 3.6)

set(GODOT_GDEXTENSION_DIR godot-cpp/gdextension/ CACHE STRING "Path to GDExtension interface header directory")
set(CPP_BINDINGS_PATH godot-cpp/ CACHE STRING "Path to C++ bindings")

if (CMAKE_BUILD_TYPE STREQUAL "")
	message(STATUS "Setting debug build as default")
	set(CMAKE_BUILD_TYPE Debug)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(TARGET_PLATFORM linux)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	set(TARGET_PLATFORM win64)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	set(TARGET_PLATFORM macos)
else()
	message(FATAL_ERROR "Not implemented support for ${CMAKE_SYSTEM_NAME}")
endif()

if(TARGET_PLATFORM STREQUAL "macos")
	set(TARGET_ARCH "universal")
else()
	set(TARGET_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

# Set the c++ standard to c++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(GODOT_COMPILE_FLAGS )
set(GODOT_LINKER_FLAGS )

set(GODOT_LINKER_FLAGS "-Wl")

set(GODOT_COMPILE_FLAGS "-fPIC -g -Wwrite-strings")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wchar-subscripts -Wcomment -Wdisabled-optimization")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wformat -Wformat=2 -Wformat-security -Wformat-y2k")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wimport -Winit-self -Winline -Winvalid-pch -Werror")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wmissing-braces -Wmissing-format-attribute")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wmissing-include-dirs -Wmissing-noreturn -Wpacked -Wpointer-arith")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wredundant-decls -Wreturn-type -Wsequence-point")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wswitch -Wswitch-enum -Wtrigraphs")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wuninitialized -Wunknown-pragmas -Wunreachable-code -Wunused-label")
set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wunused-value -Wvariadic-macros -Wvolatile-register-var -Wno-error=attributes")

# -Wshadow -Wextra -Wall -Weffc++ -Wfloat-equal -Wstack-protector -Wunused-parameter -Wsign-compare -Wunused-variable -Wcast-align
# -Wunused-function -Wstrict-aliasing -Wstrict-aliasing=2 -Wmissing-field-initializers

set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -Wno-ignored-attributes")

if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -fno-omit-frame-pointer -O0")
else()
	set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -O3")
endif()

include_directories(godot-cpp/gen/include
					godot-cpp/include
					godot-cpp/gdextension)

file(GLOB_RECURSE SOURCES src/*.c**)
file(GLOB_RECURSE HEADERS include/*.h**)

add_library(${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS})

target_include_directories(${PROJECT_NAME} PRIVATE ${CPP_BINDINGS_PATH}/bin)

if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(GODOT_CPP_BUILD_TYPE template_debug)
else()
	set(GODOT_CPP_BUILD_TYPE template_release)
endif()

target_link_directories(${PROJECT_NAME} PRIVATE ${CPP_BINDINGS_PATH}/bin/)
target_link_libraries(${PROJECT_NAME} godot-cpp.${TARGET_PLATFORM}.${GODOT_CPP_BUILD_TYPE}.${TARGET_ARCH}.a)

# Add the compile flags
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${GODOT_COMPILE_FLAGS})
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS ${GODOT_LINKER_FLAGS})

set(LIB_OUTPUT_NAME "${PROJECT_NAME}.${TARGET_PLATFORM}.${GODOT_CPP_BUILD_TYPE}.${TARGET_ARCH}")
set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME ${LIB_OUTPUT_NAME})

execute_process(COMMAND python3 gdextension_file_generator.py ${PROJECT_NAME} ${LIB_OUTPUT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
