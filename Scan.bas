B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=12.5
@EndOfDesignText@

#Region  Activity Attributes 
	#FullScreen:   False
	#IncludeTitle: True
	
#End Region

#Region Module File Attributes
	'Ignore "This sub should only be used for variables declaration or assignments of primitive values" warning (#29)
	#IgnoreWarnings: 29
	
#End Region

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Java native code
'

#If Java

private String activityName = "scan";

private myadvanced myadvancedInstance = new myadvanced();

private BroadcastReceiver DeviceIdleDetectionReceiver;

//
// This part is used by joActivity.RunMethod calls
//
import android.content.Context;
import android.app.Activity;
public boolean jDeviceHasFlashlight()
{
	return myadvancedInstance.jDeviceHasFlashlight(this);
}

import android.content.Context;
import android.app.Activity;
public boolean jDeviceHasFrontCamera()
{
	return myadvancedInstance.jDeviceHasFrontCamera(this);
}
#End If

#If Java
/* Censor the Recent Apps thumbnails on supported Android versions (the legacy ones)
 *
 * Works for devices up to Android 4.0.2 (API level 14), newer ones will just
 * ignore this Activity callback
 */
import java.lang.SuppressWarnings;
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
@SuppressWarnings({"deprecation", "removal"})
@Override
public boolean onCreateThumbnail(Bitmap outBitmap, Canvas canvas)
{
	// Just so we know when the Activity is asked to generate a thumbnail
	BA.LogInfo("** Activity ("+activityName+") Create Thumbnail **");
	
	return myadvancedInstance.jCensorActivityThumbnail(this, outBitmap, canvas);
}
#End If

'
'This part is a custom Basic4Android hack to prevent it from
'ruthlessly reposting obsolete Activity events that
'we don't care about anymore
'

#If Java
/* Note: Yes; blocking Activity events firing temporarily is compatible with
 *       the device idle detection receiver's event firing too
 *
 *       Because it fires on screen off or inactivity, not when the Activity starts again
 *       The blocking happens on Activity start, and is lifted on Activity resume
 *
 *       For the device idle detection receiver's manual firing of the Activity events
 *       Activity_Pause and Activity_Resume, it's also compatible with it because
 *       on legacy devices (the only ones where it does this), Activities are actually
 *       never paused, stopped, started nor resumed at all on screen of or inactivity:
 *        - So the blocking will not happen as _onStart is then never called when
 *          the screen turns back on
 *
 *       Also, if on legacy devices the Activity is put in the background manually,
 *       then the device idle detection receiver doesn't actually fire anything:
 *        - It only fires Activity pause & resume events manually on screen off & screen on
 *
 *       And when it does fire these Activity events, remember that it cannot actually
 *       pause any Activity for real; it just manually runs the event functions,
 *       but the Activities were never paused nor resumed:
 *        - Only Android itself (system / Android Framework) cans do it,
 *          with its protected ActivityManager module
 *
 * TLDR: Nothing to worry about regarding compatibility with the
 *       device idle detection receiver, it's actually
 *       perfectly compatible with it
 */

/* This function cans only be called by _onStart
 * Other ones are not run early enough to block those in due time
 */
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import java.util.ArrayList;
public void jClearPausedMessagesQueue()
{
	BA.LogInfo("["+activityName+"] jClearPausedMessagesQueue: Function entry");
	
	/* Check if the processBA and sharedProcessBA objects are different from null
	 *
	 * [!] This part will only compile with the modified B4AShared.jar file,
	 *     which makes the messagesDuringPaused field public
	 *
	 *     Otherwise it was not public and could not be modified from outside
	 *     its own class instance
	 */
	if ( this.processBA != null && this.processBA.sharedProcessBA != null )
	{
		// Clear the paused messages queue by replacing it with an empty list
		this.processBA.sharedProcessBA.messagesDuringPaused = new ArrayList<Runnable>();
		
		// Notify in the logging about it always
		BA.LogInfo("["+activityName+"] jClearPausedMessagesQueue: Cleared the paused messages queue");
	}
	
	BA.LogInfo("["+activityName+"] jClearPausedMessagesQueue: Function return");
}

private boolean originalIgnoreEventsFromOtherThreadsDuringMsgboxError = false;

/* Prevent Basic4Android from reposting obsolete events such as
 * the FocusChanged ones, since this is otherwise just annoying for
 * the control flow of this application
 * 
 * It sets a flag that makes Basic4Android not repost its events on
 * Activity destruction then re-creation
 * 
 * This function cans only be called by _onStart
 * Other ones are not run early enough to block it in due time
 */
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
public void jBlockEventPostingAbility()
{
	BA.LogInfo("["+activityName+"] jBlockEventPostingAbility: Function entry");
	
	/* Check if the processBA and sharedProcessBA objects are different from null
	 *
	 * [!] This part will only compile with the modified B4AShared.jar file, which
	 *     makes the ignoreEventsFromOtherThreadsDuringMsgboxError field public
	 *
	 *     Otherwise it was not public and could not be modified from outside
	 *     its own class instance
	 */
	if ( this.processBA != null && this.processBA.sharedProcessBA != null )
	{
		// Backup so that _onResume cans restore the original value later
		this.originalIgnoreEventsFromOtherThreadsDuringMsgboxError = this.processBA.sharedProcessBA.ignoreEventsFromOtherThreadsDuringMsgboxError;
		
		// Notify in the logging about it always
		BA.LogInfo("["+activityName+"] jBlockEventPostingAbility: Made a backup of this Activity's processBA->sharedProcessBA->ignoreEventsFromOtherThreadsDuringMsgboxError value");
		
		// Set the flag to true to block the repost of UI events
		this.processBA.sharedProcessBA.ignoreEventsFromOtherThreadsDuringMsgboxError = true;
		
		// Notify in the logging about it always
		BA.LogInfo("["+activityName+"] jBlockEventPostingAbility: Set the ignoring of events from other threads (during MsgBox errors) to true");
		BA.LogInfo("["+activityName+"] jBlockEventPostingAbility: This is required to strictly prevent the reposting of obsolete FocusChanged messages on Activity resume");
	}
	
	BA.LogInfo("["+activityName+"] jBlockEventPostingAbility: Function return");
}

import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
public void jRestoreEventPostingAbility()
{
	BA.LogInfo("["+activityName+"] jRestoreEventPostingAbility: Function entry");
	
	/* Check if the processBA and sharedProcessBA objects are different from null
	 *
	 * [!] This part will only compile with the modified B4AShared.jar file, which
	 *     makes the ignoreEventsFromOtherThreadsDuringMsgboxError field public
	 *
	 *     Otherwise it was not public and could not be modified from outside
	 *     its own class instance
	 */
	if ( this.processBA != null && this.processBA.sharedProcessBA != null )
	{
		// Restore the original value of IgnoreEventsFromOtherThreadsDuringMsgboxError
		this.processBA.sharedProcessBA.ignoreEventsFromOtherThreadsDuringMsgboxError = this.originalIgnoreEventsFromOtherThreadsDuringMsgboxError;
		
		// Notify in the logging about it always
		BA.LogInfo("["+activityName+"] jRestoreEventPostingAbility: Restored the original 'ignoring of events from other threads (during MsgBox errors)' value back to original");
	}
	
	BA.LogInfo("["+activityName+"] jRestoreEventPostingAbility: Function return");
}

