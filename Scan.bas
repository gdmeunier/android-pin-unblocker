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

'Java functions ------------------------------------------------
#If Java
private myadvanced ScanAdvanced = new myadvanced();

import android.content.Context;
public boolean jDeviceHasFlashlight()
{
	return ScanAdvanced.jDeviceHasFlashlight(this);
}

import android.content.Context;
public float jGetDeviceScale()
{
	return ScanAdvanced.jGetDeviceScale(this);
}

import android.content.Context;
public boolean jDeviceHasNavBar()
{
	return ScanAdvanced.jDeviceHasNavBar(this);
}

import android.content.Context;
public int jGetDeviceOrientation()
{
	return ScanAdvanced.jGetDeviceOrientation(this);
}

import android.content.Context;
public void jDisableActivityTitleBar()
{
	ScanAdvanced.jDisableActivityTitleBar(this);
}

import android.content.Context;
public void jDisableActivityActionBar()
{
	ScanAdvanced.jDisableActivityActionBar(this);
}

import android.content.Context;
public boolean jEnableActivityFlagSecure()
{
	return ScanAdvanced.jEnableActivityFlagSecure(this);
}

import android.content.Context;
public boolean jDisableRecentAppsThumbnails()
{
	return ScanAdvanced.jDisableRecentAppsThumbnails(this);
}

import android.content.Context;
public void jDisableAndroidAutofillService()
{
	ScanAdvanced.jDisableAndroidAutofillService(this);
}
#End If
'------------------------------------------------------------------

#Region ViewState functions

'Special function used for either setting initial defaults
'or for securely erasing the ViewState before Activity exit
Private Sub ResetViewState
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] ResetViewState: Sub entry"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .TorchEnabled state to False"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_TorchEnabled = False
	
	LogColor($"[Scan-${LogContextId}] ResetViewState: Set ViewState register for the QR code reader view's .PreviewCameraId value to CAMERA_REAR"$, Colors.Blue)
	ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
	
	LogColor($"[Scan-${LogContextId}] ResetViewState: Sub return"$, Colors.Blue)
End Sub

Private Sub SaveViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] SaveViewState: Sub entry"$, Colors.Blue)
	
	'The Camera preview ID (last selected Camera) is saved
	'in realtime by the Switch Camera button's event handler
	
	'The Flashlight state is saved in realtime
	'the Toggle Flash button's event handler
	
	LogColor($"[Scan-${LogContextId}] SaveViewState: Sub return"$, Colors.Blue)
End Sub

Private Sub RestoreViewState()
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Sub entry"$, Colors.Blue)
	
	'We currently don't restore the TorchEnabled state
	
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Restoring the QR code reader view's previous Camera preview ID ${ViewState_qrvQRCodeReaderView_PreviewCameraId}"$, Colors.Blue)
	SwitchCamera(Constants.CAMERA_SPECIFIC_ONE, ViewState_qrvQRCodeReaderView_PreviewCameraId)
	
	LogColor($"[Scan-${LogContextId}] RestoreViewState: Sub return"$, Colors.Blue)
End Sub

#End Region

'
'Activity event handlers ----------------------------------------
'

#Region Activity event handlers

