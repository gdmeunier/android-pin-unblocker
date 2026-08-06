B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
'
'Important notice:
'
'We want each class in this application to be standalone, so that they don't
'rely on other ones and create dependencies with eachother:
' - So don't hesitate do write two or more times the same function
'   across many classes that need it
'
'I want that people be able to easily extract specific classes from
'this application and reuse them in their own
'
'So all classes should have self-contained functions (not depending on eachother)
'
'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'This is a Java-only class, it does not offer Basic-code:
' - Functions that require a Context must not be static
' - Fields related to Context-dependent resources must not be static
'

Sub Class_Globals
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
End Sub

#If Java
//
// Class fields
//
public static int TOAST_SHORT_DURATION_LENGTH = 2000;
public static int TOAST_LONG_DURATION_LENGTH  = 3500;

//
// For caching purposes
// Their respective imports are located at the top their method
//
private Bitmap            cachedDynamicCensorThumbnail   = null;

private Resources         cachedContextResources         = null;
private Resources         cachedSystemResources          = null;

private int               cachedThumbnailHeightResId     = -0xF; // Alternative to null
private int               cachedThumbnailWidthResId      = -0xF; // Alternative to null

private int               cachedNavBarWidthResId         = -0xF; // Alternative to null

private int               cachedShowNavigationBarResId   = -0xF; // Alternative to null

private ViewConfiguration cachedContextViewConfiguration = null;

private PackageManager    cachedPackageManager           = null;

private WindowManager     cachedSystemWindowService      = null;

#End If

#If Java
//
// Class methods (for helping Activities have smaller codebases)
//
import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.widget.Toast;
import android.os.CountDownTimer;
public void jSecureActivityOnCreate(Activity ctx, final boolean firstTimeLaunch)
{
	/* Try disabling Recent Apps thumbnails on API level 33+ (Android 13+)
	 * 
	 * Older versions from a certain point in time must use FLAG_SECURE
	 * (Android 4.0.3+ / API level 15+)
	 * 
	 * Legacy versions already allow us to censor the Recent Apps thumbnail with
	 * the onCreateThumbnail Activity event (Android 4.0.2- / API level 14-)
	 */
	boolean thumbnailDisabledSuccessfully = false;
	
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		if ( jDisableRecentAppsThumbnails(ctx) )
		{
			// Recent Apps thumbnail disabled (no problem here)
			thumbnailDisabledSuccessfully = true;
		}
#End If
'Specific part only for NO_FLAG_SECURE builds
#If NO_FLAG_SECURE
#If Java
		else  /* Only for special-purpose builds (without FLAG_SECURE) */
		{
			/* If the user is running the FLAG_SECURE build then it's not really
			 * a problem because the FLAG_SECURE will prevent the thumbnail from
			 * being created by Android anyway
			 *
			 * FLAG_SECURE is added later on in this function if disabling the
			 * Recent Apps thumbnail failed
			 * 
			 * HOWEVER if the user runs the NO_FLAG_SECURE special-purpose build then
			 * it's a problem:
			 *  - Admin keys might leak in Recent Apps thumbnails,
			 *    because no FLAG_SECURE fallback will be used in such builds
			 */
			
			/* Check if the user was running the special-purpose NO_FLAG_SECURE build,
			 * and warn about the risks involved with using it if that's the case
			 *
			 * Note: Warn only on first Activity launch
			 *
			 * Note: The check for whether a NO_FLAG_SECURE build uses
			 *       conditional compilation directives:
			 *        - It uses the "#If NO_FLAG_SECURE" directive
			 */
			if ( firstTimeLaunch )
			{
				/* The user runs the NO_FLAG_SECURE build of this application
				 * Don't try adding FLAG_SECURE as a fallback
				 *
				 * HOWEVER the user deserves to be warned about this issue to avoid
				 * any potential trouble with forensic leaks on their device
				 *
				 * Note: If the toast cannot be shown, then the user cannot be warned,
				 *       so we just exit the caller Activity instead for safety reasons
				 */
				if ( !jToastMessageShow(ctx, "Failed to disable the Recent Apps thumbnail", TOAST_SHORT_DURATION_LENGTH) )
				{
					ctx.finish();
				}
				/*
				 * Wait until the first toast disappears before showing another one
				 *
				 * Note: the 500 number corresponds to a 500ms tick rate,
				 *       which neatly aligns with available toast display durations:
				 *        - 2000ms (short one) and 3500ms (long one)
				 */
				new CountDownTimer(TOAST_SHORT_DURATION_LENGTH, 500)
				{
					@Override
					public void onTick(long millisUntilFinished) { }
					
					@Override
					public void onFinish()
					{
						if ( !jToastMessageShow(ctx, "Admin keys might leak in Recent Apps thumbnails", TOAST_LONG_DURATION_LENGTH) )
						{
							ctx.finish();
						}
					}
				}.start();
			}
		}
#End If
#End If
#If Java
	}
	
	/* Legacy versions of Android allow us to properly censor the Recent Apps thumbnails
	 * without using the FLAG_SECURE functionality:
	 *  - On these legacy Android versions we consider that the
	 *    Recent Apps thumbnails have been successfully censored,
	 *    because it's done in the Activity's onCreateThumbnail event whenever
	 *    Android wishes to create one (it will return a censored one instead)
	 * 
	 * - These legacy Android versions are Android 4.0.2 & older
	 *   (API levels 14 & lower)
	 */
	if ( Build.VERSION.SDK_INT <= 14 )
	{
		thumbnailDisabledSuccessfully = true;
	}
