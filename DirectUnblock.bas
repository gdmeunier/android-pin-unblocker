B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=12.5
@EndOfDesignText@

#Region Activity Attributes
	#FullScreen:   False
	#IncludeTitle: True
	
#End Region

#Region Module File Attributes
	'Ignore "Sub x is not used" warning (#12)
	#IgnoreWarnings: 12
	
#End Region

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Java native code
'

#If Java

private String activityName = "directunblock";

private myadvanced myadvancedInstance = new myadvanced();
private mycommon   mycommonInstance   = new mycommon();

private BroadcastReceiver DeviceIdleDetectionReceiver;

//
// This part is used by joActivity.RunMethod calls
//
import android.content.Context;
import android.app.Activity;
public float jGetDisplayScale()
{
	return myadvancedInstance.jGetDisplayScale(this);
}

import android.content.Context;
import android.app.Activity;
public boolean jDeviceHasUsbOtgSupport()
{
	return myadvancedInstance.jDeviceHasUsbOtgSupport(this);
}

import android.content.Context;
import android.app.Activity;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
public void jSetKeepScreenOn()
{
	this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
}

import android.content.Context;
import android.app.Activity;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
public void jClearKeepScreenOn()
{
	this.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
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
import android.os.Build;
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
	
	// Android 13+ require explicitly exporting the receiver
	// (Android 13+ is API level 33+)
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		this.registerReceiver(DeviceIdleDetectionReceiver, myadvancedInstance.jGetDeviceIdleIntentFilter(), Context.RECEIVER_EXPORTED);
	}
	else
	{
		this.registerReceiver(DeviceIdleDetectionReceiver, myadvancedInstance.jGetDeviceIdleIntentFilter());
	}
	
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
	
	'These constants exist to save space in the source code,
	'so that we don't write these entire texts multiple times
	Private Const DEFAULT_BULLETS_NEW_PIN As String = "••••••" 'U+2022
	Private Const DEFAULT_YYYYMM_NEW_PIN  As String = "202608"
	
	'
	'ViewState variables
	'
	
	'The "Select PIN" label is restored dynamically always
	
	'1 = Primary PIN, 3 = Role #3 [...]
	Private ViewState_LastSelectedPIN As Int = 1
	
	'The "New PIN" label is restored dynamically always
	
	Private ViewState_edtNewPIN_Text            As String
	Private ViewState_edtNewPIN_SelectionStart  As Int
	Private ViewState_edtNewPIN_SelectionLength As Int
	
	Private ViewState_chkHideNewPIN_Checked As Boolean
	Private ViewState_chkHideNewPIN_Enabled As Boolean = True 'Sensitive flag
	
	Private ViewState_LastFocusedElement As String
	Private ViewState_LastScrollPosition As Int
	
	'Needed for the SetUiElementsEnabledState function
	Private ViewState_SetUiElementsEnabledState_TrueOrFalse As Boolean = True 'True by default
	
	'
	'General-use process globals
	'
	
	'Convenience constants stored inside this class
	Private Constants As MyConstants
	
	'Better method of managing the App's security
	Private Security As MySecurity
	
	'For getting Phone library functions without bundling the big Phone library
	Private Common As MyCommon
	
	'For generating text hashes & encryption (response codes)
	Private Cryptography As MyCryptography
	
	'For advanced Java functions that require context
	Private joActivity As JavaObject
	
	'For foreground device rotation detection & misc
	Private LifecycleTracking As MyLifecycleTracking
	
	'
	'-----
	'
	
	'Needed because the Select PIN label is like:
	' - "Select PIN: (Gemalto) - T=0"
	' - "Select PIN: (ActivID) - T=1"
	'
	Private DetectedCardType     As String 'No default value ("Gemalto", "ActivID")
	Private DetectedCardProtocol As String 'No default value ("T=0", "T=1", "T=CL")
	
	'Needed because the New PIN label is like:
	' - "New PIN: (6 chars) - Min: 4 | Max: 16"
	' - "New PIN: (6 chars) - Min: 4 | Max: 14"
	'
	Private DetectedCardMinPINLength As Int 'No default value
	Private DetectedCardMaxPINLength As Int 'No default value
	
	Private DetectedAlgorithm As String 'No default value
	Private DetectedAdminKey  As String 'No default value
	
	'Needed on some PKI smartcards to logout
	Private DetectedSelectAppletAPDU As String 'No default value
	
	'Card ATR helps detect if the user switches smartcards without
	'reloading the Activity, which is required before using a different
	'PKI smartcard for the next PIN unblock process
	Private DetectedCardATR As String 'No default value
	
	'
	'-----
	'
	
	Private IsFirstActivityResume As Boolean = True 'True by default (it's still a sensitive value here)
	
	'For background smartcard operations
	Private DirectUnblockThread     As Thread
	Private DirectUnblockInProgress As Boolean = False
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created
	
	'Just so that we don't write many Dim statements to declare
	'this variable multiple times in the LoadActivityLayout Sub etc
	Private LoadedLayout As LayoutValues
	
	'For being able to scroll vertically
	Private scvActivity As ScrollView
	
	Private lblSelectPIN  As Label
	Private rdoPrimaryPIN As RadioButton
	Private rdoRole3      As RadioButton
	Private rdoRole4      As RadioButton
	Private rdoRole5      As RadioButton
	Private rdoRole6      As RadioButton
	Private rdoRole7      As RadioButton
	
	Private lblNewPIN     As Label
	Private edtNewPIN     As EditText
	Private edtDecoyPIN   As EditText
	Private chkHideNewPIN As CheckBox
	
	'New Lockdown button that allows the user to
	'lockdown the New PIN field at any time
	Private btnLockdown As Button
	
	Private lblAdminKey As Label
	Private edtDecoyKey As EditText
	
	Private btnProceedToUnblock As Button
	
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
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: Setting the Hide New PIN checkbox's ViewState to Checked and resetting the Activity Lifecycle tracking"$, Colors.Black)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Idle: This will make it even quicker to securely hide the new PIN on slow devices during application resume"$, Colors.Black)
	ViewState_chkHideNewPIN_Checked = True
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
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Checking if this is the FirstTime Activity create for this running Activity instance..."$, Colors.Blue)
	If FirstTime Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: It's the FirstTime Activity create for this running Activity instance"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Setting this Activity's IsFirstActivityResume variable to True"$, Colors.Blue)
		IsFirstActivityResume = True
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: This is not the FirstTime Activity create for this running Activity instance"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: No need to set this Activity's IsFirstActivityResume variable to True"$, Colors.Blue)
		
	End If
	
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
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Constants Class (MyConstants class)"$, Colors.Blue)
		Constants.Initialize
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Security Class (MySecurity class)"$, Colors.Blue)
		Security.Initialize
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Common Class (MyCommon class)"$, Colors.Blue)
		Common.Initialize
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Cryptography Class (MyCryptography class)"$, Colors.Blue)
		Cryptography.Initialize
		
		'For background smartcard operations
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initialize the Direct Unblock thread"$, Colors.Blue)
		DirectUnblockThread.Initialize("DirectUnblockThread")
		
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
	
	If IsFirstActivityResume Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: It's the IsFirstActivityResume launch"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Get an initial ViewState with default UI element values by resetting the ViewState"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: The layout files don't always contain default UI element values"$, Colors.Blue)
		ResetViewState
		
		'On the first-time Activity create, the default Admin key is not
		'hidden, because hiding the default 48-zeroes key is unnecessary
		'
		'Remember that ResetViewState actually resets the Admin Key field's
		'text content to be 48-zeroes too
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Because this is a IsFirstActivityResume, we alter the ViewState of the Hide Admin Key checkbox to be Checked = False"$, Colors.Blue)
		ViewState_chkHideNewPIN_Checked = False
		
		'Put this part here to get the necessary Direct Unblock settings
		'from the Main Activity, because we need the MySecurity class
		'and it's only initialized in the code above,
		'so we cannot put this part on an earlier location than here
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Initializing this Activity's own Process_Globals (because IsFirstActivityResume) from the Main module's shared Process_Globals..."$, Colors.Blue)
		InitializeActivity
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Calling InitializeActivityLayout to initialize the loaded layout..."$, Colors.Blue)
	InitializeActivityLayout
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Create: Sub return"$, Colors.Blue)
End Sub

Private Sub InitializeActivity
	
	DetectedCardType     = Main.Shared_DetectedCardType
	Main.Shared_DetectedCardType = ""
	DetectedCardProtocol = Main.Shared_DetectedCardProtocol
	Main.Shared_DetectedCardProtocol = "T=?"
	
	DetectedCardMinPINLength = Main.Shared_DetectedCardMinPINLength
	Main.Shared_DetectedCardMinPINLength = 0
	DetectedCardMaxPINLength = Main.Shared_DetectedCardMaxPINLength
	Main.Shared_DetectedCardMaxPINLength = 0
	
	DetectedAlgorithm = Main.Shared_DetectedAlgorithm
	Main.Shared_DetectedAlgorithm = ""
	DetectedAdminKey  = Main.Shared_DetectedAdminKey
	Main.Shared_DetectedAdminKey = ""
	
	DetectedSelectAppletAPDU = Main.Shared_DetectedSelectAppletAPDU
	Main.Shared_DetectedSelectAppletAPDU = ""
	DetectedCardATR          = Main.Shared_DetectedCardATR
	Main.Shared_DetectedCardATR = ""
	
	Security.TriggerJvmGarbageCollection
	
End Sub

