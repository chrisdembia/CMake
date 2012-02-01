# - Try to find the LibXml2 xml processing library
# Once done this will define
#
#  LIBXML2_FOUND - System has LibXml2
#  LIBXML2_INCLUDE_DIR - The LibXml2 include directory
#  LIBXML2_LIBRARIES - The libraries needed to use LibXml2
#  LIBXML2_DEFINITIONS - Compiler switches required for using LibXml2
#  LIBXML2_XMLLINT_EXECUTABLE - The XML checking tool xmllint coming with LibXml2
#  LIBXML2_VERSION_STRING - the version of LibXml2 found (since CMake 2.8.8)

#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
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

# use pkg-config to get the directories and then use these values
# in the FIND_PATH() and FIND_LIBRARY() calls
FIND_PACKAGE(PkgConfig QUIET)
PKG_CHECK_MODULES(PC_LIBXML QUIET libxml-2.0)
SET(LIBXML2_DEFINITIONS ${PC_LIBXML_CFLAGS_OTHER})

FIND_PATH(LIBXML2_INCLUDE_DIR NAMES libxml/xpath.h
   HINTS
   ${PC_LIBXML_INCLUDEDIR}
   ${PC_LIBXML_INCLUDE_DIRS}
   PATH_SUFFIXES libxml2
   )

FIND_LIBRARY(LIBXML2_LIBRARIES NAMES xml2 libxml2
   HINTS
   ${PC_LIBXML_LIBDIR}
   ${PC_LIBXML_LIBRARY_DIRS}
   )

FIND_PROGRAM(LIBXML2_XMLLINT_EXECUTABLE xmllint)
# for backwards compat. with KDE 4.0.x:
SET(XMLLINT_EXECUTABLE "${LIBXML2_XMLLINT_EXECUTABLE}")

# handle the QUIETLY and REQUIRED arguments and set LIBXML2_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibXml2
                                  REQUIRED_VARS LIBXML2_LIBRARIES LIBXML2_INCLUDE_DIR
                                  VERSION_VAR PC_LIBXML_VERSION)

IF(LIBXML2_FOUND)
    SET(LIBXML2_VERSION_STRING ${PC_LIBXML_VERSION})
ENDIF()

MARK_AS_ADVANCED(LIBXML2_INCLUDE_DIR LIBXML2_LIBRARIES LIBXML2_XMLLINT_EXECUTABLE)