#End If
'Specific part only for the default builds (with FLAG_SECURE)
#If Not(NO_FLAG_SECURE)
#If Java
	/* Important reminder:
	 * We don't actually want to always add FLAG_SECURE even when it's the
	 * FLAG_SECURE build that the user is running:
	 *  - The goal is NOT to block screenshots of this application,
	 *    it's just for many devices it's the only way to disable the
	 *    Recent Apps thumbnails
	 *
	 * That's what the FLAG_SECURE functionality is being used for,
	 * but if we were able to disable the Recent Apps thumbnails without it,
	 * then alright; no need to add the FLAG_SECURE attribute to the Activity
	 *
	 * If the user doesn't want the FLAG_SECURE build and decides to use the
	 * NO_FLAG_SECURE special-purpose one, then they have been warned already and
	 * they are on their own, they better have good OpSec then
	 */
	if ( !thumbnailDisabledSuccessfully ) /* Only for default builds (with FLAG_SECURE) */
	{
		/* Returns true if the device is too old and the FLAG_SECURE functionality
		 * did not exit for their Android version yet (Android < 3.0)
		 *
		 * Such very old Android versions never had a Recent Apps panel with
		 * Activity thumbnails anyway, they only had a list with application icons
		 *
		 * So we don't need to particularly warn about it to such legacy device users:
		 *  - We don't warn them about it because jEnableActivityFlagSecure just
		 *    returns true on their behalf as if the addition of FLAG_SECURE succeeded
		 */
		if ( !jSetActivityFlagSecure(ctx) )
		{
			/* Always warn every time on every Activity launch IF the user runs the
			 * default build (with FLAG_SECURE) and the Activity's Recent Apps thumbnail
			 * could not be disabled or censored
			 *
			 * The check for whether the user runs the NO_FLAG_SECURE build is done
			 * using conditional compilation directives:
			 *  - By using "#If Not(NO_FLAG_SECURE)" to wrap this part of the code
			 */
			if ( !jToastMessageShow(ctx, "Failed to set FLAG_SECURE on this window", TOAST_SHORT_DURATION_LENGTH) )
			{
				ctx.finish();
			}
			//
			// Wait until the first toast disappears before showing another one
			//
			new CountDownTimer(TOAST_SHORT_DURATION_LENGTH, 500)
			{
				@Override
				public void onTick(long millisUntilFinished) { }
				
				@Override
				public void onFinish()
				{
					if ( !jToastMessageShow(ctx, "Admin keys might leak in Recent Apps thumbnails", TOAST_LONG_DURATION_LENGTH) )
					{
						ctx.finish();
					}
				}
			}.start();
		}
	}
#End If
#End If
#If Java
}
#End If

#If Java
//
// Class methods (for helping Activities have smaller codebases)
//
import android.content.Context;
import android.app.Activity;
import android.os.Build;
public boolean jDisableRecentAppsThumbnails(Activity ctx)
{
	if ( ctx == null )
	{
		return false;
	}
	
	// Check if device is Android 13 or newer (API level 33+)
	// Because we use APIs that require atleast this version
	//
	if ( Build.VERSION.SDK_INT < 33 )
	{
		/* Report that disabling Recent Apps thumbnails is not possible in
		 * older Android versions (older than Android 13)
		 */
		return false;
	}
	
	try
	{
		ctx.setRecentsScreenshotEnabled(false);
	}
	catch (Exception e)
	{
		return false;
	}
	
	return true;
}

import android.content.Context;
import android.app.Activity;
import android.widget.Toast;
public boolean jToastMessageShow(Activity ctx, final String text, final int durationMillis)
{
	if ( ctx == null )
	{
		return false;
	}
	
	try
	{
		Toast.makeText(ctx, text, (durationMillis == TOAST_SHORT_DURATION_LENGTH ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG)).show();
	}
	catch (Exception e)
	{
		return false;
	}
	
	return true;
}

import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
public boolean jSetActivityFlagSecure(Activity ctx)
{
	if ( ctx == null )
	{
		return false;
	}
	
	/* Check if device is API level 11 or higher (Android 3.0+)
	 *
	 * If the Android version too old (too low API level),
	 * then we just return true directly since such very old
	 * Android versions never had Recent Apps thumbnails to begin with:
	 *  - They only had lists with application icons instead
	 */
	if ( Build.VERSION.SDK_INT < 11 )
	{
		return true;
	}
	
	try
	{
		//
		// Don't cache this information
		//
		ctx.getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE);
	}
	catch (Exception e)
	{
		/* If any failure happened while setting the FLAG_SECURE attribute,
		 * then return false instead of letting the code reach the final return
		 */
		return false;
	}
	
	return true;
}

/*
 * - Available since Android 1.0 (API level 1)
 * - Works up to Android 4.0.2 (API level 14)
 *
 * - Accidentally broken since Android 4.0.3 (API level 15)
 * - Deliberately removed since Android 5.0 (API level 21)
 *
 * - Officially deprecated notice since Android 9 (API level 28)
 */
