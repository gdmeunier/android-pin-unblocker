
#
# This file has been modified for use with Android PIN Unblocker.
# This is not the original proguard-android-app-optimize.txt file.
#
# This file is configured to strip what the specific Android app
# Android PIN Unblocker doesn't use or doesn't need.
#
# It currently removes all logging from release builds of the APK.
#
# Big thanks to:
#  - https://craigrussell.io/2017/10/30/stripping-log-statements-using-proguard
#  - https://www.guardsquare.com/manual/configuration/usage
#  - https://developer.ravelin.com/psp/libraries-and-sdks/android/3ds-sdk/proguard-rules/
#  - https://www.guardsquare.com/manual/configuration/examples#logging
#  - https://www.zacsweers.dev/android-proguard-rules/
#

# ----- General Options

-verbose

# Suppress duplicate warning for system classes; Blaze is passing android.jar
# to proguard multiple times.
-dontnote **

# Stop warnings about missing unused classes
-dontwarn **

# ----- Input/Output Options

-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers

# ----- Keep Options (Shrinking / Optimization)

# Add the "allowobfuscation" if you want
# to use obfuscation for whatever reason
#
# Choose either of these two modifier combos:
#  - allowoptimization,includedescriptorclasses,includecode
#  - allowshrinking,includedescriptorclasses,includecode
#
# Hint: "allowoptimization" is better than "allowshrinking"
#
-keep,allowoptimization,includedescriptorclasses,includecode class **
-keepclassmembers,allowoptimization,includedescriptorclasses,includecode class * {
    *;
}

# ----- Shrinking Options

#-dontshrink

# ----- Optimization Options

#-dontoptimize
-optimizationpasses 3
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*,!code/allocation/variable,!class/unboxing/enum

# Specifies that the access modifiers of classes and class members may be broadened during optimization
-allowaccessmodification

# ----- Obfuscation Options

-keeppackagenames **
-keepattributes *
-keepparameternames

-dontobfuscate

#-useuniqueclassmembernames
#-dontusemixedcaseclassnames
#-adaptclassstrings
#-adaptresourcefilenames
#-adaptresourcefilecontents

# ----- Preverification Options

#-dontpreverify
-android

# ----- Target compatibility options

-target 1.7

# ----- Fully remove builtin Android logging

# In the optimization step, ProGuard will then remove calls to such methods
# if it can determine that the return values aren't used.
#
#  - "..." = match any parameters signature
#
# Some people online say that "println" might cause
# problems for a sizeable number of Android apps
#
# If you have any problems you might want to remove it
#
-assumenosideeffects class android.util.Log {
    public static int wtf(...);
    public static int e(...);
    public static int w(...);
    public static int i(...);
    public static int v(...);
    public static int d(...);
    public static java.lang.String getStackTraceString(java.lang.Throwable);
    public static int println(int, java.lang.String, java.lang.String);
    public static boolean isLoggable(java.lang.String, int);
}

# ----- Fully remove Basic4Android logging (release build)

-assumenosideeffects class anywheresoftware.b4a.BA {
    public static void Log(...);
    public static void LogError(...);
    public static void LogInfo(...);
}

# ----- Help remove unnecessary logging string variables too

-assumenoexternalsideeffects class java.lang.StringBuilder {
    public java.lang.StringBuilder();
    public java.lang.StringBuilder(int);
    public java.lang.StringBuilder(java.lang.String);
    public java.lang.StringBuilder append(java.lang.Object);
    public java.lang.StringBuilder append(java.lang.String);
    public java.lang.StringBuilder append(java.lang.StringBuffer);
    public java.lang.StringBuilder append(char[]);
    public java.lang.StringBuilder append(char[], int, int);
    public java.lang.StringBuilder append(boolean);
    public java.lang.StringBuilder append(char);
    public java.lang.StringBuilder append(int);
    public java.lang.StringBuilder append(long);
    public java.lang.StringBuilder append(float);
    public java.lang.StringBuilder append(double);
    public java.lang.String toString();
}

-assumenoexternalreturnvalues public final class java.lang.StringBuilder {
    public java.lang.StringBuilder append(java.lang.Object);
    public java.lang.StringBuilder append(java.lang.String);
    public java.lang.StringBuilder append(java.lang.StringBuffer);
    public java.lang.StringBuilder append(char[]);
    public java.lang.StringBuilder append(char[], int, int);
    public java.lang.StringBuilder append(boolean);
    public java.lang.StringBuilder append(char);
    public java.lang.StringBuilder append(int);
    public java.lang.StringBuilder append(long);
    public java.lang.StringBuilder append(float);
    public java.lang.StringBuilder append(double);
}


