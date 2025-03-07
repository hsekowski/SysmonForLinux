#!/bin/sh
#
#    SysmonForLinux
#
#    Copyright (c) Microsoft Corporation
#
#    All rights reserved.
#
#    MIT License
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#################################################################################
#
# makePackages.sh
#
# Builds the directory trees for DEB and RPM packages and, if suitable tools are
# available, builds the actual packages too.
#
#################################################################################


if [ "$5" = "" ]; then
    echo "Usage: $0 <SourceDir> <BinaryDir> <package name> <package version> <package release>"
    exit 1
fi

# copy cmake vars
CMAKE_SOURCE_DIR=$1
PROJECT_BINARY_DIR=$2
PACKAGE_NAME=$3
PACKAGE_VER=$4
PACKAGE_REL=$5

DEB_PACKAGE_NAME="${PACKAGE_NAME}_${PACKAGE_VER}-${PACKAGE_REL}_amd64"
RPM_PACKAGE_NAME="${PACKAGE_NAME}-${PACKAGE_VER}-${PACKAGE_REL}"

# find packaging tools
DPKGDEB=`which dpkg-deb`
RPMBUILD=`which rpmbuild`

# clean up first
if [ -d "${PROJECT_BINARY_DIR}/deb" ]; then
    rm -rf "${PROJECT_BINARY_DIR}/deb"
fi

if [ -d "${PROJECT_BINARY_DIR}/rpm" ]; then
    rm -rf "${PROJECT_BINARY_DIR}/rpm"
fi

# copy deb files
mkdir -p "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}"
cp -a "${CMAKE_SOURCE_DIR}/package/DEBIAN" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/"
cp "${PROJECT_BINARY_DIR}/DEBIANcontrol" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/DEBIAN/control"
cp -a "${CMAKE_SOURCE_DIR}/package/usr" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/"
mkdir -p "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin"
cp "${PROJECT_BINARY_DIR}/sysmon" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin/"

# make the deb
if [ "$DPKGDEB" != "" ]; then
    cd "${PROJECT_BINARY_DIR}/deb"
    "$DPKGDEB" --build --root-owner-group "${DEB_PACKAGE_NAME}"
else
    echo "No dpkg-deb found"
fi

# copy rpm files
mkdir -p "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/SPECS"
cp -a "${PROJECT_BINARY_DIR}/SPECS.spec" "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/SPECS/${RPM_PACKAGE_NAME}.spec"
mkdir "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/"
cp "${CMAKE_SOURCE_DIR}/package/usr/share/man/man8/sysmon.8.gz" "${PROJECT_BINARY_DIR}/sysmon" "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/"

# make the rpm
if [ "$RPMBUILD" != "" ]; then
    cd "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}"
    "$RPMBUILD" --define "_topdir `pwd`" -v -bb "SPECS/${RPM_PACKAGE_NAME}.spec"
    cp RPMS/x86_64/*.rpm ..
else
    echo "No rpmbuild found"
fi

