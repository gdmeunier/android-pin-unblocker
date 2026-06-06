B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=12
@EndOfDesignText@
#Region  Project Attributes 
	'Ignore function value returns warning (2)
	'Ignore return value is missing warning (4)
	#IgnoreWarnings: 2,4
#End Region

#Region  Activity Attributes 
	#FullScreen:   False
	#IncludeTitle: True
#End Region

'
' Needed libraries:
' - https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013
' - https://www.b4x.com/android/forum/threads/clipboard-library.7382/
'

Sub Process_Globals
	'These variables can be accessed from all modules.
	'
	
	'For using and running Java functions
	Private NativeMe2 As JavaObject
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	Try
		Private qrReaderView As NewQRCodeReaderView
	Catch
		Log(LastException)
		
		'Display the error dialog
		DisplayCameraErrorDialog
		
		'Return to the Main module as if the user pressed the back key
		btnBack_Click
	End Try
	
	Private btnSwitchCam   As Button
	Private btnToggleFlash As Button
	
	Private btnBack As Button
	
	Private isBackCamera  As Boolean
	Private isTorchOn     As Boolean
	
	'Avoid trying to start the Camera twice when creating
	'the Activity for a faster Camera start.
	Private isCameraAlreadyStarted As Boolean
	
End Sub

'
'I now added an easy switch (conditional symbol) to easily allow
'taking screenshots of the App, such as if you need to make demo
'screenshots, to report a bug with pictures, or simply don't need
'the higher-security Admin key anti-leak protection.
'
#If JAVA
//
// Must be before Activity_Create in order to work
//

//
// Add ability to hide the Title bar / Action bar
// on devices with a very low display scale
// such as 0.75 (120dpi/ldpi).
//
import android.view.Window;
import android.app.Activity; // requestWindowFeature() & getActionBar()
import android.app.ActionBar; // ActionBar object

//
// Adding FLAG_SECURE support to this App to avoid
// leaking Admin keys in Recent Apps thumbnails.
//
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;

#End If

Sub Activity_Create(FirstTime As Boolean)
	
	Activity.LoadLayout("ScanLayout")
	Activity.Title = Application.LabelName
	
	If FirstTime Then
		'
		'I need to initialize the native Java object context
		'
		NativeMe2.InitializeContext
		
		'
		'Adding the ability to block Android from capturing
		'screenshots of this App because otherwise they leak
		'the Admin keys in Recent Apps thumbnails.
		'
#If JAVA
		//
		// Add FLAG_SECURE which prevents Android from taking
		// Recent App thumbnail screenshots of this activity,
		// otherwise the Admin keys can leak in thumbnail files.
		//
		// Side-effect: can't screenshot the App, but fortunately
		// I already did the screenshots a while ago anyway.
		//
		public void _onCreate() {
			
			//
			// Hide the Title bar / Action bar on very-low DPI devices
			//
			if ( getDeviceScale() < 1.0 ) // less than 1.0 (160dpi/mdpi)
			{
				// The device is 120/ldpi so we need more space.
				// that means we will want to remove the
				// Titlebar / Action bar.
				requestWindowFeature(Window.FEATURE_NO_TITLE);
				
				// Action bar for API 11+ (Android 3.0+)
				if ( android.os.Build.VERSION.SDK_INT >= 11 )
				{
					ActionBar actionBar = getActionBar();
					
					if ( actionBar != null )
					{
						actionBar.hide();
					}
				}
			}
			
			// Check if device is SDK 11 or higher (Android 3.0+)
			//
			// "FLAG_SECURE is a WindowManager flag introduced in
			//  Android 3.0 (Honeycomb) to prevent screenshots,
			//  screen recording, and viewing on non-secure displays.
			//
			//  It is implemented in an Activity's onCreate method
			//  to secure sensitive data. While it works for API 11+,
			//  it is not available or functional on Android 2.3.6"
			//
			if ( android.os.Build.VERSION.SDK_INT >= 11 )
			{
				// Add FLAG_SECURE to this Window (Activity view)
				this.getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE);
			}
		}
