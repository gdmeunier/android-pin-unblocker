B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

'
'Native code
'

'Add the ability to select a different build configuration
'for people who might not want to use FLAG_SECURE in the App.
'
'It could be used for taking screenshots of the app, for example.
'
#If NO_FLAG_SECURE
	#If JAVA
	public static boolean IsFlagSecureDisabled()
	{
		return true;
	}
	#End If
#Else
	#If JAVA
	public static boolean IsFlagSecureDisabled()
	{
		return false;
	}
	#End If
#End If

#If JAVA

//
// Add ability to check the number of device cameras
//

import android.hardware.Camera;

//
// For getting the device scale (DPI)
//

// Android 11+
import android.content.res.Configuration;

// Android 4.2+
import android.content.Context;

import android.view.WindowManager;
import android.view.WindowMetrics;

import android.util.DisplayMetrics;
import android.view.Display;

// Android 4.1 & older
import android.content.res.Resources;

//
// For checking if the device has a software navbar
//

//import android.content.Context;       // Already imported for getting device scale
//import android.content.res.Resources; // Already imported for getting device scale

import android.view.ViewConfiguration;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;

//
// Get device orientation function (support API 9+ / Android 2.3+)
//

// Android 11+
//import android.content.res.Configuration; // Already imported for getting device scale

// Android 4.2+
//import android.content.Context; // Already imported for getting device scale

//import android.view.WindowManager; // Already imported for getting device scale
//import android.view.WindowMetrics; // Already imported for getting device scale
//import android.view.Display;       // Already imported for getting device scale

// Android 4.1 & older
//import android.content.res.Resources; // Already imported for getting device scale

import android.view.Surface;

/* ************************************************ */

//
// Get device orientation function (support API 9+ / Android 2.3+)
//
// Thanks to:
// https://stackoverflow.com/a/10453034
// https://stackoverflow.com/a/6786814
//
// [Configuration] API level 1+
//
// ORIENTATION_SQUARE    = 3 (0x00000003) /!\ deprecated in API level 16
// ORIENTATION_LANDSCAPE = 2 (0x00000002)
// ORIENTATION_PORTRAIT  = 1 (0x00000001)
// ORIENTATION_UNDEFINED = 0 (0x00000000)
//
// [WindowManager] API level 1+
//
// Surface.ROTATION_0   = 0 (portrait)
// Surface.ROTATION_90  = 1 (landscape)
// Surface.ROTATION_180 = 2 (reverse portrait)
// Surface.ROTATION_270 = 3 (reverse landscape)
//
public static int getDeviceOrientation(Context ctx) {
	//
	// My own constants
	//
	int UNKNOWN   = 0x0;
	int PORTRAIT  = 0x1;
	int LANDSCAPE = 0x2;
	
	// Default value
	int deviceOrientation = UNKNOWN;
	int sdkVersion = android.os.Build.VERSION.SDK_INT;
	
	// Android 11+
	if ( sdkVersion >= 31 )
	{
		Configuration cfg = new Configuration();
		
		int orientation = cfg.orientation;
		switch(orientation)
		{
			case Configuration.ORIENTATION_LANDSCAPE:
				deviceOrientation = LANDSCAPE;
				break;
			case Configuration.ORIENTATION_PORTRAIT:
				deviceOrientation = PORTRAIT;
				break;
				
			default:
				deviceOrientation = UNKNOWN;
				break;
		}
	}
	// Android 4.2+
	else if ( sdkVersion >= 17 )
	{
		WindowManager wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
		Display display = wm.getDefaultDisplay();
		
		int orientation = display.getOrientation();
		switch (orientation)
		{
			case Surface.ROTATION_0:
				deviceOrientation = PORTRAIT;
				break;
			case Surface.ROTATION_90:
				deviceOrientation = LANDSCAPE;
				break;
			case Surface.ROTATION_180: // reverse-portrait
				deviceOrientation = PORTRAIT;
				break;
			case Surface.ROTATION_270: // reverse-landscape
				deviceOrientation = LANDSCAPE;
				break;
				
			default:
				deviceOrientation = UNKNOWN;
				break;
		}
	}
	// Android 4.1 & older
	else
	{
		int orientation = Resources.getSystem().getConfiguration().orientation;
		switch(orientation)
		{
			case Configuration.ORIENTATION_LANDSCAPE:
				deviceOrientation = LANDSCAPE;
				break;
			case Configuration.ORIENTATION_PORTRAIT:
				deviceOrientation = PORTRAIT;
				break;
				
			default:
				deviceOrientation = UNKNOWN;
				break;
		}
	}
	
	return deviceOrientation;
}

//
// Check if the device has a software navbar (navigation bar)
//
// Feed this function an Activity context
//
// Thanks to:
// https://stackoverflow.com/a/35426680
// https://forums.solar2d.com/t/height-of-android-navigation-bar-solved/353073
//
public static boolean hasNavBar(Context ctx) {
	//
	// Navigation bar was introduced in Android 4.0 (API level 14)
	//
	if ( android.os.Build.VERSION.SDK_INT >= 14 )
	{
		Resources rsrc = ctx.getResources();
		int       id   = rsrc.getIdentifier("config_showNavigationBar", "bool", "android");
		
		if ( id > 0 )
		{
			return rsrc.getBoolean(id);
		}
		else
		{
			//
			// Check for keys
			//
			boolean hasMenuKey = ViewConfiguration.get(ctx).hasPermanentMenuKey();
			boolean hasBackKey = KeyCharacterMap.deviceHasKey(KeyEvent.KEYCODE_BACK);
			
			return !hasMenuKey && !hasBackKey;
		}
	}
	else
	{
		return false;
	}
}

//
// Replace the Phone library with quick Java functions
//
public static int getAndroidSdkVersion() {
	return android.os.Build.VERSION.SDK_INT;
}

//
// Get screen DPI function (support API 9+ / Android 2.3+)
//
public static float getDeviceScale(Context ctx) {
	
	int sdkVersion = android.os.Build.VERSION.SDK_INT;
	
	// Android 11+
	if ( sdkVersion >= 31 )
	{
		Configuration cfg = new Configuration();
		return (float)cfg.densityDpi; // int->float
	}
	// Android 4.2+
	else if ( sdkVersion >= 17 )
	{
		WindowManager wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
		Display display = wm.getDefaultDisplay();
		
		DisplayMetrics dm = new DisplayMetrics();
		display.getRealMetrics(dm);
		
		return dm.density; // already float
	}
	// Android 4.1 & older
	else
	{
		return Resources.getSystem().getDisplayMetrics().density; // already float
	}
}

//
// Some devices don't even have a Camera so I want to check
// if the device actually has one, otherwise I will disable
// the QR code scanning function to avoid crashing the App.
//
public static int GetNumberOfDeviceCameras() {
	//
	// Thanks to https://stackoverflow.com/a/10593071
	//
	return Camera.getNumberOfCameras(); // Android API level 9+ (Android 2.3+)
}

#End If