Private Sub DirectUnblockThread_Ended(Failed As Boolean, ErrorIfAny As String)
	'
	'Nothing to do here
	'
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
	LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Loading the Direct Unblock Activity layout into **the ScrollView's inner panel**"$, Colors.Blue)
	LoadedLayout = scvActivity.Panel.LoadLayout("DirectUnblock")
	
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
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnProceedToUnblock"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnProceedToUnblock)
		
	Else If LoadedLayout.Width == 480 And LoadedLayout.Height == 320 And LoadedLayout.Scale == 1 Then
		'480x320, scale = 1 (160dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 32dip * LoadedLayout.Scale
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnProceedToUnblock"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnProceedToUnblock)
		
	Else If LoadedLayout.Width == 240 And LoadedLayout.Height == 320 And LoadedLayout.Scale == 0.75 Then
		'240x320, scale = 0.75 (120dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 32dip * LoadedLayout.Scale
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnProceedToUnblock"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnProceedToUnblock)
		
	Else If LoadedLayout.Width == 320 And LoadedLayout.Height == 240 And LoadedLayout.Scale == 0.75 Then
		'320x240, scale = 0.75 (120dpi)
		
		LeftMargin   = 16dip * LoadedLayout.Scale
		TopMargin    = 16dip * LoadedLayout.Scale
		RightMargin  = 16dip * LoadedLayout.Scale
		BottomMargin = 32dip * LoadedLayout.Scale
		
		'[0] Left, [1] Top, [2] Right, [3] Bottom
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Setting Activity margins to left(${(LeftMargin / 1dip).As(Int)}dip), top(${(TopMargin / 1dip).As(Int)}dip), right(${(RightMargin / 1dip).As(Int)}dip) & bottom(${(BottomMargin / 1dip).As(Int)}dip)"$, Colors.Blue)
		ActivityMargins = Array As Int(LeftMargin, TopMargin, RightMargin, BottomMargin)
		
		LogColor($"[${ActivityName}-${LogContextId}] LoadActivityLayout: Calling FixVariantSpecificLayouts with the Activity margins & bottom-most element btnProceedToUnblock"$, Colors.Blue)
		FixVariantSpecificLayouts(ActivityMargins, btnProceedToUnblock)
		
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
	'  - Bottom-most element's Top + Height + desired bottom margin:
	'    Here it's btnProceedToUnblock that is the bottom-most one
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
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Setting the ViewState last focused element to "edtNewPIN""$, Colors.Blue)
	ViewState_LastFocusedElement = "edtNewPIN"
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Setting the ViewState last scroll position to 0"$, Colors.Blue)
	ViewState_LastScrollPosition = 0
	
	ViewState_LastSelectedPIN = 1 '1 = Primary PIN, 3 = Role #3 [...]
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Setting initial values for EditText fields"$, Colors.Blue)
	ViewState_edtNewPIN_Text = DEFAULT_YYYYMM_NEW_PIN
	
	'The layout file for Direct Unblock has the New PIN field revealed by default,
	'and the Hide New PIN checkbox in unchecked state by default,
	'so reset their ViewStates to safer values
	'
	'Note: Don't directly set the safer values in the layout file,
	'      because otherwise Android will not fire 'duplicate' events
	'      for setting UI element properties, and it's a bit of a hell otherwise
	'      to correctly set properties such as e.g. the New PIN field's .Hint value
	'
	'       - (I mean e.g. the bullet-dots versus YYYYMM EditText Hint)
	'
	'      If you do this anyway, then you need to adapt Activity_Create to:
	'       - Uncheck the Hide New PIN checkbox on FirstTime create,
	'         rather than check it
	'
	'      You need to then adapt Activity_Resume to
	'       - Reveal the New PIN field on first Activity resume,
	'         rather than hide it if it's not the first Activity resume
	'
	'      Finally, you need to then manually fix the EditTexts' .Hint values
	'      on every Activity resume, if you again set safer values in the layout files,
	'      which you should *not* do, even if you think that it's *safer*:
	'       - It will cause more problems for you to manage the UI state than
	'         the safety it would afford, and it might cause you to accidentally
	'         introduce bugs with safety-related consequences
	'
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Setting initial states for checkboxes & menu buttons"$, Colors.Blue)
	ViewState_chkHideNewPIN_Checked = True
	
	'Has built-in checks against re-enabling chkHideNewPIN after locking it down
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Setting initial .Enabled states of UI elements for this Activity"$, Colors.Blue)
	SetUiElementsEnabledState(True)
	
	LogColor($"[${ActivityName}-${LogContextId}] ResetViewState: Sub return"$, Colors.Blue)
End Sub

Private Sub InitializeActivityLayout
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Set the Activity layout title to the application name"$, Colors.Blue)
	Activity.Title = Application.LabelName
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Harden this Activity's EditTexts to prevent Android from leaking sensitive information"$, Colors.Blue)
	HardenActivityEditTexts(Constants.EDITTEXT_NO_SPECIFIC_ONE, Null)
	
	'Currently only the New PIN field has a monospace font
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Fix this Activity's EditTexts that have a monospace font to stay monospace on older Android versions"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Otherwise some older Android devices see these EditTexts as not being monospace"$, Colors.Blue)
	FixMonospaceEditTexts(Constants.EDITTEXT_SPECIFIC_ONE, edtNewPIN)
	
	'Check the detected card type
	'If it's not a Gemalto card, then there are no additional roles on it
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: We have a card detected as a ${DetectedCardType}-type card"$, Colors.Blue)
	If DetectedCardType <> "Gemalto" Then
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Since it's not a Gemalto smartcard, we can disable the additional PIN choices"$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: The additional PINs are a Gemalto-specific functionality"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Disabling the additional PIN selection choices (leaving only Primary PIN enabled)"$, Colors.Magenta)
		rdoRole3.Enabled = False
		rdoRole4.Enabled = False
		rdoRole5.Enabled = False
		rdoRole6.Enabled = False
		rdoRole7.Enabled = False
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: It's a Gemalto smartcard, we can enable the additional PIN choices"$, Colors.Green)
		
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Enabling the additional PIN selection choices"$, Colors.Green)
		rdoRole3.Enabled = True
		rdoRole4.Enabled = True
		rdoRole5.Enabled = True
		rdoRole6.Enabled = True
		rdoRole7.Enabled = True
		
	End If
	
	'The new New PIN Lockdown button isn't visible by default
	'So we make it visible when the Admin Key field isn't already
	'locked-down, but it disappears after a lockdown
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Checking if the New PIN field is not already locked-down..."$, Colors.Blue)
	If ViewState_chkHideNewPIN_Enabled Then
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: The New PIN field is not already locked-down, displaying the Lockdown button"$, Colors.Blue)
		btnLockdown.Visible = True
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: The New PIN field is already locked-down, no need to display the Lockdown button"$, Colors.Blue)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] InitializeActivityLayout: Sub return"$, Colors.Blue)
End Sub

Private Sub HardenActivityEditTexts(WantsToHardenASpecificOne As Boolean, WhichOneIfYes As EditText)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Sub entry"$, Colors.Blue)
	
	'Caller sanity check:
	'If you want a specific one, then don't say a "Null" one
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Checking if the caller is "sane" (if what they ask for is logical)"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Checking whether the caller requested a specific EditText to harden but says that it's "Null""$, Colors.Blue)
	If WantsToHardenASpecificOne And WhichOneIfYes == Null Then
		'Caller is confused about what it wants
		'Not doing anything in such cases
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: The caller is illogical, providing illogical parameters to this function"$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: The caller asks us to harden a specific EditText then gives "Null""$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Since the caller is asking for an illogical thing, we just cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Sub return"$, Colors.Magenta)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Sanity check completed, the caller is logical (good news!)"$, Colors.Blue)
	
	'Create a list of EditTexts to harden
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Creating a list of EditTexts to harden (currently empty)"$, Colors.Blue)
	Dim EditTextsToHarden() As EditText
	
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Checking if the caller wants to harden a specific EditText"$, Colors.Blue)
	If WantsToHardenASpecificOne Then
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Caller wants to harden a specific EditText"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Adding only the specified EditText to our list"$, Colors.Blue)
		EditTextsToHarden = Array As EditText(WhichOneIfYes)
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Caller wants to harden any & all EditTexts in this Activity (no specific one)"$, Colors.Blue)
		
		'Even the decoy fields too
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Adding all this Activity's EditTexts to our list"$, Colors.Blue)
		EditTextsToHarden = Array As EditText(edtNewPIN, edtDecoyPIN, edtDecoyKey)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Hardening the security of the EditText fields in our completed list"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: This includes disabling autocomplete, autocorrect, fullscreen keyboard etc"$, Colors.Blue)
	For Each MyEditText As EditText In EditTextsToHarden
		'First the ones that modify the InputType
		'Then the ones that modify the ImeOptions
		'
		'Changing the InputType will clear the ImeOptions
		'So do the ImeOptions changes after the InputType ones
		'
		'There are actually mitigations for this in the
		'MySecurity class's Java native functions
		
		Security.DisableAutoCorrect(MyEditText)               'inputType
		Security.DisableAutoComplete(MyEditText)              'inputType
		Security.DisableAutoSuggestions(MyEditText)           'inputType
		Security.DisableTextConversionSuggestions(MyEditText) 'inputType
		Security.DisableTextSelectionSuggestions(MyEditText)  'inputType
		Security.DisableFullscreenKeyboard(MyEditText)   'imeOptions
		Security.DisablePersonalizedLearning(MyEditText) 'imeOptions
		
		LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: An EditText found in the list has been hardened"$, Colors.Blue)
	Next
	
	LogColor($"[${ActivityName}-${LogContextId}] HardenActivityEditTexts: Sub return"$, Colors.Blue)
End Sub

