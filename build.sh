#!/bin/zsh

# Configuration
SCHEME="GlamAR"
FRAMEWORK_NAME="GlamAR"
WORKSPACE="GlamAR.xcworkspace" # Replace with your workspace name, or use PROJECT for .xcodeproj
OUTPUT_DIR="./build"
ARCHIVE_PATH_IOS="${OUTPUT_DIR}/${FRAMEWORK_NAME}-iOS.xcarchive"
ARCHIVE_PATH_SIMULATOR="${OUTPUT_DIR}/${FRAMEWORK_NAME}-Simulator.xcarchive"

# Clean previous builds
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Build for iOS devices
xcodebuild archive \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -archivePath "${ARCHIVE_PATH_IOS}" \
    -sdk iphoneos \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Build for iOS Simulator
xcodebuild archive \
    -workspace "${WORKSPACE}" \
    -scheme "${SCHEME}" \
    -archivePath "${ARCHIVE_PATH_SIMULATOR}" \
    -sdk iphonesimulator \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Create universal framework directory
UNIVERSAL_DIR="${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework"
mkdir -p "${UNIVERSAL_DIR}"

# Copy iOS framework to universal directory
cp -R "${ARCHIVE_PATH_IOS}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/" "${UNIVERSAL_DIR}"

# Combine architectures
lipo -create \
    "${ARCHIVE_PATH_IOS}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    "${ARCHIVE_PATH_SIMULATOR}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" \
    -output "${UNIVERSAL_DIR}/${FRAMEWORK_NAME}"

# Verify the architectures
lipo -info "${UNIVERSAL_DIR}/${FRAMEWORK_NAME}"

# Clean up
rm -rf "${ARCHIVE_PATH_IOS}" "${ARCHIVE_PATH_SIMULATOR}"

echo "Universal framework created at ${UNIVERSAL_DIR}"

# Optional: Create a zip file of the framework
zip -r "${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework.zip" "${UNIVERSAL_DIR}"
echo "Zipped framework created at ${OUTPUT_DIR}/${FRAMEWORK_NAME}.framework.zip"
