
@echo off

rem
rem This batch script will run zipalign to create smaller APK files
rem than what the Basic4Android IDE cans usually produce.
rem
rem Put it in the project folder (it should already be here) then
rem run it after your Basic4Android app has been compiled.
rem

rem Add the quotes too in the path to zipalign.exe
set ZipAlignExeFile="C:\Android\build-tools\33.0.3\zipalign.exe"

echo.
echo Running "zipalign -v -z 4" on the generated APK file
echo.

%ZipAlignExeFile% -v -z 4 ".\Objects\PinUnblockerAndroid.apk" ".\Objects\PinUnblockerAndroid-optimized.apk"

echo.
echo Press any key to exit
echo.
@pause >NUL

rem
rem The -z option in zipalign is what makes the APK file smaller.
rem It means 'recompress with Zopfli algorithm'.
rem