Private Sub FixMonospaceEditTexts(WantsToFixASpecificOne As Boolean, WhichOneIfYes As EditText)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Sub entry"$, Colors.Blue)
	
	'Caller sanity check:
	'If you want a specific one, then don't say a "Null" one
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Checking if the caller is "sane" (if what they ask for is logical)"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Checking whether the caller requested a specific EditText to fix but says that it's "Null""$, Colors.Blue)
	If WantsToFixASpecificOne And WhichOneIfYes == Null Then
		'Caller is confused about what it wants
		'Not doing anything in such cases
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: The caller is illogical, providing illogical parameters to this function"$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: The caller asks us to fix a specific EditText then gives "Null""$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Since the caller is asking for an illogical thing, we just cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Sub return"$, Colors.Magenta)
		Return
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Sanity check completed, the caller is logical (good news!)"$, Colors.Blue)
	
	'Create a list of EditTexts to harden
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Creating a list of EditTexts to fix (currently empty)"$, Colors.Blue)
	Dim EditTextsToFix() As EditText
	
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Checking if the caller wants to fix a specific EditText"$, Colors.Blue)
	If WantsToFixASpecificOne Then
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Caller wants to fix a specific EditText"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Adding only the specified EditText to our list"$, Colors.Blue)
		EditTextsToFix = Array As EditText(WhichOneIfYes)
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Caller wants to fix any & all EditTexts in this Activity (no specific one)"$, Colors.Blue)
		
		'Decoy fields also included if we need to fix *all* the EditTexts
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Adding all this Activity's EditTexts to our list"$, Colors.Blue)
		EditTextsToFix = Array As EditText(edtNewPIN, edtDecoyPIN, edtDecoyKey)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Correcting the monospace EditTexts in our completed list to always stay monospace"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: On older Android versions such as 2.x they are otherwise not monospace"$, Colors.Blue)
	For Each MyEditText As EditText In EditTextsToFix
		
		Common.ForceCorrectMonospaceFont(MyEditText)
		
		'Correcting the monospace EditTexts to also have proper monospace digits
		'On Android 5.0+ the monospace EditTexts don't have proper monospace digits otherwise
		Common.ForceCorrectMonospaceFontDigits(MyEditText)
		
		LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: An EditText found in the list has been fixed"$, Colors.Blue)
	Next
	
	LogColor($"[${ActivityName}-${LogContextId}] FixMonospaceEditTexts: Sub return"$, Colors.Blue)
End Sub

Sub Activity_Resume
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Stopping this Activity's Lifecycle reset Timer for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Stop
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.RESUME
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	'
	'Moved RestoreViewState further down for security reasons
	'
	
	'For always hiding the new PIN when switching apps
	'such as pausing this App to use another one,
	'then coming back to this App
	'
	'This prevents accidental showing of new PIN texts
	'incase the user forgot that the new PIN text was
	'not hidden when they paused the App prior
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Checking if this is not the first Activity resume in this App lifecycle"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Also checking if this Activity resume was not just a screen rotation or foregroud pause"$, Colors.Blue)
	If Not(IsFirstActivityResume) And Not(LifecycleTracking.WasForegroundRotation(LifecycleTracking.ActivityLifecycle)) And Not(LifecycleTracking.WasForegroundPause(LifecycleTracking.ActivityLifecycle)) Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: It's not the first-time Activity resume for this App lifecycle"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: It's also not due to a foreground device screen orientation change nor a foreground pause"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: So we want to hide the New PIN field always to prevent accidental exposure in sensitive environments"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Setting the Hide New PIN field's .Checked state to True"$, Colors.Blue)
		chkHideNewPIN.Checked = True
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: This is either the first-time Activity resume for this app lifecycle..."$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Or it's just a device screen rotation event while is app is in the foreground anyway, or a foreground-only app pause & resume"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: We don't need to specifically hide the New PIN field in such cases"$, Colors.Blue)
		
	End If
	
	'Restore the ViewState only after having first set the
	'Hide New PIN checkbox to Checked if needed
	'
	'This prevents potential milliseconds-leaks of the
	'new PIN texts in app background pause & resume scenarios
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Restore ViewState"$, Colors.Blue)
	RestoreViewState
	
	'Something to do on app resume (only after restoring ViewState):
	'Show the new PIN text (using the Visible property)
	'
	'This is how preventing potential milliseconds-leaks works
	'in this application, to avoid having the new PIN seen until
	'we confirm that it's allowed to be visible
	'
	'It's allowed to be visible only once we have properly
	'restored its PasswordMode property (incase it was hidden),
	'and after we confirmed that we did the forced
	'new PIN hiding in cases of application background-pause & resume
	'
	'It was set to invisible by Activity_Pause as a security precaution
	'against short milliseconds-wise new PIN leaks (visual leaks)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Restore new PIN field visibility to Visible"$, Colors.Blue)
	edtNewPIN.Visible = True
	
	'Hide the decoy new PIN field after it's safe to hide it
	'(The ViewState successfully completed, and its synchronous now)
	'
	' - This decoy EditText field is used for hiding
	'   the new PIN field with explanation about
	'   why it's hidden (during app pauses)
	'
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Reset decoy new PIN field visibility back to invisible"$, Colors.Blue)
	edtDecoyPIN.Visible = False
	
	'This part as always near the end of this function
	If IsFirstActivityResume Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: This was the first Activity_Resume event"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Setting IsFirstActivityResume to False to so that next time we know it won't be the first Activity_Resume"$, Colors.Blue)
		IsFirstActivityResume = False
		
	End If
	
	'Android wants to play boss with our application's focus management,
	'so we teach it a bit of a lesson by bypassing its obnoxious automatic
	'focus on the Activity View's first UI element
	'
	' - (Android does this right after Activity_Resume returns)
	'
	'This actually schedules a call 100ms caller, after Android deliberately
	'sabotaged our preferred last-focused-element restore,
	'then this will automatically correct Android's obnoxious mistake
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Calling the Hotfix function ForceRestoreCorrectLastFocusedElementState because Android is obnoxious with its default focus management with ScrollViews"$, Constants.COLORS_ORANGE)
	ForceRestoreCorrectLastFocusedElementState(ViewState_LastFocusedElement)
	
	'This part as the very last one of this function
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Resetting this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = ""
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Resume: Sub return"$, Colors.Blue)
End Sub

Private Sub RestoreViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Sub entry"$, Colors.Blue)
	
	'This is the very first thing to do
	'This is one of the most sensitive flags in this application
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the Hide New PIN checkbox .Enabled state"$, Colors.Blue)
	chkHideNewPIN.Enabled = ViewState_chkHideNewPIN_Enabled
	
	'This one is the second-most sensitive flag
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the Hide New PIN checkbox .Checked state"$, Colors.Blue)
	chkHideNewPIN.Checked = ViewState_chkHideNewPIN_Checked
	
	'Has built-in checks against re-enabling chkHideNewPIN after locking it down
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the .Enabled states of UI elements for this Activity (except chkHideNewPIN) to ${ViewState_SetUiElementsEnabledState_TrueOrFalse}"$, Colors.Blue)
	SetUiElementsEnabledState(ViewState_SetUiElementsEnabledState_TrueOrFalse)
	
	'e.g. DetectedCardProtocol cans be "T=1", "T=0", "T=CL"
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the Select PIN label .Text"$, Colors.Blue)
	lblSelectPIN.Text = $"Select PIN: (${DetectedCardType}) - ${DetectedCardProtocol}"$
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the last-selected PIN radiobox to PIN ${ViewState_LastSelectedPIN}"$, Colors.Blue)
	SetSelectedPIN(ViewState_LastSelectedPIN)
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the New PIN field .Text"$, Colors.Blue)
	edtNewPIN.Text = ViewState_edtNewPIN_Text
	
	'Needs to be done here too just incase
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the New PIN label text"$, Colors.Blue)
	edtNewPIN_ShowSelectionInfo
	
	'The New PIN label is restored dynamically on TextChanged events
	
	Dim chars As String = ""
	If DetectedAdminKey.Length >= 1 Then
		chars = $" (${DetectedAdminKey.Length} char"$
		If DetectedAdminKey.Length > 1 Then
			chars = chars&"s)"
		Else
			chars = chars&")"
		End If
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the Admin Key label .Text"$, Colors.Blue)
	lblAdminKey.Text = $"Admin Key:${chars}"$
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Checking what was the last focused element before"$, Colors.Blue)
	Select ViewState_LastFocusedElement
		Case "edtNewPIN"
			LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: The last focused element before was edtNewPIN"$, Colors.Blue)
			
			LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the focus state on edtNewPIN"$, Colors.Blue)
			edtNewPIN.RequestFocus
			
			LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the .Selection state for edtNewPIN"$, Colors.Blue)
			edtNewPIN.SetSelection(ViewState_edtNewPIN_SelectionStart, ViewState_edtNewPIN_SelectionLength)
			
		Case Else
			LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: The last focused element was not found in the list (value = ${ViewState_LastFocusedElement})"$, Colors.Magenta)
			LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Not restoring the focus state on any specific element"$, Colors.Magenta)
			
	End Select
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Restoring the ScrollView's last scroll position"$, Colors.Blue)
	Common.SynchronousSleep(100, Me, "RestoreViewState")
	Wait For SynchronousSleep_RestoreViewState_Completed
	scvActivity.ScrollPosition = ViewState_LastScrollPosition
	
	LogColor($"[${ActivityName}-${LogContextId}] RestoreViewState: Sub return"$, Colors.Blue)
End Sub

