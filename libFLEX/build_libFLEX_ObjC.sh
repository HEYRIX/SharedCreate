#!/bin/bash
###########################################################################
#  Change values here                                                     #
#                                                                         #
VERSION="1.0"
# NAME="SharedCore_SDK_v"${VERSION}                                         #
#IOS_SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`                   #
#TVOS_SDKVERSION=`xcrun -sdk appletvos --show-sdk-version`                 #
CONFIG_OPTIONS=""                                                         #
CURL_OPTIONS=""

# 工程文件所在的目录名称
SHARED_DIR="."    
# 工程名称，不需要后缀名；${SHARED_PROJCECT}.xcodeproj
SHARED_PROJCECT="FLEX"
# Target Title
# SharedKit
# SharedStyle
SHARED_TARGET="FLEX"
# SDK full name
SHARED_SDK=${SHARED_TARGET}"_SDK_v"${VERSION} 

# 编译目录
#BUILD_DIR="Build_"${SHARED_DIR}
# 输出的产品目录
PRODUCT_DIR="Products"    #PRD_DIR    

# SDK Options SDK=iphoneos SDK=iphonesimulator for Compile
SDK_OPTIONS=""
                                               #                                          #
#                                                                         #
###########################################################################
#                                                                         #
# Don't change anything under this line!                                  #
#                                                                         #
###########################################################################

export PATH=.:/opt/local/bin:/opt/local/sbin:/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
TMP_DIR=$(pwd)/tmp
TMP_PRD_DIR=${TMP_DIR}/${PRODUCT_DIR}/

# Clean former data
rm -rf ${PRODUCT_DIR}/${SHARED_SDK}
rm -rf ${TMP_DIR}/*

# Construct a New Working Directory;
mkdir ${PRODUCT_DIR}

# Compile SDK for iOS Device
CONF=Release
#CONF=Developer
SDK=iphoneos
ARCH="armv7s armv7 arm64"
echo "xcodebuild SDK for iOS Device ..."
xcodebuild -project ${SHARED_DIR}/${SHARED_PROJCECT}.xcodeproj -arch armv7s -arch armv7 -arch arm64 -sdk ${SDK} -configuration ${CONF} -target ${SHARED_TARGET} clean install SYMROOT=${TMP_DIR} GCC_PREPROCESSOR_DEFINITIONS='$(inherited) SDK_VERSION=@\"'${VERSION}'\"'

DIRIPHONEOS=${CONF}-${SDK}

echo "install library"
rm -rf ${TMP_DIR}/${CONF}-${SDK}/*.a
#echo "#########################"
mkdir ${TMP_PRD_DIR}
cp -rf ${TMP_DIR}/UninstalledProducts/${SDK}/ ${TMP_PRD_DIR}/${CONF}-${SDK}/
#cp -rf ${TMP_DIR}/${CONF}-${SDK} ${TMP_DIR}/
rm -rf ${TMP_DIR}/${CONF}-${SDK}

# Remove tmp data
#rm -rf ${TMP_DIR}/*

# Compile SDK for iOS Simulator
CONF=Release
#CONF=Developer
SDK=iphonesimulator
ARCH="i386 x86_64"
echo "xcodebuild SDK for iOS Simulator ..."
xcodebuild -project ${SHARED_DIR}/${SHARED_PROJCECT}.xcodeproj -arch i386 -arch x86_64 -sdk ${SDK} -configuration ${CONF} -target ${SHARED_TARGET} clean install SYMROOT=${TMP_DIR} GCC_PREPROCESSOR_DEFINITIONS='$(inherited) SDK_VERSION=@\"'${VERSION}'\"'

DIRIPHONESIMULATOR=${CONF}-${SDK}

echo "install library"
rm -rf ${TMP_DIR}/${CONF}-${SDK}/*.a
cp -rf ${TMP_DIR}/UninstalledProducts/${SDK}/ ${TMP_PRD_DIR}/${CONF}-${SDK}/
#cp -rf ${TMP_DIR}/${CONF}-${SDK} ${PRODUCT_DIR}
rm -rf ${TMP_DIR}/${CONF}-${SDK}

# Construct universal framework with device framework base file
UNIVERSAL_DIR=${CONF}"-Universal"
echo "Building Universal Library ... "
mkdir ${TMP_PRD_DIR}/${CONF}-Universal
cp -rf ${TMP_PRD_DIR}/${DIRIPHONEOS}/${SHARED_TARGET}.framework ${TMP_PRD_DIR}/${UNIVERSAL_DIR}
rm -rf ${TMP_PRD_DIR}/${UNIVERSAL_DIR}/${SHARED_TARGET}.framework/${SHARED_TARGET} 

# for library with ".framework", without Suffix ".a"
lipo -create ${TMP_PRD_DIR}/${DIRIPHONEOS}/${SHARED_TARGET}.framework/${SHARED_TARGET} ${TMP_PRD_DIR}/${DIRIPHONESIMULATOR}/${SHARED_TARGET}.framework/${SHARED_TARGET} -output ${TMP_PRD_DIR}/${UNIVERSAL_DIR}/${SHARED_TARGET}.framework/${SHARED_TARGET}
# for library with ".a"
#lipo -create ${PRODUCT_DIR}/${DIRIPHONEOS}/${SHARED_TARGET}.a ${PRODUCT_DIR}/${DIRIPHONESIMULATOR}/${SHARED_TARGET}.a -output ${PRODUCT_DIR}/lib${SHARED_TARGET}.a
#cp -rf ${PRODUCT_DIR}/${DIRIPHONEOS}/libSDK.h ${PRODUCT_DIR}/libSDK.h

#########buildSDK2#########
echo "Build output at ${PRODUCT_DIR} Directory ..."
rm -rf ${SHARED_SDK}
mkdir ${SHARED_SDK}
cp -rf ${TMP_PRD_DIR}/* ${SHARED_SDK}

zip -9 -r --exclude=*.git*  ${PRODUCT_DIR}/${SHARED_SDK}.zip ${SHARED_SDK}
rm -rf ${SHARED_SDK}
#rm docset-installed.txt
#rm -rf Build/appledoc

# Remove BUILDING files
rm -rf ${TMP_DIR}

