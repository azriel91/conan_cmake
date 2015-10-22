###############################################################
#  Print target properties
#
#  Uses: echo_target_property(${BII_BLOCK_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
#        echo_target_property(${BII_BLOCK_TARGET} INTERFACE_LINK_LIBRARIES)
#        echo_target_property(${BII_BLOCK_TARGET} INTERFACE_COMPILE_DEFINITIONS)
###################################################

function(ECHO_TARGET_PROPERTY tgt prop)
  # v for value, d for defined, s for set
  get_property(v TARGET ${tgt} PROPERTY ${prop})
  get_property(d TARGET ${tgt} PROPERTY ${prop} DEFINED)
  get_property(s TARGET ${tgt} PROPERTY ${prop} SET)

  # only produce output for values that are set
  if(s)
    message("target='${tgt}' prop='${prop}'")
    message("  value='${v}'")
    message("  defined='${d}'")
    message("  set='${s}'")
    message("")
  endif()
endfunction()

###############################################################
#  ACTIVATE c++11
#
#  Uses: activate_cpp11()
#        activate_cpp11(TARGET) # Default mode PUBLIC
#        activate_cpp11(MODE TARGET)
###################################################
macro(ACTIVATE_CPP11)
  set(extra_macro_args ${ARGN})
  # Did we get any optional args?
  list(LENGTH extra_macro_args num_extra_args)
  if(${num_extra_args} EQUAL 0) # No target, just compile flags
    message("Activating C++11 flags")
    if(APPLE)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
    elseif(WIN32 OR UNIX)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    endif(APPLE)
  elseif(${num_extra_args} EQUAL 1)
    list(GET extra_macro_args 0 target)
    message("Activating C++11 for PUBLIC target '${target}'")
    if(APPLE)
      target_compile_options(${target} PUBLIC -std=c++11 -stdlib=libc++)
    elseif(WIN32 OR UNIX)
      target_compile_options(${target} PUBLIC -std=c++11)
    endif(APPLE)
  elseif(${num_extra_args} EQUAL 2)
    list(GET extra_macro_args 0 mode)
    list(GET extra_macro_args 1 target)
    message("Activating C++11 for ${mode} target '${target}'")
    if(APPLE)
      target_compile_options(${target} ${mode} -std=c++11 -stdlib=libc++)
    elseif(WIN32 OR UNIX)
      target_compile_options(${target} ${mode} -std=c++11)
    endif(APPLE)
  endif()
endmacro(ACTIVATE_CPP11)