'Workaround for Android trying to force its own automatic focus management on
'our application despite us not wanting any such obnoxious 'functionality'
Private Sub ForceRestoreCorrectLastFocusedElementState(LastFocusedElement As String)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Sub entry (LastFocusedElement = ${LastFocusedElement})"$, Constants.COLORS_ORANGE)
	
	'Wait until Android foolishly forces its own focus management and
	'deliberately tries to force the wrong one on our Activity
	'
	'Use a normal sleep call here (not synchronous sleep),
	'because this is just as if this function was called via CallSubDelayed
	'when you call a function that starts with a normal sleep call
	'
	'The sleep call immediately lets the caller function finish and return,
	'then puts e.g. this one (the called function) into a queue that will
	'start later when the sleep time is completed
	'
	'Note: Synchronous sleep is not compatible with functions called via
	'      the builtin CallSubDelayed functions, because if one such function is
	'      called via CallSubDelayed is waiting, then you do a CallSubDelayed with
	'      another one, the previously waiting one gets cancelled and never finishes:
	'       - CallSubDelayed cancels the previous one
	'
	'      The alternative is to directly call the function without CallSubDelayed
	'      then put a short e.g. Sleep(100) call at the start of the function
	'
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Sleeping 100ms via Sleep(100) so that we reschedule our run 100ms later, to wait for Android to be annoying first before correcting its mistakes..."$, Constants.COLORS_ORANGE)
	Sleep(100)
	
	'
	'Now we correct Android by correcting its foolish mistake,
	'with Android being oblivious to having been swiftly corrected
	'
	
	'Restore the last focused element state as it should be, without
	'Android trying to meddle with our preferred focus management
	'
	'But there's a little thing with Android again:
	' - If any of these elements were already selected
	'   and had their focus set to focused,
	'   then the FocusChanged event doesn't fire:
	'
	'   Because Android doesn't fire redundant events for the same
	'   exact states as before (e.g. if the element is already focused)
	'
	' - So after setting the focus on any of these UI elements,
	'   we manually call their FocusChanged events ourselves
	'
	'Notes:
	' - Whenever you restore a focused state, make sure to also
	'   restore the text selection information afterwards as well
	'
	' - You need to send a 'lost focus' event manually to all
	'   other UI elements that were not the last-focused-one
	'
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Preparing a list of unfocused UI elements with all of them at first..."$, Constants.COLORS_ORANGE)
	Dim UnfocusedElementsList As String = "[edtNewPIN]"
	
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Now because we know that the last focused element is ${LastFocusedElement} we exempt this one only"$, Constants.COLORS_ORANGE)
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Removing ${LastFocusedElement} from the list of unfocused ones"$, Constants.COLORS_ORANGE)
	Select LastFocusedElement
		Case "edtNewPIN"
			UnfocusedElementsList = UnfocusedElementsList.Replace("[edtNewPIN]", "")
			
	End Select
	
	'Now UnfocusedElementsList contains only the unfocused UI elements
	'
	'These events will set ViewState_LastFocusedElement to "undetermined"
	'because they got unfocused and think that it will be fixed by the next one's
	'own FocusChanged event, so we do them first
	'
	' - (Although we still have a proper copy of it in as LastFocusedElement parameter)
	'
	'Then we fire the last focused element lastly, which fixes the
	'ViewState_LastFocusedElement value back to proper,
	'thanks to the focused one's FocusChanged event automatically doing it for us
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: We now call the unfocused elements' FocusChanged event Subs manually to report to them their lost focus status..."$, Constants.COLORS_ORANGE)
	If UnfocusedElementsList.Contains("[edtNewPIN]") Then
		LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Manually calling edtNewPIN_FocusChanged(False) to report its lost focus to it"$, Constants.COLORS_ORANGE)
		edtNewPIN_FocusChanged(False)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Again so to say the last focused element is ${LastFocusedElement}, so we proceed to restoring the focused state of this one"$, Constants.COLORS_ORANGE)
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Calling ${LastFocusedElement}.RequestFocus, then manually calling its ${LastFocusedElement}_FocusChanged event Sub and restoring its text selection information..."$, Constants.COLORS_ORANGE)
	Select LastFocusedElement
		Case "edtNewPIN"
			edtNewPIN.RequestFocus
			edtNewPIN_FocusChanged(True) 'Read "little thing with Android" notes for why it's here
			edtNewPIN.SetSelection(ViewState_edtNewPIN_SelectionStart, ViewState_edtNewPIN_SelectionLength)
			
	End Select
	
	'Setting the focus automatically scrolls it, wait until
	'its scrolling is completed before proceeding further
	Common.SynchronousSleep(100, Me, "ForceRestoreCorrectLastFocusedElementState")
	Wait For SynchronousSleep_ForceRestoreCorrectLastFocusedElementState_Completed
	
	'Restore the ViewState last scroll position because as
	'said above the scroll position has been changed to the
	'last focused UI element's position
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Restoring the ViewState last scroll position..."$, Constants.COLORS_ORANGE)
	scvActivity.ScrollPosition = ViewState_LastScrollPosition
	
	LogColor($"[${ActivityName}-${LogContextId}] ForceRestoreCorrectLastFocusedElementState: Sub return"$, Constants.COLORS_ORANGE)
End Sub

Private Sub LockdownNewPINField
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Disabling the Hide New PIN checkbox permanently"$, Colors.Blue)
	chkHideNewPIN.Enabled = False
	
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Registering the Hide New PIN checkbox disabling in the ViewState registers"$, Colors.Blue)
	ViewState_chkHideNewPIN_Enabled = False
	
	'This will fire the CheckedChange event even if
	'the checkbox is actually disabled
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Hiding the New PIN field for security reasons"$, Colors.Blue)
	chkHideNewPIN.Checked = True
	
	'Hide the Lockdown button if it's visible
	'Because it should disappear after Lockdown
	'
	'No need to check for visibility first,
	'if it's already hidden then Android don't
	'actually do the redundant call anyway
	'
	'Note: do this one last, because it's not
	'      a very high priority task to do,
	'      most important ones are the above tasks
	'
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Hiding the New PIN Lockdown button now"$, Colors.Blue)
	btnLockdown.Visible = False
	
	LogColor($"[${ActivityName}-${LogContextId}] LockdownNewPINField: Sub return"$, Colors.Blue)
End Sub

Private Sub Activity_KeyPress(KeyCode As Int) As Boolean
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub entry (KeyCode = ${KeyCode})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Verifying what the KeyCode is"$, Colors.Blue)
	Select Case KeyCode
		Case KeyCodes.KEYCODE_BACK
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_BACK"$, Colors.Blue)
			
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Calling Activity_Exit"$, Colors.Blue)
			Activity_Exit
			
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub return (returning True)"$, Colors.Blue)
			Return True
			
		Case KeyCodes.KEYCODE_HOME
			'This code branch might go too fast for the Basic4Android BridgeLogger to log
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_HOME"$, Colors.Blue)
			
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Hiding the New PIN field on application switching events (Home button press)"$, Colors.Blue)
			chkHideNewPIN.Checked = True
			
		Case Else
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: The KeyCode is something else"$, Colors.Blue)
			LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: We don't do anything particular with other KeyCodes"$, Colors.Blue)
			
	End Select
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_KeyPress: Sub return (returning False)"$, Colors.Blue)
	Return False
	
End Sub

