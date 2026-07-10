B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

#Region Activity Attributes
	#FullScreen:   False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'ViewState registers for restoring the App state
	'on Activity destruction & re-creation
	Private ViewState_qrvQRCodeReaderView_PreviewCameraId As Int
	
	'We currently don't restore the TorchEnabled state,
	'but this variable will be used elsewhere in the code
	'instead of being used by ViewState Save & Restore functions
	Private ViewState_qrvQRCodeReaderView_TorchEnabled As Boolean
	
	'The Toggle Flash button will always by dynamically
	'set to the correct .Text content on App pause & resume,
	'including on Camera preview side switch
	
	'Convenience constants stored inside this class
	Private Constants As MyConstants
	
	'For getting Phone library functions without
	'bundling the big Phone library
	Private Common As MyCommon
	
	'For safely discarding any leftover Camera preview buffer(s)
	Private Security As MySecurity
	
	'For advanced Java functions that require context
	Private joScan As JavaObject
	
End Sub

Sub Globals
	'The below declarations are needed for fixing
	'the Camera preview to be neatly square on
	'devices without a software NavBar
	Private lblQRCodeReaderBg   As Label  'It's a label used as a background
	Private btnToggleFlash      As Button
	Private btnSwitchCamera     As Button
	Private btnBack             As Button
	
	'In a try-catch block because we want to avoid
	'any potential Camera service connection error
	'that could cause a disgraceful App crash
	Try
		Private qrvQRCodeReaderView As NewQRCodeReaderView
	Catch
		HandleCameraServiceException
	End Try
End Sub

'
'Java functions ------------------------------------------------
'

#If Java
//
// This part is used by both joScan.RunMethod calls
// and the Activity events
//
private myadvanced ScanAdvanced  = new myadvanced();

#End If

#If Java
//
// This part is used by joScan.RunMethod calls
//
import android.content.Context;
import android.app.Activity;
public boolean jDeviceHasFlashlight()
{
	// Method of providing context to a class
	// Call its functions with the "this" keyword
	//
	return ScanAdvanced.jDeviceHasFlashlight(this);
}

import android.content.Context;
import android.app.Activity;
public float jGetDeviceScale()
{
	return ScanAdvanced.jGetDeviceScale(this);
}

import android.content.Context;
import android.app.Activity;
public boolean jDeviceHasNavBar()
{
	return ScanAdvanced.jDeviceHasNavBar(this);
}

import android.content.Context;
import android.app.Activity;
public int jGetDeviceOrientation()
{
	return ScanAdvanced.jGetDeviceOrientation(this);
}

import android.content.Context;
import android.app.Activity;
public void jBetterActivityFinish()
{
	ScanAdvanced.jBetterActivityFinish(this);
}
#End If

#If Java
//
// Intercept mundane configuration change events to
// ignore them instead of recreating this App's Activities
//
// This is what we've set in the App's manifest file
//
import android.content.res.Configuration;
@Override
public void onConfigurationChanged(Configuration newConfig)
{
	super.onConfigurationChanged(newConfig);
}
#End If

#If Java
//
// Censor Recent Apps thumbnails on supported
// Android versions (the legacy ones)
//
// Works for devices up to Android 4.0.2 (API level 14)
// Newer ones will just ignore this function / event
//
import java.lang.SuppressWarnings;
import android.content.Context;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
@SuppressWarnings({"deprecation", "removal"})
@Override
public boolean onCreateThumbnail(Bitmap outBitmap, Canvas canvas)
{
	return ScanAdvanced.jCensorActivityThumbnail(this, outBitmap, canvas);
}
#End If

#If Java
import android.content.Context;
import android.app.Activity;
public void _onCreate()
{
	//
	// Disable the Activity TitleBar & ActionBar if needed
	//
	ScanAdvanced.jDisableTitleBarAndActionBarIfNeeded(this);
	
	//
	// Disable the Android 8.0+ Autofill service (for security reasons)
	//
	ScanAdvanced.jDisableAndroidAutofillService(this);
	
	// Make this App Activity secure
	//
	ScanAdvanced.jSecureActivityOnCreate(this, _myglobals.Scan_IsFirstLaunch);
	
	/* Check if it's the first-time Activity launch
	 * in this Activity's lifecycle
	 * 
	 * This part is done at the end of the onCreate event
	 */
	if ( _myglobals.Scan_IsFirstLaunch )
	{
		// Mark that the next Activity onCreate events
		// will no longer be the first-time Activity launch
		_myglobals.Scan_IsFirstLaunch = false;
	}
}
#End If

