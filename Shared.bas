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
import android.content.Context;
import android.view.WindowManager;
import android.view.WindowMetrics;

import android.content.res.Configuration;

// Android 4.2+
import android.util.DisplayMetrics;
import android.view.Display;

// Android 4.1 & older
import android.content.res.Resources;

/* ************************************************ */

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

