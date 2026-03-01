cmake_minimum_required(VERSION 3.16)

project(CustomAnalyzer LANGUAGES CXX)

# ------------------------------------------------------------
# Compiler settings
# ------------------------------------------------------------
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_compile_options(-w)

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
include_directories(${CMAKE_SOURCE_DIR}/AnalyzerSDK/include)

# ------------------------------------------------------------
# Collect source files
# ------------------------------------------------------------
file(GLOB ANALYZER_SOURCES
     ${CMAKE_SOURCE_DIR}/source/*.cpp)

# ------------------------------------------------------------
# Detect analyzer name from *Analyzer.cpp
# ------------------------------------------------------------
set(ANALYZER_NAME "")

foreach(FILE ${ANALYZER_SOURCES})
    get_filename_component(FILENAME ${FILE} NAME)
    if(FILENAME MATCHES "(.+)Analyzer\\.cpp$")
        string(REGEX REPLACE "Analyzer\\.cpp$" "" ANALYZER_NAME ${FILENAME})
        break()
    endif()
endforeach()

if(ANALYZER_NAME STREQUAL "")
    message(FATAL_ERROR "Could not determine analyzer name (no *Analyzer.cpp found)")
endif()

# ------------------------------------------------------------
# Create shared library
# ------------------------------------------------------------
add_library(${ANALYZER_NAME}Analyzer SHARED ${ANALYZER_SOURCES})

# ------------------------------------------------------------
# Link directories and dependencies
# ------------------------------------------------------------
target_link_directories(${ANALYZER_NAME}Analyzer PRIVATE
    ${ANALYZER_LIB_DIR}
)

target_link_libraries(${ANALYZER_NAME}Analyzer PRIVATE
    Analyzer
)

# ------------------------------------------------------------
# Output directories
# ------------------------------------------------------------
set_target_properties(${ANALYZER_NAME}Analyzer PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_SOURCE_DIR}/debug
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/release
)