'
'------------------------------------------------------------------
'

#Region ViewState functions

'Special function used for either setting initial defaults
'or for securely erasing the ViewState before Activity exit
Private Sub ResetViewState
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ResetViewState: Sub entry"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .TorchEnabled state to False"$, Colors.Blue)
	#End If
	ViewState_qrvQRCodeReaderView_TorchEnabled = False
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .PreviewCameraId value to CAMERA_REAR"$, Colors.Blue)
	#End If
	ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ResetViewState: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub SaveViewState()
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SaveViewState: Sub entry"$, Colors.Blue)
	#End If
	
	'The Camera preview ID (last selected Camera) is saved
	'in realtime by the Switch Camera button's event handler
	
	'The Flashlight state is saved in realtime
	'the Toggle Flash button's event handler
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SaveViewState: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub RestoreViewState()
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Sub entry"$, Colors.Blue)
	#End If
	
	'We currently don't restore the TorchEnabled state
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Restoring the QR code reader view's previous Camera preview ID ${ViewState_qrvQRCodeReaderView_PreviewCameraId}"$, Colors.Blue)
	#End If
	SwitchCamera(Constants.CAMERA_SPECIFIC_ONE, ViewState_qrvQRCodeReaderView_PreviewCameraId)
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

'
'Activity event handlers ----------------------------------------
'

#Region Activity event handlers

Sub Activity_Create(FirstTime As Boolean)
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Sub entry (FirstTime = ${FirstTime})"$, Colors.Blue)
	#End If
	
	'----------------------------------------------
	' Disabling the Activity TitleBar & ActionBar '
	' must be done before adding content to the   '
	' Activity, so before loading the layout file '
	'----------------------------------------------
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Load Scan layout"$, Colors.Blue)
	#End If
	Activity.LoadLayout("Scan")
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Set Activity title"$, Colors.Blue)
	#End If
	Activity.Title = Application.LabelName
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Check if it's the FirstTime Activity launch"$, Colors.Blue)
	#End If
	If FirstTime Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: It's the FirstTime Activity launch"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: Get an initial ViewState with default UI element values by resetting the ViewState"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: The layout files don't always contain default UI element values"$, Colors.Blue)
		#End If
		ResetViewState
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Constants Class (MyConstants class)"$, Colors.Blue)
		#End If
		Constants.Initialize
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Common Class (MyCommon class)"$, Colors.Blue)
		#End If
		Common.Initialize
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Security Class (MySecurity class)"$, Colors.Blue)
		#End If
		Security.Initialize
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Create: It's not the FirstTime Activity launch"$, Colors.Blue)
		#End If
		
	End If
	
	'The Activity context must always be fresh,
	'so always re-initialize the joMain JavaObject
	'on every Activity create (not just on FirstTime)
	'
	'This is mandatory for context-dependent functions
	'that receive the Activity context, because they
	'must always have a fresh Activity context handle!
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the joScan JavaObject always (not just on FirstTime launch)"$, Colors.Blue)
	#End If
	joScan.InitializeContext
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the QR code reader view"$, Colors.Blue)
	#End If
	InitializeQRCodeReaderView
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Fixing the Camera preview to be neatly square if needed (on devices without a software NavBar)"$, Colors.Blue)
	#End If
	FixSquareCameraPreviewIfNeeded
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Create: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub FixSquareCameraPreviewIfNeeded
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub entry"$, Colors.Blue)
	#End If
	
	'Only for devices that don't have a NavBar and
	'that have a device scale of 1.0 or higher
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Fetching device's software Navigation bar information and device scale"$, Colors.Blue)
	#End If
	Dim HasNavBar   As Boolean = joScan.RunMethod("jDeviceHasNavBar", Null)
	Dim DeviceScale As Float   = joScan.RunMethod("jGetDeviceScale", Null)
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Acquired device information: HasNavbar   = ${HasNavBar}"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Acquired device information: DeviceScale = ${DeviceScale}"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: If there was any failure getting device information, safe-bet values are returned instead"$, Colors.Green)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: This is the normal behavior of these device information functions"$, Colors.Green)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Checking if the device is eligible for the square Camera preview fix"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device must not have a software NavBar & have a display scale of atleast 1.0"$, Colors.Blue)
	#End If
	If HasNavBar Or 1.0 > DeviceScale Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device is not eligible for the square Camera preview fix"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device doesn't actually need the square Camera preview fix"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: No need to proceed further"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub return"$, Colors.Blue)
		#End If
		Return
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device is eligible for the square Camera preview fix"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device needs the square Camera preview fix"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: We need to proceed further"$, Colors.Blue)
		#End If
		
	End If
	
	'Calibration values are from Huawei P9 Lite
	'
	'This is how the Designer view of the Scan layout
	'was actually created and calibrated,
	'so it's normal that they differ from
	'the standard Android values
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Getting device orientation, because the Camera preview fix is different for each orientation"$, Colors.Blue)
	#End If
	Dim Orientation As Int = joScan.RunMethod("jGetDeviceOrientation", Null)
	
	If Orientation == Constants.ORIENTATION_PORTRAIT Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is portrait, applying the portrait fix"$, Colors.Blue)
		#End If
		
		'Portrait fix
		lblQRCodeReaderBg.Height   = lblQRCodeReaderBg.Height   - 38dip
		qrvQRCodeReaderView.Height = qrvQRCodeReaderView.Height - 38dip
		
		btnToggleFlash.Top  = btnToggleFlash.Top  - 38dip
		btnSwitchCamera.Top = btnSwitchCamera.Top - 38dip
		btnBack.Top         = btnBack.Top         - 38dip
		
	Else If Orientation == Constants.ORIENTATION_LANDSCAPE Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is landscape, applying the landscape fix"$, Colors.Blue)
		#End If
		
		'Landscape fix
		qrvQRCodeReaderView.Width = qrvQRCodeReaderView.Width - 48dip
		qrvQRCodeReaderView.Left  = qrvQRCodeReaderView.Left  + 24dip 'Re-align the Camera preview on center
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is not a supported one (neither portrait nor landscape)"$, Colors.Magenta)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Maybe this is a truly old legacy device that actually has a fully square display"$, Colors.Magenta)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: No need to apply any Camera preview fix, even if the device was eligible"$, Colors.Magenta)
		#End If
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub return"$, Colors.Blue)
	#End If