#End If
	
	End If
	
	'Set default Camera flags when initializing
	'this Activity for the first time.
	'
	'You need to set these flags before calling InitializeQrCodeReader
	'because it will actually use them.
	'
	isTorchOn    = False
	
	'
	'Dynamic torch on/off icon
	'
	btnToggleFlash.Text = "" 'Flash on icon (because flash turned off)
	
	'Initialize the QR code reader static properties.
	'Static properties are properties that are mostly always
	'the same values anyway and default first-time settings.
	InitializeQrCodeReader
	
	'Allow starting the Camera on Activity_Create.
	'It means initializing the global variable to False.
	'
	'This one cans be done after the InitializeQrCodeReader function.
	isBackCamera = True
	isCameraAlreadyStarted = False
	
	'
	'Always rear/back Camera first
	'
	'Note: don't put this code inside StartQrCodeReader otherwise
	'you will not be able to switch back/front cameras with the
	'Switch Camera button, so always do it explicitly before
	'calling StartQrCodeReader and only in Activity_Create and
	'the Activity_Resume functions.
	'
	Try
		qrReaderView.PreviewCameraId = 0
		qrReaderView.setBackCamera()
	Catch
		Log(LastException)
	End Try
	
	'Start scanning QR codes immediately
	StartQrCodeReader
	
End Sub

Sub Activity_KeyPress(KeyCode As Int) As Boolean
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		
		ExitScanLayout
		Return True
	Else
		'False means I can let default Android keypress handling do its work
		Return False
	End If
	
End Sub

'Useful to reset to turn off Flashlight when pressing Home key durign QR Scan
'
Sub Activity_Pause (UserClosed As Boolean)
	
	StopQrCodeReader
	
End Sub

Sub Activity_Resume
	'
	'Always rear/back Camera first
	'
	'Note: don't put this code inside StartQrCodeReader otherwise
	'you will not be able to switch back/front cameras with the
	'Switch Camera button, so always do it explicitly before
	'calling StartQrCodeReader and only in Activity_Create and
	'the Activity_Resume functions.
	'
	isBackCamera = True
	
	Try
		qrReaderView.PreviewCameraId = 0
		qrReaderView.setBackCamera()
	Catch
		Log(LastException)
	End Try
	
	'Set default Camera flags before starting
	'the Camera access for this Activity.
	'
	'No torch automatic re-enabling here (always off first).
	isTorchOn    = False
	
	'
	'Dynamic torch on/off icon
	'
	btnToggleFlash.Text = "" 'Flash on icon (because flash turned off)
	
	StartQrCodeReader
	
End Sub

'
'Helper code
'

Private Sub InitializeQrCodeReader As Void
	
	Try
		'QR decoder settings
		qrReaderView.TorchEnabled = isTorchOn
		qrReaderView.QRDecodingEnabled = True
		qrReaderView.AutofocusInterval = 1500
		qrReaderView.ResultPointColor = Colors.Red
	
		'Set the Camera IDs properly
		qrReaderView.PreviewCameraId = 0
		qrReaderView.setBackCamera()
		
		'
		' Verify if the device has two Cameras first
		' before proceeding further.
		'
		' Android API level 9+ (Android 2.3+)
		'
		If NativeMe2.RunMethod("DeviceHasAtleastTwoCameras", Null) Then
			qrReaderView.PreviewCameraId = 1
			qrReaderView.setFrontCamera()
		End If
	Catch
		Log(LastException)
		
		'Display the error dialog
		DisplayCameraErrorDialog
		
		'Return to the Main module as if the user pressed the back key
		btnBack_Click
	End Try
	
End Sub

Private Sub StartQrCodeReader As Void
	'
	'Add exception handling incase connecting to
	'the Camera service fails.
	'
	'This cans happen on custom Android ROMs based on
	'CyanogenMod or LineageOS.
	'
	'This cans usually be fixed by running under
	'a terminal emulator this command:
	'
	'su -c killall mediaserver
	'
	Try
		If Not(isCameraAlreadyStarted) Then
			'Set isCameraAlreadyStarted to True to avoid
			'trying to start the Camera twice because of
			'how the Android intent system works.
			isCameraAlreadyStarted = True
			
			qrReaderView.Visible = True
			
			'QR decoder settings
			qrReaderView.TorchEnabled = isTorchOn
			
			'
			'Dynamic torch on/off icon
			'
			If isTorchOn Then
				'If the flash is turned on
				btnToggleFlash.Text = "" 'Flash off icon
			Else
				'If the flash is turned off
				btnToggleFlash.Text = "" 'Flash on icon
			End If
			
			'Start the Camera because it wasn't already started
			'before (start it only when needed to avoid duplicate calls)
			qrReaderView.startCamera()
			qrReaderView.ScanNow = True
		End If
	Catch
		Log(LastException)
		
		'Display the error dialog
		DisplayCameraErrorDialog
		
		'Return to the Main module as if the user pressed the back key
		btnBack_Click
	End Try
	