Sub Activity_Create(FirstTime As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] Activity_Create: Sub entry (FirstTime = ${FirstTime})"$, Colors.Blue)
	
	'----------------------------------------------
	' Disabling the Activity TitleBar & ActionBar '
	' must be done before adding content to the   '
	' Activity, so before loading the layout file '
	'----------------------------------------------
	
	#If Java
	public void _onCreate()
	{
		if ( 1.0 > jGetDeviceScale() )
		{
			jDisableActivityTitleBar();
			jDisableActivityActionBar();
		}
		jDisableAndroidAutofillService();
	}
	#End If
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Load Scan layout"$, Colors.Blue)
	Activity.LoadLayout("Scan")
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Set Activity title"$, Colors.Blue)
	Activity.Title = Application.LabelName
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Check if it's the FirstTime Activity launch"$, Colors.Blue)
	If FirstTime Then
		LogColor($"[Scan-${LogContextId}] Activity_Create: It's the FirstTime Activity launch"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Get an initial ViewState with default UI element values by resetting the ViewState"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] Activity_Create: The layout files don't always contain default UI element values"$, Colors.Blue)
		ResetViewState
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Constants Class (MyConstants class)"$, Colors.Blue)
		Constants.Initialize
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Common Class (MyCommon class)"$, Colors.Blue)
		Common.Initialize
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the Security Class (MySecurity class)"$, Colors.Blue)
		Security.Initialize
		
	Else
		LogColor($"[Scan-${LogContextId}] Activity_Create: It's not the FirstTime Activity launch"$, Colors.Blue)
		
	End If
	
	'The Activity context must always be fresh,
	'so always re-initialize the joMain JavaObject
	'on every Activity create (not just on FirstTime)
	'
	'This is mandatory for context-dependent functions
	'that receive the Activity context, because they
	'must always have a fresh Activity context handle!
	LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the joScan JavaObject always (not just on FirstTime launch)"$, Colors.Blue)
	joScan.InitializeContext
	
	#If NO_FLAG_SECURE
	'Try to disable Recent Apps thumbnails always even in NO_FLAG_SECURE mode
	LogColor($"[Scan-${LogContextId}] Activity_Create: Verifying if the device Android version is Android 13 or newer (API level >= 33)"$, Colors.Blue)
	If Common.GetAndroidSdkVersion >= 33 Then
		LogColor($"[Scan-${LogContextId}] Activity_Create: This device is running Android version 13 or newer (API level >= 33)"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] Activity_Create: We don't need to add FLAG_SECURE in these newer versions thanks to the new Activity.setRecentsScreenshotEnabled(boolean) API introduced in Android 13+"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly instead"$, Colors.Blue)
		If joScan.RunMethod("jDisableRecentAppsThumbnails", Null) Then
			LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly succeeded"$, Colors.Blue)
			
		Else
			LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly failed"$, Colors.Red)
			
			LogColor($"[Scan-${LogContextId}] Activity_Create: We won't try to add FLAG_SECURE to this Activity instead as a fallback"$, Colors.Red)
			LogColor($"[Scan-${LogContextId}] Activity_Create: This build of the App was specifically built without FLAG_SECURE"$, Colors.Red)
			
			LogColor($"[Scan-${LogContextId}] Activity_Create: Just notify the user about it in a toast notification"$, Colors.Red)
			ToastMessageShow("Failed to disable Recent Apps thumbnail", Constants.TOAST_DURATION_SHORT)
			
		End If
		
	End If
	#Else
	'Add FLAG_SECURE to this Activity View on Activity_Create
	'Add it always, not just on the FirstTime
	LogColor($"[Scan-${LogContextId}] Activity_Create: This build is compiled without NO_FLAG_SECURE, checking if we need to add FLAG_SECURE"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Verifying if the device Android version is Android 13 or newer (API level >= 33)"$, Colors.Blue)
	If Common.GetAndroidSdkVersion >= 33 Then
		LogColor($"[Scan-${LogContextId}] Activity_Create: This device is running Android version 13 or newer (API level >= 33)"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] Activity_Create: We don't need to add FLAG_SECURE in these newer versions thanks to the new Activity.setRecentsScreenshotEnabled(boolean) API introduced in Android 13+"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly instead"$, Colors.Blue)
		If joScan.RunMethod("jDisableRecentAppsThumbnails", Null) Then
			LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly succeeded"$, Colors.Blue)
			
		Else
			LogColor($"[Scan-${LogContextId}] Activity_Create: Disabling Recent Apps thumbnails properly failed"$, Colors.Red)
			
			LogColor($"[Scan-${LogContextId}] Activity_Create: Trying to add FLAG_SECURE to this Activity instead as a fallback"$, Colors.Red)
			If joScan.RunMethod("jEnableActivityFlagSecure", Null) Then
				LogColor($"[Scan-${LogContextId}] Activity_Create: Adding FLAG_SECURE to this Activity as a fallback succeeded"$, Colors.Green)
				
			Else
				LogColor($"[Scan-${LogContextId}] Activity_Create: Adding FLAG_SECURE to this Activity as a fallback failed"$, Colors.Red)
				
				LogColor($"[Scan-${LogContextId}] Activity_Create: Alerting the user about it in a toast notification"$, Colors.Red)
				ToastMessageShow("Failed to secure this App Activity!", Constants.TOAST_DURATION_SHORT)
				ToastMessageShow("The Activity FLAG_SECURE could not be set", Constants.TOAST_DURATION_LONG)
				
			End If
			
		End If
		
	Else
		LogColor($"[Scan-${LogContextId}] Activity_Create: This device is running an Android version older than 13 (API level < 33)"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] Activity_Create: The only way in these older Android versions to block Recent Apps thumbnails is to add FLAG_SECURE to the Activity on create"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Create: Adding FLAG_SECURE to this Activity"$, Colors.Blue)
		If joScan.RunMethod("jEnableActivityFlagSecure", Null) Then
			LogColor($"[Scan-${LogContextId}] Activity_Create: Adding FLAG_SECURE to this Activity succeeded"$, Colors.Blue)
			
		Else
			LogColor($"[Scan-${LogContextId}] Activity_Create: Adding FLAG_SECURE to this Activity failed"$, Colors.Red)
			
			LogColor($"[Scan-${LogContextId}] Activity_Create: Alerting the user about it in a toast notification"$, Colors.Red)
			ToastMessageShow("Failed to secure this App Activity!", Constants.TOAST_DURATION_SHORT)
			ToastMessageShow("The Activity FLAG_SECURE could not be set", Constants.TOAST_DURATION_LONG)
			
		End If
		
	End If
	#End If
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Initialize the QR code reader view"$, Colors.Blue)
	InitializeQRCodeReaderView
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Fixing the Camera preview to be neatly square if needed (on devices without a software NavBar)"$, Colors.Blue)
	FixSquareCameraPreviewIfNeeded
	
	LogColor($"[Scan-${LogContextId}] Activity_Create: Sub return"$, Colors.Blue)
End Sub

Private Sub FixSquareCameraPreviewIfNeeded
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub entry"$, Colors.Blue)
	
	'Only for devices that don't have a NavBar and
	'that have a device scale of 1.0 or higher
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Fetching device's software Navigation bar information and device scale"$, Colors.Blue)
	Dim HasNavBar   As Boolean = joScan.RunMethod("jDeviceHasNavBar", Null)
	Dim DeviceScale As Float   = joScan.RunMethod("jGetDeviceScale", Null)
	
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Acquired device information: HasNavbar   = ${HasNavBar}"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Acquired device information: DeviceScale = ${DeviceScale}"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: If there was any failure getting device information, safe-bet values are returned instead"$, Colors.Green)
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: This is the normal behavior of these device information functions"$, Colors.Green)
	
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Checking if the device is eligible for the square Camera preview fix"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device must not have a software NavBar & have a display scale of atleast 1.0"$, Colors.Blue)
	If HasNavBar Or 1.0 > DeviceScale Then
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device is not eligible for the square Camera preview fix"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device doesn't actually need the square Camera preview fix"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: No need to proceed further"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub return"$, Colors.Blue)
		Return
		
	Else
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device is eligible for the square Camera preview fix"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device needs the square Camera preview fix"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: We need to proceed further"$, Colors.Blue)
		
	End If
	
	'Calibration values are from Huawei P9 Lite
	'
	'This is how the Designer view of the Scan layout
	'was actually created and calibrated,
	'so it's normal that they differ from
	'the standard Android values
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Getting device orientation, because the Camera preview fix is different for each orientation"$, Colors.Blue)
	Dim Orientation As Int = joScan.RunMethod("jGetDeviceOrientation", Null)
	
	If Orientation == Constants.ORIENTATION_PORTRAIT Then
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is portrait, applying the portrait fix"$, Colors.Blue)
		
		'Portrait fix
		lblQRCodeReaderBg.Height   = lblQRCodeReaderBg.Height   - 38dip
		qrvQRCodeReaderView.Height = qrvQRCodeReaderView.Height - 38dip
		
		btnToggleFlash.Top  = btnToggleFlash.Top  - 38dip
		btnSwitchCamera.Top = btnSwitchCamera.Top - 38dip
		btnBack.Top         = btnBack.Top         - 38dip
		
	Else If Orientation == Constants.ORIENTATION_LANDSCAPE Then
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is landscape, applying the landscape fix"$, Colors.Blue)
		
		'Landscape fix
		qrvQRCodeReaderView.Width = qrvQRCodeReaderView.Width - 48dip
		qrvQRCodeReaderView.Left  = qrvQRCodeReaderView.Left  + 24dip 'Re-align the Camera preview on center
		
	Else
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Device orientation is not a supported one (neither portrait nor landscape)"$, Colors.Magenta)
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Maybe this is a truly old legacy device that actually has a fully square display"$, Colors.Magenta)
		
		LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: No need to apply any Camera preview fix, even if the device was eligible"$, Colors.Magenta)
		
	End If
	
	LogColor($"[Scan-${LogContextId}] FixSquareCameraPreviewIfNeeded: Sub return"$, Colors.Blue)
End Sub

#Region Activity resume event handlers

Sub Activity_Resume
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Sub entry"$, Colors.Blue)
	
	'Restoring the ViewState also calls SwitchCamera
	'SwitchCamera already handles restarting the Camera preview
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Restore ViewState"$, Colors.Blue)
	RestoreViewState
	
	LogColor($"[Scan-${LogContextId}] Activity_Resume: Sub return"$, Colors.Blue)
End Sub

#End Region

#Region Activity pause event handlers

Sub Activity_Pause(UserClosed As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Sub entry (UserClosed = ${UserClosed})"$, Colors.Blue)
	
	If Not(UserClosed) Then
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Activity is not UserClosed"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Save ViewState"$, Colors.Blue)
		SaveViewState
		
	End If
	
	'The ViewState saving function doesn't stop the Camera preview
	'because that's not its job, it only saved the current state
	'without affecting it
	'
	'So we have to manually stop the Camera preview on App pause
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Stop the QR code reader view on App pause"$, Colors.Blue)
	StopQRCodeReaderView
	
	'Do this after stopping the QR code reader view
	If UserClosed Then
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Activity is UserClosed"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] Activity_Pause: Calling ActivityExit"$, Colors.Blue)
		ActivityExit
		
	End If
	
	LogColor($"[Scan-${LogContextId}] Activity_Pause: Sub return"$, Colors.Blue)
End Sub

#End Region

Private Sub ActivityExit
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] ActivityExit: Sub entry"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] ActivityExit: Resetting the ViewState to clear all the last selected Camera preview ID etc"$, Colors.Blue)
	ResetViewState
	
	LogColor($"[Scan-${LogContextId}] ActivityExit: Asking the JVM to do a garbage collection as soon as possible"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] ActivityExit: This will clear traces of leftover Camera preview buffers"$, Colors.Blue)
	Security.TriggerJvmGarbageCollection
	
	LogColor($"[Scan-${LogContextId}] ActivityExit: Starting the Main Activity"$, Colors.Blue)
	StartActivity(Main)
	
	LogColor($"[Scan-${LogContextId}] ActivityExit: Finishing this Scan Activity"$, Colors.Blue)
	Activity.Finish()
	
	LogColor($"[Scan-${LogContextId}] ActivityExit: Sub return"$, Colors.Blue)
End Sub

#Region Activity keypress event handlers

Private Sub Activity_KeyPress(KeyCode As Int) As Boolean
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub entry (KeyCode = ${KeyCode})"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Verifying what the KeyCode is"$, Colors.Blue)
	Select Case KeyCode
		Case KeyCodes.KEYCODE_BACK
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: The KeyCode is KEYCODE_BACK"$, Colors.Blue)
			
			'The btnBack_Click already handles stopping
			'the Camera preview and finishing the Activity
			'
			'It event handles resetting the ViewState too
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Simulating a click by the user on the Back button"$, Colors.Blue)
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: This does the same thing as exiting this Scan Activity"$, Colors.Blue)
			btnBack_Click
			
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub return (returning True)"$, Colors.Red)
			Return True
			
		Case Else
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: The KeyCode is something else"$, Colors.Blue)
			LogColor($"[Scan-${LogContextId}] Activity_KeyPress: We don't do anything particular with other KeyCodes"$, Colors.Blue)
			
	End Select
	
	LogColor($"[Scan-${LogContextId}] Activity_KeyPress: Sub return (returning False)"$, Colors.Blue)
	Return False
	
End Sub

#End Region

#End Region

'
'Helper functions ---------------------------------------
'

#Region Helper functions

Private Sub InitializeQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		'QR decoder settings
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing default properties"$, Colors.Blue)
		qrvQRCodeReaderView.QRDecodingEnabled = True
		qrvQRCodeReaderView.AutofocusInterval = 1500
		qrvQRCodeReaderView.ResultPointColor  = Colors.Red
		
		'Don't set any specific Flashlight state
		'in this initialization function
		
		'Set the Camera IDs properly
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing the rear Camera preview ID"$, Colors.Blue)
		qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_REAR
		qrvQRCodeReaderView.setBackCamera()
		
		'Verify if the device has two Cameras first
		'before proceeding further
		LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Checking whether the device has two or more Cameras"$, Colors.Blue)
		If Common.GetNumberOfDeviceCameras >= 2 Then
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: The device has atleast two Cameras"$, Colors.Blue)
			
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Initializing the front Camera preview ID"$, Colors.Blue)
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_FRONT
			qrvQRCodeReaderView.setFrontCamera()
			
		Else
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: The device only has one Camera"$, Colors.Magenta)
			LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: No need to initialize a front Camera preview ID"$, Colors.Magenta)
			
		End If
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[Scan-${LogContextId}] InitializeQRCodeReaderView: Sub entry"$, Colors.Blue)
End Sub

Private Sub StartQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Starting the Camera preview"$, Colors.Blue)
		qrvQRCodeReaderView.Visible = True 'Important or switching Camera preview sides doesn't work
		qrvQRCodeReaderView.startCamera()
		
		LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Start scanning for QR codes"$, Colors.Blue)
		qrvQRCodeReaderView.ScanNow = True
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[Scan-${LogContextId}] StartQRCodeReaderView: Sub return"$, Colors.Blue)
End Sub

Private Sub StopQRCodeReaderView
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Sub entry"$, Colors.Blue)
	
	Try
		'Stop searching for valid QR codes
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Stop scanning for QR codes"$, Colors.Blue)
		qrvQRCodeReaderView.ScanNow = False
		
		'Turn off the Flashlight always when stopping the Camera preview
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Turning off the Flashlight"$, Colors.Blue)
		ToggleFlashlight(Constants.FLASH_SPECIFIC_STATE, Constants.FLASH_OFF)
		
		LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Stopping the Camera preview"$, Colors.Blue)
		qrvQRCodeReaderView.stopCamera()
		qrvQRCodeReaderView.Visible = False 'Important or switching Camera preview sides doesn't work
		
	Catch
		HandleCameraServiceException
	End Try
	
	LogColor($"[Scan-${LogContextId}] StopQRCodeReaderView: Sub return"$, Colors.Blue)
End Sub

Private Sub HandleCameraServiceException
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Sub entry"$, Colors.Red)
	
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: There was a problem dealing with the Camera service:"$, Colors.Red)
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	LogColor(LastException, Colors.Black)
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: ----------------------------------------------------"$, Colors.Red)
	
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Displaying an exception message to the user in a toast notification"$, Colors.Red)
	ToastMessageShow("Camera service failure", Constants.TOAST_DURATION_SHORT)
	
	'Stopping the Camere preview would require Camera service access anyway
	'
	'ActivityExit is used by btnBack_Click but doesn't stop the Camera preview
	'so we can use this function here for exception handling
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Exiting this Scan Activity (returning to the Main Activity)"$, Colors.Red)
	ActivityExit
	
	LogColor($"[Scan-${LogContextId}] HandleCameraServiceException: Sub return"$, Colors.Red)
End Sub

#End Region

'
'UI event handlers -------------------------------------------------------
'

#Region UI event handlers

#Region QR code reader view event handlers

Private Sub qrvQRCodeReaderView_result_found(QRCodeContents As String)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Sub entry (sensitive parameters)"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is literally empty"$, Colors.Blue)
	If QRCodeContents == "" Then
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: The QR code content is literally empty"$, Colors.Magenta)
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main module that this is not a mistake but a real value"$, Colors.Magenta)
		Main.Shared_AllowEmptyQRCodeContent = True
		
	Else
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Checking if the QR code content is not empty"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Telling the Main module that it cans consider empty values as a mistake"$, Colors.Blue)
		Main.Shared_AllowEmptyQRCodeContent = False
		
	End If
	
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Providing the QR code contents to the Main module via a shared process variable"$, Colors.Blue)
	Main.Shared_DetectedQRCodeContents = QRCodeContents
	
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Now simulating the user pressing the Back button to exit this Scan Activity (return to the Main module)"$, Colors.Blue)
	btnBack_Click
	
	LogColor($"[Scan-${LogContextId}] qrvQRCodeReaderView_result_found: Sub return"$, Colors.Blue)
End Sub

#End Region

#Region Toggle Flash button event handlers

Private Sub btnToggleFlash_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub entry"$, Colors.Blue)
	
	'Verify if the device has a Flashlight first
	'before proceeding further.
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Verifying if the device has a Flashlight before proceeding further"$, Colors.Blue)
	If Not(joScan.RunMethod("jDeviceHasFlashlight", Null)) Then
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: The device has no Flashlight, we cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		ToastMessageShow("Flashlight required for the toggle", Constants.TOAST_DURATION_SHORT)
		
		LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: The device has a Flashlight, now we can proceed further"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Calling ToggleFlashlight without requesting any specific state (toggle mode)"$, Colors.Blue)
	ToggleFlashlight(Constants.FLASH_NO_SPECIFIC_STATE, Constants.FLASH_TOGGLE)
	
	LogColor($"[Scan-${LogContextId}] btnToggleFlash_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub ToggleFlashlight(WantsSpecificState As Boolean, WhichOneIfYes As Boolean)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Sub entry (WantsSpecificState = ${WantsSpecificState}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Checking if a specific Flashlight state was requested by the caller"$, Colors.Blue)
	If Not(WantsSpecificState) Then
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: The caller didn't request any specific Flashlight state"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Switch the Flashlight state to the opposite one (current: ${ViewState_qrvQRCodeReaderView_TorchEnabled} -> ${Not(ViewState_qrvQRCodeReaderView_TorchEnabled)})"$, Colors.Blue)
		ViewState_qrvQRCodeReaderView_TorchEnabled = Not(ViewState_qrvQRCodeReaderView_TorchEnabled)
		
	Else
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: The caller requested a specific Flashlight state (${WhichOneIfYes})"$, Colors.Blue)
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Setting the ViewState for the Flashlight state to ${WhichOneIfYes}"$, Colors.Blue)
		ViewState_qrvQRCodeReaderView_TorchEnabled = WhichOneIfYes
		
	End If
	
	Try
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Applying the new Flashlight ViewState to the QR code reader view (setting it to ${ViewState_qrvQRCodeReaderView_TorchEnabled})"$, Colors.Blue)
		qrvQRCodeReaderView.TorchEnabled = ViewState_qrvQRCodeReaderView_TorchEnabled
	Catch
		'Don't exit here because not being able to
		'toggle the Flashlight state is not critical
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: We had a problem applying the new Flashlight state"$, Colors.Red)
		
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		ToastMessageShow("Failed to toggle Flashlight", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Flashlight state
		'(if no specific one was actually requested)
		If Not(WantsSpecificState) Then
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Because no specific Flashlight state was requested, restore the prior value in the ViewState"$, Colors.Red)
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: This helps avoid having an inconsistent state since the state wasn't actually in effect (failed to apply)"$, Colors.Red)
			
			LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Restoring the new Flashlight state value ${ViewState_qrvQRCodeReaderView_TorchEnabled} back to the previous one ${Not(ViewState_qrvQRCodeReaderView_TorchEnabled)}"$, Colors.Red)
			ViewState_qrvQRCodeReaderView_TorchEnabled = Not(ViewState_qrvQRCodeReaderView_TorchEnabled)
			
		End If
	End Try
	
	'Dynamic Torch on / off icon
	If ViewState_qrvQRCodeReaderView_TorchEnabled Then
		'If the Flashlight is on then show the
		'icon for turning it off
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash Off icon since the Flashlight is on"$, Colors.Blue)
		btnToggleFlash.Text = Constants.FLASH_ICON_OFF
		
	Else
		'
		'If the Flashlight is off then show the
		'icon for turning it on
		LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Set the Toggle Flash button .Text to the Flash On icon since the Flashlight is off"$, Colors.Blue)
		btnToggleFlash.Text = Constants.FLASH_ICON_ON
		
	End If
	
	LogColor($"[Scan-${LogContextId}] ToggleFlashlight: Sub return"$, Colors.Blue)
End Sub

#End Region

#Region Switch Camera button event handlers

Private Sub btnSwitchCamera_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub entry"$, Colors.Blue)
	
	'Verify if the device has two Cameras first
	'before proceeding further.
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Verifying if the device has atleast two Cameras before the Camera side switch"$, Colors.Blue)
	If Common.GetNumberOfDeviceCameras < 2 Then
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: The device only has one Camera, cannot proceed further"$, Colors.Magenta)
		
		LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Notify the user about it in a toast notification"$, Colors.Magenta)
		ToastMessageShow("Two Cameras required for the switch", Constants.TOAST_DURATION_SHORT)
		
		LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Magenta)
		Return
		
	End If
	
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: The device has atleast two Cameras, now we can try switching the Camera preview sides"$, Colors.Blue)
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Calling SwitchCamera without requesting any specific side (switch-sides mode)"$, Colors.Blue)
	SwitchCamera(Constants.CAMERA_NO_SPECIFIC_ONE, Constants.CAMERA_ANY)
	
	LogColor($"[Scan-${LogContextId}] btnSwitchCamera_Click: Sub return"$, Colors.Blue)
End Sub