/* Restore the ability to receive Activity events after having prevented
 * the reposting of obsolete Activity events during the running of our
 * Java native jBlockEventPostingAbility function (it happened in _onStart)
 */
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
public void _onPostResume()
{
	BA.LogInfo("** Activity ("+activityName+") Post Resume **");
	BA.LogInfo("["+activityName+"] _onPostResume: Function entry");
	
	BA.LogInfo("["+activityName+"] _onPostResume: We previously blocked the ability to fire Activity events by Basic4Android's core, as it was annoying with us");
	BA.LogInfo("["+activityName+"] _onPostResume: (It was trying to repost obsolete Activity events that we don't care about...)");
	BA.LogInfo("["+activityName+"] _onPostResume: However because at this stage these annoying & obsolete event reports have been blocked, we now re-enable Activity event firing for Basic4Android's core (its raiseEvent capability)");
	jRestoreEventPostingAbility();
	
	BA.LogInfo("["+activityName+"] _onPostResume: Function return");
}
#End If

'
'Custom Activity events
'

#If Java
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.objects.ActivityWrapper;
public void _onStop()
{
	// Just so we know when the Activity stops
	BA.LogInfo("** Activity ("+activityName+") Stop **");
	BA.LogInfo("["+activityName+"] _onStop: Function entry");
	
	try
	{
		// Custom Activity_Stop event
		BA.LogInfo("["+activityName+"] _onStop: Calling the custom Activity_Stop event Sub");
		
		/*                    Activity,       DontIgnoreIfPaused, EventName,       ThrowErrorIfMissingSub, ParametersObjectArray */
		processBA.raiseEvent2(this._activity, true,               "activity_stop", false,                  null);
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	BA.LogInfo("["+activityName+"] _onStop: Function return");
}

import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import android.os.Build;
import anywheresoftware.b4a.objects.ActivityWrapper;
import android.content.BroadcastReceiver;
public void _onDestroy()
{
	// Just so we know when the Activity destroys
	BA.LogInfo("** Activity ("+activityName+") Destroy **");
	BA.LogInfo("["+activityName+"] _onDestroy: Function entry");
	
	// Unregister device idle detection receiver on destroy
	try
	{
		BA.LogInfo("["+activityName+"] _onDestroy: Unregistering the DeviceIdleDetectionReceiver");
		this.unregisterReceiver(DeviceIdleDetectionReceiver);
	}
	catch (Exception e)
	{
		/* It's possible that the following happens:
		 *  - The user shares an Admin key text to the application while it's running
		 *  - The Android system kills the previous Main Activity instance
		 *
		 *  - Now the killing of the previous Activity instance already cleared
		 *    the prior DeviceIdleDetectionReceiver registration
		 *
		 *  - But because the next onDestroy call that follows will be part of
		 *    the previous instance being destroyed, and because the
		 *    DeviceIdleDetectionReceiver field got refreshed with a new one,
		 *    that this function from the previous instance does not have access to,
		 *    it's perfectly possible for _onDestroy to try unregistering
		 *    a BroadcastReceiver that already got unregistered
		 *
		 * In such cases, an exception will be thrown and if not handled,
		 * this will crash the application even if it's not an important one
		 *
		 * So we always try unregistering the BroadcastReceiver in _onDestroy,
		 * because most of the time this is fine and it's the proper way to do it,
		 * but if this call fails, we don't actually care about it:
		 *  - The application should just ignore the exception and move on
		 */
	}
	
	boolean isFinishing              = isFinishing();
	boolean isChangingConfigurations = false;
	
	// isChangingConfigurations() is only available on API levels 11+ (Android 3.0+)
	if ( Build.VERSION.SDK_INT >= 11 )
	{
		isChangingConfigurations = isChangingConfigurations();
	}
	
	try
	{
		// Custom Activity_Destroy event
		BA.LogInfo("["+activityName+"] _onDestroy: Calling the custom Activity_Destroy event Sub");
		
		/*                    Activity,       DontIgnoreIfPaused, EventName,          ThrowErrorIfMissingSub, ParametersObjectArray */
		processBA.raiseEvent2(this._activity, true,               "activity_destroy", false,                  new Object[]{ isFinishing, isChangingConfigurations });
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	BA.LogInfo("["+activityName+"] _onDestroy: Function return");
}

import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.objects.ActivityWrapper;
public void _onRestart()
{
	// Just so we know when the Activity restarts
	BA.LogInfo("** Activity ("+activityName+") Restart **");
	BA.LogInfo("["+activityName+"] _onRestart: Function entry");
	
	try
	{
		// Custom Activity_Restart event
		BA.LogInfo("["+activityName+"] _onRestart: Calling the custom Activity_Restart event Sub");
		
		/*                    Activity,       DontIgnoreIfPaused, EventName,          ThrowErrorIfMissingSub, ParametersObjectArray */
		processBA.raiseEvent2(this._activity, true,               "activity_restart", false,                  null);
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	BA.LogInfo("["+activityName+"] _onRestart: Function return");
}

import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.objects.ActivityWrapper;
public void _onStart()
{
	// Just so we know when the Activity starts
	BA.LogInfo("** Activity ("+activityName+") Start **");
	BA.LogInfo("["+activityName+"] _onStart: Function entry");
	
	// Clear paused messages queue because there were some
	// mundane pending sleep calls inside it
	//
	BA.LogInfo("["+activityName+"] _onStart: Clearing paused messages queue (there were some mundane sleep calls inside it)");
	jClearPausedMessagesQueue();
	
	BA.LogInfo("["+activityName+"] _onStart: We will be blocking Basic4Android's ability to fire Activity events temporarily, because it wants to repost mundane events between Activities' onStart & onCreate");
	BA.LogInfo("["+activityName+"] _onStart: But we have to fire the Activity_Start event before blocking the ability to fire Activity events");
	BA.LogInfo("["+activityName+"] _onStart: That's why jBlockEventPostingAbility runs after the Activity_Start event Sub");
	try
	{
		// Custom Activity_Start event
		BA.LogInfo("["+activityName+"] _onStart: Calling the custom Activity_Start event Sub");
		
		/*                    Activity,       DontIgnoreIfPaused, EventName,        ThrowErrorIfMissingSub, ParametersObjectArray */
		processBA.raiseEvent2(this._activity, true,               "activity_start", false,                  null);
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	/* Block the ability to post Activity events to prevent the reposting of
	 * obsolete Activity events before the _onCreate function is run,
	 * because _onCreate would already be too late to block it
	 *
	 * That's why it must be done in _onStart instead
	 *
	 * Also because this blocks the posting of events to begin with,
	 * we had to do it after firing the custom Activity_Start event
	 */
	BA.LogInfo("["+activityName+"] _onStart: We now temporarily block Basic4Android from firing Activity events temporarily as said prior...");
	jBlockEventPostingAbility();
	
	BA.LogInfo("["+activityName+"] _onStart: Function return");
}
#End If

'
'Add missing Activity callbacks to Basic4Android
'

#If Java
import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.BA;
@Override
public void onRestart()
{
	// Call Android's super implementation (mandatory)
	super.onRestart();
	
	try
	{
		// Mimick Basic4Android's builtin runHook ability
		processBA.runHook("onrestart", this, null);
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
}

import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.BA;
@Override
public void onPostResume()
{
	// Call Android's super implementation (mandatory)
	super.onPostResume();
	
	try
	{
		// Mimick Basic4Android's builtin runHook ability
		processBA.runHook("onpostresume", this, null);
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
}
#End If

'
'Configuration changed callback (ignored)
'

#If Java
import android.content.res.Configuration;
import android.content.Context;
import android.app.Activity;
import anywheresoftware.b4a.BA;
@Override
public void onConfigurationChanged(Configuration newConfig)
{
	// Call Android's super implementation (mandatory)
	super.onConfigurationChanged(newConfig);
	
	// Just so we know when the Activity receives a mundane configuration change event
	BA.LogInfo("** Activity ("+activityName+") Configuration Changed **");
	
	/* We deliberately ignore mundane configuration change events
	 * (as set in the application manifest)
	 *
	 * This makes sure that only device rotations will destroy then
	 * re-create our application's Activities
	 */
	
	BA.LogInfo("onConfigurationChanged: Ignoring the configuration change event");
	
	/* Nothing to do here */
}
#End If

'
'Commonly used type of inline _onCreate Java code
'
#If Java
import anywheresoftware.b4a.BA;
import android.content.Context;
import android.app.Activity;
import android.content.Intent;
import android.content.BroadcastReceiver;
import anywheresoftware.b4a.objects.ActivityWrapper;
import android.content.IntentFilter;
public void _onCreate()
{
	BA.LogInfo("["+activityName+"] _onCreate: Function entry");
	
	// Disable the Activity TitleBar & ActionBar if needed
	BA.LogInfo("["+activityName+"] _onCreate: Checking device display scale...");
	if ( myadvancedInstance.jGetDisplayScale(this) < 1.0 )
	{
		BA.LogInfo("["+activityName+"] _onCreate: Display scale is too small, freeing up some visual space");
		
		BA.LogInfo("["+activityName+"] _onCreate: Disabling the Activity's TitleBar");
		myadvancedInstance.jDisableActivityTitleBar(this);
		
		BA.LogInfo("["+activityName+"] _onCreate: Disabling the Activity's ActionBar (if Android 3.0+)");
		myadvancedInstance.jDisableActivityActionBar(this);
	}
	else
	{
		BA.LogInfo("["+activityName+"] _onCreate: Display scale is OK, no Activity tweaks are necessary");
	}
	
	// Disable the Android 8.0+ Autofill service for security reasons
	myadvancedInstance.jDisableAndroidAutofillService(this);
	
	// Make this application Activity secure
	BA.LogInfo("["+activityName+"] _onCreate: Securing this application Activity");
	myadvancedInstance.jSecureActivityOnCreate(this, isFirst);
	
	/* Below is for detecting device idle state, when the display is no longer 'interactive'
	 *  - Display off, screen locked, screensaver, inactivity [...]
	 *
	 * The "_activity" field (of type ActivityWrapper) is not a public field,
	 * so we have to explicitly give an handle to it for our DeviceIdleReceiver
	 *
	 * "DeviceIdleReceiver" is also a class so you must access the
	 * "myadvanced" package (class) directly to get it,
	 * not by accessing the current "myadvancedInstance" of it
	 *
	 * Notice the difference between "myadvanced" & "myadvancedInstance"
	 *  - "myadvanced"         = The class / package itself
	 *  - "myadvancedInstance" = The instance of it that we initialized in this Activity
	 */
	BA.LogInfo("["+activityName+"] _onCreate: Registering the DeviceIdleReceiver");
	this.DeviceIdleDetectionReceiver = new myadvanced.DeviceIdleReceiver(this.processBA, this._activity);
	this.registerReceiver(DeviceIdleDetectionReceiver, myadvancedInstance.jGetDeviceIdleIntentFilter());
	
	BA.LogInfo("["+activityName+"] _onCreate: Function return");
}
#End If

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Basic application code
'

Sub Process_Globals
	'These global variables will be declared once when the application starts
	'These variables can be accessed from all modules
	
	'This Activity's name (class name)
	Dim ActivityName As String = Regex.Replace2("^class .+\.([^\.]+?)$", Regex.CASE_INSENSITIVE, Me.As(String), "$1")
	
	'
	'ViewState variables
	'
	
	Private ViewState_qrvQRCodeReaderView_PreviewCameraId As Int
	Private ViewState_qrvQRCodeReaderView_TorchEnabled    As Boolean
	
	Private ViewState_LastScrollPosition As Int
	
	'The Toggle Flashlight button will always by dynamically set
	'to the correct .Text content on Activity pause & resume,
	'including on Camera preview side switching
	
	'
	'General-use process globals
	'
	
	'Convenience constants stored inside this class
	Private Constants As MyConstants
	
	'Better method of managing the App's security
	Private Security As MySecurity
	
	'For getting Phone library functions without bundling the big Phone library
	Private Common As MyCommon
	
	'For advanced Java functions that require context
	Private joActivity As JavaObject
	
	'For foreground device rotation detection & misc
	Private LifecycleTracking As MyLifecycleTracking
	
	'Just so that we don't write many Dim statements
	'to declare this variable multiple times in the
	'LoadActivityLayout function code (for shorter code)
	Private LoadedLayout As LayoutValues
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created
	'These variables can only be accessed from this module
	
	'Just so that we don't write many Dim statements to declare
	'this variable multiple times in the LoadActivityLayout Sub etc
	Private LoadedLayout As LayoutValues
	
	'For being able to scroll vertically
	Private scvActivity As ScrollView
	
	'The below declarations are needed for fixing the Camera preview
	'to be neatly square
	Private lblScanChallenge  As Label
	Private lblQRCodeReaderBg As Label  'It's a label used as a background
	
	Private btnToggleFlash  As Button
	Private btnSwitchCamera As Button
	Private btnBack         As Button
	
	'In a try-catch block because we want to avoid any potential
	'Camera service connection error that could cause
	'a disgraceful application crash
	Try
		Private qrvQRCodeReaderView As NewQRCodeReaderView
	Catch
		HandleCameraServiceException
	End Try
	
End Sub

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Activity events
'

'For detecting screen off / screen locked / sleep mode
'
'On legacy devices such as those running Android 2.3, the application's Activities
'are not paused on e.g. screen lock, so it doesn't fire a resume event either
'
'On such old legacy devices, this function is considered as very important because
'it's their only way of breaking the Activity lifecycle tracking
'and e.g. hiding the Admin key on device screen off then unlock / screen on
Sub Activity_Idle
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: Sub entry"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: This event was fired, so the device is idle (non-interactive UI state)"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: Setting the Flashlight ViewState status to Off and resetting the Activity lifecycle tracking"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: This will make it even quicker to turn the Flashlight off during application resume"$, Colors.Black)
	ViewState_qrvQRCodeReaderView_TorchEnabled = False
	LifecycleTracking.ActivityLifecycle = ""
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: Sub return"$, Colors.Black)
End Sub

Sub Activity_Stop()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Sub entry"$, Colors.Black)
	
	'Non-standard hack-ish Activity event Subs like this one
	'cannot even use Process_Globals in some cases, and they
	'most of the time cannot access the Activity's local Globals
	'
	'In such non-standard event Subs like this one,
	'always verify everything you fetch from the
	'Process_Globals & Activity Globals to make sure
	'that they are not Null, because they can very well be
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Checking if this Activity's Lifecycle tracking is initialized..."$, Colors.Black)
	If LifecycleTracking == Null Or Not(LifecycleTracking.IsInitialized) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: This Activity's Lifecycle tracking is NOT initialized"$, Colors.Black)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: No need to proceed further"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Sub return"$, Colors.Black)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: This Activity's Lifecycle tracking is initialized, alright"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Now we can proceed further"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Black)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.STOP
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Stop: Sub return"$, Colors.Black)
End Sub

Sub Activity_Destroy(IsFinishing As Boolean, IsChangingConfigurations As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Sub entry (IsFinishing = ${IsFinishing}, IsChangingConfigurations = ${IsChangingConfigurations})"$, Colors.Black)
	
	If IsFinishing Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Because the Activity is finishing, reset the scroll position to 0dip"$, Colors.Black)
		
		'Reset the ViewState last scroll position on Activity_Destroy,
		'because we cannot do it in Activity_Pause as otherwise
		'it doesn't know how to differenciate whether the pause event
		'is due to a screen rotation or whether it's just a normal one
		'from background app pause & resume
		'
		'Activity_Pause also doesn't know how to identify
		'the Activities' *foreground* app & resumes,
		'as they behave exactly like a normal app pause
		'if it tries to check its UserClosed parameter
		'
		'So this cans only be done in Activity_Destroy,
		'where we 100% confirm that the Activity is being
		'actually destroyed then re-created
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Resetting the ViewState's last scroll position"$, Colors.Black)
		ViewState_LastScrollPosition = 0dip
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Checking if this Activity's Lifecycle tracking is initialized..."$, Colors.Black)
	If LifecycleTracking == Null Or Not(LifecycleTracking.IsInitialized) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: This Activity's Lifecycle tracking is NOT initialized"$, Colors.Black)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: No need to proceed further"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Sub return"$, Colors.Black)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: This Activity's Lifecycle tracking is initialized, alright"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Now we can proceed further"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Checking if the Activity is finishing for real..."$, Colors.Black)
	If IsFinishing And Not(IsChangingConfigurations) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: The Activity is finishing for real, no need to update this Activity's Lifecycle tracking"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Resetting this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Black)
		LifecycleTracking.ActivityLifecycle = ""
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Sub return"$, Colors.Black)
		Return
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: The Activity is not finishing for real, alright"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Black)
		LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.DESTROY
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Black)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Destroy: Sub return"$, Colors.Black)
End Sub

Sub Activity_Restart()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Sub entry"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Checking if this Activity's Lifecycle tracking is initialized..."$, Colors.Black)
	If LifecycleTracking == Null Or Not(LifecycleTracking.IsInitialized) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: This Activity's Lifecycle tracking is NOT initialized"$, Colors.Black)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: No need to proceed further"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Sub return"$, Colors.Black)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: This Activity's Lifecycle tracking is initialized, alright"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Now we can proceed further"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Black)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.RESTART
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Restart: Sub return"$, Colors.Black)
End Sub

Sub Activity_Start()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Sub entry"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Checking if this Activity's Lifecycle tracking is initialized..."$, Colors.Black)
	If LifecycleTracking == Null Or Not(LifecycleTracking.IsInitialized) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: This Activity's Lifecycle tracking is NOT initialized"$, Colors.Black)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: No need to proceed further"$, Colors.Black)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Sub return"$, Colors.Black)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: This Activity's Lifecycle tracking is initialized, alright"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Now we can proceed further"$, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Black)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.START
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Black)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Start: Sub return"$, Colors.Black)
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Sub entry (FirstTime = ${FirstTime})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initializing this Activity's Lifecycle tracking if FirstTime..."$, Colors.Blue)
	If FirstTime Then
		LifecycleTracking.Initialize
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.CREATE
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	'Disabling the Activity TitleBar & ActionBar
	'must be done before adding content to the
	'Activity, so before loading the layout file
	'
	'So the only way to do that properly is to
	'use Java native code & the _onCreate hook
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Load Activity layout"$, Colors.Blue)
	LoadActivityLayout
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Check if it's the FirstTime Activity launch"$, Colors.Blue)
	If FirstTime Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: It's the FirstTime Activity launch"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Get an initial ViewState with default UI element values by resetting the ViewState"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: The layout files don't always contain default UI element values"$, Colors.Blue)
		ResetViewState
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Constants Class (MyConstants class)"$, Colors.Blue)
		Constants.Initialize
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Security Class (MySecurity class)"$, Colors.Blue)
		Security.Initialize
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Common Class (MyCommon class)"$, Colors.Blue)
		Common.Initialize
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: It's not the FirstTime Activity launch"$, Colors.Blue)
		
	End If
	
	'The Activity context must always be fresh,
	'so always re-initialize the joActivity JavaObject
	'on every Activity create (not just on FirstTime)
	'
	'This is mandatory for context-dependent functions
	'that receive the Activity context, because they
	'must always have a fresh Activity context handle!
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the joActivity JavaObject always (not just on FirstTime launch)"$, Colors.Blue)
	joActivity.InitializeContext
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Calling InitializeActivityLayout to initialize the loaded layout..."$, Colors.Blue)
	InitializeActivityLayout
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Sub return"$, Colors.Blue)
End Sub