import android.content.Context;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.content.res.Resources;
import android.graphics.Bitmap.Config;
import android.graphics.Color;
import java.lang.Class;              // For Reflection
import java.lang.reflect.Field;      // For Reflection
import net.gdmeunier.pinunblocker.R; // Must match the application's package name
import android.os.Build;
import android.content.res.Resources.Theme;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.BitmapFactory;
public boolean jCensorActivityThumbnail(Activity ctx, Bitmap outBitmap, Canvas canvas)
{
	//
	// Return true to prevent the default thumbnail from being generated
	//
	
	/* Reminders: - The Canvas object "canvas" is provided by the caller
	 *            - The "outBitmap" object is not used for our purposes
	 */
	try
	{
		Bitmap censorThumbnail;
		
		if ( cachedDynamicCensorThumbnail != null )
		{
			censorThumbnail = cachedDynamicCensorThumbnail;
			
			/* Canvas.drawBitmap(Bitmap bitmap, float left, float top, Paint paint); */
			canvas.drawBitmap(censorThumbnail, 0, 0, null);
		}
		else
		{
			// Default height & width of the preview thumbnail
			int h = 1; // 1px
			int w = 1; // 1px
			
			/* Undocumented method for getting Android's default
			 * thumbnail preview size dynamically instead of using
			 * hardcoded values (different devices have different values)
			 */
			Resources ctxRes;
			
			if ( cachedContextResources != null )
			{
				ctxRes = cachedContextResources;
			}
			else
			{
				ctxRes = ctx.getResources();
				cachedContextResources = ctxRes;
			}
			
			Resources sysRes;
			
			if ( cachedSystemResources != null )
			{
				sysRes = cachedSystemResources;
			}
			else
			{
				sysRes = ctxRes.getSystem();
				cachedSystemResources = sysRes;
			}
			
			/* com.android.internal.R.dimen.thumbnail_height */
			int heightResId;
			
			if ( cachedThumbnailHeightResId != -0xF )
			{
				heightResId = cachedThumbnailHeightResId;
			}
			else
			{
				heightResId = sysRes.getIdentifier("thumbnail_height", "dimen", "android");
				cachedThumbnailHeightResId = heightResId;
			}
			
			/* com.android.internal.R.dimen.thumbnail_width */
			int widthResId;
			
			if ( cachedThumbnailWidthResId != -0xF )
			{
				widthResId = cachedThumbnailWidthResId;
			}
			else
			{
				widthResId = sysRes.getIdentifier("thumbnail_width", "dimen", "android");
				cachedThumbnailWidthResId = widthResId;
			}
			
			if ( heightResId > 0 && widthResId > 0 )
			{
				//
				// Don't cache this information
				//
				h = ctxRes.getDimensionPixelSize(heightResId);
				w = ctxRes.getDimensionPixelSize(widthResId);
			}
			
			// Android actually uses RGB_565 for thumbnail previews
			censorThumbnail = Bitmap.createBitmap(w, h, Bitmap.Config.RGB_565);
			
			// Default color for censoring the preview thumbnail
			int censorColor = Color.DKGRAY; /* Or Color.BLACK */
			
			/* Get the Activity's windowBackground color:
			 *  - So that our censored thumbnail fill color matches
			 *    the Activity's window background color,
			 *    which is always neat to have
			 */
			try
			{
				//
				// Use Reflection to get it 5x faster (thanks to the Internet for this)
				//
				Class colorClass = R.color.class;
				Field colorField = colorClass.getField("windowBackground");
				int   colorResId = colorField.getInt(null);
				//
				// Don't cache this information
				//
				if ( colorResId > 0 )
				{
					if ( Build.VERSION.SDK_INT < 23 )
					{
						/* Android 5.1.1-:
						 * - Deprecated on API level 23+ (Android 6+)
						 */
						censorColor = ctxRes.getColor(colorResId);
					}
					else
					{
						/* Android 6+:
						 *  - Only available on API level 23+ (Android 6+)
						 *  - Using "null" to avoid requesting any specific Resources.Theme
						 */
						censorColor = ctxRes.getColor(colorResId, null);
					}
				}
			}
			catch (Exception e)
			{
				/* Incase we have a botched value */
				censorColor = Color.DKGRAY; /* Or Color.BLACK */
			}
			
			Paint censorPaint = new Paint();
			
			/* The default Paint style is already FILL:
			 *  - So we could also use "null" to not specify it explicitly
			 */
			censorPaint.setStyle(Paint.Style.FILL);
			censorPaint.setColor(censorColor);
			
			/* Canvas.drawBitmap(Bitmap bitmap, float left, float top, Paint paint); */
			canvas.drawBitmap(censorThumbnail, 0, 0, censorPaint);
			
			cachedDynamicCensorThumbnail = censorThumbnail;
		}
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	/* Always return true to censor the Recent Apps thumbnail
	 * 
	 * This works even if we cannot provide a valid bitmap,
	 * in such cases then the thumbnail is just null,
	 * and Android knows with the "true" value that it should just
	 * not display anything (fully white or fully black thumbnail)
	 */
	return true;
}

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
	if ( Build.VERSION.SDK_INT >= 26 )
	{
		try
		{
			//
			// Don't cache this information
			//
			ctx.getWindow().getDecorView().setImportantForAutofill(View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS);
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
	}
}

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
		/* Nothing to do here */
	}
}

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
	
	// Android 3.0 or higher only (API level 11+):
	//  - The ActionBar didn't exit on Android < 3.0
	//
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
			/* Nothing to do here */
		}
	}
}
#End If

