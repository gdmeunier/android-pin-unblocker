B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

'
'This class uses a mix of Java native and Basic-code
'
'Also notice that all its Java functions are "public" here:
' - Because this is required for accessing them via a JavaObject,
'   since we're initializing a 'new instance' of it:
'
'   And this is exactly as if we were not part of this class itself,
'   so we cannot access private functions via a JavaObject
'
'    Only this class's Java native functions themselves can do this
'

Sub Class_Globals
	
	'For running Java native code
	Private joClass As JavaObject
	
	'To ensure correct running functions order:
	' - (Variable SynchronousSleepClass cannot have
	'    the same name as the SynchronousSleep Sub)
	'
	Private SynchronousSleepClass As MySynchronousSleep
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
	'To ensure correct running functions order
	SynchronousSleepClass.Initialize
	
End Sub

Public Sub SynchronousSleep(Milliseconds As Int, OriginActivityCaller As Object, SubName As String)
	
	SynchronousSleepClass.SynchronousSleep_Start(Milliseconds, Me, "SynchronousSleep")
	Wait For SynchronousSleep_SynchronousSleep_Completed
	
	CallSubDelayed(OriginActivityCaller, "SynchronousSleep_"&SubName&"_Completed")
	
End Sub

Public Sub GetAndroidApiLevel As Int
	Return joClass.RunMethod("jGetAndroidApiLevel", Null)
End Sub
#If Java
import android.os.Build;
public static int jGetAndroidApiLevel()
{
	return Build.VERSION.SDK_INT;
}
#End If

Public Sub GetDeviceCamerasCount As Int
	Return joClass.RunMethod("jGetDeviceCamerasCount", Null)
End Sub
#If Java
import android.os.Build;
import android.hardware.Camera;
public static int jGetDeviceCamerasCount()
{
	int camerasCount = 0;
	
	// Android Android 2.3.2 or higher only (API level 9+)
	// We use APIs that require atleast this version
	//
	if ( Build.VERSION.SDK_INT < 9 )
	{
		return camerasCount;
	}
	
	try
	{
		camerasCount = Camera.getNumberOfCameras();
	}
	catch (Exception e)
	{
		/* Consider that there's no device Camera if this function fails
		 */
		camerasCount = 0;
	}
	
	return camerasCount;
}
#End If

'For correcting the flawed monospace font implementation of Android which
'does not correctly make the EditTexts monospace on some older devices
Public Sub ForceCorrectMonospaceFont(MyEditText As EditText)
	joClass.RunMethod("jForceCorrectMonospaceFont", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.graphics.Typeface;
public static void jForceCorrectMonospaceFont(EditText myEditText)
{
	// Two functions actually exist with different parameters
	// We just call both of them for extra-just-in-case reasons
	//
	myEditText.setTypeface(Typeface.MONOSPACE);
	myEditText.setTypeface(Typeface.MONOSPACE, Typeface.NORMAL);
}
#End If

Public Sub ForceCorrectMonospaceFontDigits(MyEditText As EditText)
	joClass.RunMethod("jForceCorrectMonospaceFontDigits", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
public static void jForceCorrectMonospaceFontDigits(EditText myEditText)
{
	// Android 5.0 or higher only (API level 21+)
	// This function didn't exist on older verions
	//
	if ( Build.VERSION.SDK_INT >= 21 ) /* Android 5.0+ */
	{
		myEditText.setFontFeatureSettings("tnum");
	}
}
#End If

'For forcing the multiline EditText fields to have
'the Next action button instead of the Enter one,
'incase we filter the newlines anyway (e.g. Admin key field)
'Public Sub ForceCorrectEditorActionToNext(MyEditText As EditText)
'	joClass.RunMethod("jForceCorrectEditorActionToNext", Array(MyEditText))
'End Sub
#If Java
/* ***** **
import android.widget.EditText;
import android.os.Build;
import android.view.inputmethod.EditorInfo;
public static void jForceCorrectEditorActionToNext(EditText myEditText)
{
	// IME_FLAG_NO_ENTER_ACTION, IME_MASK_ACTION & IME_ACTION_NEXT
	// are only available on Android 1.5+ (API level 3+):
	//  - Same thing for "setImeActionLabel" (API level 3+)
	//
	if ( Build.VERSION.SDK_INT >= 3 ) // Android 1.5+
	{
		int imeOptions = myEditText.getImeOptions();
		
		imeOptions = imeOptions |  EditorInfo.IME_MASK_ACTION | EditorInfo.IME_ACTION_NEXT;
		imeOptions = imeOptions & ~EditorInfo.IME_FLAG_NO_ENTER_ACTION;
		
		myEditText.setImeOptions(imeOptions);
		myEditText.setImeActionLabel("Next", EditorInfo.IME_ACTION_NEXT);
	}
}
** ***** */
#End If

'For knowing how many lines a text will take if it's wrapped,
'then determining how many pixels it will be in height:
' - This does look a bit like Magick indeed
'
Public Sub GetTextDisplayHeight(Text As String, TextSize As Int, MaxContainerWidth As Int, SoftwareNavBarWidth As Int, UserFontScale As Float) As Int
	'
	' - SoftwareNavBarWidth is directly provided in actual pixels value
	'
	' - MaxContainerWidth is also a raw pixels value but it includes the
	'   the software NavBar as 'available width' despite this being false
	'
	'   That's why we correct this in our own copy of it named "MaxWidth"
	'
	Dim TextHeight As Int = TextSize * GetDeviceLayoutValues.Scale * UserFontScale
	
	'We consider that the text height is equal to its width,
	'as if all characters were square-sized
	Dim TextWidth  As Int = TextHeight * Text.Length
	Dim MaxWidth   As Int = MaxContainerWidth - SoftwareNavBarWidth
	
	'Check if the text will be wrapped in line breaks
	If TextWidth > MaxWidth Then
		
		Dim TextLinesCount As Int = 1 'Always start with 1 as the lines count (not 0)
		
		Do Until TextWidth <= MaxWidth
			TextWidth      = TextWidth - MaxWidth
			TextLinesCount = TextLinesCount + 1
		Loop
		
		TextHeight = TextHeight * TextLinesCount 'Now the height is (height) * (lines count)
		
	End If
	
	Return TextHeight
	
End Sub


