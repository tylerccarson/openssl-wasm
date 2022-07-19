#!/bin/bash

OPENSSL_DIR="openssl"

cd ${OPENSSL_DIR} || exit 1

LDFLAGS="\
  -s ENVIRONMENT='web'\
  -s FILESYSTEM=1\
  -s MODULARIZE=1\
  -s EXPORT_NAME=OpenSSL\
  -s EXPORTED_RUNTIME_METHODS=\"['callMain', 'FS']\"\
  -s INVOKE_RUN=0\
  -s EXIT_RUNTIME=1\
  -s EXPORT_ES6=1\
  -s USE_ES6_IMPORT_META=0\
  -s ALLOW_MEMORY_GROWTH=1\
  --embed-file ../openssl.cnf"

if [[ $1 == "debug" ]]; then
  LDFLAGS="$LDFLAGS -s ASSERTIONS=1" # For logging purposes.
fi

export LDFLAGS
export CC=emcc
export CXX=emcc

emconfigure ./Configure \
  no-hw \
  no-shared \
  no-asm \
  no-threads \
  no-ssl3 \
  no-dtls \
  no-engine \
  no-dso \
  linux-x32 \
  -static\

sed -i '' 's/$(CROSS_COMPILE)//' Makefile
emmake make -j `nproc` build_generated libssl.a libcrypto.a apps/openssl

[ -d ../dist ] || mkdir ../dist

mv apps/openssl ../dist/openssl.js
mv apps/openssl.wasm ../dist/openssl.wasm
