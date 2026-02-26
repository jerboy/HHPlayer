#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACTS_DIR="${ROOT_DIR}/Artifacts"
BUILD_DIR="${ROOT_DIR}/build/spm"
ARCHIVES_DIR="${BUILD_DIR}/archives"
IOS_ARCHIVE="${ARCHIVES_DIR}/HHPlayer-iOS.xcarchive"
TVOS_ARCHIVE="${ARCHIVES_DIR}/HHPlayer-tvOS.xcarchive"
IOS_SIMULATOR_ARCHIVE="${ARCHIVES_DIR}/HHPlayer-iOS-Simulator.xcarchive"
TVOS_SIMULATOR_ARCHIVE="${ARCHIVES_DIR}/HHPlayer-tvOS-Simulator.xcarchive"
MACOS_ARCHIVE="${ARCHIVES_DIR}/HHPlayer-macOS.xcarchive"
XCFRAMEWORK_PATH="${ARTIFACTS_DIR}/HHPlayer.xcframework"
ZIP_PATH="${ARTIFACTS_DIR}/HHPlayer.xcframework.zip"
CHECKSUM_PATH="${ARTIFACTS_DIR}/HHPlayer.xcframework.checksum.txt"

INCLUDE_SIMULATOR="${INCLUDE_SIMULATOR:-1}"
IOS_DEVICE_ARCHS="${IOS_DEVICE_ARCHS:-arm64}"
TVOS_DEVICE_ARCHS="${TVOS_DEVICE_ARCHS:-arm64}"
MACOS_ARCHS="${MACOS_ARCHS:-arm64 x86_64}"
IOS_SIMULATOR_ARCHS="${IOS_SIMULATOR_ARCHS:-arm64-simulator}"
TVOS_SIMULATOR_ARCHS="${TVOS_SIMULATOR_ARCHS:-arm64-simulator}"

mkdir -p "${ARTIFACTS_DIR}" "${ARCHIVES_DIR}"
rm -rf "${IOS_ARCHIVE}" "${TVOS_ARCHIVE}" "${IOS_SIMULATOR_ARCHIVE}" "${TVOS_SIMULATOR_ARCHIVE}" "${MACOS_ARCHIVE}" "${XCFRAMEWORK_PATH}"
rm -f "${ZIP_PATH}" "${CHECKSUM_PATH}"

run_build_deps() {
    local platform="$1"
    local ios_archs="$2"
    local tvos_archs="$3"
    local macos_archs="$4"

    FF_ALL_ARCHS_IOS="${ios_archs}" \
    FF_ALL_ARCHS_TVOS="${tvos_archs}" \
    FF_ALL_ARCHS_MACOS="${macos_archs}" \
    "${ROOT_DIR}/build.sh" "${platform}" build
}

has_ffmpeg_arch_output() {
    local platform="$1"
    local archs="$2"
    local arch
    for arch in ${archs}; do
        if [[ -f "${ROOT_DIR}/build/libs/${platform}/ffmpeg-${arch}/output/lib/libavcodec.a" ]]; then
            return 0
        fi
    done
    return 1
}

archive_framework() {
    local scheme="$1"
    local platform="$2"
    local archive_path="$3"

    xcodebuild archive \
        -project "${ROOT_DIR}/SGPlayer.xcodeproj" \
        -scheme "${scheme}" \
        -configuration Release \
        -destination "generic/platform=${platform}" \
        -archivePath "${archive_path}" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        DEFINES_MODULE=YES \
        PRODUCT_NAME=HHPlayer \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO
}

if [[ "${SKIP_DEPS_BUILD:-0}" != "1" ]]; then
    run_build_deps "iOS" "${IOS_DEVICE_ARCHS}" "${TVOS_DEVICE_ARCHS}" "${MACOS_ARCHS}"
    run_build_deps "tvOS" "${IOS_DEVICE_ARCHS}" "${TVOS_DEVICE_ARCHS}" "${MACOS_ARCHS}"
    run_build_deps "macOS" "${IOS_DEVICE_ARCHS}" "${TVOS_DEVICE_ARCHS}" "${MACOS_ARCHS}"
fi

