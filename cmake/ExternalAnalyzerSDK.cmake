include(FetchContent)

# Use the C++11 standard
set(CMAKE_CXX_STANDARD 11)

set(CMAKE_CXX_STANDARD_REQUIRED YES)

if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY OR NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin/)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin/)
endif()

# Fetch the Analyzer SDK if the target does not already exist.
if(NOT TARGET Saleae::AnalyzerSDK)
    if(LOGIC EQUAL 1)
        set(ANALYZER_SDK_TAG "temp-1.2.40")
    else()
        set(ANALYZER_SDK_TAG "master")
    endif()

    FetchContent_Declare(
        analyzersdk
        GIT_REPOSITORY https://github.com/saleae/AnalyzerSDK.git
        GIT_TAG        ${ANALYZER_SDK_TAG}
        GIT_SHALLOW    TRUE
        GIT_PROGRESS   TRUE
    )

    FetchContent_GetProperties(analyzersdk)

    if(NOT analyzersdk_POPULATED)
        FetchContent_Populate(analyzersdk)
        include(${analyzersdk_SOURCE_DIR}/AnalyzerSDKConfig.cmake)

        if(APPLE OR WIN32)
            get_target_property(analyzersdk_lib_location Saleae::AnalyzerSDK IMPORTED_LOCATION)
            if(CMAKE_LIBRARY_OUTPUT_DIRECTORY)
                file(COPY ${analyzersdk_lib_location} DESTINATION ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
            else()
                message(WARNING "Please define CMAKE_RUNTIME_OUTPUT_DIRECTORY and CMAKE_LIBRARY_OUTPUT_DIRECTORY if you want unit tests to locate ${analyzersdk_lib_location}")
            endif()
        endif()

    endif()
endif()

function(add_analyzer_plugin TARGET)
    set(options )
    set(single_value_args )
    set(multi_value_args SOURCES)
    cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}" ${ARGN} )


    add_library(${TARGET} MODULE ${_p_SOURCES})
    target_link_libraries(${TARGET} PRIVATE Saleae::AnalyzerSDK)

    set(ANALYZER_DESTINATION "Analyzers")
    install(TARGETS ${TARGET} RUNTIME DESTINATION ${ANALYZER_DESTINATION}
                              LIBRARY DESTINATION ${ANALYZER_DESTINATION})

    set_target_properties(${TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ANALYZER_DESTINATION}
                                               LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ANALYZER_DESTINATION})

    if(LOGIC EQUAL 1 AND UNIX AND NOT APPLE)
        find_program(PATCHELF_EXECUTABLE patchelf)

        if(PATCHELF_EXECUTABLE)
            add_custom_command(TARGET ${TARGET} POST_BUILD
                COMMAND ${PATCHELF_EXECUTABLE}
                    --replace-needed libAnalyzer.so libanalyzer.so
                    $<TARGET_FILE:${TARGET}>
                COMMENT "Fixing AnalyzerSDK library case mismatch"
            )
        endif()

    endif()
endfunction()