Private Sub SwitchCamera(WantsSpecificCamera As Boolean, WhichOneIfYes As Int)
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Sub entry (WantsSpecificCamera = ${WantsSpecificCamera}, WhichOneIfYes = ${WhichOneIfYes})"$, Colors.Blue)
	
	'Stop the Camera preview
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Starting the Camera preview"$, Colors.Blue)
	StopQRCodeReaderView
	
	'Change the Camera to the opposite side
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Check whether the caller wants a specific Camera side"$, Colors.Blue)
	If Not(WantsSpecificCamera) Then
		LogColor($"[Scan-${LogContextId}] SwitchCamera: The caller does not want any specific Camera side"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Switching the Camera preview ID to the opposite side"$, Colors.Blue)
		If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
			LogColor($"[Scan-${LogContextId}] SwitchCamera: The current opposite side is rear, switchng to front"$, Colors.Blue)
			ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_FRONT
			
		Else
			LogColor($"[Scan-${LogContextId}] SwitchCamera: The current opposite side is front, switchng to rear"$, Colors.Blue)
			ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
			
		End If
		
	Else
		LogColor($"[Scan-${LogContextId}] SwitchCamera: The caller wants a specific Camera side"$, Colors.Blue)
		
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Setting the Camera preview ID to the specifically requested one (${WhichOneIfYes})"$, Colors.Blue)
		ViewState_qrvQRCodeReaderView_PreviewCameraId = WhichOneIfYes
		
	End If
	
	Try
		If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Applying the new Camera preview ID (rear)"$, Colors.Blue)
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_REAR
			qrvQRCodeReaderView.setBackCamera()
			
		Else If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_FRONT Then
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Applying the new Camera preview ID (front)"$, Colors.Blue)
			qrvQRCodeReaderView.PreviewCameraId = Constants.CAMERA_FRONT
			qrvQRCodeReaderView.setFrontCamera()
			
		End If
	Catch
		'Don't exit here because the StopQRCodePreview and
		'StartQRCodePreview Methods already exit on failure
		'
		'And not being able to switch Cameras is not critical
		LogColor($"[Scan-${LogContextId}] SwitchCamera: We had a problem applying the new Camera preview ID"$, Colors.Red)
		
		LogColor($"[Scan-${LogContextId}] SwitchCamera: Because this one is not critical, notify the user in a toast notification"$, Colors.Red)
		ToastMessageShow("Failed to switch Camera preview ID", Constants.TOAST_DURATION_SHORT)
		
		'Restoring the previous ViewState Camera preview ID
		'(if no specific one was actually requested)
		If Not(WantsSpecificCamera) Then
			LogColor($"[Scan-${LogContextId}] SwitchCamera: Because no specific Camera ID was requested, restore the prior value in the ViewState"$, Colors.Red)
			LogColor($"[Scan-${LogContextId}] SwitchCamera: This helps avoid having an inconsistent state since the new ID wasn't actually in effect (failed to apply)"$, Colors.Red)
			
			If ViewState_qrvQRCodeReaderView_PreviewCameraId == Constants.CAMERA_REAR Then
				LogColor($"[Scan-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to the previous value (front)"$, Colors.Red)
				ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_FRONT
				
			Else
				LogColor($"[Scan-${LogContextId}] SwitchCamera: Restoring the ViewState register of the Camera preview ID to the previous value (rear)"$, Colors.Red)
				ViewState_qrvQRCodeReaderView_PreviewCameraId = Constants.CAMERA_REAR
				
			End If
		End If
	End Try
	
	'Resume the Camera preview
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Starting the Camera preview"$, Colors.Blue)
	StartQRCodeReaderView
	
	LogColor($"[Scan-${LogContextId}] SwitchCamera: Sub return"$, Colors.Blue)
End Sub

#End Region

#Region Back button event handlers

Private Sub btnBack_Click
	Dim LogContextId As Int = Rnd(1000, 9999)
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Sub entry"$, Colors.Blue)
	
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Stopping the QR code reader view"$, Colors.Blue)
	StopQRCodeReaderView
	
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Calling the ActivityExit function"$, Colors.Blue)
	ActivityExit
	
	LogColor($"[Scan-${LogContextId}] btnBack_Click: Sub return"$, Colors.Blue)
End Sub

#End Region

#End Region


