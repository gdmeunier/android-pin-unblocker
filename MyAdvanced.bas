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
End Sub

Public Sub Initialize
	
End Sub

'
'For detecting screen off / screen locked / sleep mode ----------------
'
'On legacy devices such as those running Android 2.3,
'the app's Activity is not paused on screen lock,
'so it doesn't fire a resume event either
'
'On such old legacy devices, this function is considered
'as very important before it's their only way of breaking
'the Activity Lifecycle tracking and hiding the Admin key
'on device screen off then unlock
'
#If Java
/* In Android versions up to 2.3.7 (API level 10),
 * the Android Activity lifecycle was so strict that
 * Android frequently killed apps that were
 * in the background to save memory,
 * as the devices back two decandes ago (~2010) had
 * very low amounts of RAM (most of them had 512MB)
 * 
 * So up to Android 2.3.7 (API level 10) an app's
 * Activities were considered as killable to save
 * the device's RAM resources which were low at the time
 * 
 * As such, that means these legacy Android version also
 * actually *avoid* pausing applications when the screen
 * is turned off, because it might kill its process
 * 
 * These older Android versions even allowed only one
 * foreground Activity to stay active and just shortly killed
 * those that were put in the background after a short while,
 * without even calling pausing or stopping them first
 * 
 * It's only starting with Android 3.0 (API level 11)
 * that this Activity lifecycle system was revamped,
 * with Android no longer considering Activities as
 * killable but instead having a more graceful behavior
 * towards them, and started to pause Activities when
 * non-interactive events happen (e.g. screen off)
 * 
 * So long story short, when the screen is turned off
 * older legacy devices Android 2.3.7- will not pause
 * this application's Activities, so they also won't
 * resume them either; in these cases we have no other
 * way to handle pause & resume on screen off than
 * intercepting both screen-on & screen-off events,
 * and we simulate the newer Activity lifecycle of
 * Android 3.0+ (API level 11+) by ourselves calling
 * our Activity_Pause & Activity_Resume functions
 * 
 * I actually verified that this is actually what
 * really happens on my Android 2.3.6 device,
 * and I confirmed that it's indeed what happens:
 *  - The Activities don't pause & resume on
 *    device screen-off then screen-on events
 * 
 * So to better support these legacy devices
 * we register for both "Intent.ACTION_SCREEN_OFF"
 * and "Intent.ACTION_SCREEN_ON" events
 */

/*
 * - "Read the doc carefully!
 *    This answer actually tells you if the device is "interactive".
 *    If the screen is locked, the device is not interactive."
 */

/* This one is static because we don't need a running
 * instance of this class just for device idle detection,
 * which cans run independently of the other MyAdvanced code
 */
import android.content.IntentFilter;
import android.content.Intent;
public static IntentFilter jGetIdleDeviceIntentFilter()
{
	IntentFilter IdleDeviceIntentFilter = new IntentFilter();
	
	IdleDeviceIntentFilter.addAction(Intent.ACTION_SCREEN_OFF);
    IdleDeviceIntentFilter.addAction(Intent.ACTION_SCREEN_ON);
	
	return IdleDeviceIntentFilter;
}

/* Classes are not functions, so they should not
 * start with j[...] here unlike function names
 * 
 * This one is static because we don't need a running
 * instance of this class just for device idle detection,
 * which cans run independently of the other MyAdvanced code
 */
import android.content.BroadcastReceiver;
import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.objects.ActivityWrapper;
import android.content.Intent;
import android.os.Build;
public static class IdleDeviceReceiver extends BroadcastReceiver
{
	//
	// For storing the Activity handle of the caller's Activity
	//
	
	BA callerProcessBA;
	ActivityWrapper callerWrappedActivity;
	
	//
	// For calling this class with:
	//  - new myadvanced.IdleDeviceReceiver(BA processBA, ActivityWrapper _activity);
	//
	
	/* Constructor method */
	public IdleDeviceReceiver(BA processBA, ActivityWrapper _activity)
	{
		callerProcessBA        = processBA;
		callerWrappedActivity  = _activity;
		
		/* Always save the current instance because
		 * the getInstance function might be called
		 * later even if the caller shouldn't do it
		 * after using the new-constructor method.
		 */
		sInstance = this;
		
		//
		// Constructors cannot have a return value
		//
	}
	
	//
	// The IdleDeviceReceiver class code
	//
	
