mkdir -p cmake-build-release-macos
cd cmake-build-release-macos || exit
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DTARGET_ARCH=macos -DCMAKE_DEPENDS_USE_COMPILER=FALSE -G "CodeBlocks - Unix Makefiles" ..
make && make install