cmake_minimum_required(VERSION 3.19)

project(test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

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

########################################################################################################################
# Debug Options
########################################################################################################################

if (CMAKE_BUILD_TYPE STREQUAL "")
	message(STATUS "Setting debug build as default")
	set(CMAKE_BUILD_TYPE Debug)
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(GODOT_CPP_BUILD_TYPE debug)
	set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -fno-omit-frame-pointer -O0")
else()
	set(GODOT_CPP_BUILD_TYPE release)
	set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -O3")
endif()

########################################################################################################################
# GODOT-CPP
########################################################################################################################

include(FetchContent)

FetchContent_Declare(
		GDExtension
		GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
		GIT_TAG godot-4.0-stable
)

FetchContent_MakeAvailable(GDExtension)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/gdextension-build/gen/include)

########################################################################################################################

include_directories(src/headers)

# Automatically pick up files added to src
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
	 "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h*"
	 "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
	 "${CMAKE_CURRENT_SOURCE_DIR}/src/headers/*.h*)"
	 "${CMAKE_CURRENT_SOURCE_DIR}/src/sources/*.cpp")

add_library(${PROJECT_NAME} SHARED ${SOURCES})

target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(${PROJECT_NAME} PUBLIC godot::cpp)

source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}/src" PREFIX src FILES ${SOURCES})

set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${GODOT_COMPILE_FLAGS})

set(LIB_OUTPUT_NAME "${PROJECT_NAME}.${TARGET_PLATFORM}.${GODOT_CPP_BUILD_TYPE}.${TARGET_ARCH}")
set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME ${LIB_OUTPUT_NAME})

execute_process(COMMAND python3 gdextension_file_generator.py ${PROJECT_NAME} ${LIB_OUTPUT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
