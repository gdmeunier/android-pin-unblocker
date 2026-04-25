B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=12
@EndOfDesignText@

#Region  Activity Attributes 
	#FullScreen:   False
	#IncludeTitle: True
	
	'Ignore function value returns warning (2)
	#IgnoreWarnings: 2
#End Region

'
' Needed libraries:
' - https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013
' - https://www.b4x.com/android/forum/threads/clipboard-library.7382/
'

Sub Process_Globals
	'These variables can be accessed from all modules.
	'
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	Private qrReaderView As NewQRCodeReaderView
	
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
			
			// Add FLAG_SECURE to this Window (Activity view)
			this.getWindow().setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE);
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
	qrReaderView.PreviewCameraId = 0
	qrReaderView.setBackCamera()
	
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
	
	qrReaderView.PreviewCameraId = 0
	qrReaderView.setBackCamera()
	
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
	
	'QR decoder settings
	qrReaderView.TorchEnabled = isTorchOn
	qrReaderView.QRDecodingEnabled = True
	qrReaderView.AutofocusInterval = 1500
	qrReaderView.ResultPointColor = Colors.Red
	
	'Set the Camera IDs properly
	qrReaderView.PreviewCameraId = 0
	qrReaderView.setBackCamera()
	qrReaderView.PreviewCameraId = 1
	qrReaderView.setFrontCamera()
	
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
		
		'Display the error dialog
		DisplayCameraErrorDialog
		
		'Return to the Main module as if the user pressed the back key
		btnBack_Click
		
		Log(LastException)
		
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
	
	isTorchOn = Not(isTorchOn)
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
	
End Sub

Private Sub btnSwitchCam_Click
	
	'Disabling the Flashlight when changing camera
	isTorchOn = False
	qrReaderView.TorchEnabled = isTorchOn
	
	'
	'Dynamic torch on/off icon
	'
	btnToggleFlash.Text = "" 'Flash on icon (because flash turned off)
	
	'Change Camera to the opposite side
	isBackCamera = Not(isBackCamera)
	
	StopQrCodeReader
	
	If isBackCamera Then
		qrReaderView.PreviewCameraId = 0
		qrReaderView.setBackCamera()
	Else
		qrReaderView.PreviewCameraId = 1
		qrReaderView.setFrontCamera()
	End If
	
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

