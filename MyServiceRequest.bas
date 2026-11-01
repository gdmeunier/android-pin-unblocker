B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Class File Attributes
	
#End Region

'
'This class allows easily calling Services and
'receiving replies from the Smartcard service
'with a "MyServiceResponse" Object
'

Sub Class_Globals
	
	Private TargetService As Object
	
	Private Caller        As Object
	Private CallerSubName As String
	
	Private Operation    As Int
	Private Parameters() As String
	
	'For being able to do synchronous sleep
	Private Common As MyCommon
	
End Sub

'Initializes the object.
'You can add parameters to this method if needed.
Public Sub Initialize(TheTargetService As Object, TheCaller As Object, TheCallerSubName As String)
	
	TargetService = TheTargetService
	Caller        = TheCaller
	CallerSubName = TheCallerSubName
	
	'For being able to do synchronous sleep
	Common.Initialize
	
End Sub

Public Sub GetCaller As Object
	
	Return Caller
	
End Sub
Public Sub GetCallerSubName As String
	
	Return CallerSubName
	
End Sub

Public Sub SetOperation(TheOperation As Int)
	
	Operation = TheOperation
	
End Sub
Public Sub GetOperation As Int
	
	Return Operation
	
End Sub

Public Sub SetParameters(TheParameters() As String)
	
	Parameters = TheParameters
	
End Sub
Public Sub GetParameters As String()
	
	Return Parameters
	
End Sub

'
'Convenience methods to get and set a single parameter easily
'
Public Sub SetParameter(TheParameter As String)
	
	SetParameters(Array As String(TheParameter))
	
End Sub
Public Sub GetParameter As String
	
	Dim TheParameters() As String = GetParameters
	Return TheParameters(0)
	
End Sub

'
'Convenience methods to easily send and receive
'Service messages without using CallSubDelayed
'everytime we want to send a message manually
'
Public Sub SendRequest
	
	'Check if the target Service is running:
	' - IsPaused cans be used here because it also
	'   returns True for components that are
	'   not started yet, so if the target Service
	'   is already running, then it returns False
	'
	If IsPaused(TargetService) Then
		
		'The target Service is not running yet,
		'so start it now
		StartService(TargetService)
		
		'Sleep 275ms to let the target Service
		'have enough time to initialize properly
		'
		'275ms = (300 - 25)ms
		Common.SynchronousSleep(275, Me, "SendRequest")
		Wait For SynchronousSleep_SendRequest_Completed
		
	End If
	
	'The "MyServiceRequest" Object is "Me"
	CallSub2(TargetService, "Service_Message", Me.As(MyServiceRequest))
	Wait For ServiceRequest_Completed(ServiceResponse As MyServiceResponse)
	
	'Add an asynchronous sleep delay (async Sleep):
	' - It has been noticed that on very fast devices,
	'   such as the latest smartphones,
	'   the Direct Unblock completes *so fast* that
	'   it completes before the caller's "Wait For"
	'   even has the time to actually start waiting
	'   for the Direct Unblock result
	'
	Sleep(25)
	
	CallSubDelayed2(Caller, CallerSubName&"_ServiceRequest_Completed", ServiceResponse)
	
End Sub


