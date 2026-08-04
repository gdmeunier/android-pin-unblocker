B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Class File Attributes
	'Ignore "Variable x was not initialized" warning (#11)
	#IgnoreWarnings: 11
	
#End Region

'
'This class is a subclass of the MyCommon one
'
'It should not directly be used as-is, use it through
'the MyCommon class only
'

Sub Class_Globals
	
	'To ensure correct running functions order
	Private SynchronousSleepThread As Thread
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'To ensure correct running functions order
	'
	'Note: "Initialise" is the real function name for
	'      the thread initialization, it's a typo but
	'      that's how the function is actually named
	'
	SynchronousSleepThread.Initialise("SynchronousSleepThread")
	
End Sub

Private Sub SynchronousSleepThread_Ended(Failed As Boolean, ErrorIfAny As String)
	
End Sub

Public Sub SynchronousSleep_Start(Milliseconds As Int, OriginClassCaller As Object, SubName As String)
	
	SynchronousSleepThread.Start(Me, "SynchronousSleep_Sleep_Thread", Array(Milliseconds, Me))
	Wait For SynchronousSleep_Completed
	
	CallSubDelayed(OriginClassCaller, "SynchronousSleep_"&SubName&"_Completed")
	
End Sub

Private Sub SynchronousSleep_Sleep_Thread(Milliseconds As Int, ThisClassCaller As Object)
	
	SleepForNewThreads(Milliseconds)
	CallSubDelayed(ThisClassCaller, "SynchronousSleep_Completed")
	
End Sub

Private Sub SleepForNewThreads(Milliseconds As Int)
	
	Dim DueTime As Long = DateTime.Now + Milliseconds
	
	Do While DateTime.Now < DueTime
		SynchronousSleepThread.Sleep(20)
	Loop
	
End Sub

