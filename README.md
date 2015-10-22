# CMake Macros and Tools

## Local

1. Clone this repository, and export it:

    ```bash
    git clone git@github.com:azriel91/conan_cmake.git
    cd conan_cmake && conan export demo
    ```
2. Add the requirement into your project's **conanfile.py**:

    ```python
    # Either:
    requires = 'conan_cmake/0.1.0@demo/testing'

    # Or:
    def requirements(self):
        """ Declare here your project requirements or configure any of them """
        self.requires('conan_cmake/0.1.0@demo/testing')
    ```
3. Use the `conan install <settings> <options>` command to download it:

    ```bash
    conan install -s build_type=Debug -s compiler=gcc
    ```

4. Include the CMake macros in the **CMakeLists.txt** file for your conan project:

    ```cmake
    include(conanbuildinfo.cmake)
    conan_basic_setup()

    # Detect conan_cmake directory based on a file we expect to exist
    find_path(conan_cmake_DIR "conanTools.cmake" PATHS ${CONAN_INCLUDE_DIRS})
    include("${conan_cmake_DIR}/conanTools.cmake")
    ```

Now you can use directly the macros defined in **conanTools.cmake**:

```cmake
activate_cpp11(${PROJECT_TARGET}) # Activate C++11 for a target
activate_cpp11(INTERFACE ${PROJECT_TARGET}) # Activate C++11 for an INTERFACE target

add_osx_framework(Foundation ${PROJECT_TARGET}) # Add the foundation OSX Framework
```

## Notes

This was originally from [biicode/cmake](https://www.biicode.com/biicode/cmake).