Private Sub LoadActivityLayout
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Sub entry"$, Colors.Blue)
	
	'Note: you cannot use any of this Activity's
	'helper classes here
	'
	'Its classes have not been initialized yet
	'when this function is called by Activity_Create
	'
	'However you can create your own temporary ones
	
	'Load the base layout (contains a ScrollView)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Loading the base Activity layout which contains a ScrollView only..."$, Colors.Blue)
	Activity.LoadLayout("Base")
	
	'Initialize the ScrollView
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Initializing the Activity's ScrollView"$, Colors.Blue)
	scvActivity.Initialize(Activity.Height) 'Default initial height for its Panel
	scvActivity.Height = Activity.Height    'Must set an explit height on the ScrollView
	scvActivity.Width  = Activity.Width     'Must set an explit width on the ScrollView
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: scvActivity height = ${scvActivity.Height} & width = ${scvActivity.Width}"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Activity height = ${Activity.Height} & width = ${Activity.Width}"$, Colors.Blue)
	
	'Initialize the ScrollView panel
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Initializing the Activity ScrollView's inner panel"$, Colors.Blue)
	scvActivity.Panel.Initialize("scvActivityPanel")
	scvActivity.Panel.Height = scvActivity.Height 'Must set an height before loading layouts
	scvActivity.Panel.Width  = scvActivity.Width  'Must set a width before loading layouts
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: scvActivity Panel height = ${scvActivity.Panel.Height} & width = ${scvActivity.Panel.Width}"$, Colors.Blue)
	
	'Load the Activity layout into the ScrollView's panel
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Loading the Main Activity layout into **the ScrollView's inner panel**"$, Colors.Blue)
	LoadedLayout = scvActivity.Panel.LoadLayout("Scan")
	
	'Check which layout was loaded (which layout variant)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: The loaded layout variant is ${LoadedLayout.Width}x${LoadedLayout.Height}, scale = ${LoadedLayout.Scale}"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Applying variant-specific layout fixes and tweaks to this Activity layout..."$, Colors.Blue)
	
	Dim LeftMargin, TopMargin, RightMargin, BottomMargin As Int
	Dim ActivityMargins() As Int
	
	If LoadedLayout.Width == 320 And LoadedLayout.Height == 480 And LoadedLayout.Scale == 1 Then
		'320x480, scale = 1 (160dpi)
		
		'Each layout variant declares its own Activity margins
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 32dip * LoadedLayout.Scale
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnToggleFlash"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnToggleFlash)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Fixing the Camera preview to be neatly square..."$, Colors.Blue)
		Dim ProperCameraPreviewHeight As Int
		ProperCameraPreviewHeight = btnToggleFlash.Top - lblScanChallenge.Top - lblScanChallenge.Height
		
		lblQRCodeReaderBg.Height   = ProperCameraPreviewHeight
		qrvQRCodeReaderView.Height = ProperCameraPreviewHeight
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Now adjusting this Activity layout's btnToggleFlash, btnSwitchCamera & btnBack UI elements for the square Camera preview accordingly..."$, Colors.Blue)
		For Each MyButton As View In Array As View(btnToggleFlash, btnSwitchCamera, btnBack)
			MyButton.Top = qrvQRCodeReaderView.Top + qrvQRCodeReaderView.Height + (16dip * LoadedLayout.Scale)
		Next
		
	Else If LoadedLayout.Width == 480 And LoadedLayout.Height == 320 And LoadedLayout.Scale == 1 Then
		'480x320, scale = 1 (160dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 16dip * LoadedLayout.Scale '16dip for this specific Scan Activity (not 32dip) [landscape mode]
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element lblQRCodeReaderBg"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, lblQRCodeReaderBg)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Fixing the Camera preview to be neatly square..."$, Colors.Blue)
		Dim ProperCameraPreviewLeft As Int
		ProperCameraPreviewLeft = ((btnToggleFlash.Left - (16dip * LoadedLayout.Scale) - LeftMargin - qrvQRCodeReaderView.Height) / 2 ) + LeftMargin
		
		qrvQRCodeReaderView.Left  = ProperCameraPreviewLeft
		qrvQRCodeReaderView.Width = qrvQRCodeReaderView.Height
		
		'
		'The buttons don't need to be adjusted in landscape layout variants
		'
		
	Else If LoadedLayout.Width == 240 And LoadedLayout.Height == 320 And LoadedLayout.Scale == 0.75 Then
		'240x320, scale = 0.75 (120dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 32dip * LoadedLayout.Scale
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnToggleFlash"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnToggleFlash)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Fixing the Camera preview to be neatly square..."$, Colors.Blue)
		Dim ProperCameraPreviewHeight As Int
		ProperCameraPreviewHeight = btnToggleFlash.Top - lblScanChallenge.Top - lblScanChallenge.Height
		
		lblQRCodeReaderBg.Height   = ProperCameraPreviewHeight
		qrvQRCodeReaderView.Height = ProperCameraPreviewHeight
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Now adjusting this Activity layout's btnToggleFlash, btnSwitchCamera & btnBack UI elements for the square Camera preview accordingly..."$, Colors.Blue)
		For Each MyButton As View In Array As View(btnToggleFlash, btnSwitchCamera, btnBack)
			MyButton.Top = qrvQRCodeReaderView.Top + qrvQRCodeReaderView.Height + (16dip * LoadedLayout.Scale)
		Next
		
	Else If LoadedLayout.Width == 320 And LoadedLayout.Height == 240 And LoadedLayout.Scale == 0.75 Then
		'320x240, scale = 0.75 (120dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 16dip * LoadedLayout.Scale '16dip for this specific Scan Activity (not 32dip) [landscape mode]
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element lblQRCodeReaderBg"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, lblQRCodeReaderBg)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Fixing the Camera preview to be neatly square..."$, Colors.Blue)
		Dim ProperCameraPreviewLeft As Int
		ProperCameraPreviewLeft = ((btnToggleFlash.Left - (16dip * LoadedLayout.Scale) - LeftMargin - qrvQRCodeReaderView.Height) / 2 ) + LeftMargin
		
		qrvQRCodeReaderView.Left  = ProperCameraPreviewLeft
		qrvQRCodeReaderView.Width = qrvQRCodeReaderView.Height
		
		'
		'The buttons don't need to be adjusted in landscape layout variants
		'
		
	End If
	
	'Add the ScrollView itself to the Activity View (must be done explicitly)
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Adding the ScrollView's View to the Activity (must be done explicitly in code)"$, Colors.Blue)
	Activity.AddView(scvActivity, 0, 0, scvActivity.Width, scvActivity.Height)
	
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Sub return"$, Colors.Blue)
End Sub

