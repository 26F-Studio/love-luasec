cmake_minimum_required(VERSION 3.18)

set(CMAKE_C_STANDARD 11 CACHE STRING "Cmake c standard" FORCE)
set(CMAKE_C_STANDARD_REQUIRED ON)
message(STATUS "C standard set to ${CMAKE_C_STANDARD}")

project(luasec C CXX)

option(LUASEC_BUILD_SHARED "Build shared library" ON)
option(LUASEC_BUILD_STATIC "Build static library" ON)

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    message(STATUS "Compiler is Clang")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message(STATUS "Compiler is GCC")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
    message(STATUS "Compiler is Intel C++")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(STATUS "Compiler is Visual Studio C++")
    add_compile_options(/std:c11 /MP)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS LUASEC_EXPORTS)
endif ()

### Config love-lua
add_subdirectory(love-lua)
### End

### Config openssl
include(FetchContent)
FetchContent_Declare(
        ssl_content
        GIT_REPOSITORY https://github.com/janbar/openssl-cmake.git
        GIT_TAG "1.1.1k-20210430"
)
FetchContent_MakeAvailable(ssl_content)
add_library(OpenSSL::SSL ALIAS ssl)
add_library(OpenSSL::Crypto ALIAS crypto)
### End

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source MAIN_SRC)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source/luasocket SOCKET_SRC)
if (WIN32)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/windows/source/luasocket PLATFORM_SRC)
elseif (UNIX)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/unix/source/luasocket PLATFORM_SRC)
endif ()

if (LUASEC_BUILD_STATIC)
    add_library(${PROJECT_NAME}-static STATIC
            ${MAIN_SRC}
            ${SOCKET_SRC}
            ${PLATFORM_SRC})
    add_library(${PROJECT_NAME}::static ALIAS ${PROJECT_NAME}-static)

    target_link_libraries(${PROJECT_NAME}-static PRIVATE
            OpenSSL::SSL
            OpenSSL::Crypto
            lua51-static)

    target_include_directories(${PROJECT_NAME}-static PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/include)
    if (WIN32)
        target_include_directories(${PROJECT_NAME}-static PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/windows/include)
    elseif (UNIX)
        target_include_directories(${PROJECT_NAME}-static PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/unix/include)
    endif ()

    install(TARGETS ${PROJECT_NAME}-static EXPORT ${PROJECT_NAME}-static_Config
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
            RUNTIME DESTINATION bin)
endif ()

if (LUASEC_BUILD_SHARED)
    add_library(${PROJECT_NAME}-shared SHARED ${MAIN_SRC}
            ${SOCKET_SRC}
            ${PLATFORM_SRC})
    add_library(${PROJECT_NAME}::shared ALIAS ${PROJECT_NAME}-shared)

    target_link_libraries(${PROJECT_NAME}-shared PRIVATE
            OpenSSL::SSL
            OpenSSL::Crypto
            lua51-static)

    target_include_directories(${PROJECT_NAME}-shared PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/include)
    if (WIN32)
        target_include_directories(${PROJECT_NAME}-shared PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/windows/include)
    elseif (UNIX)
        target_include_directories(${PROJECT_NAME}-shared PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/unix/include)
    endif ()

    install(TARGETS ${PROJECT_NAME}-shared EXPORT ${PROJECT_NAME}-shared_Config
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
            RUNTIME DESTINATION bin)
endif ()

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lua/ DESTINATION lua/)
