cmake_minimum_required(VERSION 3.20)
project(code-splash LANGUAGES NONE)

# Set Swift compiler flags based on build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

# Swift compiler flags
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(SWIFT_BUILD_TYPE "debug")
    set(SWIFT_FLAGS "-Onone" "-g")
else()
    set(SWIFT_BUILD_TYPE "release")
    set(SWIFT_FLAGS "-O")
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(SWIFT_BUILD_DIR ${CMAKE_BINARY_DIR}/.build/${SWIFT_BUILD_TYPE})

# Code signing identity (optional)
set(CODESIGN_IDENTITY "" CACHE STRING "Code signing identity for macOS")

# Source files
file(GLOB_RECURSE SWIFT_SOURCES
    Sources/code-splash/*.swift
    Sources/code-splash/Effects/*.swift
)

# Custom target to build with Swift Package Manager
add_custom_target(code-splash ALL
    COMMAND ${CMAKE_COMMAND} -E echo "Building code-splash ${CMAKE_BUILD_TYPE}..."
    COMMAND swift build -c ${SWIFT_BUILD_TYPE}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    BYPRODUCTS "${CMAKE_SOURCE_DIR}/.build/${SWIFT_BUILD_TYPE}/code-splash"
    COMMENT "Building code-splash with Swift Package Manager"
    VERBATIM
)

# Copy executable to CMake binary directory
add_custom_command(TARGET code-splash POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_SOURCE_DIR}/.build/${SWIFT_BUILD_TYPE}/code-splash"
        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/code-splash"
    COMMENT "Copying executable to build directory"
    VERBATIM
)

# Run target - build and run the application
add_custom_target(run
    COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/code-splash"
    DEPENDS code-splash
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    COMMENT "Running code-splash"
    VERBATIM
)

# Sign target - code sign and copy to release directory
add_custom_target(sign
    DEPENDS code-splash
    COMMENT "Signing and copying to release directory"
)

if(CODESIGN_IDENTITY)
    add_custom_command(TARGET sign POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_SOURCE_DIR}/release"
        COMMAND codesign --force --sign "${CODESIGN_IDENTITY}"
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/code-splash"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/code-splash"
            "${CMAKE_SOURCE_DIR}/release/code-splash"
        COMMENT "Code signing with '${CODESIGN_IDENTITY}' and copying to release/"
        VERBATIM
    )
else()
    add_custom_command(TARGET sign POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_SOURCE_DIR}/release"
        COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/code-splash"
            "${CMAKE_SOURCE_DIR}/release/code-splash"
        COMMAND ${CMAKE_COMMAND} -E echo "Warning: No CODESIGN_IDENTITY specified, copying without signing"
        COMMENT "Copying to release/ (unsigned)"
        VERBATIM
    )
endif()

# Clean target - clean Swift build artifacts
add_custom_target(clean-all
    COMMAND swift package clean
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_SOURCE_DIR}/.build"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    COMMENT "Cleaning all build artifacts"
    VERBATIM
)

# Print build configuration
message(STATUS "code-splash build configuration:")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Swift build type: ${SWIFT_BUILD_TYPE}")
message(STATUS "  Output directory: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
if(CODESIGN_IDENTITY)
    message(STATUS "  Code signing: ${CODESIGN_IDENTITY}")
else()
    message(STATUS "  Code signing: disabled")
endif()