	@Override
	public void onReceive(Context ctx, Intent receivedIntent)
	{
		// Don't include "callerWrappedActivity"
		// "callerWrappedActivity" cans legitimately be null
		if ( receivedIntent == null || callerProcessBA == null )
		{
			return;
		}
		
		// Using the undocumented "className" public field
		// of the caller's "processBA" object
		//
		// Otherwise it would be e.g. "net.gdmeunier.pinublocker.main"
		// Here it will instead become e.g. "main", "scan" etc
		//
		// Also in Java you have to escape the "\" character
		// since it's literally in itself the escape operator
		// and we use a RegEx string that the literal "\"
		String callerClassName = callerProcessBA.className.replaceAll("^.+\\.([^\\.]+?)$", "$1");
		
		// Just so we know when the Activity receives
		// a device idle broadcast
		//
		// We say "Received System Broadcast" because otherwise
		// you would receive other non-system ones via your own
		// Receiver-type modules, and declare them in your app manifest
		//
		// Here this class receives System broadcasts, those that can
		// only be received by asking for them using Java code
		//
		// So we know that we're not going to receive non-System ones
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
			if ( Build.VERSION.SDK_INT <= 10 )
			{
				/* Android 2.3.7 or older */
				//
				// Simulate the Android 3.0+ Activity lifecycle ourselves
				// (Android 3.0+ is API level 11)
				//
				// We do it before Activity_Idle because that's how
				// newer Android versions also do it,
				// System broadcast receivers are send after the
				// Activity's own builtin lifecycle events
				//
				// If the app is already paused, no need to fire this event
				//
				// Remember also that this will not actually pause the Activity,
				// it will only run the Activity_Pause function
				//
				// Only Android itself cans pause Activities via ActivityManager
				//
				try
				{
					/* Fire the caller's Activity_Pause event handler
					 *                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
					callerProcessBA.raiseEvent2(callerWrappedActivity,  false,              "activity_pause",     false,                  new Object[]{false}); // UserClosed = False
				}
				catch (Exception e)
				{
					// Nothing to do here
				}
			}
			
			try
			{
				/* Fire the caller's Activity_Idle event handler
				 * 
				 * Sub signature:
				 *  - Sub Activity_Idle
				 *        'Do idle-related tasks here
				 *    End Sub
				 * 
				 *                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
				callerProcessBA.raiseEvent2(callerWrappedActivity,  true,               "activity_idle",      false,                  null);
			}
			catch (Exception e)
			{
				// Nothing to do here
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
			if ( Build.VERSION.SDK_INT <= 10 )
			{
				/* Android 2.3.7 or older */
				
				// Simulate the Android 3.0+ Activity lifecycle ourselves
				// (Android 3.0+ is API level 11)
				try
				{
					/* Fire the caller's Activity_Resume event handler
					 * 
					 * We don't actually need to fire this event always
					 * even if the application was paused,
					 * because we never actually truly paused the app
					 * 
					 * The app was never paused to begin with,
					 * we only manually prior our Activity_Pause function
					 * but the app's Activity was not paused at all
					 * 
					 * This is just a way for us to better hide the
					 * Admin key field when the screen is turned off
					 * then turned back on
					 * 
					 * And if you want to fire Activity_Resume for this,
					 * then you must first have a ViewState to restore
					 * so that's why we fired Activity_Pause prior
					 * 
					 * Because Activity_Pause saves the ViewState,
					 * then this Activity_Resume call cans restore it
					 * instead of restoring wrong prior ViewStates
					 * 
					 * TLDR: Activity_Resume will do a ViewState restore,
					 *       but if you don't refresh it then it will
					 *       restore an outdated wrong one
					 *       
					 *       So to satisfy the needs of Activity_Resume,
					 *       we produced a fresh ViewState by calling
					 *       Activity_Pause prior when the screen was off
					 * 
					 *                          Activity,               DontIgnoreIfPaused, EventName,            ThrowErrorIfMissingSub, ParametersObjectArray */
					callerProcessBA.raiseEvent2(callerWrappedActivity,  false,              "activity_resume",    false,                  null);
					//
					// This will actually fire when the screen is turned on,
					// even when it's just on the lockscreen without being
					// back to the app's Activity yet
					//
					// So the Activity_Resume will fire while the keyguard
					// is being shown, incase there's a lockscreen enabled
					// (even the unsecured 'swipe to unlock' one)
					//
					// However this is not a problem for us, because we fired
					// Activity_Pause first and deliberately prevented any
					// accidental 'positive' ViewState register restore such as
					// the Flashlight 'on' and Hide Admin Key 'unchecked' states
					//
					// That means that for example the Flashlight and Admin key field
					// will be restored on legacy Android 2.3.7- devices early-on
					// even while on the lockscreen, but they will be restored
					// to safe values always:
					//  - Flashlight state always restored to Off
					//  - Hide Admin Key state restored to Hidden
					//
					// This is what Activity_Idle event Subs did for us when
					// the screen was turned off:
					//  - Deliberately preventing any potential inconvenience
					//    (Flashlight state) or potential leak (Admin Key field)
					//
					// So yes it fires immediately when the screen is on,
					// but in our case it's even better for us, and remember that
					// this always happens on legacy devices only:
					//
					// Those that won't already fire Activity_Pause or Activite_Resume
					// lifecycle events on their own when the screen is turned on/off
					//
					// So we won't run into a problem such as firing
					// these events twice as the new devices that do
					// run these events themselves are excluded from
					// this fallback functionality (API level <= 10 checks)
					//
				}
				catch (Exception e)
				{
					// Nothing to do here
				}
			}
		}
	}
	