Private Sub FixVariantSpecificLayouts(ActivityMargins() As Int, BottomMostElement As View)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Sub entry"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: ActivityMargins = { Left: ${(ActivityMargins(0) / 1dip).As(Int)}dip, Top: ${(ActivityMargins(1) / 1dip).As(Int)}dip, Right: ${(ActivityMargins(2) / 1dip).As(Int)}dip, Bottom: ${(ActivityMargins(3) / 1dip).As(Int)}dip }"$, Colors.Blue)
	
	'Correct the ScrollView inner panel's height to add
	'the layout's variant-specific bottom margin
	'
	'It's computed based on the below formula:
	'  - Bottom-most element's Top + Height + desired bottom margin
	'
	'  - Portrait mode:
	'    It's btnToggleFlash / btnSwitchCamera / btnBack that are the bottom-most ones
	'
	'  - Landscape mode:
	'    It's lblQRCodeReaderBg / qrvQRCodeReaderView that are the bottom-most ones
	'
	'[0] Left, [1] Top, [2] Right, [3] Bottom
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Setting the ScrollView's inner panel height to bottom-most element's top(${(BottomMostElement.Top / 1dip).As(Int)}dip) + height(${(BottomMostElement.Height / 1dip).As(Int)}dip) and the layout's bottom margin(${(ActivityMargins(3) / 1dip).As(Int)}dip) too"$, Colors.Blue)
	scvActivity.Panel.Height = BottomMostElement.Top + BottomMostElement.Height + ActivityMargins(3)
	
	'Fix the ScrollView panel's height if it was created
	'but not given the proper height automatically
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: The ScrollView's panel should always fully cover the Activity view, so that modal background shades fully cover the screen"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Checking if the ScrollView's inner panel is somehow smaller than the Activity view's height..."$, Colors.Blue)
	If scvActivity.Panel.Height < Activity.Height Then
		LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: The ScrollView's inner panel height is somehow smaller than the Activity view height"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Increasing the ScrollView's inner panel height to match the Activity view height"$, Colors.Magenta)
		scvActivity.Panel.Height = Activity.Height
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: The ScrollView's inner panel height is equal or greater than the Activity view's height"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Alright, so no need to fix its height"$, Colors.Blue)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] FixVariantSpecificLayouts: Sub return"$, Colors.Blue)
End Sub

