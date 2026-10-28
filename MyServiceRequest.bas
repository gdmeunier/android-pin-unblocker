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
	
End Sub

'Initializes the object.
'You can add parameters to this method if needed.
Public Sub Initialize(TheTargetService As Object, TheCaller As Object, TheCallerSubName As String)
	
	TargetService = TheTargetService
	Caller        = TheCaller
	CallerSubName = TheCallerSubName
	
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
	
	'The "MyServiceRequest" Object is "Me"
	CallSubDelayed2(TargetService, "Service_Message", Me.As(MyServiceRequest))
	Wait For ServiceRequest_Completed(ServiceResponse As MyServiceResponse)
	
	CallSubDelayed2(Caller, CallerSubName&"_ServiceRequest_Completed", ServiceResponse)
	
End Sub


