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
	
	Private TargetServiceRequest As Object
	
	Private IsSuccessful As Boolean = True 'True by default
	Private Replies()    As String
	
	'For being able to do synchronous sleep
	Private Common As MyCommon
	
End Sub

'Initializes the object.
'You can add parameters to this method if needed.
Public Sub Initialize(TheTargetServiceRequest As Object)
	
	TargetServiceRequest = TheTargetServiceRequest
	
	'For being able to do synchronous sleep
	Common.Initialize
	
End Sub

Public Sub SetIsSuccessful(TheIsSuccessful As Boolean)
	
	IsSuccessful = TheIsSuccessful
	
End Sub
Public Sub GetIsSuccessful As Boolean
	
	Return IsSuccessful
	
End Sub

Public Sub SetReplies(TheReplies() As String)
	
	Replies = TheReplies
	
End Sub
Public Sub GetReplies As String()
	
	Return Replies
	
End Sub

'
'Convenience methods to get and set a single reply easily
'
Public Sub SetReply(TheReply As String)
	
	SetReplies(Array As String(TheReply))
	
End Sub
Public Sub GetReply As String
	
	Dim TheReplies() As String = GetReplies
	Return TheReplies(0)
	
End Sub

'
'Convenience methods to easily send and receive
'Service messages without using CallSubDelayed
'everytime we want to send a message manually
'
Public Sub SendResponse
	
	'Check if the original Service caller is not paused,
	'because perhaps the user switched to a different application
	'while the called Service was processing the request of
	'that original Activity
	'
	'If it's paused, then bring it back to front which resumes
	'the original Activity before sending the completed event
	Dim OriginServiceRequest As MyServiceRequest = TargetServiceRequest.As(MyServiceRequest)
	Dim OriginCaller         As Object           = OriginServiceRequest.GetCaller
	
	'Make sure to specifically confirm that it's paused,
	'so don't use e.g. "Not(IsPaused(OriginCaller))" because
	'this this would also match those that are not yet run
	If IsPaused(OriginCaller) Then
		
		'Basic4Android does not recommend starting Activities from a Service,
		'but in this case we only start the Activity if it's actually paused
		'
		'So what this will do is actually bring the existing Activity
		'back to foreground, not starting a new one
		'
		'This is also what the user wants, they want to be able to immediately
		'get the result of the requested Service operation even while they are
		'using a different application while this Service operation completes
		StartActivity(OriginCaller)
		
		'Wait 475ms before actually proceeding further
		'for the Activity to be visually brought back
		'to the foreground before sending the event
		'
		'475ms = (500 - 25)ms
		Common.SynchronousSleep(475, Me, "SendResponse")
		Wait For SynchronousSleep_SendResponse_Completed
		
	End If
	
	'Add an asynchronous sleep delay (async Sleep):
	' - It has been noticed that on very fast devices,
	'   such as the latest smartphones,
	'   the Direct Unblock completes *so fast* that
	'   it completes before the caller's "Wait For"
	'   even has the time to actually start waiting
	'   for the Direct Unblock result
	'
	Sleep(25)
	
	'The "MyServiceResponse" Object is "Me"
	CallSubDelayed2(TargetServiceRequest, "ServiceRequest_Completed", Me.As(MyServiceResponse))
	
End Sub


