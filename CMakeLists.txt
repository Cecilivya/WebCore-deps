cmake_minimum_required(VERSION 3.4.0)

set(CMAKE_BUILD_TYPE MinSizeRel)

set(OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/out)
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(COMMON_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${OUT_DIR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_FIND_ROOT_PATH=${OUT_DIR} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)

if (CMAKE_TOOLCHAIN_FILE)
  # Make the toolchain file path absolute (resolve against directory containing CMakeLists.txt)
  get_filename_component(CMAKE_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}"
                        REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  # Pass the toolchain arg to each subproject
  list(APPEND COMMON_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
endif ()

project(WebCore-Deps)

include(ExternalProject)

message(STATUS "Building to: ${OUT_DIR}")

# Set the port if not already set
if (NOT PORT)
    if (UNIX)
        if (APPLE)
            set(PORT UltralightMac)
        else ()
            set(PORT UltralightLinux)
        endif ()
    elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(PORT UltralightWin)
    else ()
        message(FATAL_ERROR "Unknown OS '${CMAKE_SYSTEM_NAME}'")
    endif ()
endif ()

if (PORT MATCHES "UltralightWin")
  set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
  set(PLATFORM_DEFINES_HEADER ${SRC_DIR}/WinPlatformDefines.h)
  set(MSVC_FLAGS "/Zc:inline /Gy /Gw /DWINDOWS_DESKTOP_PLATFORM=1 /FI ${PLATFORM_DEFINES_HEADER}")
  list(APPEND COMMON_ARGS -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY} -DCMAKE_CXX_FLAGS=${MSVC_FLAGS} -DCMAKE_C_FLAGS=${MSVC_FLAGS})
endif ()

ExternalProject_Add(zlib
  SOURCE_DIR        ${SRC_DIR}/zlib-1.2.11
  CMAKE_ARGS        ${COMMON_ARGS} -DBUILD_SHARED_LIBS=OFF 
)

ExternalProject_Add(libpng
  SOURCE_DIR        ${SRC_DIR}/libpng-1.6.37
  CMAKE_ARGS        ${COMMON_ARGS} -DPNG_SHARED=OFF -DPNG_TESTS=OFF -DPNG_BUILD_ZLIB=ON -DZLIB_LIBRARY:STRING=${OUT_DIR}/lib/zlibstat.lib -DZLIB_INCLUDE_DIR:STRING=${OUT_DIR}/include/
  DEPENDS           zlib
)

set(LIBJPEGTURBO_ARGS ${COMMON_ARGS} -DWITH_SIMD=ON -DWITH_TURBOJPEG=OFF -DENABLE_SHARED=OFF)
if (PORT MATCHES "UltralightWin")
  set(LIBJPEGTURBO_ARGS ${LIBJPEGTURBO_ARGS} -DWITH_CRT_DLL=ON -DCMAKE_SYSTEM_PROCESSOR=amd64)
endif ()

ExternalProject_Add(libjpeg-turbo
  SOURCE_DIR        ${SRC_DIR}/libjpeg-turbo-2.0.4/libjpeg-turbo-2.0.4
  CMAKE_ARGS        ${LIBJPEGTURBO_ARGS}
)

ExternalProject_Add(icu
  SOURCE_DIR        ${SRC_DIR}/icu-67.1
  CMAKE_ARGS        ${COMMON_ARGS}
)

set(LIBXML2_ARGS ${COMMON_ARGS} -DLIBXML_THREAD_SAFETY=no -DWITH_THREAD_ALLOC=OFF -DWITH_C14N=OFF -DWITH_CATALOG=OFF -DWITH_DEBUG=OFF -DWITH_DOCB=OFF -DWITH_FTP=OFF -DWITH_FTP=OFF -DWITH_HTTP=OFF -DWITH_ICONV=OFF -DWITH_ICU=ON -DWITH_ISO8859X=ON -DWITH_LEGACY=OFF -DWITH_LZMA=OFF -DWITH_MEM_DEBUG=OFF -DWITH_MODULES=OFF -DWITH_OUTPUT=ON -DWITH_PATTERN=OFF -DWITH_PUSH=ON -DWITH_PYTHON=OFF -DWITH_READER=OFF -DWITH_REGEXPS=ON -DWITH_RUN_DEBUG=OFF -DWITH_SAX1=ON -DWITH_SCHEMAS=OFF -DWITH_SCHEMATRON=OFF -DWITH_VALID=OFF -DWITH_WALKER=ON -DWITH_WRITER=OFF -DWITH_XINCLUDE=OFF -DWITH_XPTR=OFF -DWITH_ZLIB=OFF -DWITH_HTML=ON -DWITH_TREE=ON -DWITH_XPATH=ON -DICU_ROOT=${OUT_DIR})
if (PORT MATCHES "UltralightWin")
  set(LIBXML2_ARGS ${LIBXML2_ARGS} -DLIBXML2_CONFIG_INCLUDE_DIR=win32/VC10)
else ()
  set(LIBXML2_ARGS ${LIBXML2_ARGS} -DLIBXML2_CONFIG_INCLUDE_DIR=macos)
endif ()

ExternalProject_Add(libxml2
  SOURCE_DIR        ${SRC_DIR}/libxml2-v2.9.10/libxml2-v2.9.10
  CMAKE_ARGS        ${LIBXML2_ARGS}
  DEPENDS           icu
)

set(LIBXSLT_ARGS ${COMMON_ARGS} -DWITH_TRIO=OFF -DWITH_XSLT_DEBUG=OFF -DWITH_MEM_DEBUG=OFF -DWITH_DEBUGGER=OFF -DWITH_ICONV=OFF -DWITH_ZLIB=OFF -DWITH_CRYPTO=OFF -DWITH_MODULES=OFF -DLIBXML2_INCLUDE_DIR=${OUT_DIR}/include)
if (PORT MATCHES "UltralightWin")
  set(LIBXSLT_ARGS ${LIBXSLT_ARGS} -DLIBXML2_LIBRARY=${OUT_DIR}/lib/xml2.lib)
else ()
  set(LIBXSLT_ARGS ${LIBXSLT_ARGS} -DLIBXML2_LIBRARY=${OUT_DIR}/lib/libxml2.a)
endif ()

ExternalProject_Add(libxslt
  SOURCE_DIR        ${SRC_DIR}/libxslt-v1.1.34/libxslt-v1.1.34
  CMAKE_ARGS        ${LIBXSLT_ARGS}
  DEPENDS           libxml2
)

ExternalProject_Add(brotli
  SOURCE_DIR        ${SRC_DIR}/brotli-1.0.7
  CMAKE_ARGS        ${COMMON_ARGS} -DBROTLI_DISABLE_CLI=ON -DBROTLI_DISABLE_TESTS=ON
)

ExternalProject_Add(nghttp2
  SOURCE_DIR        ${SRC_DIR}/nghttp2-1.40.0
  CMAKE_ARGS        ${COMMON_ARGS} -DENABLE_LIB_ONLY=ON -DENABLE_ASIO_LIB=OFF -DENABLE_FAILMALLOC=OFF -DENABLE_THREADS=OFF -DENABLE_WERROR=OFF -DWITH_JEMALLOC=OFF -DWITH_LIBXML2=OFF -DWITH_MRUBY=OFF -DWITH_NEVERBLEED=OFF -DWITH_SPDYLAY=OFF -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON
)

ExternalProject_Add(libressl
  SOURCE_DIR        ${SRC_DIR}/libressl-3.0.2
  CMAKE_ARGS        ${COMMON_ARGS} -DLIBRESSL_APPS=OFF -DLIBRESSL_TESTS=OFF
)

ExternalProject_Add(curl
  SOURCE_DIR        ${SRC_DIR}/curl-7.69.1
  CMAKE_ARGS        ${COMMON_ARGS} -DBUILD_CURL_EXE=OFF -DBUILD_TESTING=OFF -DCMAKE_USE_GSSAPI=OFF -DCMAKE_USE_LIBSSH2=OFF -DCMAKE_USE_OPENLDAP=OFF -DCURL_BROTLI=ON -DCURL_ZLIB=ON -DCURL_DISABLE_COOKIES=ON -DCURL_DISABLE_CRYPTO_AUTH=OFF -DCURL_DISABLE_DICT=ON -DCURL_DISABLE_FILE=OFF -DCURL_DISABLE_FTP=ON -DCURL_DISABLE_GOPHER=ON -DCURL_DISABLE_HTTP=OFF -DCURL_DISABLE_IMAP=ON -DCURL_DISABLE_LDAP=ON -DCURL_DISABLE_LDAPS=ON -DCURL_DISABLE_POP3=ON -DCURL_DISABLE_PROXY=OFF -DCURL_DISABLE_RTSP=ON -DCURL_DISABLE_SMTP=ON -DCURL_DISABLE_TELNET=ON -DCURL_DISABLE_TFTP=ON -DENABLE_ARES=OFF -DENABLE_MANUAL=OFF -DENABLE_THREADED_RESOLVER=ON -DUSE_NGHTTP2=ON -DUSE_WIN32_LDAP=OFF -DENABLE_IPV6=ON -DUSE_OPENSSL=ON -DNGHTTP2_INCLUDE_DIR=${OUT_DIR}/include -DCURL_STATICLIB=ON -DBUILD_SHARED_LIBS=OFF -DZLIB_FOUND=1 -DZLIB_INCLUDE_DIRS:STRING=${OUT_DIR}/include -DBROTLI_FOUND=1 -DBROTLI_INCLUDE_DIRS:STRING=${OUT_DIR}/include/brotli 
  -DOPENSSL_INCLUDE_DIR=${OUT_DIR}/include -DCMAKE_PREFIX_PATH=${OUT_DIR} -DNGHTTP2_LIBRARY=${OUT_DIR}/lib/foobar.a
  DEPENDS           nghttp2 libressl brotli zlib
)

ExternalProject_Add(freetype
  SOURCE_DIR        ${SRC_DIR}/freetype-2.10.1
  CMAKE_ARGS        ${COMMON_ARGS} -DFT_WITH_ZLIB=ON -DFT_WITH_BZIP2=OFF -DFT_WITH_PNG=ON -DFT_WITH_HARFBUZZ=OFF -DPNG_PNG_INCLUDE_DIR=${OUT_DIR}/include/libpng16 -DPNG_LIBRARY=${OUT_DIR}/lib/foobar.a -DZLIB_INCLUDE_DIR=${OUT_DIR}/include -DZLIB_LIBRARY=${OUT_DIR}/lib/foobar.a
  DEPENDS           zlib libpng
)

set(HARFBUZZ_ARGS ${COMMON_ARGS} -DHB_HAVE_FREETYPE=ON -DHB_HAVE_ICU=ON -DHB_BUILD_UTILS=OFF -DHB_BUILD_SUBSET=OFF -DHB_BUILD_TESTS=OFF -DFREETYPE_INCLUDE_DIRS=${OUT_DIR}/include -DFREETYPE_LIBRARY=${OUT_DIR}/lib/foobar.a -DICU_ROOT=${OUT_DIR})
if (PORT MATCHES "UltralightMac")
  set(CXX_FLAGS "-std=gnu++14")
  list(APPEND HARFBUZZ_ARGS -DCMAKE_CXX_FLAGS=${CXX_FLAGS} )
endif ()

ExternalProject_Add(harfbuzz
  SOURCE_DIR        ${SRC_DIR}/harfbuzz-2.6.4
  CMAKE_ARGS        ${HARFBUZZ_ARGS}
  DEPENDS           freetype icu
)