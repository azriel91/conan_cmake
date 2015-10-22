from conans import *

class ConanCmakeConan(ConanFile):
    name = 'conan_cmake'
    version = '0.1.0'
    exports = ['conanTools.cmake']

    def package(self):
        self.copy('conanTools.cmake', dst='.', src='.')

    def package_info(self):
        # HACK: This is not the right way to get macros defined by other projects into cmake
        self.cpp_info.includedirs += ['.']
