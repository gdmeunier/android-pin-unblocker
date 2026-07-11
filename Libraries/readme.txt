
1. Copy libraries to your Basic4Android install
===============================================

Copy all provided library files (JAR & XML) to this folder:
C:\Program Files\Anywhere Software\B4A\AdditionalLibraries\B4A

 [i] Create this folder structure if it doesn't already exist.

2. Configure the Additional Libraries path
==========================================

After running Basic4Android, click on the
'Tools -> Configure Paths' menu item and set
the 'Additional Libraries' path to this value:

C:\Program Files\Anywhere Software\B4A\AdditionalLibraries

 [i] Basic4Android automatically search subfolders for
     compatible Basic4Android additional libraries.

3. Example javac.exe and android.jar file paths
===============================================

javac.exe:   C:\java\jdk-14.0.1\bin\javac.exe
android.jar: C:\Android\platforms\android-37.0\android.jar

 [i] You can change the paths to your own if you installed
     the Java JDK and Android SDK elsewhere on your system.

4. Clear the Basic4Android library cache
========================================

If your Android SDK is installed in "C:\Android" then
you can delete all the files & folders located at:

C:\Android\extras\b4a_local

Finally inside this project's "Objects" folder delete
all the contents except this file which must exist:

Objects\res\drawable\icon.png

 [i] Doing the above step will force refreshing
     the library cache with the updated libraries.