	//
	// For convenience purposes
	// For calling it with:
	//  - myadvanced.IdleDeviceReceiver.getInstance(BA processBA, ActivityWrapper _activity);
	//
	
	private static IdleDeviceReceiver sInstance;
	
	public static IdleDeviceReceiver getInstance(BA processBA, ActivityWrapper _activity)
	{
		if (sInstance == null)
		{
			sInstance = new IdleDeviceReceiver(processBA, _activity);
		}
		
		return sInstance;
	}
}
#End If

'
'Java-only functions for making the Activity --------------------------
'onCreate events easier to read
'

'
'Implement caching of various context-dependent objects
'
#If Java
/* ----- ----- Not used ----- ----- **
private Bitmap            cachedDrawableCensorThumbnail  = null;
** ----- ----- Not used ----- ----- */
private Bitmap            cachedDynamicCensorThumbnail   = null;

private Resources         cachedContextResources         = null;
private Resources         cachedSystemResources          = null;

private int               cachedThumbnailHeightResId     = -0xF; // alternative to null
private int               cachedThumbnailWidthResId      = -0xF; // alternative to null

private WindowManager     cachedSystemWindowService      = null;

private int               cachedShowNavigationBarResId   = -0xF; // alternative to null
private ViewConfiguration cachedContextViewConfiguration = null;

private Context           cachedApplicationContext       = null;
private PackageManager    cachedPackageManager           = null;
#End If

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
		if ( jDisableRecentAppsThumbnails(ctx) )
		{
			// Recent Apps thumbnail disabled
			// No problem here
			thumbnailDisabledSuccessfully = true;
		}
