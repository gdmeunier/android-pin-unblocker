B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

Sub Class_Globals
	#If JAVA
	// Device orientation type constants
	//
	// There's a copy of each one of these variables
	// in the MyCommon class
	//
	// This version of the constants is for internal
	// Advanced class access only
	public static int ORIENTATION_UNKNOWN   = 0;
	public static int ORIENTATION_PORTRAIT  = 1;
	public static int ORIENTATION_LANDSCAPE = 2;
	#End If
	
End Sub

Public Sub Initialize
	
End Sub

'
'Java-only functions --------------------------------------------------
'Some functions implicitly convert a Context to Activity & vice-versa
'

'
'Disable the Android Autofill service for an Activity
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.app.Activity;
import android.view.Window;
import android.view.ViewStructure;
import android.view.View;
import android.os.Build;
public void jDisableAndroidAutofillService(Activity ctx)
{
	if ( ctx == null )
	{
		return;
	}
	
	// Disable the new Android 8.0+ Autofill service (API level 26+)
	// For Android 8.0+ (API level 26+)
	if ( Build.VERSION.SDK_INT >= 26 )
	{
		try
		{
			ctx.getWindow().getDecorView().setImportantForAutofill(View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS);
		}
		catch (Exception e)
		{
			// Nothing to do here
		}
	}
}
#End If

'
'Disable Recent Apps thumbnails for an Activity
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.os.Build;
public boolean jDisableRecentAppsThumbnails(Activity ctx)
{
	if ( ctx == null )
	{
		return false;
	}
	
	// Check if device is API level 33 or higher (Android 13+)
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		try
		{
			ctx.setRecentsScreenshotEnabled(false);
		}
		catch (Exception e)
		{
			return false;
		}
	}
	else
	{
		// Report that disabling Recent Apps thumbnails
		// is not possible in older Android versions < 13
		return false;
	}
	
	return true;
}
#End If

'
'Enable FLAG_SECURE for an Activity
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
public boolean jEnableActivityFlagSecure(Activity ctx)
{
	if ( ctx == null )
	{
		return false;
	}
	
	// Check if device is API level 11 or higher (Android 3.0+)
	if ( Build.VERSION.SDK_INT >= 11 )
	{
		try
		{
			ctx.getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE);
		}
		catch (Exception e)
		{
			return false;
		}
	}
	else
	{
		// FLAG_SECURE didn't exist prior to Android 3.0
		//
		// But the Recent Apps panel back in Android 2.x
		// Also didn't leak any App thumbnails,
		// it only showed the App icon
		//
		// So just let the return of this function be true
		// for older Android 2.x versions since they are
		// not affected by Recent Apps thumbnail leaks
	}
	
	return true;
}
#End If

'
'Disable the Activity TitleBar
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.view.Window;
public void jDisableActivityTitleBar(Activity ctx)
{
	if ( ctx == null )
	{
		return;
	}
	
	try
	{
		ctx.requestWindowFeature(Window.FEATURE_NO_TITLE);
	}
	catch (Exception e)
	{
		// Nothing to do here
	}
}
#End If

'
'Disable the Activity ActionBar
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.app.ActionBar;
public void jDisableActivityActionBar(Activity ctx)
{
	if ( ctx == null )
	{
		return;
	}
	
	// ActionBar for API 11+ (Android 3.0+)
	if ( Build.VERSION.SDK_INT >= 11 )
	{
		try
		{
			ActionBar actionBar = ctx.getActionBar();
			
			if ( actionBar != null )
			{
				actionBar.hide();
			}
		}
		catch (Exception e)
		{
			// Nothing to do here
		}
	}
}
#End If

'
'Better Activity finish
'
#If Java
import android.content.Context;
import android.os.Build;
import android.app.Activity;
public void jBetterActivityFinish(Activity ctx)
{
	if ( ctx == null )
	{
		return;
	}
	
	/* Check if device is SDK 21 or higher (Android 5.0+) */
	if ( Build.VERSION.SDK_INT >= 21 )
	{
		ctx.finishAndRemoveTask();
	}
	/* Check if device is SDK 16 or higher (Android 4.1+) */
	else if ( Build.VERSION.SDK_INT >= 16 )
	{
		ctx.finishAffinity();
	}
	/* Fallback for older Android versions */
	else
	{
		ctx.finish();
	}
}
#End If

'
'Open browser URL
'Replaces the big Phone library with a Java native function
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
public void jOpenBrowserUrl(String browserUrl, Activity ctx)
{
	if ( ctx == null )
	{
		return;
	}
	
	if ( !browserUrl.startsWith("https://") && !browserUrl.startsWith("http://") )
	{
		browserUrl = "http://" + browserUrl;
	}
	
	try
	{
		ctx.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(browserUrl)));
	}
	catch (Exception e)
	{
		// Nothing to do here
	}
}
#End If

'
'Get the device scale
'
#If Java
import android.os.Build;
import android.content.res.Configuration; // Android 11+
import android.content.Context;           // Android 4.2+
import android.view.WindowManager;        // Android 4.2+
import android.view.WindowMetrics;        // Android 4.2+
import android.util.DisplayMetrics;       // Android 4.2+
import android.view.Display;              // Android 4.2+
import android.content.res.Resources;     // Android 4.1-
public float jGetDeviceScale(Context ctx)
{
	float devScale = (float)0.75;
	
	if ( ctx == null )
	{
		return devScale;
	}
	
	try
	{
		/* Android 11+ */
		if ( Build.VERSION.SDK_INT >= 31 )
		{
			Configuration cfg = new Configuration();
			devScale = (float)cfg.densityDpi; // int -> float
		}
		/* Android 4.2+ */
		else if ( Build.VERSION.SDK_INT >= 17 )
		{
			WindowManager wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
			Display  display = wm.getDefaultDisplay();
			
			DisplayMetrics dm = new DisplayMetrics();
			display.getRealMetrics(dm);
			
			devScale = dm.density; // Already float
		}
		/* Android 4.1- */
		else
		{
			devScale = Resources.getSystem().getDisplayMetrics().density; // Already float
		}
	}
	catch (Exception e)
	{
		// If this function fails then it's probably a very old device
		// with a very small display scale anyway
		devScale = (float)0.75;
	}
	
	return devScale;
}
#End If

