
-verbose

# Suppress duplicate warning for system classes; Blaze is passing android.jar
# to proguard multiple times.
-dontnote **

# Stop warnings about missing unused classes
-dontwarn **

-keep public class com.acs.smartcard.** {
    public protected *;
}

-keepclassmembernames class com.acs.smartcard.** {
    java.lang.Class class$(java.lang.String);
    java.lang.Class class$(java.lang.String, boolean);
}

-keepclasseswithmembernames class com.acs.smartcard.** {
    native <methods>;
}

-keepclassmembers class com.acs.smartcard.** extends java.lang.Enum {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class com.acs.smartcard.** implements java.io.Serializable {
    static final long serialVersionUID;
    static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-optimizations library/*,!class/*,!field/*,!method/*,!code/merging,code/simplification/variable,!code/simplification/arithmetic,code/simplification/cast,code/simplification/field,code/simplification/branch,code/simplification/string,!code/simplification/math,code/simplification/advanced,code/removal/advanced,code/removal/simple,!code/removal/variable,code/removal/exception,code/allocation/*

# Specifies that the access modifiers of classes and class members may be broadened during optimization
-allowaccessmodification

-keeppackagenames com.acs.smartcard
-keeppackagenames com.acs.smartcard.ccid

-keepattributes *
-keepparameternames

-dontobfuscate

#-useuniqueclassmembernames
#-dontusemixedcaseclassnames
#-adaptclassstrings
#-adaptresourcefilenames
#-adaptresourcefilecontents

#-dontpreverify
-android

-target 1.7

