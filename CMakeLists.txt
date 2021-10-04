cmake_minimum_required(VERSION 3.18)

set(CMAKE_C_STANDARD 11 CACHE STRING "Cmake c standard" FORCE)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")

project(luasec C CXX)

set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")

if (WIN32)
    message(STATUS "Platform is Win32")
    set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "Vcpkg target triplet" FORCE)
elseif (UNIX)
    message(STATUS "Platform is Unix")
    set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "Vcpkg target triplet" FORCE)
endif ()

message(STATUS "C++ standard set to ${CMAKE_CXX_STANDARD}")

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    message(STATUS "Compiler is Clang")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message(STATUS "Compiler is GCC")
    add_compile_options(-Wno-volatile -fcoroutines)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
    message(STATUS "Compiler is Intel C++")
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    message(STATUS "Compiler is Visual Studio C++")
    add_compile_options(/std:c11 /MP)
    add_compile_definitions(
            _CRT_SECURE_NO_WARNINGS
            LUASEC_EXPORTS
    )
endif ()

find_package(OpenSSL REQUIRED)
find_package(Lua REQUIRED)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source MAIN_SRC)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/source/luasocket SOCKET_SRC)
if (WIN32)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/windows/source/luasocket PLATFORM_SRC)
elseif (UNIX)
    aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/unix/source/luasocket PLATFORM_SRC)
endif ()

add_library(${PROJECT_NAME})
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE
        ${MAIN_SRC}
        ${SOCKET_SRC}
        ${PLATFORM_SRC})

target_link_libraries(${PROJECT_NAME} PRIVATE
        OpenSSL::SSL
        OpenSSL::Crypto
        ${LUA_LIBRARIES})

target_include_directories(${PROJECT_NAME} PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include)
if (WIN32)
    target_include_directories(${PROJECT_NAME} PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/windows/include)
elseif (UNIX)
    target_include_directories(${PROJECT_NAME} PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/unix/include)
endif ()

target_include_directories(${PROJECT_NAME} PUBLIC ${LUA_INCLUDE_DIR})

install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Config
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin)