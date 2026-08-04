B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
'
'Important notice:
'
'We want each class in this application to be standalone, so that they don't
'rely on other ones and create dependencies with eachother:
' - So don't hesitate do write two or more times the same function
'   across many classes that need it
'
'I want that people be able to easily extract specific classes from
'this application and reuse them in their own
'
'So all classes should have self-contained functions (not depending on eachother)
'
'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

Sub Class_Globals
	
	'For labeling the lifecycle events of an Activity
	Public Const PAUSE		As String = "[PAUSE]"
	Public Const STOP		As String = "[STOP]"
	Public Const DESTROY	As String = "[DESTROY]"
	Public Const RESTART	As String = "[RESTART]"
	Public Const START		As String = "[START]"
	Public Const CREATE		As String = "[CREATE]"
	Public Const RESUME		As String = "[RESUME]"
	
	'For tracking the lifecycle of an Activity
	Public ActivityLifecycle As String = "" 'Must have a default value
	
	'If an Activity is paused for more than a short while then we
	'mark the pause as being a background device rotation event by
	'resetting its lifecycle tracking
	'
	'This way you can only restore certain sensitive properties if you
	'don't pause the Activity for too long before resuming it again
	'For running the wait code in a separate Thread, to avoid
	'having it get paused when the Activity gets paused
	Public LifecycleClearingThread As Thread
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'Initialize the Activity lifecycle tracking thread
	'It will be named e.g. "ActivityLifecycleTimer_Thread_Ended"
	'
	'Note: "Initialise" is the real function name for
	'      the thread initialization, it's a typo but
	'      that's how the function is actually named
	'
	LifecycleClearingThread.Initialise("LifecycleClearingThread")
	
End Sub

Private Sub LifecycleClearingThread_Ended(Failed As Boolean, ErrorIfAny As String)
	'
	'Nothing to do here
	'
End Sub

Public Sub LifecycleClearingThread_Start
	
	LifecycleClearingThread.Start(Me, "LifecycleClearingThread_Clearing_Thread", Null)
	
End Sub

Private Sub LifecycleClearingThread_Clearing_Thread
	
	'According to the Internet:
	' - "An Android phone typically takes 200 milliseconds to 1 second to rotate an Activity.
	'    This duration is split between physical sensor detection and software layout rendering."
	'
	'Sleep for 2 seconds (this will surely cover even the very slow devices)
	SleepForNewThreads(2000) '2000ms
	
	'After the specified 2s delay, if the Timer wasn't stopped by
	'a quick enough Activity resume we will clear the Activity's
	'lifecycle tracking value to prevent it from matching a
	'foreground device rotation lifecycle
	ActivityLifecycle = ""
	
End Sub

'Synchronous sleep workaround because new threads need it
'Basic4Android's sleep function is asynchronous...
'
'Basic4Android's sleep call also sleeps the Main thread,
'not the new threads' that are created in this class
Private Sub SleepForNewThreads(Milliseconds As Int)
	
	'Don't directly sleep the thread for (Milliseconds value)
	'
	'Sleeping threads don't receive interrupts and therefore this thread
	'won't be able to abort early when Activity_Resume sends an interrupt call
	'in order to allow preserving the Activity lifecycle tracking value
	Dim DueTime As Long = DateTime.Now + Milliseconds
	
	Do While DateTime.Now < DueTime
		
		'You must use very short sleep durations, so that the
		'lifecycle tracking thread quickly receives any
		'interrupt call when an Activity's Activity_Resume wants to
		'stop it early before it clears its lifecycle tracking value
		LifecycleClearingThread.Sleep(20)
		
	Loop
	
End Sub

Public Sub LifecycleClearingThread_Stop
	
	LifecycleClearingThread.Interrupt
	
End Sub

