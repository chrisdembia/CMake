# - Try to find the OpenSSL encryption library
# Once done this will define
#
#  OPENSSL_ROOT_DIR - Set this variable to the root installation of OpenSSL
#
# Read-Only variables:
#  OPENSSL_FOUND - system has the OpenSSL library
#  OPENSSL_INCLUDE_DIR - the OpenSSL include directory
#  OPENSSL_LIBRARIES - The libraries needed to use OpenSSL
#  OPENSSL_VERSION - This is set to $major.$minor.$revision$path (eg. 0.9.8s)

#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
# Copyright 2009-2011 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

if (UNIX)
  find_package(PkgConfig QUIET)
  pkg_check_modules(_OPENSSL QUIET openssl)
endif (UNIX)

# http://www.slproweb.com/products/Win32OpenSSL.html
SET(_OPENSSL_ROOT_HINTS
  $ENV{OPENSSL_ROOT_DIR}
  ${OPENSSL_ROOT_DIR}
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]"
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (64-bit)_is1;Inno Setup: App Path]"
  )
SET(_OPENSSL_ROOT_PATHS
  "$ENV{PROGRAMFILES}/OpenSSL"
  "$ENV{PROGRAMFILES}/OpenSSL-Win32"
  "$ENV{PROGRAMFILES}/OpenSSL-Win64"
  "C:/OpenSSL/"
  "C:/OpenSSL-Win32/"
  "C:/OpenSSL-Win64/"
  )
SET(_OPENSSL_ROOT_HINTS_AND_PATHS
  HINTS ${_OPENSSL_ROOT_HINTS}
  PATHS ${_OPENSSL_ROOT_PATHS}
  )

FIND_PATH(OPENSSL_INCLUDE_DIR
  NAMES
    openssl/ssl.h
  HINTS
    ${_OPENSSL_INCLUDEDIR}
  ${_OPENSSL_ROOT_HINTS_AND_PATHS}
  PATH_SUFFIXES
    include
)

IF(WIN32 AND NOT CYGWIN)
  # MINGW should go here too
  IF(MSVC)
    # /MD and /MDd are the standard values - if someone wants to use
    # others, the libnames have to change here too
    # use also ssl and ssleay32 in debug as fallback for openssl < 0.9.8b
    # TODO: handle /MT and static lib
    # In Visual C++ naming convention each of these four kinds of Windows libraries has it's standard suffix:
    #   * MD for dynamic-release
    #   * MDd for dynamic-debug
    #   * MT for static-release
    #   * MTd for static-debug

    # Implementation details:
    # We are using the libraries located in the VC subdir instead of the parent directory eventhough :
    # libeay32MD.lib is identical to ../libeay32.lib, and
    # ssleay32MD.lib is identical to ../ssleay32.lib
    FIND_LIBRARY(LIB_EAY_DEBUG
      NAMES
        libeay32MDd
        libeay32
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "VC"
        "lib/VC"
    )

    FIND_LIBRARY(LIB_EAY_RELEASE
      NAMES
        libeay32MD
        libeay32
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "VC"
        "lib/VC"
    )

    FIND_LIBRARY(SSL_EAY_DEBUG
      NAMES
        ssleay32MDd
        ssleay32
        ssl
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "VC"
        "lib/VC"
    )

    FIND_LIBRARY(SSL_EAY_RELEASE
      NAMES
        ssleay32MD
        ssleay32
        ssl
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "VC"
        "lib/VC"
    )

    if( CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE )
      set( OPENSSL_LIBRARIES
        optimized ${SSL_EAY_RELEASE} debug ${SSL_EAY_DEBUG}
        optimized ${LIB_EAY_RELEASE} debug ${LIB_EAY_DEBUG}
        )
    else()
      set( OPENSSL_LIBRARIES ${SSL_EAY_RELEASE} ${LIB_EAY_RELEASE} )
    endif()
    MARK_AS_ADVANCED(SSL_EAY_DEBUG SSL_EAY_RELEASE)
    MARK_AS_ADVANCED(LIB_EAY_DEBUG LIB_EAY_RELEASE)
  ELSEIF(MINGW)
    # same player, for MingW
    FIND_LIBRARY(LIB_EAY
      NAMES
        libeay32
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "lib/MinGW"
    )

    FIND_LIBRARY(SSL_EAY
      NAMES
        ssleay32
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        "lib"
        "lib/MinGW"
    )

    MARK_AS_ADVANCED(SSL_EAY LIB_EAY)
    set( OPENSSL_LIBRARIES ${SSL_EAY} ${LIB_EAY} )
  ELSE(MSVC)
    # Not sure what to pick for -say- intel, let's use the toplevel ones and hope someone report issues:
    FIND_LIBRARY(LIB_EAY
      NAMES
        libeay32
      HINTS
        ${_OPENSSL_LIBDIR}
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        lib
    )

    FIND_LIBRARY(SSL_EAY
      NAMES
        ssleay32
      HINTS
        ${_OPENSSL_LIBDIR}
      ${_OPENSSL_ROOT_HINTS_AND_PATHS}
      PATH_SUFFIXES
        lib
    )

    MARK_AS_ADVANCED(SSL_EAY LIB_EAY)
    set( OPENSSL_LIBRARIES ${SSL_EAY} ${LIB_EAY} )
  ENDIF(MSVC)
