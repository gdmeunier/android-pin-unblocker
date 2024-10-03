B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=12
@EndOfDesignText@

#Region  Activity Attributes 
	#FullScreen:   False
	#IncludeTitle: True
	
	'Ignore function value returns warning
	#IgnoreWarnings: 2
#End Region

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	
	Private qrReaderView As NewQRCodeReaderView
	
	Private btnSwitchCam   As Button
	Private btnToggleFlash As Button
	
	Private btnBack As Button
	
	Private isBackCamera  As Boolean
	Private isTorchOn     As Boolean
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	Activity.LoadLayout("ScanLayout")
	
	InitializeQrCodeReader
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
	
	isTorchOn = False
	qrReaderView.TorchEnabled = isTorchOn
	
End Sub

Sub Activity_Resume
	
	StartQrCodeReader
	
End Sub

'
'Helper code
'

Private Sub InitializeQrCodeReader As Void
	
	isBackCamera = True
	isTorchOn    = False
	
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
	
	'Now always rear Camera first
	qrReaderView.PreviewCameraId = 0
	qrReaderView.setBackCamera()
	
End Sub

Private Sub StartQrCodeReader As Void
	
	qrReaderView.Visible = True
	
	qrReaderView.startCamera()
	qrReaderView.ScanNow = True
	
End Sub

Private Sub StopQrCodeReader As Void

	qrReaderView.stopCamera()
	qrReaderView.ScanNow = False
	
	qrReaderView.Visible = False
	
End Sub

Private Sub ExitScanLayout As Void
	
	ExitScanLayoutInternal(False)
	
End Sub

Private Sub ExitScanLayoutInternal(NoActivityStart As Boolean) As Void
	
	StopQrCodeReader
	
	isBackCamera = True
	isTorchOn    = False
	
	qrReaderView.TorchEnabled = isTorchOn
	
	'Close this Activity once no longer needed
	'
	Activity.Finish()
		
	'Return to the Main Android PIN Unblocker activity
	'
	If NoActivityStart == False Then
		StartActivity(Main)
	End If
	
End Sub

'
'UI event handlers
'

Private Sub qrReaderView_result_found(ReturnValue As String)
	
	Dim shareIntent As Intent
	shareIntent.Initialize(shareIntent.ACTION_SEND, "")
	
	shareIntent.SetPackage("net.generic.smartcardpuk")
	shareIntent.SetType("text/plain")
	shareIntent.PutExtra("android.intent.extra.CHALLENGE_CODE", ReturnValue)
	
	StartActivity(shareIntent)
	ExitScanLayoutInternal(True)
	
End Sub

Private Sub btnToggleFlash_Click
	
	isTorchOn = Not(isTorchOn)
	qrReaderView.TorchEnabled = isTorchOn
	
End Sub

Private Sub btnSwitchCam_Click
	
	'Disabling the Flashlight when changing camera
	isTorchOn = False
	qrReaderView.TorchEnabled = isTorchOn
	
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

Sub Process_Globals
	
End Sub