'Activity lifecycles and their fingerprints:
' - Pause, Stop, Destroy,          Start, Create, Resume = Foreground rotation
' - Pause, Stop,          Restart, Start,         Resume = Activity pause to background & resume to foreground
' -              Destroy,          Start, Create, Resume = Background rotation (outside of the Activity)
'
Public Sub WasForegroundRotation(Lifecycle As String) As Boolean
	
	'Foreground device rotation lifecycle
	If Lifecycle == PAUSE & STOP & DESTROY & START & CREATE & RESUME Then
		Return True
	End If
	
	Return False
	
End Sub


'Foreground Activity pause & resume is when the application's Activity loses focus then
'regains it, but the application's Activity was always visible in the foreground
'
'In an ideal scenario the Activity lifecycle looks like this:
' - Pause,                                        Resume = Activity pause & resume while always in foreground
'
'But it's also possible that the Activity lifecycle tracking was cleared by
'the Activity's lifecycle tracking thread, which is started by
'the Activities' Activity_Pause Subs
'
'This will actually very much happen in almost all cases because the
'Activities' lifecycle tracking thread has a short enough delay of 2 seconds (2000ms)
'before clearing it post-Activity pause
'
'In such most-likely cases the Activity lifecycle looks like this:
' -                                               Resume = Activity pause & resume while always in foreground
'
'Notice how the Activity lifecycle will then just be [Resume] without the prior [Pause]
'
'If the Activity is truly paused (screen turned off or Activity put in the background),
'then Android fires another Pause followed by a Stop event:
'
' - [Pause][Pause][Stop]
' - ^Prior foreground Pause
'          ^Pause because of app being put in the background
'                 ^The app is now in the background
'
'And this of course leads to later firing the Restart & Start Lifecycles before
'reaching the Resume one:
'
' - [Restart][Start][Resume]
'
'So it's very easy to distinguish Activity pause & resumes made while in
'the foreground only versus those made with the Activity is in the background
'
'So to conclude, a foreground-only Activity pause & resume is either one of:
' - Pause,                                        Resume = Activity pause & resume while always in foreground
' -                                               Resume = Activity pause & resume while always in foreground
'
Public Sub WasForegroundPause(Lifecycle As String) As Boolean
	
	'Activity pause & resumes made all while the Activity is in
	'the foreground only (always visible to the user)
	If Lifecycle == PAUSE & RESUME _
	Or Lifecycle ==         RESUME Then
		'The Lifecycle == Resume check might 'accidentally mistake' as a
		'foreground Activity pause & resume the cases where the user clicks on
		'one of an Activity's UI buttons, then this button runs a function which
		'starts another Activity:
		' - For example, clicking on Scan QR code button in the Main Activity,
		'   then the user takes a while to scan a QR code and comes back to
		'   the Main Activity
		'
		'In such cases for example, the Admin Key field is not hidden when you
		'come back from scanning a QR code in the Scan Activity
		'
		'However this is not a bug, it's as intended:
		' - The Activity was always in the foreground (not put in the background)
		'
		'So preventing e.g. the Admin key from being 'shown when you come back to
		'the Main Activity, after coming back from e.g. the Scan Activity,
		'is the responsibility of the Activities' themselves:
		' - It's their own job (own responsibility), and they have to censor
		'   their sensitive information themselvs prior to running another Activity
		'
		' - It's not the job of this function (nor this class a whole) to
		'   accomodate such scenarios where the Activity is always in the foreground
		'
		'TLDR: This check will also give a 'false positive' result even when you were
		'      not in the target Activity for a while, then come back to it from
		'      another one:
		'       - Android will not put your application's Activities in
		'         the background unless *none* of its Activities are visible
		'
		'       - If any Activity from your application is visible, then none of them
		'         actually get put in the background, although they do get destroyed
		'         after a long while if they stay paused for too long
		'
		'So again the Activities themselves are responsible for hiding their
		'sensitive information before launching other Activities
		'
		Return True
		
	End If
	
	Return False
	
End Sub