End Sub

#Region Activity resume event handlers

Sub Activity_Resume
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Sub entry"$, Colors.Blue)
	#End If
	
	'Restoring the ViewState also calls SwitchCamera
	'SwitchCamera already handles restarting the Camera preview
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Restore ViewState"$, Colors.Blue)
	#End If
	RestoreViewState
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

#Region Activity pause event handlers

Sub Activity_Pause(UserClosed As Boolean)
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Sub entry (UserClosed = ${UserClosed})"$, Colors.Blue)
	#End If
	
	If Not(UserClosed) Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Activity is not UserClosed"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Save ViewState"$, Colors.Blue)
		#End If
		SaveViewState
		
	End If
	
	'The ViewState saving function doesn't stop the Camera preview
	'because that's not its job, it only saved the current state
	'without affecting it
	'
	'So we have to manually stop the Camera preview on App pause
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Stop the QR code reader view on App pause"$, Colors.Blue)
	#End If
	StopQRCodeReaderView
	
	'Do this after stopping the QR code reader view
	If UserClosed Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Activity is UserClosed"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Calling ActivityExit"$, Colors.Blue)
		#End If
		ActivityExit
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

Private Sub ActivityExit
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Sub entry"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Resetting the ViewState to clear all the last selected Camera preview ID etc"$, Colors.Blue)
	#End If
	ResetViewState
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Asking the JVM to do a garbage collection as soon as possible"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: This will clear traces of leftover Camera preview buffers"$, Colors.Blue)
	#End If
	Security.TriggerJvmGarbageCollection
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Starting the Main Activity"$, Colors.Blue)
	#End If
	StartActivity(Main)
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Finishing this Scan Activity"$, Colors.Blue)
	#End If
	Activity.Finish()
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ActivityExit: Sub return"$, Colors.Blue)
	#End If
End Sub

#Region Activity keypress event handlers