#If Java
//
// Class fields, subclasses & methods
//
/* In Android versions up to 2.3.7 (API level 10), the Android Activity lifecycle was so strict
 * that Android frequently killed apps that were in the background to save memory,
 * as the devices back two decandes ago (~2010) had very low amounts of RAM (512MB for most)
 *
 * So up to Android 2.3.7 (API level 10) an app's Activities were considered as killable to save
 * on the device's scarce RAM resources which were low at the time
 *
 * As such that means these legacy Android version also actually *avoid* pausing applications
 * when the screen is turned off (because it might kill its process)
 *
 * These older Android versions even allowed only one foreground Activity to stay active and
 * just killed those that were put in the background after a short while,
 * without even calling pausing or stopping them first
 *
 * It's only starting with Android 3.0 (API level 11) that this Activity lifecycle was
 * revamped, with Android no longer considering Activities as killable but instead having
 * a more graceful behavior towards them; and started to pause Activities when
 * non-interactive events happen (e.g. screen off, screen locked, screensaver running [...])
 *
 * So long story short, when the screen is turned off, older legacy devices such as
 * Android 2.3.7 and earlier will not pause this application's Activities,
 * so Android also won't resume them either:
 *  - In such cases we have no other way to handle pause & resume on screen off than
 *    intercepting both screen-on & screen-off events then simulate the newer
 *    Activity lifecycle of Android 3.0 and higher (API level 11+) by ourselves:
 *
 *    By calling our Activity_Pause & Activity_Resume functions manually
 *
 * I actually verified that this is actually what really happens on my Android 2.3.6 device,
 * and I confirmed that it's what indeed happens:
 *  - The Activities don't pause & resume on device screen-off then screen-on events
 *
 * So to better support these legacy devices we register for both the
 * "Intent.ACTION_SCREEN_OFF" and "Intent.ACTION_SCREEN_ON" events
 *
 * Misc notes:
 *  - "Read the doc carefully!
 *     This broadcast actually tells you if the device is "interactive".
 *     If the screen is locked, the device is not interactive."
 */

/* This one is static because we don't need a running instance of this class
 * for just detecting device idle states,
 * which cans run independently of the other class code
 */
import android.content.IntentFilter;
import android.content.Intent;
public static IntentFilter jGetDeviceIdleIntentFilter()
{
	IntentFilter DeviceIdleIntentFilter = new IntentFilter();
	
	DeviceIdleIntentFilter.addAction(Intent.ACTION_SCREEN_OFF);
    DeviceIdleIntentFilter.addAction(Intent.ACTION_SCREEN_ON);
	
	return DeviceIdleIntentFilter;
}

/* Classes are not functions, so they should not start with j[...] here
 * unlike function names
 *
 * This one is static because we don't need a running instance of this class
 * for just detecting device idle states,
 * which cans run independently of the other class code
 */
import android.content.BroadcastReceiver;
import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.objects.ActivityWrapper;
import android.content.Intent;
import android.os.Build;
public static class DeviceIdleReceiver extends BroadcastReceiver
{
	// For storing the Activity handle of the caller's Activity
	BA callerProcessBA;
	ActivityWrapper callerWrappedActivity;
	
	/* Constructor method:
	 *  - For calling this class with:
	 *    new myadvanced.DeviceIdleReceiver(BA processBA, ActivityWrapper _activity);
	 */
	public DeviceIdleReceiver(BA processBA, ActivityWrapper _activity)
	{
		callerProcessBA        = processBA;
		callerWrappedActivity  = _activity;
		
		/* Always save the current instance because the getInstance function
		 * might be called later even if the caller shouldn't do it,
		 * after using the new-constructor method
		 */
		sInstance = this;
		
		/* Constructors cannot have a return statement */
	}
	