if [[ "${INCLUDE_SIMULATOR}" == "1" && "${SKIP_DEPS_BUILD:-0}" == "1" ]]; then
    if ! has_ffmpeg_arch_output "iOS" "${IOS_SIMULATOR_ARCHS}"; then
        echo "Missing iOS simulator FFmpeg outputs. Build with SKIP_DEPS_BUILD=0 or set INCLUDE_SIMULATOR=0." >&2
        exit 1
    fi
    if ! has_ffmpeg_arch_output "tvOS" "${TVOS_SIMULATOR_ARCHS}"; then
        echo "Missing tvOS simulator FFmpeg outputs. Build with SKIP_DEPS_BUILD=0 or set INCLUDE_SIMULATOR=0." >&2
        exit 1
    fi
fi

archive_framework "SGPlayer iOS" "iOS" "${IOS_ARCHIVE}"
archive_framework "SGPlayer tvOS" "tvOS" "${TVOS_ARCHIVE}"
archive_framework "SGPlayer macOS" "macOS" "${MACOS_ARCHIVE}"

if [[ "${INCLUDE_SIMULATOR}" == "1" ]]; then
    if [[ "${SKIP_DEPS_BUILD:-0}" != "1" ]]; then
        run_build_deps "iOS" "${IOS_SIMULATOR_ARCHS}" "${TVOS_SIMULATOR_ARCHS}" "${MACOS_ARCHS}"
        run_build_deps "tvOS" "${IOS_SIMULATOR_ARCHS}" "${TVOS_SIMULATOR_ARCHS}" "${MACOS_ARCHS}"
    fi

    archive_framework "SGPlayer iOS" "iOS Simulator" "${IOS_SIMULATOR_ARCHIVE}"
    archive_framework "SGPlayer tvOS" "tvOS Simulator" "${TVOS_SIMULATOR_ARCHIVE}"
fi

IOS_FRAMEWORK="${IOS_ARCHIVE}/Products/Library/Frameworks/HHPlayer.framework"
TVOS_FRAMEWORK="${TVOS_ARCHIVE}/Products/Library/Frameworks/HHPlayer.framework"
MACOS_FRAMEWORK="${MACOS_ARCHIVE}/Products/Library/Frameworks/HHPlayer.framework"
IOS_SIMULATOR_FRAMEWORK="${IOS_SIMULATOR_ARCHIVE}/Products/Library/Frameworks/HHPlayer.framework"
TVOS_SIMULATOR_FRAMEWORK="${TVOS_SIMULATOR_ARCHIVE}/Products/Library/Frameworks/HHPlayer.framework"

for framework in "${IOS_FRAMEWORK}" "${TVOS_FRAMEWORK}" "${MACOS_FRAMEWORK}"; do
    if [[ ! -d "${framework}" ]]; then
        echo "Missing framework: ${framework}" >&2
        exit 1
    fi
done

XCFRAMEWORK_ARGS=(
    -framework "${IOS_FRAMEWORK}"
    -framework "${TVOS_FRAMEWORK}"
    -framework "${MACOS_FRAMEWORK}"
)

if [[ "${INCLUDE_SIMULATOR}" == "1" ]]; then
    for framework in "${IOS_SIMULATOR_FRAMEWORK}" "${TVOS_SIMULATOR_FRAMEWORK}"; do
        if [[ ! -d "${framework}" ]]; then
            echo "Missing framework: ${framework}" >&2
            exit 1
        fi
    done
    XCFRAMEWORK_ARGS+=(
        -framework "${IOS_SIMULATOR_FRAMEWORK}"
        -framework "${TVOS_SIMULATOR_FRAMEWORK}"
    )
fi

xcodebuild -create-xcframework "${XCFRAMEWORK_ARGS[@]}" -output "${XCFRAMEWORK_PATH}"

(
    cd "${ARTIFACTS_DIR}"
    ditto -c -k --sequesterRsrc --keepParent "HHPlayer.xcframework" "HHPlayer.xcframework.zip"
)

swift package compute-checksum "${ZIP_PATH}" > "${CHECKSUM_PATH}"

echo "XCFramework: ${XCFRAMEWORK_PATH}"
echo "Zip: ${ZIP_PATH}"
echo "Checksum: $(cat "${CHECKSUM_PATH}")"