Private Sub Activity_KeyPress(KeyCode As Int) As Boolean
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub entry (KeyCode = ${KeyCode})"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Verifying what the KeyCode is"$, Colors.Blue)
	#End If
	Select Case KeyCode
		Case KeyCodes.KEYCODE_BACK
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_BACK"$, Colors.Blue)
			#End If
			
			'The btnBack_Click already handles stopping
			'the Camera preview and finishing the Activity
			'
			'It event handles resetting the ViewState too
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Simulating a click by the user on the Back button"$, Colors.Blue)
			#End If
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: This does the same thing as exiting this Scan Activity"$, Colors.Blue)
			#End If
			btnBack_Click
			
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub return (returning True)"$, Colors.Red)
			#End If
			Return True
			
		Case Else
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: The KeyCode is something else"$, Colors.Blue)
			#End If
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: We don't do anything particular with other KeyCodes"$, Colors.Blue)
			#End If
			
	End Select
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub return (returning False)"$, Colors.Blue)
	#End If
	Return False
	
End Sub

#End Region

#End Region

'
'Helper functions ---------------------------------------
'

#Region Helper functions

Private Sub InitializeQRCodeReaderView
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
	#End If
	
	Try
		'QR decoder settings
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing default properties"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.QRDecodingEnabled = True
		qrvQRCodeReaderView.AutofocusInterval = 1500
		qrvQRCodeReaderView.ResultPointColor  = Colors.Red
		
		'Don't set any specific Flashlight state
		'in this initialization function
		
		'Set the Camera IDs properly
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing the rear Camera preview ID"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_REAR
		qrvQRCodeReaderView.setBackCamera()
		
		'Verify if the device has two Cameras first
		'before proceeding further
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Checking whether the device has two or more Cameras"$, Colors.Blue)
		#End If
		If Common.GetNumberOfDeviceCameras >= 2 Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: The device has atleast two Cameras"$, Colors.Blue)
			#End If
			
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing the front Camera preview ID"$, Colors.Blue)
			#End If
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_FRONT
			qrvQRCodeReaderView.setFrontCamera()
			
		Else
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: The device only has one Camera"$, Colors.Magenta)
			#End If
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: No need to initialize a front Camera preview ID"$, Colors.Magenta)
			#End If
			
		End If
		
	Catch
		HandleCameraServiceException
	End Try
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
	#End If
End Sub

Private Sub StartQRCodeReaderView
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Sub entry"$, Colors.Blue)
	#End If
	
	Try
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Starting the Camera preview"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.Visible = True 'Important or switching Camera preview sides doesn't work
		qrvQRCodeReaderView.startCamera()
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Start scanning for QR codes"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.ScanNow = True
		
	Catch
		HandleCameraServiceException
	End Try
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub StopQRCodeReaderView
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Sub entry"$, Colors.Blue)
	#End If
	
	Try
		'Stop searching for valid QR codes
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Stop scanning for QR codes"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.ScanNow = False
		
		'Turn off the Flashlight always when stopping the Camera preview
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Turning off the Flashlight"$, Colors.Blue)
		#End If
		ToggleFlashlight(Constants.FLASH_SPECIFIC_STATE, Constants.FLASH_OFF)
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Stopping the Camera preview"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.stopCamera()
		qrvQRCodeReaderView.Visible = False 'Important or switching Camera preview sides doesn't work
		
	Catch
		HandleCameraServiceException
	End Try
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub HandleCameraServiceException
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Sub entry"$, Colors.Red)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: There was a problem dealing with the Camera service:"$, Colors.Red)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	#End If
	#If LOGGING
	LogColor(LastException, Colors.Black)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Displaying an exception message to the user in a toast notification"$, Colors.Red)
	#End If
	ToastMessageShow("Camera service failure", Constants.TOAST_DURATION_SHORT)
	
	'Stopping the Camere preview would require Camera service access anyway
	'
	'ActivityExit is used by btnBack_Click but doesn't stop the Camera preview
	'so we can use this function here for exception handling
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Exiting this Scan Activity (returning to the Main Activity)"$, Colors.Red)
	#End If
	ActivityExit
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Sub return"$, Colors.Red)
	#End If
End Sub

#End Region

'
'UI event handlers -------------------------------------------------------
'

#Region UI event handlers

#Region QR code reader view event handlers

