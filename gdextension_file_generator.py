import os
import sys

"""
This script generates the .gdextension file necessary for importing the 
extension shared library into your godot project. This script is called 
automatically by the CMakeLists.txt file. 

Example:
python3 gdextension_file_generator.py <project-name> <lib-filename>
"""


def main(args):
    """
    main

    :param args: program args
    """
    project_name = args[1]
    lib = args[2]

    gd_extension_filename = f"{project_name}.gdextension"

    if os.path.exists(gd_extension_filename):
        lib_line = create_gdextension_lib_string(lib)
        with open(gd_extension_filename, "r") as fin:
            lib_already_present = any([lib_line in line for line in fin.readlines()]) is True
        if not lib_already_present:
            with open(gd_extension_filename, "a") as fout:
                fout.write(f"{lib_line}\n")
    else:
        with open(gd_extension_filename, "w") as fout:
            file_contents = create_gdextension_file_contents(lib)
            fout.write(file_contents)


def create_gdextension_file_contents(lib):
    """
    Generate the contents for a .gdextension file

    :param lib: library filename
    :return: .gdextension file contents
    """
    function_name = get_entry_point_name()

    lib_string = create_gdextension_lib_string(lib)

    contents = \
        f"""[configuration]
  
entry_symbol = \"{function_name}\"
 
[libraries]
   
{lib_string}
"""
    return contents


def get_entry_point_name():
    with open("src/register_types.cpp") as f:
        for line in f.readlines():
            if "GDE_EXPORT" in line:
                return line.split("GDE_EXPORT")[1].split("(")[0].strip()  # Should probably be a proper regex
    return ""


def get_platform_dynamic_library_extension(platform):
    return {
        "macos": "dylib",
        "linux": "so",
        "windows": "dll"
    }[platform]


def create_gdextension_lib_string(lib):
    """
    Create gdextension lib string

    Expected lib filename format
    <lib-name>.<platform>.<build-type>.<architecture>

    :param lib: lib filename
    :return: formatted line string to be added to .gdextension file
    """
    items = lib.split(".")
    platform = items[1]
    build_type = items[2].replace('template_', '')
    arch = "" if platform == "macos" else "." + items[3]
    ext = get_platform_dynamic_library_extension(platform)
    lib_string = f"{platform}.{build_type}{arch} = \"res://libs/lib{lib}.{ext}\""
    return lib_string


if __name__ == "__main__":
    main(sys.argv)
