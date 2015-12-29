from conans import *

class ConanCmakeConan(ConanFile):
    name = 'conan_cmake'
    version = '0.2.0'
    exports = ['conanTools.cmake']

    def package(self):
        self.copy('conanTools.cmake', dst='.', src='.')