Private Sub ResetViewState
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .TorchEnabled state to False"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_TorchEnabled = False
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .PreviewCameraId value to CAMERA_REAR"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
	
	LogColor($"[Scan-${LogContextId}] ResetViewState: Setting the ViewState last scroll position to 0dip"$, Colors.Blue)
	ViewState_LastScrollPosition = 0dip
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Sub return"$, Colors.Blue)
End Sub

Sub InitializeActivityLayout
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Set the Activity layout title to the application name"$, Colors.Blue)
	Activity.Title = Application.LabelName
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Call InitializeQRCodeReaderView to reinitialize the QR code reader view..."$, Colors.Blue)
	InitializeQRCodeReaderView
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Sub return"$, Colors.Blue)
End Sub
Private Sub InitializeQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		'QR decoder settings
		'
		'Note: 1500ms is a fine value for the Autofocus interval,
		'      avoid setting very short values or you won't be able to
		'      reliably scan QR codes on devices that are not as superfast as
		'      the latest shiny new phones:
		'       - Because by the time the QR scanner recognizes the QR dots,
		'         your very short Autofocus interval in such cases would already have
		'         caused the Camera preview buffer to refocus, thus blurring the preview
		'         when the QR scanner was yet to try decoding the QR code contents
		'
		'       - (Autofocus always causes a temporary blurring of the Camera preview)
		'
		LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: Initializing default properties"$, Colors.Blue)
		qrvQRCodeReaderView.QRDecodingEnabled = True
		qrvQRCodeReaderView.AutofocusInterval = 1500
		qrvQRCodeReaderView.ResultPointColor  = Colors.Red
		
		'
		'Don't set any specific Flashlight state in this initialization function
		'
		
		'Set the Camera IDs properly
		LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: Initializing the rear Camera preview ID"$, Colors.Blue)
		qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_REAR
		qrvQRCodeReaderView.setBackCamera()
		
		'Verify if the device has two Cameras first before proceeding further
		LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: Checking whether the device has a front Camera"$, Colors.Blue)
		If joActivity.RunMethod("jDeviceHasFrontCamera", Null) Then
			LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: The device has a front Camera (or atleast has two Cameras?)"$, Colors.Blue)
			
			LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: Initializing the front Camera preview ID"$, Colors.Blue)
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_FRONT
			qrvQRCodeReaderView.setFrontCamera()
			
		Else
			LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: The device only has one Camera"$, Colors.Magenta)
			LogColor($"[${ActivityName}-${LogContextId}] InitializeQRCodeReaderView: No need to initialize a front Camera preview ID"$, Colors.Magenta)
			
		End If
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
End Sub