ELSE(WIN32 AND NOT CYGWIN)

  FIND_LIBRARY(OPENSSL_SSL_LIBRARY
    NAMES
      ssl
      ssleay32
      ssleay32MD
    HINTS
      ${_OPENSSL_LIBDIR}
    ${_OPENSSL_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
      lib
  )

  FIND_LIBRARY(OPENSSL_CRYPTO_LIBRARY
    NAMES
      crypto
    HINTS
      ${_OPENSSL_LIBDIR}
    ${_OPENSSL_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
      lib
  )

  MARK_AS_ADVANCED(OPENSSL_CRYPTO_LIBRARY OPENSSL_SSL_LIBRARY)

  # compat defines
  SET(OPENSSL_SSL_LIBRARIES ${OPENSSL_SSL_LIBRARY})
  SET(OPENSSL_CRYPTO_LIBRARIES ${OPENSSL_CRYPTO_LIBRARY})

  SET(OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY})

ENDIF(WIN32 AND NOT CYGWIN)

if (OPENSSL_INCLUDE_DIR)
  if (_OPENSSL_VERSION)
    set(OPENSSL_VERSION "${_OPENSSL_VERSION}")
  elseif(OPENSSL_INCLUDE_DIR AND EXISTS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h")
    file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" openssl_version_str
         REGEX "^#define[\t ]+OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])+.*")

    # The version number is encoded as 0xMNNFFPPS: major minor fix patch status
    # The status gives if this is a developer or prerelease and is ignored here.
    # Major, minor, and fix directly translate into the version numbers shown in
    # the string. The patch field translates to the single character suffix that
    # indicates the bug fix state, which 00 -> nothing, 01 -> a, 02 -> b and so
    # on.

    string(REGEX REPLACE "^.*OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F]).*$"
           "\\1;\\2;\\3;\\4;\\5" OPENSSL_VERSION_LIST "${openssl_version_str}")
    list(GET OPENSSL_VERSION_LIST 0 OPENSSL_VERSION_MAJOR)
    list(GET OPENSSL_VERSION_LIST 1 OPENSSL_VERSION_MINOR)
    list(GET OPENSSL_VERSION_LIST 2 OPENSSL_VERSION_FIX)
    list(GET OPENSSL_VERSION_LIST 3 OPENSSL_VERSION_PATCH)

    string(REGEX REPLACE "^0(.)" "\\1" OPENSSL_VERSION_MINOR "${OPENSSL_VERSION_MINOR}")
    string(REGEX REPLACE "^0(.)" "\\1" OPENSSL_VERSION_FIX "${OPENSSL_VERSION_FIX}")

    if (NOT OPENSSL_VERSION_PATCH STREQUAL "00")
      # 96 is the ASCII code of 'a' minus 1
      math(EXPR OPENSSL_VERSION_PATCH_ASCII "${OPENSSL_VERSION_PATCH} + 96")
      # Once anyone knows how OpenSSL would call the patch versions beyond 'z'
      # this should be updated to handle that, too. This has not happened yet
      # so it is simply ignored here for now.
      string(ASCII "${OPENSSL_VERSION_PATCH_ASCII}" OPENSSL_VERSION_PATCH_STRING)
    endif (NOT OPENSSL_VERSION_PATCH STREQUAL "00")

    set(OPENSSL_VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX}${OPENSSL_VERSION_PATCH_STRING}")
  endif (_OPENSSL_VERSION)
endif (OPENSSL_INCLUDE_DIR)

include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)

if (OPENSSL_VERSION)
  find_package_handle_standard_args(OpenSSL
    REQUIRED_VARS
      OPENSSL_LIBRARIES
      OPENSSL_INCLUDE_DIR
    VERSION_VAR
      OPENSSL_VERSION
    FAIL_MESSAGE
      "Could NOT find OpenSSL, try to set the path to OpenSSL root folder in the system variable OPENSSL_ROOT_DIR"
  )
else (OPENSSL_VERSION)
  find_package_handle_standard_args(OpenSSL "Could NOT find OpenSSL, try to set the path to OpenSSL root folder in the system variable OPENSSL_ROOT_DIR"
    OPENSSL_LIBRARIES
    OPENSSL_INCLUDE_DIR
  )
endif (OPENSSL_VERSION)

MARK_AS_ADVANCED(OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES)