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
	// in the MyConstants class
	//
	// This version of the constants is for internal
	// Advanced class access only
	public static final int ORIENTATION_UNKNOWN   = 0;
	public static final int ORIENTATION_PORTRAIT  = 1;
	public static final int ORIENTATION_LANDSCAPE = 2;
	
	// Toast duration length constants
	//
	// There's a copy of each one of these variables
	// in the MyConstants class
	//
	// This version of the constants is for internal
	// Advanced class access only
	public static final boolean TOAST_DURATION_SHORT = false;
	public static final boolean TOAST_DURATION_LONG  = true;
	
	// Toast duration lengths in milliseconds
	//
	// These are the actual toast durations
	// instead of boolean flags
	//
	// Useful for waiting until a toast has finished
	// before showing another one
	//
	public static final int TOAST_LONG_DELAY  = 3500; // 3.5 seconds
	public static final int TOAST_SHORT_DELAY = 2000; // 2 seconds
	#End If
	
	'For letting the Java native code know whether
	'the App was compiled without FLAG_SECURE
	#If NO_FLAG_SECURE
	#If Java
	public static final boolean NO_FLAG_SECURE = true;
	#End If
	#Else
	#If Java
	public static final boolean NO_FLAG_SECURE = false;
	#End If
	#End If
End Sub

Public Sub Initialize
	
End Sub

'
'Java-only functions for making the Activity --------------------------
'onCreate events easier to read
'

#If Java
import android.content.Context;
import android.app.Activity;
public void jDisableTitleBarAndActionBarIfNeeded(Activity ctx)
{
	// Check if the device display scale is too small (scale < 1.0)
	//
	if ( 1.0 > jGetDeviceScale(ctx) )
	{
		// Device display scale is too small
		// Disable the Activity TitleBar & ActionBar to save visual UI space
		//
		jDisableActivityTitleBar(ctx);
		jDisableActivityActionBar(ctx);
	}
}
#End If

#If Java
import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.os.CountDownTimer;
public void jSecureActivityOnCreate(Activity ctx, final boolean firstTimeLaunch)
{
	/* Try disabling Recent Apps thumbnails
	 * API level 33+ (Android 13+)
	 * 
	 * Older versions from a certain point in time
	 * must use FLAG_SECURE (Android 4.0.3+ / API level 15+)
	 * 
	 * Legacy versions already allow us to censor
	 * the Recent Apps thumbnail with the onCreateThumbnail
	 * Activity event (Android 4.0.2- / API level 14-)
	 */
	boolean thumbnailDisabledSuccessfully = false;
	
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		if ( !jDisableRecentAppsThumbnails(ctx) )
		{
			/* If the user is running the FLAG_SECURE build
			 * then it's not really a problem because
			 * the FLAG_SECURE will prevent the thumbnail
			 * from being created by Android anyway
			 *
			 * FLAG_SECURE is added later on in this function
			 * if disabling the Recent Apps thumbnail failed
			 * 
			 * However if the user runs the NO_FLAG_SECURE
			 * special-purpose build then it's a problem:
			 *  - Admin keys might leak in Recent Apps thumbnails
			 * 
			 * Check if the user was running the special-purpose
			 * NO_FLAG_SECURE build of this App
			 * 
			 * Note: warn only on first Activity launch
			 */
			if ( NO_FLAG_SECURE && firstTimeLaunch )
			{
				// User runs the NO_FLAG_SECURE build of this App
				// Don't try adding FLAG_SECURE as a fallback
				//
				// However the user does deserve to be warned
				// about this issue to avoid any potential trouble
				//
				if ( !jToastMessageShow(ctx, "Failed to disable the Recent Apps thumbnail", TOAST_DURATION_SHORT) )
				{
					jBetterActivityFinish(ctx);
					mycommon.jTrueApplicationExit();
				}
				//
				// Wait until the first toast disappears
				// before showing another one
				//
				new CountDownTimer(TOAST_SHORT_DELAY, 500)
				{
					@Override
					public void onTick(long millisUntilFinished) { }
					@Override
					public void onFinish()
					{
						if ( !jToastMessageShow(ctx, "Admin keys might leak in the thumbnails", TOAST_DURATION_LONG) )
						{
							jBetterActivityFinish(ctx);
							mycommon.jTrueApplicationExit();
						}
					}
				}.start();
			}
		}
		else
		{
			// Recent Apps thumbnail disabled
			// No problem here
			thumbnailDisabledSuccessfully = true;
		}
	}
	
	/* Legacy versions of Android allow us to properly
	 * censor Recent Apps thumbnails without FLAG_SECURE
	 * 
	 * On these legacy versions we consider that the
	 * Recent Apps thumbnails have been successfully
	 * censored, because it's done in the Activity's
	 * onCreateThumbnail event automatically
	 * 
	 * These legacy versions are Android 4.0.2 & older
	 * (API levels 14 & older)
	 */
	if ( Build.VERSION.SDK_INT <= 14 )
	{
		thumbnailDisabledSuccessfully = true;
	}
	
	/* Important reminder:
	 * We don't actually want to always add FLAG_SECURE
	 * even when the FLAG_SECURE build is used
	 * 
	 * The goal is not to block screenshots of this App,
	 * it's just that on some devices it's the only way
	 * to disable the Recent Apps thumbnails
	 *
	 * That's what FLAG_SECURE is used for, but if we
	 * were able to disable Recent Apps without it
	 * then alright, no need to add FLAG_SECURE
	 *
	 * If the user doesn't want the FLAG_SECURE build
	 * and decides to use NO_FLAG_SECURE, then they
	 * have been warned already and are on their own
	 */
	if ( !thumbnailDisabledSuccessfully && !NO_FLAG_SECURE )
	{
		// Returns true if the device is too old
		// and FLAG_SECURE did not exit in their
		// Android version (Android < 3.0)
		//
		if ( !jEnableActivityFlagSecure(ctx) )
		{
			/* Always warn every time on every Activity launch
			 * if the user runs the FLAG_SECURE build and the
			 * Activity's Recent Apps thumbnail could not be
			 * censored or disabled
			 */
			if ( !jToastMessageShow(ctx, "Failed to add the FLAG_SECURE", TOAST_DURATION_SHORT) )
			{
				jBetterActivityFinish(ctx);
				mycommon.jTrueApplicationExit();
			}
			//
			// Wait until the first toast disappears
			// before showing another one
			//
			new CountDownTimer(TOAST_SHORT_DELAY, 500)
			{
				@Override
				public void onTick(long millisUntilFinished) { }
				@Override
				public void onFinish()
				{
					if ( !jToastMessageShow(ctx, "Admin keys might leak in Recent Apps thumbnails", TOAST_DURATION_LONG) )
					{
						jBetterActivityFinish(ctx);
						mycommon.jTrueApplicationExit();
					}
				}
			}.start();
		}
	}
}
#End If

#If Java
/*
 * Available since Android 1.0 (API level 1)
 * Works up to Android 4.0.2 (API level 14)
 * 
 * Accidentally broken since Android 4.0.3 (API level 15)
 * Deliberately removed since Android 5.0 (API level 21)
 * 
 * Officially deprecated notice since Android 9 (API level 28)
 */
import android.content.Context;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.content.res.Resources;
import android.graphics.Bitmap.Config;
import android.graphics.Color;
import java.lang.Class;         // For Reflection
import java.lang.reflect.Field; // For Reflection
import net.gdmeunier.pinunblocker.R; // Must match App's package name
import android.os.Build;
import android.content.res.Resources.Theme;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.BitmapFactory;
//
// Avoid re-drawing thumbnails all the time
//
/* ----- ----- Not used ----- ----- **
private Bitmap cachedDrawableCensorThumbnail = null;
** ----- ----- Not used ----- ----- */
private Bitmap cachedDynamicCensorThumbnail  = null;

public boolean jCensorActivityThumbnail(Activity ctx, Bitmap outBitmap, Canvas canvas)
{
	//
	// Return true to prevent the default thumbnail from being generated
	// You can also draw your own thumbnail or dynamically generate one
	//
	
	//
	// [Reminders] The Canvas object "canvas" is provided by the caller
	//             The outBitmap object is not used for our purposes
	//
	
	//
	// ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
	//
	/* If you want to dynamically generate a Bitmap
	 * instead of using one in your "res/drawable" folder
	 */
	
	try
	{
		Bitmap censorThumbnail;
		
		if ( cachedDynamicCensorThumbnail != null )
		{
			censorThumbnail = cachedDynamicCensorThumbnail;
			
			//
			// Canvas.drawBitmap(Bitmap bitmap, float left, float top, Paint paint);
			//
			canvas.drawBitmap(censorThumbnail, 0, 0, null);
		}
		else
		{
			//
			// Default height & width of the preview thumbnail
			//
			int h = 1;
			int w = 1;
			
			/* Undocumented method for getting Android's
			 * default thumbnail preview size dynamically
			 * instead of using hardcoded values
			 */
			
			Resources res = ctx.getResources();
			
			// com.android.internal.R.dimen.thumbnail_height
			//
			int heightResId = res.getSystem().getIdentifier("thumbnail_height", "dimen", "android");
			
			// com.android.internal.R.dimen.thumbnail_width
			//
			int widthResId  = res.getSystem().getIdentifier("thumbnail_width", "dimen", "android");
			
			if ( heightResId > 0 && widthResId > 0 )
			{
				h = res.getDimensionPixelSize(heightResId);
				w = res.getDimensionPixelSize(widthResId);
			}
			
			// Android actually uses RGB_565 for thumbnail previews
			//
			censorThumbnail = Bitmap.createBitmap(w, h, Bitmap.Config.RGB_565);
			
			// Default color for censoring the preview thumbnail
			//
			int censorColor = Color.BLACK; // Or Color.DKGRAY
			
			// Get Activity's windowBackground color
			//
			try
			{
				// Use Reflection to get it 5x faster
				//
				Class colorClass = R.color.class;
				Field colorField = colorClass.getField("windowBackground");
				int   colorResId = colorField.getInt(null);
				
				if ( colorResId > 0 )
				{
					if ( Build.VERSION.SDK_INT < 23 )
					{
						/* Android 5.1.1- */
						
						// Deprecated on API level 23+ (Android 6+)
						//
						censorColor = res.getColor(colorResId);
					}
					else
					{
						/* Android 6+ */
						
						// Only available on API level 23+ (Android 6+)
						// Using null to avoid requesting any specific Resources.Theme
						//
						censorColor = res.getColor(colorResId, null);
					}
				}
			}
			catch (Exception e)
			{
				// Incase we have a botched value
				censorColor = Color.BLACK; // Or Color.DKGRAY
			}
			
			Paint censorPaint = new Paint();
			//
			// The default Paint style is already FILL
			// We could've used a null value anyway
			//
			censorPaint.setStyle(Paint.Style.FILL);
			censorPaint.setColor(censorColor);
			
			//
			// Canvas.drawBitmap(Bitmap bitmap, float left, float top, Paint paint);
			//
			canvas.drawBitmap(censorThumbnail, 0, 0, censorPaint);
			cachedDynamicCensorThumbnail = censorThumbnail;
		}
	}
	catch (Exception e)
	{
		// Nothing to do here
	}
	
	//
	// ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
	//
	/* If you want to use a bitmap file as the source
	 * for your preview thumbnail instead of
	 * dynamically generating it on-the-fly
	 *
	 */
	 
	/* ----- ----- Not used ----- ----- **
	try
	{
		//
		// Example: "myCensorThumbnail.bmp" in your App's "res/drawable" folder
		//
		Bitmap censorThumbnail;
		
		if ( cachedDrawableCensorThumbnail != null )
		{
			censorThumbnail = cachedDrawableCensorThumbnail;
		}
		else
		{
			censorThumbnail = BitmapFactory.decodeResource(ctx.getResources(), R.drawable.myCensorThumbnail);
		}
		
		//
		// Canvas.drawBitmap(Bitmap bitmap, float left, float top, Paint paint);
		//
		// We don't provide a Paint object (using null)
		// Paint objects should not be provided for drawing Bitmap files
		//
		canvas.drawBitmap(censorThumbnail, 0, 0, null);
		
		if ( cachedDrawableCensorThumbnail == null )
		{
			cachedDrawableCensorThumbnail = censorThumbnail;
		}
	}
	catch (Exception e)
	{
		// Nothing to do here
	}
	** ----- ----- Not used ---- ----- */
	
	//
	// ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
	//
	
	// Return true always to censor the thumbnail
	// Works even if we cannot provide a valid Bitmap
	//
	// Then the thumbnail is just nulled (prevented)
	//
	return true;
}
#End If

'
'Java-only functions --------------------------------------------------
'Some functions implicitly convert a Context to Activity & vice-versa
'

'
'Display a toast notification from Java code
'
#If Java
import android.content.Context;
import android.app.Activity;
import android.widget.Toast;
public boolean jToastMessageShow(Activity ctx, final String text, final boolean longDuration)
{
	if ( ctx == null )
	{
		return false;
	}
	
	try
	{
		Toast.makeText(ctx, text, longDuration ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT).show();
	}
	catch (Exception e)
	{
		return false;
	}
	
	return true;
}
#End If

'
'Disable the Android Autofill service for an Activity
'
#If Java
import android.content.Context;
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
import android.app.Activity;
import android.os.Build;
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
public void jOpenBrowserUrl(Activity ctx, String browserUrl)
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
import android.content.Context;
import android.os.Build;
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
import android.content.Context;
import android.os.Build;
import android.content.pm.PackageManager;
//
// Avoid re-acquiring a new ApplicationContext
// and PackageManager all the time
//
private PackageManager cachedPackageManagerHandle = null;

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
			PackageManager pkgMgr;
			
			if ( cachedPackageManagerHandle != null )
			{
				pkgMgr = cachedPackageManagerHandle;
			}
			else
			{
				pkgMgr = ctx.getApplicationContext().getPackageManager();
				cachedPackageManagerHandle = pkgMgr;
			}
			
			hasFlashlight = pkgMgr.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
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