Private Sub HandleCameraServiceException
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: Sub entry"$, Colors.Red)
	
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: There was a problem dealing with the Camera service:"$, Colors.Red)
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	LogColor(LastException, Colors.Black) 'Let the color be black rather than red, it's easier to distinguish in the logs this way
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: Displaying an exception message to the user in a toast notification"$, Colors.Red)
	ToastMessageShow("Camera service failure", Constants.TOAST_DURATION_SHORT)
	
	'Stopping the Camere preview would require Camera service access anyway
	'
	'ActivityExit is used by btnBack_Click but doesn't stop the Camera preview
	'so we can use this function here for exception handling
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: Exiting this ${ActivityName} Activity (returning to the previous Activity)"$, Colors.Red)
	Activity_Exit
	
	LogColor($"[${ActivityName}-${LogContextId}] HandleCameraServiceException: Sub return"$, Colors.Red)
End Sub

Private Sub Activity_Exit
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Stopping this Activity's lifecycle reset thread for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Stop
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Resetting the ViewState to clear all the last selected Camera preview ID, Flashlight state etc"$, Colors.Blue)
	ResetViewState
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Asking the JVM to do a garbage collection as soon as possible"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: This will clear traces of leftover Camera preview buffers"$, Colors.Blue)
	Security.TriggerJvmGarbageCollection
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Starting the Main Activity"$, Colors.Blue)
	StartActivity(Main)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Finishing this Scan Activity"$, Colors.Blue)
	Activity.Finish
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Sub return"$, Colors.Blue)
End Sub

Sub Activity_Resume
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Stopping this Activity's lifecycle reset thread for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Stop
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Updating this Activity's lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.RESUME
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	'Note: Don't start the Camera preview here yourself
	'       - Restoring the ViewState also calls SwitchCamera
	'       - SwitchCamera already handles restarting the Camera preview
	'
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Restore ViewState"$, Colors.Blue)
	RestoreViewState
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Resetting this Activity's lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = ""
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Sub return"$, Colors.Blue)
End Sub

Private Sub RestoreViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Sub entry"$, Colors.Blue)
	
	'
	'Don't explicitly start the Camera preview because the
	'SwitchCamera function will already do it
	'
	
	'
	'Note: In this function, you don't need to do e.g. this:
	'       - ViewState_qrvQRCodeReaderView_TorchEnabled = ToggleFlashlight(...)
	'
	'      This would be redundant since these Camera management functions will
	'      return to you exactly the same value as the ViewState value you provided,
	'      which you would be writing to your ViewState again
	'
	'      In such cases, it's like doing "ViewState_Flashlight = ViewState_Flashlight"
	'
	'      So you don't need to save into the ViewState their results,
	'      since you're sending to them the ViewState to begin with
	'
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the QR code reader view's previous Camera preview ID ${ViewState_qrvQRCodeReaderView_PreviewCameraId}"$, Colors.Blue)
	SwitchCamera(Constants.CAMERA_SPECIFIC_ONE, ViewState_qrvQRCodeReaderView_PreviewCameraId)
	
	'We can now restore the TorchEnabled state too because we have a method of
	'knowing exactly when the device screen orientation changed while
	'the application is running, so no risk of accidentally blinding the user anymore
	'
	'Note 1: We only restore it, if it was due to a device screen orientation change,
	'        that the Activity had to resume, and therefore it had to call
	'        this RestoreViewState function
	'
	'Note 2: You have to do it after switching the Camera preview IDs
	'
	'        Some front Cameras have a Flashlight, so we want to wait for
	'        the correct one (front or rear) to be switched to and only then
	'        restore the previous Flashlight state
	'
	'        This way it's the state of that specific last-selected
	'        Camera preview side's Flashlight that gets restored,
	'        not always the rear Camera's
	'
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Verify if the Activity resume was because of screen rotation"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: We don't restore the previous Flashlight state (let it off) unless it's because of a foreground screen rotation only"$, Colors.Blue)
	If LifecycleTracking.WasForegroundRotation(LifecycleTracking.ActivityLifecycle) _
	Or LifecycleTracking.WasForegroundPause(LifecycleTracking.ActivityLifecycle) Then
		LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: The Activity resume was because of foreground screen rotation or foreground pause & resume"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the QR code reader view's previous ${ViewState_qrvQRCodeReaderView_TorchEnabled} Flashlight state"$, Colors.Blue)
		ToggleFlashlight(Constants.FLASH_SPECIFIC_STATE, ViewState_qrvQRCodeReaderView_TorchEnabled)
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: The Activity resume was because of a normal (background) application pause and not a foreground screen rotation either"$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: We don't restore the QR code reader view's previous Flashlight state, we let it stay off instead"$, Colors.Magenta)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the ScrollView's last scroll position"$, Colors.Blue)
	scvActivity.ScrollPosition = ViewState_LastScrollPosition
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Sub return"$, Colors.Blue)
End Sub

