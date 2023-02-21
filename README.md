# GDExtension Template

***Disclaimer: This template is not fully tested or documented. It is a work in progress.***

Simple GDExtension template. This template uses `scons` to build the `godot-cpp` static library, and `cmake` to build
the actual extension. 

## Getting Started

### Create and Init Repo
In the top right corner click `Use this tempalte` and create a new Git repo. 

After cloning the repo use the following command to init the `godot-cpp` submodule

```bash
git submodule update --init --recursive
```

### Build `godot-cpp`

This project uses `scons` to build `godot-cpp` and `cmake` to build the actual extension. Unless you are making changes 
to the `godot-cpp` source code, you should only need to do this step when building on a new platform or creating a 
`debug` or `release` build

```bash
cd godot-cpp
scons target=template_debug
```

### Modify the Project 

You will probably need to make changes to the cmake file as your project grows, but for now you need
to only change the project name on the first line. 

```cmake
project(<your-extension-name>)
```

### Build the Extension

```bash
mkdir build
cd build
cmake ..
make
```