End Sub

Private Sub StopQrCodeReader As Void
	'
	'Add exception handling incase connecting to
	'the Camera service fails.
	'
	'This cans happen on custom Android ROMs based on
	'CyanogenMod or LineageOS.
	'
	'This cans usually be fixed by running under
	'a terminal emulator this command:
	'
	'su -c killall mediaserver
	'
	Try
		qrReaderView.ScanNow = False
		
		'QR decoder settings
		isTorchOn = False
		qrReaderView.TorchEnabled = isTorchOn
		
		'
		'Dynamic torch on/off icon
		'
		btnToggleFlash.Text = "" 'Flash on icon (because flash turned off)
		
		qrReaderView.stopCamera()
		qrReaderView.Visible = False
		
		'Set isCameraAlreadyStarted to False to allow
		'the Camera to be started again.
		isCameraAlreadyStarted = False
		
	Catch
		'
		'Don't show an error message when stopping the Camera
		'even if Camera connection fails,
		'otherwise the user gets multiple error dialogs (two).
		'
		Log(LastException)
		
	End Try
	
End Sub

Private Sub DisplayCameraErrorDialog
	'
	'The CameraFix command incase the user needs it
	'
	Dim CameraFixCommand As String = "su -c killall mediaserver"
	
	'
	'Positive button is named 'Copy Command'
	'Cancel button is named 'Dismiss'
	'
	Msgbox2Async($"Connecting to the Camera service failed.
If your phone runs a custom ROM based on CyanogenMod or LineageOS, this might sometimes happen.

To fix this issue, reboot your phone or use root access with the command:
""${CameraFixCommand}"""$&".", "Camera Failed", "Copy Command", "Dismiss", "", Application.Icon, True)
	
	Wait For Msgbox_Result (Result As Int)
	
	If Result = DialogResponse.POSITIVE Then
		'
		'Copy the root CameraFix command to clipboard
		'
		Dim BClipboard As BClipboard
		BClipboard.setText(CameraFixCommand)
		
		'Tell the user that the command has been copied to clipboard
		ToastMessageShow("Command copied to clipboard", False)
		
	End If
	
End Sub

Private Sub ExitScanLayout As Void
	
	ExitScanLayoutInternal(False)
	
End Sub

Private Sub ExitScanLayoutInternal(NoActivityStart As Boolean) As Void
	
	'Stop the Camera access first before exiting this module
	'
	StopQrCodeReader
	
	'Close this Activity once no longer needed
	'
	Activity.Finish()
	
	'Return to the Main Android PIN Unblocker activity
	'
	'Only prevent a new Activity start when it's the
	'qrReaderView_result_found function that calls this one,
	'because it already starts the Main activity in its own way.
	'
	If NoActivityStart == False Then
		StartActivity(Main)
	End If
	
End Sub

'
'UI event handlers
'

Private Sub qrReaderView_result_found(ReturnValue As String)
	
	'Prepare the Share To intent for the QR code
	Dim shareIntent As Intent
	shareIntent.Initialize(shareIntent.ACTION_SEND, "")
	
	'Set the Share To intent properties
	'Package name cans now easily be changed without changing it here
	shareIntent.SetPackage(Application.PackageName)
	shareIntent.SetType("text/plain")
	shareIntent.PutExtra("android.intent.extra.CHALLENGE_CODE", ReturnValue)
	
	'Set the Main module's SharingQRCodeChallengeIntentAllowed variable
	'to True in order to let the App accept the Share To intent.
	Main.SharingQRCodeChallengeIntentAllowed = True
	
	'Finally start the Share To activity
	StartActivity(shareIntent)
	
	'Exit without re-starting the Main activity (True flag).
	'
	'This is because we already started the Main Activity ourselves
	'using a Share To intent with the challenge code.
	'
	ExitScanLayoutInternal(True)
	
End Sub

Private Sub btnToggleFlash_Click
	'
	' Verify if the device has a flashlight first
	' before proceeding further.
	'
	' Android API level 7+ (Android 2.1+)
	'
	If Not(NativeMe2.RunMethod("checkDeviceFlashlight", Null)) Then
		'
		' In the few cases nowadays where it doesn't have a flashlight
		' I don't disable the Flashlight toggle button,
		' because I want the user to be able to see that it's
		' an available functionality and to know why they can't use it,
		' rather than seeing a disabled Flashlight toggle button and
		' thinking that it may be an App bug.
		'
		ToastMessageShow("Flashlight required for the toggle", False)
		Return
	End If
	
	isTorchOn = Not(isTorchOn)
	
	Try
		qrReaderView.TorchEnabled = isTorchOn
	Catch
		isTorchOn = Not(isTorchOn)
		Log(LastException)
		
		Return
	End Try
	
	'
	'Dynamic torch on/off icon
	'
	If isTorchOn Then
		'If the flash is turned on
		btnToggleFlash.Text = "" 'Flash off icon
	Else
		'If the flash is turned off
		btnToggleFlash.Text = "" 'Flash on icon
	End If
	
End Sub

Private Sub btnSwitchCam_Click
	'
	' Verify if the device has two Cameras first
	' before proceeding further.
	'
	' Android API level 9+ (Android 2.3+)
	'
	If Not(NativeMe2.RunMethod("DeviceHasAtleastTwoCameras", Null)) Then
		'
		' In the rare case where it doesn't have two Cameras I don't
		' disable the Camera switching button, because I want the user
		' to be able to see that it's an available functionality and
		' to know why they can't use it, rather than seeing a disabled
		' Camera switching button and thinking that it may be an App bug.
		'
		ToastMessageShow("Two cameras required for the switch", False)
		Return
	End If
	
	Dim oldTorchOnValue As Boolean = isTorchOn
	
	Try
		'Disabling the Flashlight when changing camera
		isTorchOn = False
		qrReaderView.TorchEnabled = isTorchOn
	Catch
		Log(LastException)
		
		isTorchOn = oldTorchOnValue
		Return
	End Try
	
	'
	'Dynamic torch on/off icon
	'
	btnToggleFlash.Text = "" 'Flash on icon (because flash turned off)
	
	StopQrCodeReader
	
	'Change Camera to the opposite side
	isBackCamera = Not(isBackCamera)
	
	Try
		If isBackCamera Then
			qrReaderView.PreviewCameraId = 0
			qrReaderView.setBackCamera()
		Else
			qrReaderView.PreviewCameraId = 1
			qrReaderView.setFrontCamera()
		End If
	Catch
		Log(LastException)
		isBackCamera = Not(isBackCamera)
	End Try
	
	StartQrCodeReader
	
End Sub

Private Sub btnBack_Click
	ExitScanLayout
End Sub

'
'Unused code
'

'
'
'Unused code goes here
'
'

'
'Native code
'

#If JAVA

//
// Add ability to check if the device has a Camera
//

import android.hardware.Camera;

//
// For getting the device scale (DPI)
//

// Android 11+
import android.content.Context;

//import android.view.WindowManager; // Already imported at start of Main code
import android.view.WindowMetrics;

import android.content.res.Configuration;

// Android 4.2+
import android.util.DisplayMetrics;
import android.view.Display;

// Android 4.1 & older
import android.content.res.Resources;

//
// Check if the device has a flashlight
//

//import android.content.Context; // Already imported for getting the device scale
import android.content.pm.PackageManager;

/* ************************************************ */

//
// Check if the device has a flashlight
//
// Thanks to:
// https://stackoverflow.com/questions/29622298/getpackagemanager-hassystemfeaturepackagemanager-feature-camera-flash-return
//

public boolean checkDeviceFlashlight() {
	
	// "getApplicationContext();" or "this.getContext();"
	Context ctx = getApplicationContext();
	
	// Android API level 7+ (Android 2.1+)
	return ctx.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
}

//
// Get screen DPI function (support API 9+ / Android 2.3+)
//

public float getDeviceScale() {
	
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
		WindowManager wm = (WindowManager)getSystemService(Context.WINDOW_SERVICE);
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
// Some devices don't even have two cameras so I want to check
// If the device actually has two, otherwise I will disable
// the Camera switching function To avoid crashing the App.
//
public boolean DeviceHasAtleastTwoCameras() {
	//
	// Thanks To https://stackoverflow.com/a/10593071
	//
	
	return Camera.getNumberOfCameras() >= 2; // Android API level 9+ (Android 2.3+)
}

#End If

