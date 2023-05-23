cmake_minimum_required(VERSION 3.23.2)
project(test-project)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(GAME_DIR ${CMAKE_CURRENT_SOURCE_DIR}/game)

function(generate_gdextension_file project_name lib_name)
    add_custom_command(
            TARGET ${project_name} POST_BUILD
            COMMAND python3 ${CMAKE_HOME_DIRECTORY}/gdextension_file_generator.py ${project_name} ${lib_name} .
            COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/*.gdextension ${GAME_DIR}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMENT "Generating gdextension file..."
    )
endfunction()

function(move_compiled_binaries project_name lib_name)
    add_custom_command(
            TARGET ${project_name} POST_BUILD
            COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/*${lib_name}.* ${GAME_DIR}/libs
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMENT "Moving built gdextension lib"
    )
endfunction()

add_subdirectory(extensions/extension)

########################################################################################################################
# GODOT-CPP
########################################################################################################################

include(FetchContent)

FetchContent_Declare(
        GDExtension
        GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
        GIT_TAG godot-4.0.3-stable
)

FetchContent_MakeAvailable(GDExtension)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/gdextension-build/gen/include)

########################################################################################################################