mkdir -Force cmake-build-release-android-arm64
Push-Location cmake-build-release-android-arm64
cmake -DCMAKE_BUILD_TYPE=Release `
-DCMAKE_MAKE_PROGRAM="$env:ANDROID_NDK_ROOT\prebuilt\windows-x86_64\bin\make.exe" `
-DCMAKE_C_COMPILER="$env:ANDROID_NDK_ROOT\toolchains\llvm\prebuilt\windows-x86_64\bin\clang.exe" `
-DCMAKE_CXX_COMPILER="$env:ANDROID_NDK_ROOT\toolchains\llvm\prebuilt\windows-x86_64\bin\clang++.exe" `
-DCMAKE_TOOLCHAIN_FILE="$env:ANDROID_NDK_ROOT\build\cmake\android.toolchain.cmake" `
-DCMAKE_SYSTEM_NAME=Android `
-DANDROID_ABI=arm64-v8a `
-DCMAKE_ANDROID_NDK="$env:ANDROID_NDK_ROOT" `
-DCMAKE_SYSTEM_VERSION=22 `
-DCMAKE_C_FLAGS="" `
-DCMAKE_CXX_FLAGS="" `
-DTARGET_ARCH=android_arm64 `
-DCMAKE_DEPENDS_USE_COMPILER=FALSE `
-G "CodeBlocks - MinGW Makefiles" ..
cmake --build --config Release --target luasec . -- -j 12
Pop-Location