Private Sub Activity_Exit
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Sub entry"$, Colors.Blue)
	
	'Don't accidentally exit the app if direct unblock is in progress
	'And also if the Smartcard service has ongoing operations
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Checking if a Direct Unblock(?) operation is in progress..."$, Colors.Blue)
	If DirectUnblockInProgress Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Direct Unblock(?) is in progress..."$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Show small toast notification about it"$, Colors.Magenta)
		ToastMessageShow($"Direct Unblock in progress...
Please wait until is completes"$, Constants.TOAST_DURATION_SHORT)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Returning early without exiting Activity..."$, Colors.Magenta)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Sub return"$, Colors.Magenta)
		Return
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: No Direct Unblock(?) operation is in progress, alright"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: We can continue to proceed further"$, Colors.Blue)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Stopping this Activity's Lifecycle reset Timer for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Stop
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Resetting the ViewState to clear all input contents etc"$, Colors.Blue)
	ResetViewState
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Hide the New PIN EditText field before finishing this Activity"$, Colors.Blue)
	chkHideNewPIN.Checked = True
	
	'
	'We allow, in exchange of clearing sensitive ViewState registers
	'and UI elements data, to reset the Lockdown state on full Activity finish
	'
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Clear sensitive Public process globals before finishing this Activity"$, Colors.Blue)
	DetectedAdminKey  = ""
	DetectedAlgorithm = Cryptography.ALGORITHM_UNKNOWN
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Clear the New PIN EditText field .Text before finishing this Activity"$, Colors.Blue)
	edtNewPIN.Text = ""
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Clearing some more variables of initialization before finishing this Activity"$, Colors.Blue)
	DetectedCardType     = "Unknown"
	DetectedCardProtocol = "T=?"
	DetectedCardMinPINLength = 0
	DetectedCardMaxPINLength = 0
	DetectedSelectAppletAPDU = ""
	DetectedCardATR          = ""
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Asking the JVM to do a garbage collection as soon as possible"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: This will clear traces of leftover variable contents"$, Colors.Blue)
	Security.TriggerJvmGarbageCollection
	
	'
	'Now it's safe to consider that the next Activity launches
	'for this Direct Unblock Activity are just like a first-launch
	'
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Now it's safe to set IsFirstActivityResume to True for this Activity's next launch in this application lifecycle"$, Colors.Green)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Setting IsFirstActivityResume to True"$, Colors.Green)
	IsFirstActivityResume = True
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Also setting ViewState_chkHideNewPIN_Enabled to True before finishing this Activity"$, Colors.Green)
	ViewState_chkHideNewPIN_Enabled = True
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Starting the Main Activity"$, Colors.Blue)
	StartActivity(Main)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Finishing this Direct Unblock Activity"$, Colors.Blue)
	Activity.Finish
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Exit: Sub return"$, Colors.Blue)
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Sub entry (UserClosed = ${UserClosed})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Updating this Activity's Lifecycle tracking for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.ActivityLifecycle = LifecycleTracking.ActivityLifecycle & LifecycleTracking.PAUSE
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: New Activity lifecycle tracking value: "$&LifecycleTracking.ActivityLifecycle, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Save ViewState"$, Colors.Blue)
	SaveViewState
	
	'
	'Important notice:
	'
	'On Activity pause, we have very little time afforded to us by Android
	'to quickly backup the Activity's ViewState, and while this little time
	'is well enough to backup variable contents and save UI elements' properties,
	'it's definitely not long enough to wait until we *set* UI element properties
	'before proceeding to the ViewState saving:
	' - In such cases, it's already too late:
	'
	'   The Activity got actually paused, and the Activity state is lost,
	'   *except* what Android already backs up by default on its own:
	'    - Such as EditTexts' text contents and checkbox checked states,
	'      but otherwise that's about it; the rest then gets lost
	'
	'      (anything not saved by Android itself in an Instance save Bundle)
	'
	'So that's why the New PIN field is hidden *After* saving the ViewState
	'and updating the Activity lifecycle tracking value
	'
	'It's the only way that we get enough time to save everything before the
	'Activity gets paused, *stopped*, destroyed, started, created & resumed
	'
	'Note: Yes, in Basic4Android Activities are started first then created...
	'
	'TLDR: Don't *set* ANY UI element properties until you've *read* ALL the
	'      UI element properties you need save then put them in
	'      process globals *first*:
	'       - Because while the UI elements will still exist on Activity pause,
	'         their contents & states will shortly be lost as said above
	'
	'      So first do all your properties' reading and only then the
	'      properties writing
	'
	
	'Something to always do first on app pause events:
	'
	'Hide the New PIN text (using the Visible property),
	'before even updating the Lifecycle tracking of this Activity
	'
	'This prevents potential milliseconds-leaks of the
	'new PIN texts in app background pause & resume scenarios
	'
	'It will be set to visible again anyway on app resume
	'This is done before even checking if UserClosed is True or not
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Set the New PIN field visibility to invisible"$, Colors.Blue)
	edtNewPIN.Visible = False
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Check if the Activity is closing for real (check UserClosed parameter)..."$, Colors.Blue)
	If UserClosed Then
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Activity is UserClosed"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: No need to proceed further in this case"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Sub return"$, Colors.Blue)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Activity is not UserClosed"$, Colors.Blue)
	
	'Do the decoy new PIN display here after we make sure that the
	'Activity's pause event is not UserClosed (so UserClosed must be False)
	'
	' - (Otherwise why bother showing it if the Activity will fully finish anyway)
	'
	'Show the decoy new PIN field during application pauses
	'
	'It's used for hiding the new PIN field with explanation about
	'why it's hidden, so that users know that it's not a bug
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Set the decoy New PIN field visibility to Visible"$, Colors.Blue)
	edtDecoyPIN.Visible = True
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Starting this Activity's Lifecycle reset Timer for foreground rotation detection"$, Colors.Blue)
	LifecycleTracking.LifecycleClearingThread_Start
	
	LogColor($"[${ActivityName}-${LogContextId}] Activity_Pause: Sub return"$, Colors.Blue)
End Sub

Private Sub SaveViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Sub entry"$, Colors.Blue)
	
	'The Select PIN label is always dynamically re-generated anyway
	
	'The last-selected PIN identifier is saved in realtime already
	
	'The New PIN label is always dynamically re-generated anyway
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Saving New PIN field .Text"$, Colors.Blue)
	ViewState_edtNewPIN_Text = edtNewPIN.Text
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Saving New PIN field .Selection state"$, Colors.Blue)
	ViewState_edtNewPIN_SelectionStart  = edtNewPIN.SelectionStart
	ViewState_edtNewPIN_SelectionLength = edtNewPIN.SelectionLength
	
	'The Hide New PIN checkbox's .Checked is saved in realtime
	'in its own respective CheckedChanged event handler
	
	'The Admin Key label is always dynamically re-generated anyway
	
	'Last focused element is always saved in realtime in their
	'own respective FocusChanged event handlers
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Saving the ScrollView's last scroll position"$, Colors.Blue)
	ViewState_LastScrollPosition = scvActivity.ScrollPosition
	
	'The last UI elements enabled state is already saved in realtime
	'by the SetUiElementsEnabledState function
	
	LogColor($"[${ActivityName}-${LogContextId}] SaveViewState: Sub return"$, Colors.Blue)
End Sub

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'UI element events
'

'Helper function
Private Sub SetUiElementsEnabledState(TrueOrFalse As Boolean)
	'
	'Save the last SetUiElementsEnabledState's TrueOrFalse parameter
	'in the ViewState registers, so that if the screen rotates,
	'even during direct unblock, the elements still get restored as
	'the last disabled state that was used in the last function call
	'
	ViewState_SetUiElementsEnabledState_TrueOrFalse = TrueOrFalse
	
	rdoPrimaryPIN.Enabled = TrueOrFalse
	
	'These are already disabled if the card isn't a Gemalto one,
	'and we don't re-enable them for non-Gemalto cards
	If DetectedCardType == "Gemalto" Then
		'Only the Gemalto PKI smartcards have these additional roles
		rdoRole3.Enabled      = TrueOrFalse
		rdoRole4.Enabled      = TrueOrFalse
		rdoRole5.Enabled      = TrueOrFalse
		rdoRole6.Enabled      = TrueOrFalse
		rdoRole7.Enabled      = TrueOrFalse
		
	End If
	
	edtNewPIN.Enabled = TrueOrFalse
	
	'Don't affect the chkHideNewPIN enabled state
	'if it was already locked-down before
	If ViewState_chkHideNewPIN_Enabled Then
		chkHideNewPIN.Enabled = TrueOrFalse
		
		'We put this one here because if the Lockdown
		'has already happened then no need to bother
		'with processing a button that already got
		'hidden entirely to begin with
		'
		'Lockdown = Permanently hiding the New PIN field until
		'           next Activity instance launch (reload)
		'
		btnLockdown.Enabled = TrueOrFalse
		
	End If
	
	btnProceedToUnblock.Enabled = TrueOrFalse
	
End Sub

'Small helper function to avoid having to rewrite
'this function code multiple times in the code
Private Sub btnProceedToUnblock_GetDialogHeader(DeviceHasUsbOtg As Boolean) As CSBuilder
	
	Dim DirectUnblockInfoText As CSBuilder
	DirectUnblockInfoText.Initialize
	
	DirectUnblockInfoText.Bold
	DirectUnblockInfoText.Append(Application.LabelName&CRLF)
	DirectUnblockInfoText.Pop
	DirectUnblockInfoText.RelativeSize(0.9)
	If DeviceHasUsbOtg Then
		DirectUnblockInfoText.Append("Direct unblock over USB-OTG"&CRLF)
	Else
		DirectUnblockInfoText.Append("Device has no USB-OTG support"&CRLF)
	End If
	DirectUnblockInfoText.PopAll
	
	DirectUnblockInfoText.Append(CRLF)
	DirectUnblockInfoText.PopAll
	
	Return DirectUnblockInfoText
	
End Sub

