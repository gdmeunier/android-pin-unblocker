
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
set ANDROID_JAR=C:\Android\platforms\android-37.0\android.jar
set PROGUARD_CONFIG=.\proguard-7.9.1\proguard-android-app-optimize.pro

rem 1. Set output JAR filepath from dex2jar
rem    '%~nx1' - Expands '%~f1' to a file name and extension only
rem    Here it will be e.g. 'Android-PIN-Unblocker-4.13.1.apk'
rem 2. Remove '.apk' part from the filename
rem 3. Set the filename to add '-dex2jar'
set JAR=%~nx1
set JAR=!JAR:~0,-4!
set JAR=%JAR%-dex2jar
rem 4. Now it will be e.g. '.\Android-PIN-Unblocker-4.13.1-dex2jar'

rem Set output JAR filepath for ProGuard
rem It will be e.g. '.\Android-PIN-Unblocker-4.13.1-dex2jar-proguard.jar'
set OUTJAR=%JAR%-proguard.jar

rem Set output JAR filepath from dex2jar
rem Now it will be e.g. '.\Android-PIN-Unblocker-4.13.1-dex2jar.jar'
set JAR=%JAR%.jar

rem You need Java installed in your system for this
echo Located the JAR of this apk as:
echo %JAR%
echo.
echo Running ProGuard on the located JAR file...
echo.
"%JAVA_HOME%\bin\java.exe" -jar ".\proguard-7.9.1\lib\proguard.jar" -include "%PROGUARD_CONFIG%" -libraryjars "%ANDROID_JAR%" -injars "%JAR%" -outjars "%OUTJAR%"

echo Optimization done.
echo Press any key to exit.
echo.
@pause