	//
	// The DeviceIdleReceiver class code
	//
	@Override
	public void onReceive(Context ctx, Intent receivedIntent)
	{
		// Don't include "callerWrappedActivity" in the checks
		// "callerWrappedActivity" cans legitimately be null
		//
		if ( receivedIntent == null || callerProcessBA == null )
		{
			return;
		}
		
		/* Using the undocumented "className" public field of
		 * the caller's "processBA" object
		 *
		 * Otherwise it would be e.g. "net.gdmeunier.pinublocker.main"
		 *
		 * Here it will instead become e.g. "main", "scan" [...]
		 */
		String callerClassName = jFullClassNameToShortClassName(callerProcessBA.className);
		
		/* Just so we know when the Activity receives a device idle broadcast
		 *
		 * We say "Received System Broadcast" because otherwise you would
		 * receive other the non-system ones via your own Receiver modules,
		 * and declare them in your app manifest instead
		 *
		 * Here this class receives System broadcasts,
		 * those that can only be received by registering for them using Java code
		 *
		 * So we know that we're not going to receive non-System ones here
		 */
		BA.LogInfo("** Activity ("+callerClassName+") Received System Broadcast **");
		
		String receivedIntentAction = receivedIntent.getAction();
		
		if ( receivedIntentAction == null )
		{
			return;
		}
		
		if ( receivedIntentAction.equals(Intent.ACTION_SCREEN_OFF) )
		{
			//
			// Device idle state detected
			//
			BA.LogInfo("** Activity ("+callerClassName+") Screen Off System Broadcast **");
			
			// Check if we have an Android 2.3.7 or older device
			// Android 2.3.7 is API level 10
			//
			if ( Build.VERSION.SDK_INT <= 10 )
			{
				/* Android 2.3.7 or older */
				BA.LogInfo("DeviceIdleReceiver->onReceive: Android version < Android 3.0");
				BA.LogInfo("DeviceIdleReceiver->onReceive: Manually firing the "+callerClassName+" Activity's Activity_Pause event");
				
				/* Simulate the Android 3.0+ Activity lifecycle ourselves
				 * (Android 3.0+ is API level 11)
				 *
				 * We do it before Activity_Idle because that's how newer Android versions
				 * also do it, System broadcast receivers are send after the Activity's own
				 * builtin lifecycle events
				 *
				 * And if the application is already paused, no need to fire this event
				 *
				 * Remember also that this will not actually pause the Activity,
				 * it will only run its Activity_Pause function:
				 *  - Only Android itself cans pause Activities via its ActivityManager
				 */
				try
				{
					// Fire the caller's Activity_Pause event handler
					/*                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
					callerProcessBA.raiseEvent2(callerWrappedActivity,  false,              "activity_pause",     false,                  new Object[]{ false }); /* UserClosed = False */
				}
				catch (Exception e)
				{
					/* Nothing to do here */
				}
			}
			else
			{
				/* Android 3.0 or newer */
				BA.LogInfo("DeviceIdleReceiver->onReceive: Android version >= 3.0");
				BA.LogInfo("DeviceIdleReceiver->onReceive: No need to manually fire the "+callerClassName+" Activity's Activity_Pause event");
			}
			
			// This one is the Activity_Idle event
			// It's always manually fired on all Android versions
			//
			BA.LogInfo("DeviceIdleReceiver->onReceive: Firing the "+callerClassName+" Activity's custom Activity_Idle event (for all Android versions)");
			try
			{
				/* Fire the caller's Activity_Idle event handler
				 * 
				 * Sub signature:
				 *  - Sub Activity_Idle
				 *        'Do idle-related tasks here
				 *    End Sub
				 */
				/*                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
				callerProcessBA.raiseEvent2(callerWrappedActivity,  true,               "activity_idle",      false,                  null);
			}
			catch (Exception e)
			{
				/* Nothing to do here */
			}
		}
		else if ( receivedIntentAction.equals(Intent.ACTION_SCREEN_ON) )
		{
			//
			// Device screen on event detected
			//
			BA.LogInfo("** Activity ("+callerClassName+") Screen On System Broadcast **");
			
			// Check if we have an Android 2.3.7 or older device
			// Android 2.3.7 is API level 10
			//
			if ( Build.VERSION.SDK_INT <= 10 )
			{
				/* Android 2.3.7 or older */
				BA.LogInfo("DeviceIdleReceiver->onReceive: Android version < Android 3.0");
				BA.LogInfo("DeviceIdleReceiver->onReceive: Manually firing the "+callerClassName+" Activity's Activity_Resume event");
				
				// Simulate the Android 3.0+ Activity lifecycle ourselves
				// (Android 3.0+ is API level 11)
				//
				try
				{
					/* Fire the caller's Activity_Resume event handler
					 *
					 * We don't actually need to always fire this event even if the application was paused,
					 * because we never actually paused the application
					 *
					 * The application was never paused to begin with, we just manually called the
					 * Activity_Pause function prior but the application's Activity was not paused per-se
					 *
					 * This is just a way for us to better hide the Admin Key field when the screen is
					 * turned off then turned back on
					 *
					 * And if you want to fire Activity_Resume for this, then you must first have
					 * a ViewState to restore so that's why we fired Activity_Pause before (on screen off)
					 *
					 * Because Activity_Pause saves the ViewState, then this Activity_Resume call cans
					 * restore it instead of restoring wrong prior ViewStates
					 *
					 * TLDR: Activity_Resume will do a ViewState restore, but if you don't refresh it
					 *       then it will restore an outdated wrong one
					 *       
					 *       So to satisfy the needs of Activity_Resume, we produced a fresh ViewState
					 *       by firing the Activity's Activity_Pause event prior (when the screen was off)
					 */
					/*                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
					callerProcessBA.raiseEvent2(callerWrappedActivity,  false,              "activity_resume",    false,                  null);
					
					/* Additional notes:
					 *
					 * This call above will actually fire when the screen is turned on,
					 * but also even when it's just on the lockscreen without being back
					 * to back to the application's Activity yet
					 *
					 * So the Activity_Resume will fire while the keyguard is being shown,
					 * incase there's a lockscreen enabled (even the 'swipe to unlock' one)
					 *
					 * However this is not a problem for us, because we fired Activity_Pause first
					 * and deliberately prevented any accidental 'positive'
					 * ViewState register restore such as the Flashlight 'on' and
					 * Hide Admin Key checkbox 'unchecked' states (examples of sensitive states)
					 *
					 * This means that, for example, while the Flashlight and the
					 * Admin Key field's 'revealable' status will be thus restored
					 * on legacy Android 2.3.7- devices early-on, while on the lockscreen,
					 * they will actually always be restored to safe versions instead:
					 *  - Flashlight state always restored to Off
					 *  - Hide Admin Key checkbox state restored to Hidden
					 *  - Admin Key field always restored to password-mode (hidden)
					 *
					 * This is what Activity_Idle event Subs do for us when the screen
					 * is turned off:
					 *  - Deliberately preventing any potential inconvenience
					 *    (Flashlight state) or potential leaks (Admin Key field state)
					 *
					 * So yes it does fire immediately when the screen is on,
					 * but in our case it's even better for us
					 *
					 * And remember that this only always happens on legacy devices:
					 * - Those that won't already fire Activity_Pause or Activite_Resume
					 *   lifecycle events on their own when the screen is turned on/off
					 *
					 * So we won't run into problems such as firing these events twice
					 * as the new devices that do run these events themselves are
					 * excluded from this part of the code (API level <= 10 checks)
					 */
				}
				catch (Exception e)
				{
					/* Nothing to do here */
				}
			}
			else
			{
				/* Android 3.0+ */
				BA.LogInfo("DeviceIdleReceiver->onReceive: Android version >= 3.0");
				BA.LogInfo("DeviceIdleReceiver->onReceive: No need to manually fire the "+callerClassName+" Activity's Activity_Resume event");
			}
		}
	}
	
