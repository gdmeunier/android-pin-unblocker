
1. Copy libraries
=================

Copy these files to this folder (create it if it doesn't exist):

C:\Program Files\Anywhere Software\B4A\AdditionalLibraries\B4A

2. Configure Additional Libraries path
======================================

After running Basic4Android go to the "Tools -> Configure Paths"
menu and set the Additional Libraries path to this folder:

C:\Program Files\Anywhere Software\B4A\AdditionalLibraries

3. Example javac.exe and android.jar paths
==========================================

javac.exe:   C:\java\jdk-14.0.1\bin\javac.exe
android.jar: C:\Android\platforms\android-33\android.jar

You can change the paths to your own if you installed
the Java JDK and Android SDK elsewhere on your system.

4. Clear Basic4Android library cache
====================================

If your Android SDK is installed in "C:\Android" then
you can delete all folders located inside:

C:\Android\extras\b4a_local

Finally inside this project's "Objects" folder delete
all the contents except this file which needs to exist:

Objects\res\drawable\icon.png

Doing the above will force refreshing the library files
with the latest updated versions.