#End If
#If NO_FLAG_SECURE
#If Java
		else
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
			if ( firstTimeLaunch )
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
#End If
#End If
#If Java
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
#End If
#If Not(NO_FLAG_SECURE)
#If Java
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
	if ( !thumbnailDisabledSuccessfully ) // Only for FLAG_SECURE builds
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
#End If
#End If
#If Java
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
			
			Resources res;
			if ( cachedContextResources != null )
			{
				res = cachedContextResources;
			}
			else
			{
				res = ctx.getResources();
				cachedContextResources = res;
			}
			
			Resources systemRes;
			if ( cachedSystemResources != null )
			{
				systemRes = cachedSystemResources;
			}
			else
			{
				systemRes = res.getSystem();
				cachedSystemResources = systemRes;
			}
			
			//
			// com.android.internal.R.dimen.thumbnail_height
			//
			int heightResId;
			if ( cachedThumbnailHeightResId != -0xF )
			{
				heightResId = cachedThumbnailHeightResId;
			}
			else
			{
				heightResId = systemRes.getIdentifier("thumbnail_height", "dimen", "android");
				cachedThumbnailHeightResId = heightResId;
			}
			
			//
			// com.android.internal.R.dimen.thumbnail_width
			//
			int widthResId;
			if ( cachedThumbnailWidthResId != -0xF )
			{
				widthResId = cachedThumbnailWidthResId;
			}
			else
			{
				widthResId = systemRes.getIdentifier("thumbnail_width", "dimen", "android");
				cachedThumbnailWidthResId = widthResId;
			}
			
			if ( heightResId > 0 && widthResId > 0 )
			{
				//
				// Don't cache this information
				//
				h = res.getDimensionPixelSize(heightResId);
				w = res.getDimensionPixelSize(widthResId);
			}
			
			//
			// Android actually uses RGB_565 for thumbnail previews
			//
			censorThumbnail = Bitmap.createBitmap(w, h, Bitmap.Config.RGB_565);
			//
			// Default color for censoring the preview thumbnail
			//
			int censorColor = Color.BLACK; // Or Color.DKGRAY
			//
			// Get Activity's windowBackground color
			//
			try
			{
				//
				// Use Reflection to get it 5x faster
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
						/* Android 5.1.1- */
						//
						// Deprecated on API level 23+ (Android 6+)
						//
						censorColor = res.getColor(colorResId);
					}
					else
					{
						/* Android 6+ */
						//
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
			Resources res;
			if ( cachedContextResources != null )
			{
				res = cachedContextResources;
			}
			else
			{
				res = ctx.getResources();
				cachedContextResources = res;
			}
			
			censorThumbnail = BitmapFactory.decodeResource(res, R.drawable.myCensorThumbnail);
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
			//
			// Don't cache this information
			//
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
			//
			// Don't cache this information
			//
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
		browserUrl = "https://" + browserUrl;
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
			//
			// Don't cache this information
			//
			Configuration cfg = new Configuration();
			devScale = (float)cfg.densityDpi; // int -> float
		}
		/* Android 4.2+ */
		else if ( Build.VERSION.SDK_INT >= 17 )
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
			
			devScale = dm.density; // Already float
		}
		/* Android 4.1- */
		else
		{
			Resources systemRes;
			if ( cachedSystemResources != null )
			{
				systemRes = cachedSystemResources;
			}
			else
			{
				systemRes = Resources.getSystem();
				cachedSystemResources = systemRes;
			}
			//
			// Don't cache this information
			//
			devScale = systemRes.getDisplayMetrics().density; // Already float
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
	int devOrientation = Configuration.ORIENTATION_UNDEFINED;
	
	if ( ctx == null )
	{
		return devOrientation;
	}
	
	try
	{
		/* Android 11+ */
		if ( Build.VERSION.SDK_INT >= 31 )
		{
			//
			// Don't cache this information
			//
			Configuration cfg = new Configuration();
			int   orientation = cfg.orientation;
			
			switch(orientation)
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					devOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					devOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				default:
					// Ignore any other orientation values
					//
					// If any other value then just say that
					// the device orientation is undefined
					break;
			}
		}
		/* Android 4.2+ */
		else if ( Build.VERSION.SDK_INT >= 17 )
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
			
			switch (orientation)
			{
				case Surface.ROTATION_0:
					devOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_90:
					devOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Surface.ROTATION_180: // Reverse-portrait
					devOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				case Surface.ROTATION_270: // Reverse-landscape
					devOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				default:
					// Ignore any other orientation values
					//
					// If any other value then just say that
					// the device orientation is undefined
					break;
			}
		}
		/* Android 4.1- */
		else
		{
			Resources systemRes;
			if ( cachedSystemResources != null )
			{
				systemRes = cachedSystemResources;
			}
			else
			{
				systemRes = Resources.getSystem();
				cachedSystemResources = systemRes;
			}
			//
			// Don't cache this information
			//
			int orientation = systemRes.getConfiguration().orientation;
			
			switch(orientation)
			{
				case Configuration.ORIENTATION_LANDSCAPE:
					devOrientation = Configuration.ORIENTATION_LANDSCAPE;
					break;
					
				case Configuration.ORIENTATION_PORTRAIT:
					devOrientation = Configuration.ORIENTATION_PORTRAIT;
					break;
					
				default:
					// Ignore any other orientation values
					//
					// If any other value then just say that
					// the device orientation is undefined
					break;
			}
		}
	}
	catch (Exception e)
	{
		// If this function fails (very old device?)
		// then just claim that the device orientation
		// is actually unknown (the safer option)
		devOrientation = Configuration.ORIENTATION_UNDEFINED;
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
			Resources res;
			if ( cachedContextResources != null )
			{
				res = cachedContextResources;
			}
			else
			{
				res = ctx.getResources();
				cachedContextResources = res;
			}
			
			int resId;
			if ( cachedShowNavigationBarResId != -0xF )
			{
				resId = cachedShowNavigationBarResId;
			}
			else
			{
				resId = res.getIdentifier("config_showNavigationBar", "bool", "android");
				cachedShowNavigationBarResId = resId;
			}
			//
			// Don't cache this information
			//
			if ( resId > 0 )
			{
				hasNavBar = res.getBoolean(resId);
			}
			else
			{
				// Check for keys
				ViewConfiguration viewCfg;
				if ( cachedContextViewConfiguration != null )
				{
					viewCfg = cachedContextViewConfiguration;
				}
				else
				{
					viewCfg = ViewConfiguration.get(ctx);
					cachedContextViewConfiguration = viewCfg;
				}
				//
				// Don't cache this information
				//
				boolean hasMenuKey = viewCfg.hasPermanentMenuKey();
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
			if ( cachedPackageManager != null )
			{
				pkgMgr = cachedPackageManager;
			}
			else
			{
				Context appCtx;
				if ( cachedApplicationContext != null )
				{
					appCtx = cachedApplicationContext;
				}
				else
				{
					appCtx = ctx.getApplicationContext();
					cachedApplicationContext = appCtx;
				}
				
				pkgMgr = appCtx.getPackageManager();
				cachedPackageManager = pkgMgr;
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