Private Sub Activity_KeyPress(KeyCode As Int) As Boolean
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub entry (KeyCode = ${KeyCode})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Verifying what the KeyCode is"$, Colors.Blue)
	Select Case KeyCode
		Case KeyCodes.KEYCODE_BACK
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_BACK"$, Colors.Blue)
			
			'The btnBack_Click already handles stopping the
			'Camera preview and finishing the Activity
			'
			'It also event handles resetting the ViewState too
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Simulating a click by the user on the Back button"$, Colors.Blue)
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: This does the same thing as exiting this Activity"$, Colors.Blue)
			btnBack_Click
			
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub return (returning True)"$, Colors.Red)
			Return True
			
		Case KeyCodes.KEYCODE_HOME
			'This code branch might go too fast for the Basic4Android BridgeLogger to log
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_HOME"$, Colors.Blue)
			
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Turning the Flashlight off on application switching events (Home button press)"$, Colors.Blue)
			ViewState_qrvQRCodeReaderView_TorchEnabled = ToggleFlashlight(Constants.FLASH_SPECIFIC_STATE, Constants.FLASH_OFF)
			
		Case Else
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is something else"$, Colors.Blue)
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: We don't do anything particular with other KeyCodes"$, Colors.Blue)
			
	End Select
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub return (returning False)"$, Colors.Blue)
	Return False
	
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Sub entry (UserClosed = ${UserClosed})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.Pause
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Save ViewState"$, Colors.Blue)
	SaveViewState
	
	'The ViewState saving function doesn't stop the Camera preview
	'because that's not its job, it only saved the current state
	'without affecting it
	'
	'So we have to manually stop the Camera preview on App pause
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Stop the QR code reader view on application pause"$, Colors.Blue)
	StopQRCodeReaderView
	
	'Do this only after stopping the QR code reader view
	If UserClosed Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Activity is UserClosed"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Calling Activity_Exit"$, Colors.Blue)
		Activity_Exit
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Starting this Activity's Lifecycle reset thread for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Start
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Sub return"$, Colors.Blue)
End Sub

Private Sub SaveViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Sub entry"$, Colors.Blue)
	
	'
	'The Camera preview ID (last selected Camera) is saved in realtime by
	'the Switch Camera button's event handler
	'
	
	'
	'The Flashlight state is saved in realtime the Toggle Flashlight button's event handler
	'
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Saving the ScrollView's last scroll position"$, Colors.Blue)
	ViewState_LastScrollPosition = scvActivity.ScrollPosition
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Sub return"$, Colors.Blue)
End Sub

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'UI element events
'

Private Sub qrvQRCodeReaderView_result_found(QRCodeContents As String)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Sub entry (sensitive parameters)"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is literally empty"$, Colors.Blue)
	If QRCodeContents == "" Then
		LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: The QR code content is literally empty"$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main Activity that this is not a mistake but a real value"$, Colors.Magenta)
		Main.Shared_AllowEmptyQRCodeContent = True
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is not empty"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main Activity that it cans consider empty values as a mistake"$, Colors.Blue)
		Main.Shared_AllowEmptyQRCodeContent = False
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Providing the QR code contents to the Main Activity via a shared process variable"$, Colors.Blue)
	Main.Shared_DetectedQRCodeContents = QRCodeContents
	
	LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Now simulating the user pressing the Back button to exit this Activity (returning to the Main Activity)"$, Colors.Blue)
	btnBack_Click
	
	LogColor($"[${ActivityName}-${LogContextId}] qrvQRCodeReaderView_result_found: Sub return"$, Colors.Blue)
End Sub

