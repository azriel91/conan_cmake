# CMake Macros and Tools

1. Add the requirement into your project's **conanfile.py**:

    ```python
    # Either:
    requires = 'conan_cmake/0.1.0@azriel91/stable'

    # Or:
    def requirements(self):
        """ Declare here your project requirements or configure any of them """
        self.requires('conan_cmake/0.1.0@azriel91/stable')
    ```

2. Use the `conan install [settings] [options]` command to download it:

    ```bash
    conan install --build=missing
    ```

3. Include the CMake macros in the **CMakeLists.txt** file for your conan project:

    ```cmake
    include(conanbuildinfo.cmake)
    conan_basic_setup()
    include("${CONAN_CONAN_CMAKE_ROOT}/conanTools.cmake")
    ```

Now you can use directly the macros defined in **conanTools.cmake**:

```cmake
activate_cpp11(${PROJECT_TARGET}) # Activate C++11 for a target
activate_cpp11(INTERFACE ${PROJECT_TARGET}) # Activate C++11 for an INTERFACE target

add_osx_framework(Foundation ${PROJECT_TARGET}) # Add the foundation OSX Framework
```

## Notes

This was originally from [biicode/cmake](https://www.biicode.com/biicode/cmake), and adapted for [conan](https://www.conan.io/).