###################################################
# LINKS A OSX FRAMEWORK TO A TARGET
# EX:
#   add_osx_framework(Foundation ${BII_LIB_TARGET})
#
###################################################
macro(ADD_OSX_FRAMEWORK fwname target)
  find_library(FRAMEWORK_${fwname}
               NAMES ${fwname}
               PATHS ${CMAKE_OSX_SYSROOT}/System/Library
               PATH_SUFFIXES Frameworks
               NO_DEFAULT_PATH)
  if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
    message(ERROR ": Framework ${fwname} not found")
  else()
    target_link_libraries(${target} PUBLIC "${FRAMEWORK_${fwname}}/${fwname}")
    message(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
  endif()
endmacro(ADD_FRAMEWORK)

###############################################################
#   Operating System detection variables                      #
###############################################################
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(LINUX TRUE)
else()
  set(LINUX FALSE)
endif()

if(CMAKE_CXX_COMPILER MATCHES ".*clang")
  set(CLANG TRUE)
else()
  set(CLANG FALSE)
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  set(GCC TRUE)
else()
  set(GCC FALSE)
endif()

# Define PROGRAMFILES86_PATH and PROGRAMFILES_PATH if EXISTS
if(WIN32)
  set(BINDIR32_ENV_NAME "ProgramFiles(x86)")
  set(BINDIR_ENV_NAME "ProgramFiles")
  if(EXISTS $ENV{${BINDIR32_ENV_NAME}})
    set(PROGRAMFILES86_PATH $ENV{${BINDIR32_ENV_NAME}})
  endif()
  if(EXISTS $ENV{${BINDIR_ENV_NAME}})
    set(PROGRAMFILES_PATH  $ENV{${BINDIR_ENV_NAME}})
  endif()
endif()

##################################################################################################
#  DYNAMIC CUSTOM FIND_LIBRARY DECLARATOR
#  EX: inline_find_package(BITSCOPELIB bitlib.h "${PROGRAMFILES86_PATH}/BitScope/Library" BitLib "${PROGRAMFILES86_PATH}/BitScope")
#  returns (for this example):
#        - BITSCOPELIB_FOUND: Filled with True or False
#        - BITSCOPELIB_INCLUDE_DIRS and BITSCOPELIB_LIBRARIES, filled with the found libraries
#  USE EXAMPLE OF RETURN:
#     if(NOT BITSCOPELIB_FOUND)
#        message(FATAL_ERROR "Package BitScopeLib not found")
#     endif()
#
#     include_directories(${BITSCOPELIB_INCLUDE_DIRS})
#     target_link_libraries(${BII_LIB_TARGET} PUBLIC ${BITSCOPELIB_LIBRARIES})
#################################################################################################
macro(INLINE_FIND_PACKAGE LIB INCLUDE_NAME INCLUDE_PATH LIB_NAME LIB_PATH)

  # Try to find ${LIB} library
  # Once done this will define
  #  ${LIB}_FOUND - if system found ${LIB} library
  #  ${LIB}_INCLUDE_DIRS - The ${LIB} include directories
  #  ${LIB}_LIBRARIES - The libraries needed to use ${LIB}
  #  ${LIB}_DEFINITIONS - Compiler switches required for using ${LIB}

  find_path("${LIB}_INCLUDE_DIR"
            NAMES ${INCLUDE_NAME}
            PATHS /usr/include /usr/local/include "${INCLUDE_PATH}"
            DOC "The ${LIB} include directory")

  find_library("${LIB}_LIBRARY"
               NAMES ${LIB_NAME}
               PATHS /usr/lib /usr/local/lib "${LIB_PATH}"
               DOC "The ${LIB} library")

  include(FindPackageHandleStandardArgs)
  # handle the QUIETLY and REQUIRED arguments and set LOGGING_FOUND to TRUE
  # if all listed variables are TRUE
  find_package_handle_standard_args("${LIB}" DEFAULT_MSG "${LIB}_INCLUDE_DIR" "${LIB}_LIBRARY")

  if(${${LIB}_FOUND})
    set("${LIB}_LIBRARIES" ${${LIB}_LIBRARY})
    set("${LIB}_INCLUDE_DIRS" ${${LIB}_INCLUDE_DIR})
    set("${LIB}_DEFINITIONS")
  endif()

  # Tell cmake GUIs to ignore the "local" variables.
  mark_as_advanced("${LIB}_INCLUDE_DIR" "${LIB}_LIBRARY")
endmacro()

##################################
#  LIST MANIPULATION
##################################

##################################
#  REMOVE FROM LIST IF MATCH AN ER
#  EX: remove_if_matches(BII_LIB_SRC "macos/(.*)")
##################################
macro(REMOVE_IF_MATCHES THELIST REGEX)
  foreach(loop_var ${${THELIST}})
    if(loop_var MATCHES ${REGEX})
      list(REMOVE_ITEM ${THELIST} ${loop_var})
    endif()
  endforeach()
endmacro()


################################################################################
# Macro definitions for some simple CMake utility functions: Thanks to https://github.com/glehmann/WrapITK
################################################################################

################################################################################
# Functions for list operations.
################################################################################

macro(SORT var_name list)
  # Sort the given list and store it in var_name.
  set(sort_tmp1 "")
  foreach(l ${list})
    set(sort_inserted 0)
    set(sort_tmp2 "")
    foreach(l1 ${sort_tmp1})
      if("${l}" STRLESS "${l1}" AND ${sort_inserted} EQUAL 0)
        set(sort_tmp2 ${sort_tmp2} "${l}" "${l1}")
        set(sort_inserted 1)
      else("${l}" STRLESS "${l1}" AND ${sort_inserted} EQUAL 0)
        set(sort_tmp2 ${sort_tmp2} "${l1}")
      endif("${l}" STRLESS "${l1}" AND ${sort_inserted} EQUAL 0)
    endforeach(l1)
    if(${sort_inserted} EQUAL 0)
      set(sort_tmp1 ${sort_tmp1} "${l}")
    else(${sort_inserted} EQUAL 0)
      set(sort_tmp1 ${sort_tmp2})
    endif(${sort_inserted} EQUAL 0)
  endforeach(l)
  set(${var_name} ${sort_tmp1})
endmacro(SORT)

macro(UNIQUE var_name list)
  # Make the given list have only one instance of each unique element and
  # store it in var_name.
  set(unique_tmp "")
  foreach(l ${list})
    if(NOT "${unique_tmp}" MATCHES "(^|;)${l}(;|$)")
    set(unique_tmp ${unique_tmp} ${l})
    endif(NOT "${unique_tmp}" MATCHES "(^|;)${l}(;|$)")
  endforeach(l)
  set(${var_name} ${unique_tmp})
endmacro(UNIQUE)

macro(INTERSECTION var_name list1 list2)
  # Store the intersection between the two given lists in var_name.
  set(intersect_tmp "")
  foreach(l ${list1})
    if("${list2}" MATCHES "(^|;)${l}(;|$)")
    set(intersect_tmp ${intersect_tmp} ${l})
    endif("${list2}" MATCHES "(^|;)${l}(;|$)")
  endforeach(l)
  set(${var_name} ${intersect_tmp})
endmacro(INTERSECTION)

macro(REMOVE var_name list1 list2)
  # Remove elements in list2 from list1 and store the result in var_name.
  set(filter_tmp "")
  foreach(l ${list1})
    if(NOT "${list2}" MATCHES "(^|;)${l}(;|$)")
    set(filter_tmp ${filter_tmp} ${l})
    endif(NOT "${list2}" MATCHES "(^|;)${l}(;|$)")
  endforeach(l)
  set(${var_name} ${filter_tmp})
endmacro(REMOVE)
