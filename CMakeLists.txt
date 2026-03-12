cmake_minimum_required(VERSION 3.13)

project(DHTxxProtocolAnalyzer)

# ------------------------------------------------------------
# Logic version (user configurable)
# ------------------------------------------------------------
set(LOGIC 2 CACHE STRING "Saleae Logic version (1 or 2)")

if(LOGIC EQUAL 2)
    add_compile_definitions(LOGIC2)
endif()

message(STATUS "Building for Logic version: ${LOGIC}")


# ------------------------------------------------------------
# MacOS Compatibility Layer
# ------------------------------------------------------------
if(APPLE)
    list(GET CMAKE_OSX_ARCHITECTURES 0 ARCH)
else()
    set(ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

message("Build architecture: ${ARCH}")

if(ARCH STREQUAL "arm64")
    set(LIB_DIR lib_arm64)
elseif(ARCH STREQUAL "x86_64")
    set(LIB_DIR lib_x86_64)
endif()


# ------------------------------------------------------------
# Compiler settings
# ------------------------------------------------------------
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# custom CMake Modules are located in the cmake directory.
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)


include(ExternalAnalyzerSDK)

# ------------------------------------------------------------
# Detect architecture
# ------------------------------------------------------------
message(STATUS "System processor: ${CMAKE_SYSTEM_PROCESSOR}")

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
    set(ANALYZER_LIB_DIR ${CMAKE_SOURCE_DIR}/AnalyzerSDK/lib_arm64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    set(ANALYZER_LIB_DIR ${CMAKE_SOURCE_DIR}/AnalyzerSDK/lib_x86_64)
else()
    message(FATAL_ERROR "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

message(STATUS "Using AnalyzerSDK library path: ${ANALYZER_LIB_DIR}")

# ------------------------------------------------------------
# Include directories
# ------------------------------------------------------------
include_directories(
    ${CMAKE_SOURCE_DIR}/AnalyzerSDK/include
    ${CMAKE_SOURCE_DIR}/source
)

# ------------------------------------------------------------
# Collect source files
# ------------------------------------------------------------
file(GLOB ANALYZER_SOURCES
     ${CMAKE_SOURCE_DIR}/source/*.cpp)

set(SOURCES ${ANALYZER_SOURCES})

add_analyzer_plugin(${PROJECT_NAME}_${CMAKE_SYSTEM_NAME}_${ARCH}_V${LOGIC} SOURCES ${SOURCES})