Private Sub qrvQRCodeReaderView_result_found(QRCodeContents As String)
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Sub entry (sensitive parameters)"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is literally empty"$, Colors.Blue)
	#End If
	If QRCodeContents == "" Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: The QR code content is literally empty"$, Colors.Magenta)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main module that this is not a mistake but a real value"$, Colors.Magenta)
		#End If
		Main.Shared_AllowEmptyQRCodeContent = True
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is not empty"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main module that it cans consider empty values as a mistake"$, Colors.Blue)
		#End If
		Main.Shared_AllowEmptyQRCodeContent = False
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Providing the QR code contents to the Main module via a shared process variable"$, Colors.Blue)
	#End If
	Main.Shared_DetectedQRCodeContents = QRCodeContents
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Now simulating the user pressing the Back button to exit this Scan Activity (return to the Main module)"$, Colors.Blue)
	#End If
	btnBack_Click
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

#Region Toggle Flash button event handlers

Private Sub btnToggleFlash_Click
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub entry"$, Colors.Blue)
	#End If
	
	'Verify if the device has a Flashlight first
	'before proceeding further.
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Verifying if the device has a Flashlight before proceeding further"$, Colors.Blue)
	#End If
	If Not(joScan.RunMethod("jDeviceHasFlashlight", Null)) Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: The device has no Flashlight, we cannot proceed further"$, Colors.Magenta)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		#End If
		ToastMessageShow("Flashlight required for the toggle", Constants.TOAST_DURATION_SHORT)
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Magenta)
		#End If
		Return
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: The device has a Flashlight, now we can proceed further"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Calling ToggleFlashlight without requesting any specific state (toggle mode)"$, Colors.Blue)
	#End If
	ToggleFlashlight(Constants.FLASH_NO_SPECIFIC_STATE, Constants.FLASH_TOGGLE)
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub ToggleFlashlight(WantsSpecificState As Boolean, WhichOneIfYes As Boolean)
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Sub entry (WantsSpecificState = ${WantsSpecificState}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Checking if a specific Flashlight state was requested by the caller"$, Colors.Blue)
	#End If
	If Not(WantsSpecificState) Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: The caller didn't request any specific Flashlight state"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Switch the Flashlight state to the opposite one (current: ${ViewState_qrvQRCodeReaderView_TorchEnabled} -> ${Not(ViewState_qrvQRCodeReaderView_TorchEnabled)})"$, Colors.Blue)
		#End If
		ViewState_qrvQRCodeReaderView_TorchEnabled = Not(ViewState_qrvQRCodeReaderView_TorchEnabled)
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: The caller requested a specific Flashlight state (${WhichOneIfYes})"$, Colors.Blue)
		#End If
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Setting the ViewState for the Flashlight state to ${WhichOneIfYes}"$, Colors.Blue)
		#End If
		ViewState_qrvQRCodeReaderView_TorchEnabled = WhichOneIfYes
		
	End If
	
	Try
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Applying the new Flashlight ViewState to the QR code reader view (setting it to ${ViewState_qrvQRCodeReaderView_TorchEnabled})"$, Colors.Blue)
		#End If
		qrvQRCodeReaderView.TorchEnabled = ViewState_qrvQRCodeReaderView_TorchEnabled
	Catch
		'Don't exit here because not being able to
		'toggle the Flashlight state is not critical
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: We had a problem applying the new Flashlight state"$, Colors.Red)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		#End If
		ToastMessageShow("Failed to toggle Flashlight", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Flashlight state
		'(if no specific one was actually requested)
		If Not(WantsSpecificState) Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Because no specific Flashlight state was requested, restore the prior value in the ViewState"$, Colors.Red)
			#End If
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: This helps avoid having an inconsistent state since the state wasn't actually in effect (failed to apply)"$, Colors.Red)
			#End If
			
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Restoring the new Flashlight state value ${ViewState_qrvQRCodeReaderView_TorchEnabled} back to the previous one ${Not(ViewState_qrvQRCodeReaderView_TorchEnabled)}"$, Colors.Red)
			#End If
			ViewState_qrvQRCodeReaderView_TorchEnabled = Not(ViewState_qrvQRCodeReaderView_TorchEnabled)
			
		End If
	End Try
	
	'Dynamic Torch on / off icon
	If ViewState_qrvQRCodeReaderView_TorchEnabled Then
		'If the Flashlight is on then show the
		'icon for turning it off
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash Off icon since the Flashlight is on"$, Colors.Blue)
		#End If
		btnToggleFlash.Text = Constants.FLASH_ICON_OFF
		
	Else
		'
		'If the Flashlight is off then show the
		'icon for turning it on
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash On icon since the Flashlight is off"$, Colors.Blue)
		#End If
		btnToggleFlash.Text = Constants.FLASH_ICON_ON
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

#Region Switch Camera button event handlers

Private Sub btnSwitchCamera_Click
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub entry"$, Colors.Blue)
	#End If
	
	'Verify if the device has two Cameras first
	'before proceeding further.
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Verifying if the device has atleast two Cameras before the Camera side switch"$, Colors.Blue)
	#End If
	If Common.GetNumberOfDeviceCameras < 2 Then
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: The device only has one Camera, cannot proceed further"$, Colors.Magenta)
	#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		#End If
		ToastMessageShow("Two Cameras required for the switch", Constants.TOAST_DURATION_SHORT)
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Magenta)
		#End If
		Return
		
	End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: The device has atleast two Cameras, now we can try switching the Camera preview sides"$, Colors.Blue)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Calling SwitchCamera without requesting any specific side (switch-sides mode)"$, Colors.Blue)
	#End If
	SwitchCamera(Constants.CAMERA_NO_SPECIFIC_ONE, Constants.CAMERA_ANY)
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Blue)
	#End If