Private Sub btnProceedToUnblock_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Sub entry"$, Colors.Blue)
	
	'Don't allow clicking the Proceed To Unblock button
	'if there's already another unblock operation in progress
	LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Checking if a Direct Unblock(?) operation is in progress..."$, Colors.Blue)
	If DirectUnblockInProgress Then
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Ongoing direct unblock already in progress, returning early..."$, Colors.Magenta)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Sub return"$, Colors.Magenta)
		Return
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: No Direct Unblock(?) operation is in progress, alright"$, Colors.Blue)
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: We can continue to proceed further"$, Colors.Blue)
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Get the USB OTG support status of this device..."$, Colors.Blue)
	Dim DeviceHasUsbOtg As Boolean = joActivity.RunMethod("jDeviceHasUsbOtgSupport", Null)
	
	Dim DirectUnblockInfoText As CSBuilder
	Dim DirectUnblockIcon     As Bitmap = Application.Icon
	Dim SquareIcoSize         As Int    = Common.GetSquareIconSizeForDisplayScale
	
	If DirectUnblockIcon.Height <> SquareIcoSize Then
		DirectUnblockIcon = DirectUnblockIcon.Resize(SquareIcoSize, SquareIcoSize, Constants.BITMAP_RESIZE_KEEP_ASPECT_RATIO)
	End If
	
	If Not(DeviceHasUsbOtg) Then
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Device has no USB-OTG function, displaying an error dialog..."$, Colors.Magenta)
		DirectUnblockInfoText = btnProceedToUnblock_GetDialogHeader(DeviceHasUsbOtg)
		
		DirectUnblockInfoText.Append("Direct unblocking of smartcard PINs requires a device with USB-OTG support but your device claimed that it doesn't support it.")
		DirectUnblockInfoText.PopAll
		
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: The device does not support USB-OTG, displaying an operation abort message"$, Colors.Magenta)
		Msgbox2Async(DirectUnblockInfoText, "Direct Unblock", Constants.MSGBOX_HIDE_POSITIVE, "Close", Constants.MSGBOX_HIDE_NEGATIVE, DirectUnblockIcon, Constants.MSGBOX_CANCELLABLE)
		
		Wait For Msgbox_Result(Result As Int)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	
	Dim UserProvidedNewPIN       As String = edtNewPIN.Text
	Dim UserSelectedPinID        As Int    = ViewState_LastSelectedPIN
	Dim UserProvidedNewPINLength As Int    = UserProvidedNewPIN.Length
	
	'Check if the provided new PIN fits within the required length limits
	If UserProvidedNewPINLength < DetectedCardMinPINLength Or UserProvidedNewPINLength > DetectedCardMaxPINLength Then
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: The provided new PIN is not within the length restrictions, displaying an error dialog..."$, Colors.Magenta)
		DirectUnblockInfoText = btnProceedToUnblock_GetDialogHeader(DeviceHasUsbOtg)
		
		DirectUnblockInfoText.Append($"The new PIN you provided is not within the required length constraints of being atleast ${DetectedCardMinPINLength} chars and not being more than ${DetectedCardMaxPINLength} chars."$)
		DirectUnblockInfoText.PopAll
		
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: displaying the operation abort message"$, Colors.Magenta)
		Msgbox2Async(DirectUnblockInfoText, "Direct Unblock", Constants.MSGBOX_HIDE_POSITIVE, "Close", Constants.MSGBOX_HIDE_NEGATIVE, DirectUnblockIcon, Constants.MSGBOX_CANCELLABLE)
		
		Wait For Msgbox_Result(Result As Int)
		
		LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	
	'Now there's an active Direct Unblock operation in progress
	DirectUnblockInProgress = True
	
	'Disable all this Activity's UI elements
	SetUiElementsEnabledState(False)
	
	'--------------------------------------------------------------------------------
	'Set the Activity to always keep the screen on during the process
	'
	'This helps avoid Android suspending the USB port when the screen is
	'turned off or its brightness gets dimmed
	joActivity.RunMethod("jSetKeepScreenOn", Null)
	
	'--------------------------------------------------------------------------------
	'
	'Hide the New PIN field during the PIN unblock, because I currently don't do it
	'in a separate thread, so the Activity's View might look visually frozen with
	'the New PIN still visible on it
	'
	'In order to mitigate this (having the key visually seen for too long)
	'I always hide the New PIN field before proceeding to sending APDUs
	'
	chkHideNewPIN.Checked = True
	
	'Wait 100ms until the New PIN field is surely hidden by now
	Common.SynchronousSleep(100, Me, "btnProceedToUnblock_Click")
	Wait For SynchronousSleep_btnProceedToUnblock_Click_Completed
	
	'--------------------------------------------------------------------------------
	
	DirectUnblockThread.Start(Me, "SendPinUnblockAPDUSequence", Array(DetectedAdminKey, DetectedAlgorithm, DetectedCardType, DetectedSelectAppletAPDU, DetectedCardATR, UserProvidedNewPIN, UserSelectedPinID))
	Wait For btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed(IsSuccessful As Boolean, ErrorIfAny As String)
	
	'Direct Unblock operation completed (either successfully or failed)
	DirectUnblockInProgress = False
	
	'Re-enable all this Activity's UI elements
	'Has built-in checks against re-enabling chkHideAdminKey after locking it down
	SetUiElementsEnabledState(True)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Requesting a JVM garbage collection to discard the sensitive variable contents as soon as possible"$, Colors.Blue)
	Security.TriggerJvmGarbageCollection
	
	'Set the Activity back to normal (clear the FLAG_KEEP_SCREEN_ON flag)
	joActivity.RunMethod("jClearKeepScreenOn", Null)
	
	DirectUnblockInfoText = btnProceedToUnblock_GetDialogHeader(DeviceHasUsbOtg)
	
	If IsSuccessful Then
		'
		'Now we tell the user about the successful PIN unblock operation,
		'and what their new PIN code is whatever they chose
		'
		ToastMessageShow("New PIN was successfully set", Constants.TOAST_DURATION_LONG)
		
		DirectUnblockInfoText.Append($"Smartcard ${GetSelectedPINAsName(UserSelectedPinID)} unblocked successfully!

Your new ${GetSelectedPINAsName(UserSelectedPinID)} code is now "$)
		DirectUnblockInfoText.Bold
		DirectUnblockInfoText.Append("the new PIN you provided")
		DirectUnblockInfoText.Pop 'Pop the Bold node
		DirectUnblockInfoText.Append(".")
		DirectUnblockInfoText.PopAll
		
		Msgbox2Async(DirectUnblockInfoText, "Direct Unblock", "Close", Constants.MSGBOX_HIDE_CANCEL, Constants.MSGBOX_HIDE_NEGATIVE, DirectUnblockIcon, Constants.MSGBOX_CANCELLABLE)
		
	Else
		DirectUnblockInfoText.Append(ErrorIfAny)
		DirectUnblockInfoText.PopAll
		
		Msgbox2Async(DirectUnblockInfoText, "Direct Unblock", Constants.MSGBOX_HIDE_POSITIVE, Constants.MSGBOX_HIDE_CANCEL, "Close", DirectUnblockIcon, Constants.MSGBOX_CANCELLABLE)
		
	End If
	
	Wait For Msgbox_Result(Result As Int)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnProceedToUnblock_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub SendPinUnblockAPDUSequence(AdminKey As String, Algorithm As String, CardType As String, SelectAppletAPDU As String, CardATR As String, NewPIN As String, PinIdentifier As Int)
	
	'-----                                         CLA (80 = Proprietary / Management)
	'                                              |  Command (INS)
	'                                              |  |
	'                                              |  |  P1 P2
	'                                              |  |  |  |
	Dim GET_CHALLENGE_GENERIC         As String = "80 84 00 00"
	
	'-----                                         CLA (80 = Proprietary / Management, 00 = ISO-7816)
	'                                              |  Command (INS)
	'                                              |  |
	'                                              |  |  P1 P2 (31 = Key ID, Gemalto)
	'                                              |  |  |  |
	Dim EXTERNAL_AUTHENTICATE_GEMALTO As String = "00 82 00 31"
	'                                              |  |
	'                                              |  |  P1     P2 (11 = User PIN, 8X = Role #X, Gemalto)
	'                                              |  |  |      |
	Dim SET_REFERENCE_DATA_GEMALTO    As String = "80 2C 90 " & GetSelectedPINAsGemaltoByteString(PinIdentifier)
	'                                              |  |
	'                                              |  |  P1 (FF = Logout)
	'                                              |  |  |  P2 (31 = Key ID, Gemalto)
	'                                              |  |  |  |
	Dim EXTERNAL_AUTH_LOGOUT_GEMALTO  As String = "00 82 FF 31"
	
	'-----                                         CLA (80 = Proprietary / Management)
	'                                              |  Command (INS)
	'                                              |  |
	'                                              |  |  P1 P2 (01 = Key ID, ActivID)
	'                                              |  |  |  |
	Dim EXTERNAL_AUTHENTICATE_ACTIVID As String = "80 82 00 01"
	'                                              |  |
	'                                              |  |  P1 P2 (02 00 = User PIN, ActivID)
	'                                              |  |  |  |
	Dim SET_REFERENCE_DATA_ACTIVID    As String = "80 2C 02 00"
	
	'--------------------------------------------------------------------------------
	'
	'Reusable variables for all APDU requests
	'
	Dim CallerBundle() As Object
	Dim LastSentAPDU   As String
	
	'--------------------------------------------------------------------------------
	'Check if we have the same smartcard model still plugged-in (check ATR)
	'Otherwise the user has to go back to the Main Activity to reload this one
	
	'CallerBundle(0) = Caller       - Object
	'CallerBundle(1) = SubName      - String
	'CallerBundle(2) = Parameters() - Object()
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object() _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.GET_ATR, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	
	If IsSucessful == False Then
		
		'Tell the btnProceedToUnblock_Click function that the task is completed (failure)
		' - IsSuccessful = False
		' - ErrorIAny    = (error message)
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to get the smartcard's ATR!

Cannot verify that the same PKI smartcard model is still plugged-in the smartcard reader.

[Received]
${ResponseBundle(0)}"$)
		Return
		
	End If
	
	'The smartcard ATR will be in ResponseBundle(0) (as String)
	If ResponseBundle(0) <> CardATR Then
		
		'Tell the btnProceedToUnblock_Click function that the task is completed (failure)
		' - IsSuccessful = False
		' - ErrorIAny    = (error message)
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"The smartcard isn't the same model as the previously connected one!

When you use a different smartcard model, you have to go back to the Main Activity then reload this page.

[Previous card ATR]
${CardATR}

[Current card ATR]
${ResponseBundle(0)}"$)
		Return
		
	End If
	
	'--------------------------------------------------------------------------------
	'
	'Try selecting the last PKI Applet ID
	'
	LastSentAPDU = SelectAppletAPDU
	
	'CallerBundle(0) = Caller       - Object
	'CallerBundle(1) = SubName      - String
	'CallerBundle(2) = Parameters() - Object()
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object( _
			LastSentAPDU _
		) _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	'
	'Check whether both applet IDs were not found
	'If no PKI applet was found then we can't proceed further
	'
	If IsSucessful == False Then
		
		'Tell the btnProceedToUnblock_Click function that the task is completed (failure)
		' - IsSuccessful = False
		' - ErrorIAny    = (error message)
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to select the last PKI applet ID!

[Sent APDU]
${CardType} Applet ID:
${LastSentAPDU}

[Received]
The smartcard could not find the PKI applet we searched for"$&".")
		Return
		
	End If
	
	'--------------------------------------------------------------------------------
	If Algorithm == Cryptography.ALGORITHM_2DES	_
	Or Algorithm == Cryptography.ALGORITHM_3DES	Then
		LastSentAPDU = GET_CHALLENGE_GENERIC & " 08" 'Request a challenge code of 8 bytes (0x08 bytes)
		
	Else If Algorithm == Cryptography.ALGORITHM_AES128 _
	Or      Algorithm == Cryptography.ALGORITHM_AES256 Then
		LastSentAPDU = GET_CHALLENGE_GENERIC & " 10" 'Request a challenge code of 16 bytes (0x10 bytes)
		
	End If
	
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object( _
			LastSentAPDU _
		) _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	
	If IsSucessful == False Then
		
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to request a ${DetectedAlgorithm} challenge code!

[Sent APDU]
${LastSentAPDU}

[Received]
${ResponseBundle(0)}"$)
		Return
		
	End If
	
	'--------------------------------------------------------------------------------
	
	Dim SmartcardChallengeCode As String = Null
	Dim SmartcardResponseCode  As String = Null
	
	Try
		If Algorithm == Cryptography.ALGORITHM_2DES	_
		Or Algorithm == Cryptography.ALGORITHM_3DES	Then
			'2DES / 3DES
			SmartcardChallengeCode = ResponseBundle(0).As(String).SubString2(0, 16) '16 chars = 8 bytes
			SmartcardResponseCode  = Cryptography.TripleDesEncrypt(SmartcardChallengeCode, AdminKey)
			
		Else If Algorithm == Cryptography.ALGORITHM_AES128 _
		Or      Algorithm == Cryptography.ALGORITHM_AES256 Then
			'AES-128 / AES-256
			SmartcardChallengeCode = ResponseBundle(0).As(String).SubString2(0, 32) '32 chars = 16 bytes
			SmartcardResponseCode  = Cryptography.AesEncrypt(SmartcardChallengeCode, AdminKey)
			
		End If
	Catch
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to generate a Response code locally on this device!

[Algorithm]
${Algorithm} / ECB / NoPadding

[Challenge]
${SmartcardChallengeCode}

[Exception]
${LastException.Message}"$)
		Return
		
	End Try
	
	'--------------------------------------------------------------------------------
	'Clear the last-sent APDU just incase no PKI applet ID matches
	LastSentAPDU = Null
	
	If CardType == "Gemalto" Then
		'Specific to Gemalto PKI smartcards
		LastSentAPDU = EXTERNAL_AUTHENTICATE_GEMALTO
		
	Else If CardType == "ActivID" Then
		'Specific to ActivID PKI smartcards
		LastSentAPDU = EXTERNAL_AUTHENTICATE_ACTIVID
		
	End If
	
	If Algorithm == Cryptography.ALGORITHM_2DES	_
	Or Algorithm == Cryptography.ALGORITHM_3DES	Then
		'2DES / 3DES (data length 0x08)
		LastSentAPDU = LastSentAPDU & " 08 " & SmartcardResponseCode
		
	Else If Algorithm == Cryptography.ALGORITHM_AES128 _
	Or      Algorithm == Cryptography.ALGORITHM_AES256 Then
		'AES-128 / AES-256 (data length 0x10)
		LastSentAPDU = LastSentAPDU & " 10 " & SmartcardResponseCode
		
	End If
	
	If CardType == "ActivID" Then
		'Specific to ActivID PKI smartcards
		LastSentAPDU = LastSentAPDU & " 00" 'Le is set to 00 for ActivID PKI smartcards
		
	End If
	
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object( _
			LastSentAPDU _ 'Send EXTERNAL AUTHENTICATE request APDU
		) _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	
	If IsSucessful == False Then
		
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to perform EXTERNAL AUTHENTICATE with generated Response code!

[Algorithm]
${Algorithm} / ECB / NoPadding

[Challenge]
${SmartcardChallengeCode}

[Response]
${SmartcardResponseCode}

[Sent APDU]
${LastSentAPDU}

[Received]
${ResponseBundle(0)}"$)
		Return
		
	End If
	
	'--------------------------------------------------------------------------------
	'Clear the last-sent APDU just incase no PKI applet ID matches
	LastSentAPDU = Null
	
	' - Many smartcards have a minimum PIN requirement of 4 characters
	' - Some smartcards also have a PIN policy that only allows digits
	' - PKI smartcards should allow up to 16 and even 64 characters,
	'   but it's not guaranteed that it's what the card owner actually allows
	'
	Dim NewPINLength        As Int
	Dim NewPINLengthHexByte As String
	
	If CardType == "Gemalto" Then
		'
		'Specific to Gemalto PKI smartcards
		'
		'Note: Gemalto PKI smartcards expect you to give a new
		'      PIN Try Count for the PIN you want to unblock,
		'      you can choose any from 1 to 15 (0x01 to 0x0F)
		'
		'Note: Gemalto PKI smartcards don't need any padding
		'      for the new PIN, even if it's smaller than 8 bytes
		'
		NewPINLength = NewPIN.Length + 1 'Add 1 for the New PIN Try Count
		NewPIN       = Cryptography.StringToASCIIHex(NewPIN) 'Reuse the NewPIN variable
		
		'You can send a raw number to NumberToStringHex
		'Then if you give it e.g. 15, it returns "0F"
		NewPINLengthHexByte = Cryptography.NumberToStringHex(NewPINLength)
		
		'                                               Lc (Length: New PIN Try Count + New PIN)
		'                                               |                      New PIN Try Count (3 tries, 1 byte)
		'                                               |                      |    New PIN (in ASCII Hex)
		'                                               |                      |    |
		LastSentAPDU = SET_REFERENCE_DATA_GEMALTO &" "& NewPINLengthHexByte &" 03 "&NewPIN 'No Le is set
		
	Else If CardType == "ActivID" Then
		'
		'Specific to ActivID PKI smartcards
		'
		'Note: the new PIN data length must be atleast 8 bytes,
		'      if the PIN is shorter then you must pad it with 0xFF bytes
		'      until it reaches 8 bytes (must be atleast 8 bytes or more)
		'
		NewPIN = Cryptography.StringToASCIIHex(NewPIN) 'Reuse the NewPIN variable
		
		If NewPIN.Length < (8 * 2) Then      'Check if we need to add padding (8 bytes = 16 chars)
			Do While NewPIN.Length < (8 * 2) 'Add necessary 0xFF padding
				NewPIN = NewPIN & "FF"
				
			Loop
			
		End If
		
		NewPINLength = (NewPIN.Length / 2).As(Int) 'Back to a bytes count instead of chars count
		
		'You can send a raw number to NumberToStringHex
		'Then if you give it e.g. 15, it returns "0F"
		NewPINLengthHexByte = Cryptography.NumberToStringHex(NewPINLength)
		
		'                                               Lc (Length: New PIN + padding if any, atleast 8 bytes)
		'                                               |                         New PIN (in ASCII Hex)
		'                                               |                         |
		'                                               |                         |         Le is set to 00
		'                                               |                         |         |
		LastSentAPDU = SET_REFERENCE_DATA_ACTIVID &" "& NewPINLengthHexByte &" "& NewPIN &" 00"
		
	End If
	
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object( _
			LastSentAPDU _ 'Send SET REFERENCE DATA APDU for the selected PIN
		) _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	
	If IsSucessful == False Then
		'
		'Remember then when new PINs will be user-defined,
		'you will have to never disclose what the APDU data was
		'
		'(Showing only generic info such as 'The Gemalto SET_REFERENCE_DATA APDU for the new PIN failed'
		'
		CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", False, $"Failed to perform SET REFERENCE DATA with the provided new PIN value (sensitive parameter)!

[Sent APDU]
SET_REFERENCE_DATA for ${CardType}

[Received]
${ResponseBundle(0)}"$)
		Return
		
	End If
	
	'--------------------------------------------------------------------------------
	'At this point the job is done, the rest is just informal APDU requests that
	'I saw being used by the Gemalto MiniDriver Manager
	'
	'They're probably not needed but just incase I want to fully replicate
	'the exact behavior of Gemalto MiniDriver Manager, by doing exactly
	'what it does with its smartcard PIN unblock APDU sequences
	'
	'And because it's now informal APDU requests, we just ignore any 'errors' here
	'If any 'error' happens, it's simply just a common warning from the smartcard
	'that you would happen anyway even if you used an established & popular CMS / SCMS
	
	'--------------------------------------------------------------------------------
	'Clear the last-sent APDU just incase no PKI applet ID matches
	LastSentAPDU = Null
	
	'ActivID PKI smartcards only support logout using
	'SELECT FILE request APDU (selecting the PKI applet again)
	'to clear the authenticated state
	If CardType == "Gemalto" Then
		'
		'Specific to Gemalto PKI smartcards
		'
		LastSentAPDU = EXTERNAL_AUTH_LOGOUT_GEMALTO
		
		If DetectedAlgorithm == Cryptography.ALGORITHM_2DES	_
		Or DetectedAlgorithm == Cryptography.ALGORITHM_3DES	Then
			'2DES / 3DES (data length 0x08)
			LastSentAPDU = LastSentAPDU & " 08 " & "00 00 00 00 00 00 00 00"
			
		Else If DetectedAlgorithm == Cryptography.ALGORITHM_AES128 _
		Or      DetectedAlgorithm == Cryptography.ALGORITHM_AES256 Then
			'AES-128 / AES-256 (data length 0x10)
			LastSentAPDU = LastSentAPDU & " 10 " & "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
			
		End If
		
		CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
			Array As Object( _
				LastSentAPDU _ 'Send EXTERNAL AUTHENTICATE (LOGOUT) request APDU
			) _
		)
		CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
		Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
		
	End If
	
	'--------------------------------------------------------------------------------
	
	LastSentAPDU = SelectAppletAPDU 'Select last PKI Applet ID again (to 'logout' again / reset logged-in status)
	
	CallerBundle = Array As Object(Me, "SendPinUnblockAPDUSequence", _
		Array As Object( _
			LastSentAPDU _
		) _
	)
	CallSubDelayed3(Smartcard, "Service_Message", Smartcard.SEND_APDU, CallerBundle)
	Wait For Smartcard_SendPinUnblockAPDUSequence_Completed(IsSucessful As Boolean, ResponseBundle() As Object)
	
	'--------------------------------------------------------------------------------
	
	'Tell the btnProceedToUnblock_Click function that the task is completed (success)
	' - IsSuccessful = True
	' - ErrorIAny    = (empty string)
	CallSubDelayed3(Me, "btnProceedToUnblock_Click_SendPinUnblockAPDUSequence_Completed", True, "")
	
