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
'Pause, Stop,          Restart, Start,         Resume = App pause to background & resume to foreground
'             Destroy,          Start, Create, Resume = Background rotation (outside of the app)
'
'Note:
' - We actually allow considering as 'foreground rotation'
'   the *foreground*-only app pause & resumes
'
' - Foreground app pause & resume is when the app's
'   Activity loses focus then regains it,
'   but the app was always visible in the foreground
'
'In the ideal cases the Activity lifecycle looks like this:
'Pause,                                        Resume = App pause & resume while always in foreground
'
'But it's also possible that the Activity lifecycle tracking was
'cleared by the Activity lifecycle tracking thread,
'which is started by the Activities' App_Pause Subs
'
'This actually will very likely happen in most cases because
'the Activity lifecycle tracking thread has a short enough delay
'of 2 secondds (2000ms) delay before clearing it after Activity pause
'
'In these likely cases the Activity lifecycle looks like this:
'                                              Resume = App pause & resume while always in foreground
'
'Notice how the Activity lifecycle will then just be
'[Resume] without the prior [Pause]
'
'If the app is truly paused (screen turned off of app put in background)
'then Android fires another Pause followed by a Stop event
'
'[Pause][Pause][Stop]
'^Prior foreground Pause
'       ^Pause because of app being put in the background
'              ^The app is now in the background
'
'And this of course leads to later firing the Restart & Start Lifecycles
'before reaching a Resume one
'
'[Restart][Start][Resume]
'
'So it's very easy to distinguish app pauses & resumes made
'while in the foreground only vs. those made with the app in background
'
'So to conclude, a foreground-only app pause & resume is either one of:
'Pause,                                        Resume = App pause & resume while always in foreground
'                                              Resume = App pause & resume while always in foreground
'
Sub CheckIfForegroundRotation(MyActivityLifecycle As String) As Boolean
	
	'Foreground device rotation lifecycle
	If MyActivityLifecycle == Pause & Stop & Destroy & Start & Create & Resume Then
		Return True
	End If
	
	'App pauses & resumes made all while the app is
	'in the foreground only (always visible)
	'
	'Such Activity Lifecycles are whitelisted and
	'considered as foreground device rotation for
	'the callers of this CheckIfForegroundRotation Sub
	If MyActivityLifecycle == Pause & Resume _
	Or MyActivityLifecycle ==         Resume Then
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