End Sub

Private Sub SwitchCamera(WantsSpecificCamera As Boolean, WhichOneIfYes As Int)
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Sub entry (WantsSpecificCamera = ${WantsSpecificCamera}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	#End If
	
	'Stop the Camera preview
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Starting the Camera preview"$, Colors.Blue)
	#End If
	StopQRCodeReaderView
	
	'Change the Camera to the opposite side
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Check whether the caller wants a specific Camera side"$, Colors.Blue)
	#End If
	If Not(WantsSpecificCamera) Then
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: The caller does not want any specific Camera side"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Switching the Camera preview ID to the opposite side"$, Colors.Blue)
		#End If
		If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: The current opposite side is rear, switchng to front"$, Colors.Blue)
			#End If
			ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_FRONT
			
		Else
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: The current opposite side is front, switchng to rear"$, Colors.Blue)
			#End If
			ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
			
		End If
		
	Else
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: The caller wants a specific Camera side"$, Colors.Blue)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Setting the Camera preview ID to the specifically requested one (${WhichOneIfYes})"$, Colors.Blue)
		#End If
		ViewState_qrvQRCodeReaderView_PreviewCameraId = WhichOneIfYes
		
	End If
	
	Try
		If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Applying the new Camera preview ID (rear)"$, Colors.Blue)
			#End If
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_REAR
			qrvQRCodeReaderView.setBackCamera()
			
		Else If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_FRONT Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Applying the new Camera preview ID (front)"$, Colors.Blue)
			#End If
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_FRONT
			qrvQRCodeReaderView.setFrontCamera()
			
		End If
	Catch
		'Don't exit here because the StopQRCodePreview and
		'StartQRCodePreview Methods already exit on failure
		'
		'And not being able to switch Cameras is not critical
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: We had a problem applying the new Camera preview ID"$, Colors.Red)
		#End If
		
		#If LOGGING
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		#End If
		ToastMessageShow("Failed to switch Camera preview ID", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Camera preview ID
		'(if no specific one was actually requested)
		If Not(WantsSpecificCamera) Then
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Because no specific Camera ID was requested, restore the prior value in the ViewState"$, Colors.Red)
			#End If
			#If LOGGING
			LogColor($"[Scan-${LogContextId}] SwitchCamera: This helps avoid having an inconsistent state since the new ID wasn't actually in effect (failed to apply)"$, Colors.Red)
			#End If
			
			If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
				#If LOGGING
				LogColor($"[Scan-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to the previous value (front)"$, Colors.Red)
				#End If
				ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_FRONT
				
			Else
				#If LOGGING
				LogColor($"[Scan-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to the previous value (rear)"$, Colors.Red)
				#End If
				ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
				
			End If
		End If
	End Try
	
	'Resume the Camera preview
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Starting the Camera preview"$, Colors.Blue)
	#End If
	StartQRCodeReaderView
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

#Region Back button event handlers

Private Sub btnBack_Click
	#If LOGGING
	Dim LogContextId As Int = Rnd(1000, 9999)
	#End If
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Sub entry"$, Colors.Blue)
	#End If
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Stopping the QR code reader view"$, Colors.Blue)
	#End If
	StopQRCodeReaderView
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Calling the ActivityExit function"$, Colors.Blue)
	#End If
	ActivityExit
	
	#If LOGGING
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Sub return"$, Colors.Blue)
	#End If
End Sub

#End Region

#End Region