	/* For convenience purposes
	 *
	 * For calling it with:
	 *  - myadvanced.DeviceIdleReceiver.getInstance(BA processBA, ActivityWrapper _activity);
	 */
	private static DeviceIdleReceiver sInstance;
	
	public static DeviceIdleReceiver getInstance(BA processBA, ActivityWrapper _activity)
	{
		if (sInstance == null)
		{
			sInstance = new DeviceIdleReceiver(processBA, _activity);
		}
		
		return sInstance;
	}
}

/* This one is static because we don't need a running instance of this class
 * for just detecting device idle states,
 * which cans run independently of the other class code
 */
public static String jFullClassNameToShortClassName(final String fullClassName)
{
	/* In Java (and generally any programming languages with expandable strings)
	 * you have to escape the "\" character since it's literally in itself
	 * the escape operator, and we use a RegEx string that uses a literal "\"
	 * character to match the dots in a full class name
	 *
	 * So if you want this:
	 *  -> "^.+\.([^\.]+?)$"
	 *
	 * Then you must instead write:
	 *  -> "^.+\\.([^\\.]+?)$"
	 *
	 * Examples of class names:
	 *  - Full:  net.gdmeunier.pinunblocker.main
	 *  - Short: main
	 */
	return fullClassName.replaceAll("^.+\\.([^\\.]+?)$", "$1");
}
#End If

#If Java
//
// Class methods
//
import android.content.Context;
import android.os.Build;
import android.content.res.Resources;
public int jGetSoftwareNavBarWidth(Context ctx)
{
	int softwareNavBarWidth = 0;
	
	if ( ctx == null || !jDeviceHasSoftwareNavBar(ctx) )
	{
		return softwareNavBarWidth;
	}
	
	try
	{
		Resources ctxRes;
		
		if ( cachedContextResources != null )
		{
			ctxRes = cachedContextResources;
		}
		else
		{
			ctxRes = ctx.getResources();
			cachedContextResources = ctxRes;
		}
		
		int resId;
		
		if ( cachedNavBarWidthResId != -0xF )
		{
			resId = cachedNavBarWidthResId;
		}
		else
		{
			resId = ctxRes.getIdentifier("navigation_bar_width", "dimen", "android");
			cachedNavBarWidthResId = resId;
		}
		//
		// Don't cache this information
		//
		if ( resId > 0 )
		{
			softwareNavBarWidth = ctxRes.getDimensionPixelSize(resId);
		}
	}
	catch (Exception e)
	{
		/* If any failure happens while getting information about the
		 * device software NavBar width, then just default to returning the
		 * default Android 48dip width in raw pixels instead
		 */
		softwareNavBarWidth = (int)(48 * jGetDisplayScale(ctx)); // In actual pixels
	}
	
	return softwareNavBarWidth;
}