'
'Get the device orientation
'
#If Java
//
// Configuration - API level 1+
//  - ORIENTATION_SQUARE    = 3 (0x00000003) /!\ deprecated in API level 16
//  - ORIENTATION_LANDSCAPE = 2 (0x00000002)
//  - ORIENTATION_PORTRAIT  = 1 (0x00000001)
//  - ORIENTATION_UNDEFINED = 0 (0x00000000)
//
// WindowManager - API level 1+
//  - Surface.ROTATION_0   = 0 (portrait)
//  - Surface.ROTATION_90  = 1 (landscape)
//  - Surface.ROTATION_180 = 2 (reverse portrait)
//  - Surface.ROTATION_270 = 3 (reverse landscape)
//
import android.os.Build;
import android.content.res.Configuration; // Android 11+
import android.content.Context;           // Android 4.2+
import android.view.WindowManager;        // Android 4.2+
import android.view.WindowMetrics;        // Android 4.2+
import android.view.Display;              // Android 4.2+
import android.content.res.Resources;     // Android 4.1-
import android.view.Surface;
public int jGetDeviceOrientation(Context ctx)
{
	// Default value is unknown
	// Better set initially a safe bet saying that we don't know
	int devOrientation = ORIENTATION_UNKNOWN;
	
	if ( ctx == null )
	{
		return devOrientation;
	}
	
	try
	{
		/* Android 11+ */
		if ( Build.VERSION.SDK_INT >= 31 )
		{
			Configuration cfg = new Configuration();
			int   orientation = cfg.orientation;
			
			switch(orientation)
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					devOrientation = ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					devOrientation = ORIENTATION_PORTRAIT;
					break;
					
				default:
					break;
			}
		}
		/* Android 4.2+ */
		else if ( Build.VERSION.SDK_INT >= 17 )
		{
			WindowManager wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
			Display  display = wm.getDefaultDisplay();
			int  orientation = display.getOrientation();
			
			switch (orientation)
			{
				case Surface.ROTATION_0:
					devOrientation = ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_90:
					devOrientation = ORIENTATION_LANDSCAPE;
					break;
					
				case Surface.ROTATION_180: // Reverse-portrait
					devOrientation = ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_270: // Reverse-landscape
					devOrientation = ORIENTATION_LANDSCAPE;
					break;
					
				default:
					break;
			}
		}
		/* Android 4.1- */
		else
		{
			int orientation = Resources.getSystem().getConfiguration().orientation;
			
			switch(orientation)
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					devOrientation = ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					devOrientation = ORIENTATION_PORTRAIT;
					break;
					
				default:
					break;
			}
		}
	}
	catch (Exception e)
	{
		// If this function fails (very old device?)
		// then just claim that the device orientation
		// is actually unknown (the safer option)
		devOrientation = ORIENTATION_UNKNOWN;
	}
	
	return devOrientation;
}
#End If

'
'Check if the device has a software NavBar
'
#If Java
import android.os.Build;
import android.content.Context;
import android.content.res.Resources;
import android.view.ViewConfiguration;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
public boolean jDeviceHasNavBar(Context ctx)
{
	boolean hasNavBar = false;
	
	if ( ctx == null )
	{
		return hasNavBar;
	}
	
	// Navigation bar was introduced in Android 4.0 (API level 14)
	if ( Build.VERSION.SDK_INT >= 14 )
	{
		try
		{
			Resources rsrc = ctx.getResources();
			int       id   = rsrc.getIdentifier("config_showNavigationBar", "bool", "android");
			
			if ( id > 0 )
			{
				hasNavBar = rsrc.getBoolean(id);
			}
			else
			{
				// Check for keys
				boolean hasMenuKey = ViewConfiguration.get(ctx).hasPermanentMenuKey();
				boolean hasBackKey = KeyCharacterMap.deviceHasKey(KeyEvent.KEYCODE_BACK);
				
				hasNavBar = !hasMenuKey && !hasBackKey;
			}
		}
		catch (Exception e)
		{
			// If any failure getting information about
			// device NavBar visibility,
			// then just default to claiming that the
			// device doesn't have a NavBar anyway
			hasNavBar = false;
		}
	}
	
	// Software NavBars didn't exist before Android 4.0
	return hasNavBar;
}
#End If

'
'Check if the device has a flashlight
'
#If Java
import android.os.Build;
import android.content.Context;
import android.content.pm.PackageManager;
public boolean jDeviceHasFlashlight(Context ctx)
{
	boolean hasFlashlight = false;
	
	if ( ctx == null )
	{
		return hasFlashlight;
	}
	
	// Android API level 7+ (Android 2.1+)
	if ( Build.VERSION.SDK_INT >= 7 )
	{
		/* Android 2.1+ */
		try
		{
			hasFlashlight = ctx.getApplicationContext().getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
		}
		catch (Exception e)
		{
			// Consider that there's no Flashlight
			// if this function fails
			hasFlashlight = false;
		}
	}
	
	return hasFlashlight;
}
#End If


