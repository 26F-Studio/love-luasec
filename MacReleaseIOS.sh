mkdir -p cmake-build-release-ios
cd cmake-build-release-ios || exit
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=8.0 -DCMAKE_IOS_INSTALL_COMBINED=YES -DTARGET_ARCH=ios -DCMAKE_DEPENDS_USE_COMPILER=FALSE -G "CodeBlocks - Unix Makefiles" ..
make -j 12 && make install