import android.content.Context;
import android.os.Build;
import android.content.res.Resources;
import android.view.ViewConfiguration;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
public boolean jDeviceHasSoftwareNavBar(Context ctx)
{
	boolean hasSoftwareNavBar = false;
	
	// Software navigation bars were introduced in Android 4.0 (API level 14)
	// Older Android versions never had software NavBars anyway
	//
	if ( ctx == null  || Build.VERSION.SDK_INT < 14 )
	{
		return hasSoftwareNavBar;
	}
	
	try
	{
		Resources ctxRes;
		
		if ( cachedContextResources != null )
		{
			ctxRes = cachedContextResources;
		}
		else
		{
			ctxRes = ctx.getResources();
			cachedContextResources = ctxRes;
		}
		
		int resId;
		
		if ( cachedShowNavigationBarResId != -0xF )
		{
			resId = cachedShowNavigationBarResId;
		}
		else
		{
			resId = ctxRes.getIdentifier("config_showNavigationBar", "bool", "android");
			cachedShowNavigationBarResId = resId;
		}
		//
		// Don't cache this information
		//
		if ( resId > 0 )
		{
			hasSoftwareNavBar = ctxRes.getBoolean(resId);
		}
		else
		{
			// If this method doesn't work, then use the ViewConfiguration one to
			// check what physical keys are present on the device instead
			//
			ViewConfiguration ctxViewCfg;
			
			if ( cachedContextViewConfiguration != null )
			{
				ctxViewCfg = cachedContextViewConfiguration;
			}
			else
			{
				ctxViewCfg = ViewConfiguration.get(ctx);
				cachedContextViewConfiguration = ctxViewCfg;
			}
			//
			// Don't cache this information
			//
			boolean hasMenuKey = ctxViewCfg.hasPermanentMenuKey();
			boolean hasBackKey = KeyCharacterMap.deviceHasKey(KeyEvent.KEYCODE_BACK);
			
			hasSoftwareNavBar = !hasMenuKey && !hasBackKey;
		}
	}
	catch (Exception e)
	{
		/* If any failure happens while getting information about whether
		 * there's a software NavBar, then just default to claiming that
		 * the device doesn't have a software NavBar instead
		 */
		hasSoftwareNavBar = false;
	}
	
	return hasSoftwareNavBar;
}

import android.content.Context;
import android.os.Build;
import android.content.pm.PackageManager;
public boolean jDeviceHasUsbOtgSupport(Context ctx)
{
	boolean hasUsbOtgSupport = false;
	
	// Android 3.1 or higher only (API-level 12+)
	// USB-OTG was only added to Android since Android 3.1
	//
	if ( ctx == null || Build.VERSION.SDK_INT < 12 )
	{
		return hasUsbOtgSupport;
	}
	
	try
	{
		PackageManager pkgMgr;
		
		if ( cachedPackageManager != null )
		{
			pkgMgr = cachedPackageManager;
		}
		else
		{
			pkgMgr = ctx.getPackageManager();
			cachedPackageManager = pkgMgr;
		}
		
		hasUsbOtgSupport = pkgMgr.hasSystemFeature(PackageManager.FEATURE_USB_HOST);
	}
	catch (Exception e)
	{
		/* Consider that there's no USB OTG feature if this function fails
		 */
		hasUsbOtgSupport = false;
	}
	
	return hasUsbOtgSupport;
}

import android.content.Context;
import android.os.Build;
import android.content.pm.PackageManager;
public boolean jDeviceHasFlashlight(Context ctx)
{
	boolean hasFlashlight = false;
	
	// Android 2.1 or higher only (API level 7+)
	// We use APIs that require atleast this version
	//
	if ( ctx == null || Build.VERSION.SDK_INT < 7 )
	{
		return hasFlashlight;
	}
	
	try
	{
		PackageManager pkgMgr;
		
		if ( cachedPackageManager != null )
		{
			pkgMgr = cachedPackageManager;
		}
		else
		{
			pkgMgr = ctx.getPackageManager();
			cachedPackageManager = pkgMgr;
		}
		
		hasFlashlight = pkgMgr.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
	}
	catch (Exception e)
	{
		/* Consider that there's no Flashlight if this function fails
		 */
		hasFlashlight = false;
	}
	
	return hasFlashlight;
}

import android.content.Context;
import android.os.Build;
import android.content.pm.PackageManager;
public boolean jDeviceHasFrontCamera(Context ctx)
{
	boolean hasFrontCamera = false;
	
	// Android 2.3.2 or higher only (API level 9+)
	// We use APIs that require atleast this version
	//
	if ( ctx == null || Build.VERSION.SDK_INT < 9 )
	{
		return hasFrontCamera;
	}
	
	try
	{
		PackageManager pkgMgr;
		
		if ( cachedPackageManager != null )
		{
			pkgMgr = cachedPackageManager;
		}
		else
		{
			pkgMgr = ctx.getPackageManager();
			cachedPackageManager = pkgMgr;
		}
		
		hasFrontCamera = pkgMgr.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT);
	}
	catch (Exception e)
	{
		/* If any problem fallback to checking the number of Cameras instead
		 */
		hasFrontCamera = (jGetDeviceCamerasCount() >= 2);
	}
	
	return hasFrontCamera;
}

/* This one is static because we don't need a running instance of this class
 * for just detecting device idle states,
 * which cans run independently of the other class code
 */
import android.os.Build;
import android.hardware.Camera;
public static int jGetDeviceCamerasCount()
{
	int camerasCount = 0;
	
	// Android Android 2.3.2 or higher only (API level 9+)
	// We use APIs that require atleast this version
	//
	if ( Build.VERSION.SDK_INT < 9 )
	{
		return camerasCount;
	}
	
	try
	{
		camerasCount = Camera.getNumberOfCameras();
	}
	catch (Exception e)
	{
		/* Consider that there's no device Camera if this function fails
		 */
		camerasCount = 0;
	}
	
	return camerasCount;
}

