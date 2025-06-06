include(FetchContent)

set(LIBUV_MINVERSION 1.46.0)
set(BOOST_MINVERSION 1.81)
set(NGHTTP2_MINVERSION 1.64.0)
set(PROTOBUF_MINVERSION 3.15.0)
set(FMT_MINVERSION 10.1.1)
set(GTEST_MINVERSION 1.15.2)

if(NOT GRPCXX_USE_ASIO)
    if(GRPCXX_HERMETIC_BUILD)
        # libuv
        FetchContent_Declare(libuv
            URL      https://github.com/libuv/libuv/archive/refs/tags/v${LIBUV_MINVERSION}.tar.gz
            URL_HASH SHA256=7aa66be3413ae10605e1f5c9ae934504ffe317ef68ea16fdaa83e23905c681bd
        )

        set(LIBUV_BUILD_SHARED ${BUILD_SHARED_LIBS} CACHE BOOL "Build libuv shared lib")
        FetchContent_MakeAvailable(libuv)

        if (BUILD_SHARED_LIBS)
            install(TARGETS uv EXPORT grpcxx COMPONENT Development)
            add_library(libuv::uv ALIAS uv)
        else()
            install(TARGETS uv_a EXPORT grpcxx COMPONENT Development)
            add_library(libuv::uv ALIAS uv_a)
        endif()
    else()
        # Unfortunately the libuv CMakeLists.txt does not export
        # a version file. This is a bug in libuv.
        # So we cannot use ${LIBUV_MINVERSION} in find_package().
        # To work around it, we do a pkg_config call just to check
        # the version.
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(uv REQUIRED "libuv>=${LIBUV_MINVERSION}")
        find_package(libuv REQUIRED)
    endif()
else()

endif()

# nghttp2
if(NOT GRPCXX_HERMETIC_BUILD)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(nghttp2 REQUIRED IMPORTED_TARGET "libnghttp2>=${NGHTTP2_MINVERSION}")
    add_library(libnghttp2::nghttp2 ALIAS PkgConfig::nghttp2)
else()
    FetchContent_Declare(nghttp2
        URL      https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_MINVERSION}/nghttp2-${NGHTTP2_MINVERSION}.tar.xz
        URL_HASH SHA256=88bb94c9e4fd1c499967f83dece36a78122af7d5fb40da2019c56b9ccc6eb9dd
    )

    if (NOT BUILD_SHARED_LIBS)
        set(BUILD_STATIC_LIBS ON CACHE BOOL "Build libnghttp2 in static mode")
    endif()
    set(ENABLE_LIB_ONLY   ON  CACHE BOOL "Build libnghttp2 only")
    set(ENABLE_DOC        OFF CACHE BOOL "Build libnghttp2 documentation")
    FetchContent_MakeAvailable(nghttp2)

    if (BUILD_SHARED_LIBS)
        install(TARGETS nghttp2 EXPORT grpcxx COMPONENT Development)
        add_library(libnghttp2::nghttp2 ALIAS nghttp2)
    else()
        install(TARGETS nghttp2_static EXPORT grpcxx COMPONENT Development)
        add_library(libnghttp2::nghttp2 ALIAS nghttp2_static)
    endif()
endif()

# protobuf
find_package(Protobuf REQUIRED)

if(NOT GRPCXX_HERMETIC_BUILD)
    find_package(fmt ${FMT_MINVERSION} REQUIRED)
else()
    # fmt
    FetchContent_Declare(fmt
        URL      https://github.com/fmtlib/fmt/archive/refs/tags/${FMT_MINVERSION}.tar.gz
        URL_HASH SHA256=78b8c0a72b1c35e4443a7e308df52498252d1cefc2b08c9a97bc9ee6cfe61f8b
    )
    FetchContent_MakeAvailable(fmt)
endif()