Private Sub btnToggleFlash_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Sub entry"$, Colors.Blue)
	
	'Verify if the device has a Flashlight first before proceeding further.
	LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Verifying if the device has a Flashlight before proceeding further"$, Colors.Blue)
	If Not(joActivity.RunMethod("jDeviceHasFlashlight", Null)) Then
		LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: The device has no Flashlight, we cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		ToastMessageShow("Flashlight required for the toggle", Constants.TOAST_DURATION_SHORT)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: The device has a Flashlight, now we can proceed further"$, Colors.Blue)
	
	'This also saves the new ViewState for the Flashlight state
	LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Calling ToggleFlashlight without requesting any specific state (toggle mode)"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_TorchEnabled = ToggleFlashlight(Constants.FLASH_NO_SPECIFIC_STATE, Constants.FLASH_TOGGLE)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub ToggleFlashlight(WantsSpecificState As Boolean, WhichOneIfYes As Boolean) As Boolean
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Sub entry (WantsSpecificState = ${WantsSpecificState}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	
	Dim FlashlightState As Boolean = Not(ViewState_qrvQRCodeReaderView_TorchEnabled)
	
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Checking if a specific Flashlight state was requested by the caller"$, Colors.Blue)
	If Not(WantsSpecificState) Then
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: The caller didn't request any specific Flashlight state"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Switch the Flashlight state to the opposite one (current: ${ViewState_qrvQRCodeReaderView_TorchEnabled} -> ${FlashlightState})"$, Colors.Blue)
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: The caller requested a specific Flashlight state (${WhichOneIfYes})"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Setting the Flashlight state to ${WhichOneIfYes}"$, Colors.Blue)
		FlashlightState = WhichOneIfYes
		
	End If
	
	Try
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Applying the new Flashlight state via ToggleFlashlight_Proxy..."$, Constants.COLORS_ORANGE)
		ToggleFlashlight_Proxy(FlashlightState)
		
	Catch
		'
		'Don't exit here because not being able to toggle the Flashlight state is not critical
		'
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: We had a problem applying the new Flashlight state"$, Colors.Red)
		
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		ToastMessageShow("Failed to toggle Flashlight", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Flashlight state
		'(if no specific one was actually requested)
		If Not(WantsSpecificState) Then
			LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Because no specific Flashlight state was requested, restore the prior value"$, Colors.Red)
			LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: This helps avoid having an inconsistent state since the state wasn't actually in effect (failed to apply)"$, Colors.Red)
			
			LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Restoring the new Flashlight state value ${FlashlightState} back to the previous one ${Not(FlashlightState)}"$, Colors.Red)
			FlashlightState = Not(FlashlightState)
			
		End If
		
	End Try
	
	'Dynamic Torch on / off icon
	If FlashlightState == Constants.FLASH_ON Then
		'If the Flashlight is on then show the icon for turning it off
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash Off icon since the Flashlight is on"$, Colors.Blue)
		btnToggleFlash.Text = Constants.FLASH_ICON_OFF
		
	Else
		'If the Flashlight is off then show the icon for turning it on
		LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash On icon since the Flashlight is off"$, Colors.Blue)
		btnToggleFlash.Text = Constants.FLASH_ICON_ON
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight: Sub return (returning FlashlightState = ${FlashlightState})"$, Colors.Blue)
	Return FlashlightState
	
End Sub

'This function was added because Basic4Android doesn't want to
'allow returning a value from any Sub which uses a Sleep call
'
'And yet, our original ToggleFLashlight must return a True or False
'return value so that it gets saved into the ViewState for the
'Flashlight state:
' - For this reason, this proxy function was added which just
'   stops Basic4Android from complaining about the Sleep call,
'   such that our original ToggleFlashlight function cans return
'   a value rather than being a void function
'
Private Sub ToggleFlashlight_Proxy(FlashlightState As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight_Proxy: Sub entry"$, Constants.COLORS_ORANGE)
	
	'Somehow on Activity resume, it's not possible to re-enable the Flashlight
	'if we try to do it too quickly, we have to wait a little bit of time before
	'trying to enable it
	'
	'Otherwise the Camera service didn't even finish initializing,
	'so don't remove this small delay (telling just incase)
	'
	'Note: Don't use synchronous sleep, since the synchronous ones get
	'      suspended then discard on device screen rotation and
	'      Activity pause & resume events
	'
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight_Proxy: Using a Sleep(100) call to reschedule the running of this function to 100ms later..."$, Constants.COLORS_ORANGE)
	Sleep(100)
	
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight_Proxy: Applying the new Flashlight state to the QR code reader view (setting it to ${FlashlightState})"$, Constants.COLORS_ORANGE)
	qrvQRCodeReaderView.TorchEnabled = FlashlightState
	
	LogColor($"[${ActivityName}-${LogContextId}] ToggleFlashlight_Proxy: Sub entry"$, Constants.COLORS_ORANGE)
End Sub

Private Sub btnSwitchCamera_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Sub entry"$, Colors.Blue)
	
	'Verify if the device has two Cameras first
	'before proceeding further.
	LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Verifying if the device has atleast two Cameras before the Camera side switch"$, Colors.Blue)
	If Not(joActivity.RunMethod("jDeviceHasFrontCamera", Null)) Then
		LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: The device only has one Camera, cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		ToastMessageShow("Front Camera required for the switch", Constants.TOAST_DURATION_SHORT)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: The device has atleast two Cameras, now we can try switching the Camera preview sides"$, Colors.Blue)
	
	'This also saves the new ViewState for the selected Camera ID
	LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Calling SwitchCamera without requesting any specific side (switch-sides mode)"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_PreviewCameraId = SwitchCamera(Constants.CAMERA_NO_SPECIFIC_ONE, Constants.CAMERA_ANY)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub SwitchCamera(WantsSpecificCamera As Boolean, WhichOneIfYes As Int) As Int
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Sub entry (WantsSpecificCamera = ${WantsSpecificCamera}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	
	'Stop the Camera preview
	LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Stopping the Camera preview"$, Colors.Blue)
	StopQRCodeReaderView
	
	Dim SelectedCamera As Int = Constants.CAMERA_REAR
	
	'Change the Camera to the opposite side
	LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Check whether the caller wants a specific Camera side"$, Colors.Blue)
	If Not(WantsSpecificCamera) Then
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: The caller does not want any specific Camera side"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Switching the Camera preview ID to the opposite side"$, Colors.Blue)
		If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: The current opposite side is rear, switching to front"$, Colors.Blue)
			SelectedCamera = Constants.CAMERA_FRONT
			
		Else
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: The current opposite side is front, switching to rear"$, Colors.Blue)
			'
			'It's already the initial value
			'
		End If
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: The caller wants a specific Camera side"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Setting the Camera preview ID to the specifically requested one (${WhichOneIfYes})"$, Colors.Blue)
		SelectedCamera = WhichOneIfYes
		
	End If
	
	Try
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Applying the new Camera preview ID (${SelectedCamera})"$, Colors.Blue)
		qrvQRCodeReaderView.PreviewCameraId = SelectedCamera
		
		If SelectedCamera == Constants.CAMERA_REAR Then
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Setting the new selected Camera side to rear (ID ${SelectedCamera} = rear)"$, Colors.Blue)
			qrvQRCodeReaderView.setBackCamera()
			
		Else If SelectedCamera == Constants.CAMERA_FRONT Then
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Setting the new selected Camera side to front (ID ${SelectedCamera} = front)"$, Colors.Blue)
			qrvQRCodeReaderView.setFrontCamera()
			
		End If
		
	Catch
		'Don't exit here because the StopQRCodePreview and
		'StartQRCodePreview Methods already exit on failure
		'
		'And not being able to switch Cameras is not critical
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: We had a problem applying the new Camera preview ID"$, Colors.Red)
		
		LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		ToastMessageShow("Failed to switch Camera preview side", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Camera preview ID
		'(if no specific one was actually requested)
		If Not(WantsSpecificCamera) Then
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Because no specific Camera ID was requested, restore the prior value in the ViewState"$, Colors.Red)
			LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: This helps avoid having an inconsistent state since the new ID wasn't actually in effect (failed to apply)"$, Colors.Red)
			
			If SelectedCamera == Constants.CAMERA_REAR Then
				LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to front"$, Colors.Red)
				SelectedCamera = Constants.CAMERA_FRONT
				
			Else
				LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to rear"$, Colors.Red)
				SelectedCamera = Constants.CAMERA_REAR
				
			End If
			
		End If
		
	End Try
	
	'Resume the Camera preview
	LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Starting the Camera preview"$, Colors.Blue)
	StartQRCodeReaderView
	
	LogColor($"[${ActivityName}-${LogContextId}] SwitchCamera: Sub return (returning SelectedCamera = ${SelectedCamera})"$, Colors.Blue)
	Return SelectedCamera
	
End Sub

Private Sub StartQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] StartQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		LogColor($"[${ActivityName}-${LogContextId}] StartQRCodeReaderView: Starting the Camera preview"$, Colors.Blue)
		qrvQRCodeReaderView.startCamera()
		qrvQRCodeReaderView.Visible = True 'Important or switching Camera preview sides doesn't work
		
		LogColor($"[${ActivityName}-${LogContextId}] StartQRCodeReaderView: Start scanning for QR codes"$, Colors.Blue)
		qrvQRCodeReaderView.ScanNow = True
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[${ActivityName}-${LogContextId}] StartQRCodeReaderView: Sub return"$, Colors.Blue)
End Sub

Private Sub StopQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] StopQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		'Stop searching for valid QR codes
		LogColor($"[${ActivityName}-${LogContextId}] StopQRCodeReaderView: Stop scanning for QR codes"$, Colors.Blue)
		qrvQRCodeReaderView.ScanNow = False
		
		'Always turn off the Flashlight when stopping the Camera preview
		'
		'Note: Don't save into the ViewState the new Flashlight state,
		'      this function is called recursively by other background ones,
		'      such as SwitchCamera, called by RestoreViewState [...]
		'
		'       - Only explicit, non-background event Subs where the user does
		'         an explicit action should save the new state into the ViewState
		'
		LogColor($"[${ActivityName}-${LogContextId}] StopQRCodeReaderView: Turning off the Flashlight"$, Colors.Blue)
		ToggleFlashlight(Constants.FLASH_SPECIFIC_STATE, Constants.FLASH_OFF)
		
		LogColor($"[${ActivityName}-${LogContextId}] StopQRCodeReaderView: Stopping the Camera preview"$, Colors.Blue)
		qrvQRCodeReaderView.Visible = False 'Important or switching Camera preview sides doesn't work
		qrvQRCodeReaderView.stopCamera()
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[${ActivityName}-${LogContextId}] StopQRCodeReaderView: Sub return"$, Colors.Blue)
End Sub

Private Sub btnBack_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnBack_Click: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnBack_Click: Stopping the QR code reader view"$, Colors.Blue)
	StopQRCodeReaderView
	
	LogColor($"[${ActivityName}-${LogContextId}] btnBack_Click: Calling the Activity_Exit function"$, Colors.Blue)
	Activity_Exit
	
	LogColor($"[${ActivityName}-${LogContextId}] btnBack_Click: Sub return"$, Colors.Blue)
End Sub