/*
import android.os.Build;
import android.content.res.Configuration;
import android.content.Context;
import android.view.WindowManager;
import android.view.WindowMetrics;
import android.view.Display;
import android.content.res.Resources;
import android.view.Surface;
public int jGetDisplayOrientation(Context ctx)
{
	// Configuration - API level 1+:
	//  - ORIENTATION_UNDEFINED = 0 (0x00000000)
	//  - ORIENTATION_PORTRAIT  = 1 (0x00000001)
	//  - ORIENTATION_LANDSCAPE = 2 (0x00000002)
	//  - ORIENTATION_SQUARE    = 3 (0x00000003) /!\ deprecated since API level 16
	//
	// WindowManager - API level 1+:
	//  - Surface.ROTATION_0   = 0 (portrait)
	//  - Surface.ROTATION_90  = 1 (landscape)
	//  - Surface.ROTATION_180 = 2 (reverse portrait)
	//  - Surface.ROTATION_270 = 3 (reverse landscape)
	//
	
	// Default value is unknown
	// Better initially set a safe bet by saying that we don't know
	//
	int displayOrientation = Configuration.ORIENTATION_UNDEFINED;
	
	if ( ctx == null )
	{
		return displayOrientation;
	}
	
	try
	{
		if ( Build.VERSION.SDK_INT  >= 31) // Android 11+
		{
			//
			// Don't cache this information
			//
			Configuration cfg = new Configuration();
			int   orientation = cfg.orientation;
			
			switch ( orientation )
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					displayOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					displayOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				default:
					//
					// Ignore any other orientation values
					//
					break;
			}
		}
		else if ( Build.VERSION.SDK_INT >= 17 ) // Android 4.2+
		{
			WindowManager wm;
			
			if ( cachedSystemWindowService != null )
			{
				wm = cachedSystemWindowService;
			}
			else
			{
				wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
				cachedSystemWindowService = wm;
			}
			//
			// Don't cache this information
			//
			Display  display = wm.getDefaultDisplay();
			int  orientation = display.getOrientation();
			
			switch ( orientation )
			{
				case Surface.ROTATION_0:
					displayOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_90:
					displayOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Surface.ROTATION_180: // Reverse-portrait
					displayOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_270: // Reverse-landscape
					displayOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				default:
					//
					// Ignore any other orientation values
					//
					break;
			}
		}
		else // Android 4.1-
		{
			Resources sysRes;
			
			if ( cachedSystemResources != null )
			{
				sysRes = cachedSystemResources;
			}
			else
			{
				sysRes = Resources.getSystem();
				cachedSystemResources = sysRes;
			}
			//
			// Don't cache this information
			//
			int orientation = sysRes.getConfiguration().orientation;
			
			switch ( orientation )
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					displayOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					displayOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				default:
					//
					// Ignore any other orientation values
					//
					break;
			}
		}
	}
	catch (Exception e)
	{
		// If this function fails (very old device?) then just claim that
		// the display orientation is actually unknown (the safer option)
		//
		displayOrientation = Configuration.ORIENTATION_UNDEFINED;
	}
	
	return displayOrientation;
}
*/

import android.os.Build;
import android.content.res.Configuration;
import android.content.Context;
import android.view.WindowManager;
import android.view.WindowMetrics;
import android.util.DisplayMetrics;
import android.view.Display;
import android.content.res.Resources;
public float jGetDisplayScale(Context ctx)
{
	float displayScale = (float)0.75;
	
	if ( ctx == null )
	{
		return displayScale;
	}
	
	try
	{
		if ( Build.VERSION.SDK_INT >= 31 ) /* Android 11+ */
		{
			//
			// Don't cache this information
			//
			Configuration cfg = new Configuration();
			displayScale = (float)cfg.densityDpi; /* int -> float */
		}
		else if ( Build.VERSION.SDK_INT >= 17 ) /* Android 4.2+ */
		{
			
			WindowManager wm;
			
			if ( cachedSystemWindowService != null )
			{
				wm = cachedSystemWindowService;
			}
			else
			{
				wm = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
				cachedSystemWindowService = wm;
			}
			//
			// Don't cache this information
			//
			Display  display = wm.getDefaultDisplay();
			
			DisplayMetrics dm = new DisplayMetrics();
			display.getRealMetrics(dm);
			
			displayScale = dm.density; // Already float
		}
		else /* Android 4.1- */
		{
			Resources sysRes;
			
			if ( cachedSystemResources != null )
			{
				sysRes = cachedSystemResources;
			}
			else
			{
				sysRes = Resources.getSystem();
				cachedSystemResources = sysRes;
			}
			//
			// Don't cache this information
			//
			displayScale = sysRes.getDisplayMetrics().density; // Already float
		}
	}
	catch (Exception e)
	{
		/* If this function fails then it's probably a very old device with
		 * a very small display scale anyway
		 */
		displayScale = (float)0.75;
	}
	
	return displayScale;
}

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
		browserUrl = "https://" + browserUrl;
	}
	
	try
	{
		ctx.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(browserUrl)));
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
}
#End If


