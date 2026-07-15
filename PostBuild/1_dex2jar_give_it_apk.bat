
@echo off

rem Give this script the APK file, not the DEX
rem
rem This script takes take of creating the JAR file for you
rem from the APK file itself
rem
rem You can also drag-drop the APK file to this script

rem Enabled delayed expansion
rem Needed to trim filenames
setlocal EnableDelayedExpansion

rem These are the current options for Android PIN Unblocker
rem And also set to the paths of my local machine
rem
rem Don't add the quotes because they are autoamtically
rem added in the script already
rem
rem Don't add trailing '\' to the JAVA_HOME path
set JAVA_HOME=C:\java\jdk-14.0.1

rem Set APK filepath to the first bat file argument
rem Not '%~f0' because it's the bat file itself
rem
rem '%~f1' means no surrounding quotes around the path
rem Otherwise it would be '%1'
set APK=%~f1

rem Initial empty first line
echo.

echo Running Dex2Jar on the provided APK file...
echo.
".\dex-tools-v2.4\d2j-dex2jar.bat" -f "%APK%"

echo Dex2Jar done.
echo Press any key to exit.
echo.
@pause


