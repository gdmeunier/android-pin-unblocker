
@echo off

rem Enabled delayed expansion
rem Needed to trim filenames
setlocal EnableDelayedExpansion

rem Give this script the APK file, not the JAR
rem
rem This script takes take of creating the DEX file for you
rem from the APK file itself (it uses its path to find the JAR)
rem
rem You can also drag-drop the APK file to this script

rem Initial empty first line
echo.

rem These are the current options for Android PIN Unblocker
rem And also set to the paths of my local machine
rem
rem Don't add the quotes because they are autoamtically
rem added in the script already
rem
rem Don't add trailing '\' to the JAVA_HOME path
set JAVA_HOME=C:\java\jdk-14.0.1

rem 1. Set output JAR filepath from dex2jar
rem    '%~nx1' - Expands '%~f1' to a file name and extension only
rem    Here it will be e.g. 'Android-PIN-Unblocker-4.13.1.apk'
rem 2. Remove '.apk' part from the filename (remove last 4 chars)
rem 3. Set the filename to add '-dex2jar.jar'
set JAR=%~nx1
set JAR=!JAR:~0,-4!
set JAR=%JAR%-dex2jar.jar
rem 4. Now it will be e.g. '.\Android-PIN-Unblocker-4.13.1-dex2jar.jar'

echo Located the JAR of this apk as:
echo %JAR%
echo.
echo Running Jar2Dex on the located JAR file...
echo.
".\dex-tools-v2.4\d2j-jar2dex.bat" -f "%JAR%"

echo Jar2Dex done.
echo Press any key to exit.
echo.
@pause