End Sub

'
'Selected PIN management functions
'

Private Sub SetSelectedPIN(PinIdentifier As Int)
	
	Dim PinIDToRadioButtonMap() As RadioButton = Array As RadioButton( _
		Null, _          '0 = Null
		rdoPrimaryPIN, _ '1 = Primary PIN
		Null, _          '2 = Null
		rdoRole3, _      '3 = Role #3
		rdoRole4, _      '4 = Role #4
		rdoRole5, _      '5 = Role #5
		rdoRole6, _      '6 = Role #6
		rdoRole7 _       '7 = Role #7
	)
	
	If PinIdentifier < 1 Or PinIdentifier > 7 Or PinIdentifier == 2 Then
		'Ignore invalid PIN identifiers (return early)
		Return
		
	End If
	
	PinIDToRadioButtonMap(PinIdentifier).Checked = True
	
End Sub

Private Sub GetSelectedPINAsName(PinIdentifier As Int) As String
	
	Dim PinIDToPINNameMap() As String = Array As String( _
		Null, _          '0
		"Primary PIN", _ '1
		Null, _          '2 (actually SO PIN but not supported)
		"Role #3", _     '3
		"Role #4", _     '4
		"Role #5", _     '5
		"Role #6", _     '6
		"Role #7" _      '7
	)
	
	If PinIdentifier < 1 Or PinIdentifier > 7 Or PinIdentifier == 2 Then
		'Ignore invalid PIN identifiers (return early)
		Return "Unknown"
		
	End If
	
	Return PinIDToPINNameMap(PinIdentifier)
	
