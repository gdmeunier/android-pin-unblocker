
@echo off

rem Give this script the APK file, not the JAR
rem
rem This script takes take of creating the DEX file for you
rem from the APK file itself (it uses its path to find the JAR)
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

rem Set output JAR filepath from dex2jar
rem '%~nx1' - Expands '%~f1' to a file name and extension only
rem Here it will be e.g. 'Android-PIN-Unblocker-4.8.0.apk'
set JAR=.\%~nx1
rem Remove '.apk' part from the filename (remove last 4 chars)
set JAR=!JAR:~0,-4!
rem Set the filename to add '-dex2jar.jar'
set JAR=%JAR%-dex2jar.jar
rem Now it will be e.g. '.\Android-PIN-Unblocker-4.8.0-dex2jar.jar'

rem Initial empty first line
echo.

echo Running Jar2Dex on the provided APK file...
echo.
".\dex-tools-v2.4\d2j-jar2dex.bat" -f "%JAR%"

echo Jar2Dex done.
echo Press any key to exit.
echo.
@pause


