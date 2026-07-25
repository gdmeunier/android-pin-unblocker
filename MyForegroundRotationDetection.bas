B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

Sub Class_Globals
	
	'For tracking the Activity lifecycle of the Activity
	Public ActivityLifecycle As String = "" 'Must have a default value
	
	'
	'If the app is paused for more than a small delay
	'then we mark the pause as background rotation
	'by resetting its lifecycle tracking
	'
	'This way you can only restore certain
	'sensitive properties if you don't
	'pause the app for too long before resuming it
	'
	
	'For labelling the Activity lifecycle events of the Activity
	Public Const Pause		As String = "[PAUSE]"
	Public Const Stop		As String = "[STOP]"
	Public Const Destroy	As String = "[DESTROY]"
	Public Const Restart	As String = "[RESTART]"
	Public Const Start		As String = "[START]"
	Public Const Create		As String = "[CREATE]"
	Public Const Resume		As String = "[RESUME]"
	
	'For running the Timer in a separate Thread,
	'to avoid having it get paused when the app is paused
	Public ActivityLifecycleTrackingThread As Thread
	
End Sub

Public Sub Initialize
	
	'Initialize the Thread end event for this Thread
	'It will be named e.g. "ActivityLifecycleTimer_Thread_Ended"
	ActivityLifecycleTrackingThread.Initialise("ActivityLifecycleTimer_Thread")
	
End Sub

'
'Pause, Stop, Destroy,          Start, Create, Resume = Foreground rotation
'Pause, Stop,          Restart, Start,         Resume = App pause & resume
'             Destroy,          Start, Create, Resume = Background rotation (outside of the app)
'
Sub CheckIfForegroundRotation(MyActivityLifecycle As String) As Boolean
	
	If MyActivityLifecycle == Pause & Stop & Destroy & Start & Create & Resume Then
		Return True
	End If
	
	Return False
	
End Sub

Sub ActivityLifecycleTimer_Start
	
	ActivityLifecycleTrackingThread.Start(Me, "ActivityLifecycleTimer_Start_NewThread", Null)
	
End Sub

Sub ActivityLifecycleTimer_Stop
	
	ActivityLifecycleTrackingThread.Interrupt
	
End Sub

Private Sub ActivityLifecycleTimer_Thread_Ended(Failed As Boolean, ErrorIfAny As String)
	'
	'Nothing to do here
	'
End Sub

Private Sub ActivityLifecycleTimer_Start_NewThread
	'
	'According to the Internet:
	'
	' - "An Android phone typically takes 200 milliseconds to 1 second to rotate an Activity.
	'    This duration is split between physical sensor detection and software layout rendering."
	'
	'Sleep 2 seconds (this will surely cover even the very slow devices)
	SleepForNewThreads(2000)
	
	'After the specified 2s delay, if the Timer wasn't stopped
	'by a quick enough Activity resume we will clear the
	'Activity's lifecycle tracking to prevent it from matching
	'a foreground device rotation lifecycle
	ActivityLifecycle = ""
	
End Sub

'Synchronous Sleep workaround because new Threads need it
'Basic4Android's Sleep function is asynchronous...
'
'Basic4Android's Sleep call also sleeps the Main Thread,
'not the new Threads that are created here
Private Sub SleepForNewThreads(Milliseconds As Int)
	
	Dim DueTime As Long = DateTime.Now + Milliseconds
	
	Do While DateTime.Now < DueTime
		
		ActivityLifecycleTrackingThread.Sleep(20)
		
	Loop
	
End Sub