End Sub

Private Sub GetSelectedPINAsGemaltoByteString(PinIdentifier As Int) As String
	
	Dim PinIDToGemaltoByteStringMap() As String = Array As String( _
		Null, _ '0
		"11", _ '1 (Primary PIN)
		Null, _ '2 (actually SO PIN but not supported for Admin key change)
		"83", _ '3 (Role #3)
		"84", _ '4 (Role #4)
		"85", _ '5 (Role #5)
		"86", _ '6 (Role #6)
		"87" _  '7 (Role #7)
	)
	
	If PinIdentifier < 1 Or PinIdentifier > 7 Or PinIdentifier == 2 Then
		'Ignore invalid PIN identifiers (return early)
		Return "11"
		
	End If
	
	Return PinIDToGemaltoByteStringMap(PinIdentifier)
	
End Sub

'
'Other UI elements' functions
'

'
'-----
'
Private Sub rdoAnyPIN_CheckedChange_Helper(Checked As Boolean, PinIdentifier As Int)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoAnyPIN_CheckedChange_Helper: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	If Not(Checked) Then
		LogColor($"[${ActivityName}-${LogContextId}] rdoAnyPIN_CheckedChange_Helper: Sub return (early, Checked = ${Checked})"$, Colors.Blue)
		Return
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoAnyPIN_CheckedChange_Helper: Set ViewState_LastSelectedPIN = ${PinIdentifier}"$, Colors.Blue)
	ViewState_LastSelectedPIN = PinIdentifier
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoAnyPIN_CheckedChange_Helper: Sub return"$, Colors.Blue)
End Sub
'
'-----
'
Private Sub rdoPrimaryPIN_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoPrimaryPIN_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoPrimaryPIN_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 1)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 1)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoPrimaryPIN_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub rdoRole3_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole3_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole3_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 3)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 3)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole3_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub rdoRole4_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole4_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole4_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 4)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 4)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole4_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub rdoRole5_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole5_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole5_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 5)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 5)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole5_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub rdoRole6_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole6_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole6_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 6)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 6)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole6_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub rdoRole7_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole7_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole7_CheckedChange: Calling rdoAnyPIN_CheckedChange_Helper(Checked = ${Checked}, PinIdentifier = 7)"$, Colors.Blue)
	rdoAnyPIN_CheckedChange_Helper(Checked, 7)
	
	LogColor($"[${ActivityName}-${LogContextId}] rdoRole7_CheckedChange: Sub return"$, Colors.Blue)
End Sub
'
'-----
'
Private Sub edtNewPIN_FocusChanged(HasFocus As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: Sub entry (HasFocus = ${HasFocus})"$, Colors.Blue)
	
	If HasFocus Then
		LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: HasFocus is True"$, Colors.Blue)
		
		LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: Set ViewState last focused element to "edtNewPIN""$, Colors.Blue)
		ViewState_LastFocusedElement = "edtNewPIN"
		
	Else
		LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: HasFocus is False"$, Colors.Blue)
		
		'Android doesn't reset the selection information of
		'EditText fields when the focus is lost
		'
		'So the EditText selection timers call their respective
		'EditText_ShowSelectionInfo method but these functions
		'think that the their EditText selection didn't change
		'
		'To fix this, I just forewarn that the last focused
		'element is "undetermined" and the EditTexts'
		'respective EditText_ShowSelectionInfo methods will
		'verify that their element still has the focus
		'thanks to this forewarning being done in advance
		LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: Set ViewState last focused element to "undetermined" (will be set again properly by the next focused element)"$, Colors.Blue)
		ViewState_LastFocusedElement = "undetermined"
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: Correct the scroll position to be better than Android's default scrolling to focused elements"$, Colors.Blue)
	scvActivity.ScrollPosition = rdoRole6.Top + rdoRole6.Height
	
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_FocusChanged: Sub return"$, Colors.Blue)
End Sub

Private Sub edtNewPIN_TextChanged(Old As String, New As String)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_TextChanged: Sub entry (sensitive parameters)"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_TextChanged: Running the edtNewPIN_ShowSelectionInfo Sub to update the New PIN label text"$, Colors.Blue)
	edtNewPIN_ShowSelectionInfo
	
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_TextChanged: Sub return"$, Colors.Blue)
End Sub

Private Sub edtNewPIN_ShowSelectionInfo
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_ShowSelectionInfo: Sub entry"$, Colors.Blue)
	
	Dim NewPINLength As Int    = edtNewPIN.Text.Length
	Dim chars        As String = " "
	
	If NewPINLength >= 1 Then
		chars = $" (${NewPINLength} char"$
		If NewPINLength > 1 Then
			chars = chars&"s) - "
		Else
			chars = chars&") - "
		End If
	End If
	
	lblNewPIN.Text = $"New PIN:${chars}Min: ${DetectedCardMinPINLength} | Max: ${DetectedCardMaxPINLength}"$
	
	LogColor($"[${ActivityName}-${LogContextId}] edtNewPIN_ShowSelectionInfo: Sub return"$, Colors.Blue)
End Sub

Private Sub chkHideNewPIN_CheckedChange(Checked As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Sub entry (Checked = ${Checked})"$, Colors.Blue)
	
	If Checked Then
		'The Hide Admin Key Checkbox is checked
		'Its .Hint should also display bullet dots too
		
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Set the New PIN field .Hint (not .Text) to show bullets characters because Checked is True"$, Colors.Blue)
		edtNewPIN.Hint = DEFAULT_BULLETS_NEW_PIN
		
	Else
		'The Hide Admin Key Checkbox is unchecked
		'Its .Hint cans now display the default Admin Key zeroes
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Set the New PIN field .Hint (not .Text) to show zeroes characters because Checked if False"$, Colors.Blue)
		edtNewPIN.Hint = DEFAULT_YYYYMM_NEW_PIN
		
	End If
	
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Verifying if the Admin Key was made unrevealable before and the requested .Checked state is False"$, Colors.Blue)
	If Not(ViewState_chkHideNewPIN_Enabled) And Not(Checked) Then
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: We have a problem, looks like the Hide Admin Key checkbox was forcibly re-enabled using hacks"$, Colors.Red)
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: This might be a forensic New PIN recovery attack"$, Colors.Red)
		
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: We don't allow proceeding further (return early)"$, Colors.Red)
		
		LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Sub return"$, Colors.Red)
		Return
		
	End If
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: All good, the caller isn't trying to reveal an unrevealable New PIN"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: The requested Checked value is ${Checked}"$, Colors.Blue)
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Set ViewState of this checkbox checked state to ${Checked}"$, Colors.Blue)
	ViewState_chkHideNewPIN_Checked = Checked
	
	'Allow preserving the selection state when toggling password modes
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Saving information about the current selection state before toggling password modes"$, Colors.Blue)
	Dim LastSelectionStart, LastSelectionLength As Int
	LastSelectionStart  = edtNewPIN.SelectionStart
	LastSelectionLength = edtNewPIN.SelectionLength
	
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Setting the New PIN field password mode to PasswordMode = ${Checked}"$, Colors.Blue)
	edtNewPIN.PasswordMode = Checked
	
	'Allow preserving the selection state when toggling password modes
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Restoring information about the previous selection state after toggling password modes"$, Colors.Blue)
	edtNewPIN.SetSelection(LastSelectionStart, LastSelectionLength)
	
	LogColor($"[${ActivityName}-${LogContextId}] chkHideNewPIN_CheckedChange: Sub return"$, Colors.Blue)
End Sub

Private Sub btnLockdown_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_Click: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_Click: This is a single-click, so display a short toast notification about how to use this button"$, Colors.Blue)
	ToastMessageShow("Make New PIN unrevealable by long-pressing this button", Constants.TOAST_DURATION_SHORT)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub btnLockdown_LongClick
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_LongClick: Sub entry"$, Colors.Blue)
	
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_LongClick: Locking down the New PIN field (making it unrevealable)"$, Colors.Blue)
	LockdownNewPINField
	
	LogColor($"[${ActivityName}-${LogContextId}] btnLockdown_LongClick: Sub return"$, Colors.Blue)
End Sub


