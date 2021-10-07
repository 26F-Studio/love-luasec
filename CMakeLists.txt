cmake_minimum_required(VERSION 3.18)

### Create project
project(luasec C)


### Set C standard
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11 CACHE STRING "Cmake c standard" FORCE)


### Print
message(STATUS "C standard is ${CMAKE_C_STANDARD}")
message(STATUS "Processor is ${CMAKE_SYSTEM_PROCESSOR}")


### Build options
option(LUASEC_BUILD_SHARED "Build shared library" ON)
option(LUASEC_BUILD_STATIC "Build static library" ON)


### Config compiler options
if (NOT DEFINED TARGET_ARCH)
    set(TARGET_ARCH NOTFOUND)
    message(FATAL_ERROR "TARGET_ARCH is ${TARGET_ARCH}")
endif ()
message(STATUS "TARGET_ARCH is '${TARGET_ARCH}'")

set(ANDROID_REGEX ^android.*$)
set(ANDROID_ARM64 android_arm64)
set(ANDROID_ARMEABI android_armeabi)
set(IOS_GENERIC ios)
set(LINUX_REGEX ^linux.*$)
set(LINUX_X64 linux_x64)
set(LINUX_X86 linux_x86)
set(MACOS_GENERIC macos)
set(WINDOWS_REGEX ^windows.*$)
set(WINDOWS_X64 windows_x64)
set(WINDOWS_X86 windows_x86)

if ("${TARGET_ARCH}" MATCHES ${LINUX_REGEX})
    add_compile_options(-fPIC)
endif ()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(FATAL_ERROR "Does not support Microsoft compiler, please use MinGW!")
endif ()


### Config precompiled libs
if ("${TARGET_ARCH}" MATCHES ${ANDROID_REGEX})
    message(STATUS "Linking Android...")
    if ("${TARGET_ARCH}" STREQUAL "${ANDROID_ARM64}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ARM64}/liblove.so)
    elseif ("${TARGET_ARCH}" STREQUAL "${ANDROID_ARMEABI}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${ANDROID_ARMEABI}/liblove.so)
    else ()
        message(FATAL_ERROR "Invalid TARGET_ARCH, supports: ${ANDROID_ARM64}, ${ANDROID_ARMEABI}")
    endif ()
elseif ("${TARGET_ARCH}" STREQUAL ${IOS_GENERIC})
    message(STATUS "Linking iOS...")
    set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${IOS_GENERIC}/libluajit.a)
elseif ("${TARGET_ARCH}" MATCHES ${LINUX_REGEX})
    message(STATUS "Linking Linux...")
    if ("${TARGET_ARCH}" STREQUAL "${LINUX_X64}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${LINUX_X64}/libluajit-5.1.so.2)
    elseif ("${TARGET_ARCH}" STREQUAL "${LINUX_X86}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${LINUX_X86}/libluajit-5.1.so.2)
    else ()
        message(FATAL_ERROR "Invalid TARGET_ARCH, supports: ${LINUX_X64}, ${LINUX_X86}")
    endif ()
elseif ("${TARGET_ARCH}" STREQUAL ${MACOS_GENERIC})
    message(STATUS "Linking MacOS...")
    set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${MACOS_GENERIC}/libluajit.dylib)
elseif ("${TARGET_ARCH}" MATCHES ${WINDOWS_REGEX})
    message(STATUS "Linking Windows...")
    if ("${TARGET_ARCH}" STREQUAL "${WINDOWS_X64}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${WINDOWS_X64}/lua51.dll)
    elseif ("${TARGET_ARCH}" STREQUAL "${WINDOWS_X86}")
        set(LUA_51_LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib/${WINDOWS_X86}/lua51.dll)
    else ()
        message(FATAL_ERROR "Invalid TARGET_ARCH, supports: ${WINDOWS_X64}, ${WINDOWS_X86}")
    endif ()
else ()
    message(FATAL_ERROR "Invalid TARGET_ARCH, supports:
    ${ANDROID_ARM64}, ${ANDROID_ARMEABI},
    ${IOS_GENERIC},
    ${LINUX_X64}, ${LINUX_X86},
    ${MACOS_GENERIC},
    ${WINDOWS_X64}, ${WINDOWS_X86}")
endif ()


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


### Collect source files
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source MAIN_SRC)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source/luasocket SOCKET_SRC)
if (WIN32)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/windows/source/luasocket PLATFORM_SRC)
elseif (UNIX)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/unix/source/luasocket PLATFORM_SRC)
endif ()


### Build static library
if (LUASEC_BUILD_STATIC)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/lib${PROJECT_NAME}")
    add_library(lib${PROJECT_NAME} STATIC
            ${MAIN_SRC}
            ${SOCKET_SRC}
            ${PLATFORM_SRC})
    add_library(${PROJECT_NAME}::static ALIAS lib${PROJECT_NAME})

    target_link_libraries(lib${PROJECT_NAME} PRIVATE
            OpenSSL::SSL
            OpenSSL::Crypto
            ${LUA_51_LIB})

    target_include_directories(lib${PROJECT_NAME} PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/include)
    if (WIN32)
        target_include_directories(lib${PROJECT_NAME} PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/windows/include)
    elseif (UNIX)
        target_include_directories(lib${PROJECT_NAME} PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/unix/include)
    endif ()

    install(TARGETS lib${PROJECT_NAME} EXPORT lib${PROJECT_NAME}Config
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
            RUNTIME DESTINATION bin)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/ DESTINATION scripts/)
endif ()


### Build shared library
if (LUASEC_BUILD_SHARED)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")
    add_library(${PROJECT_NAME} SHARED ${MAIN_SRC}
            ${SOCKET_SRC}
            ${PLATFORM_SRC})
    add_library(${PROJECT_NAME}::shared ALIAS ${PROJECT_NAME})

    target_link_libraries(${PROJECT_NAME} PRIVATE
            OpenSSL::SSL
            OpenSSL::Crypto
            ${LUA_51_LIB})

    target_include_directories(${PROJECT_NAME} PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/include)
    if (WIN32)
        target_include_directories(${PROJECT_NAME} PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/windows/include)
    elseif (UNIX)
        target_include_directories(${PROJECT_NAME} PUBLIC
                ${CMAKE_CURRENT_SOURCE_DIR}/unix/include)
    endif ()

    install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Config
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
            RUNTIME DESTINATION bin)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/ DESTINATION scripts/)
endif ()
