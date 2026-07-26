
@echo off

rem Enabled delayed expansion
rem Needed to trim filenames
setlocal EnableDelayedExpansion

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
set MINIMUM_API_LEVEL=9
set ANDROID_JAR=C:\Android\platforms\android-37.0\android.jar
set PROGUARD_CONFIG=.\r8-9.1.31\proguard-android-app-optimize.pro

rem 1. Set output JAR filepath from dex2jar
rem    '%~nx1' - Expands '%~f1' to a file name and extension only
rem    Here it will be e.g. 'Android-PIN-Unblocker-4.13.1.apk'
rem 2. Remove '.apk' part from the filename
rem 3. Set the filename to add '-dex2jar.jar'
set JAR=%~nx1
set JAR=!JAR:~0,-4!
set JAR=%JAR%-dex2jar.jar
rem 4. Now it will be e.g. '.\Android-PIN-Unblocker-4.13.1-dex2jar.jar'

rem You need Java installed in your system for this
rem Output file will be '.\classes.dex'
echo Located the JAR of this apk as:
echo %JAR%
echo.
echo Running Google R8 on the Dex2Jar output JAR file...
echo.
"%JAVA_HOME%\bin\java.exe" -cp ".\r8-9.1.31\r8-9.1.31.jar" com.android.tools.r8.R8 --release --min-api %MINIMUM_API_LEVEL% --output "." --pg-conf "%PROGUARD_CONFIG%" --lib "%ANDROID_JAR%" "%JAR%"

echo Optimization done.
echo Press any key to exit.
echo.
@pause


