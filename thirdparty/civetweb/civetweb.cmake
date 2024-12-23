message(STATUS "FetchContent: civetweb")

# Disable builds
set(CIVETWEB_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CIVETWEB_ENABLE_SERVER_EXECUTABLE OFF CACHE BOOL "" FORCE)

# Disable ASAN debug
set(CIVETWEB_ENABLE_ASAN OFF CACHE BOOL "" FORCE)

# Enable websocket connections
set(CIVETWEB_ENABLE_WEBSOCKETS ON CACHE BOOL "" FORCE)

# Disable IPv6 as we use only IPv4
set(CIVETWEB_ENABLE_IPV6 OFF CACHE BOOL "" FORCE)

# Apply source code tweaks
set(workdir "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/civetweb")
set(civetweb_patches
    "${CMAKE_CURRENT_LIST_DIR}/0001-Setting-TCP_NODELAY-on-outbound-connections.patch"
    "${CMAKE_CURRENT_LIST_DIR}/0002-Moving-include-CTest-into-if-testing-guard.patch"
)
set(patch_executor git apply --ignore-whitespace ${civetweb_patches})

if (APPLE)
    add_compile_options(
        -Wno-expansion-to-defined
        -Wno-extra-semi
        -Wno-macro-redefined
        -Wno-nullability-completeness
        -Wno-nullability-extension
        -Wno-used-but-marked-unused
    )
endif ()

# Function to apply patches silently
function(apply_patch_silently)
    execute_process(
            COMMAND ${patch_executor}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/civetweb"
            RESULT_VARIABLE apply_result
            ERROR_QUIET
            OUTPUT_QUIET
    )
    if(NOT apply_result EQUAL 0)
        message(WARNING "Ignoring error while applying patch: ${patch_file}")
    else()
        message(STATUS "Patch applied successfully: ${patch_file}")
    endif()
endfunction()

FetchContent_Declare(
    civetweb
    GIT_REPOSITORY https://github.com/civetweb/civetweb.git
    GIT_TAG 1fb204ecc630515d53291f58955c799785cb90c7
)

FetchContent_GetProperties(civetweb)
if(NOT civetweb_POPULATED)
    apply_patch_silently()

    FetchContent_MakeAvailable(civetweb)
endif ()

set_target_properties(civetweb-c-library PROPERTIES FOLDER contrib)

target_compile_options(civetweb-c-library PUBLIC -DUSE_IPV6=1)
