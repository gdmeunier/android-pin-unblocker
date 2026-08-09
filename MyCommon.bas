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
	
	'To ensure correct running functions order'
	'
	'Using SynchronousSleep2 as the name because
	'Basic4Android doesn't allow the SynchronousSleep name
	'to be the same as the SynchronousSleep2 Sub's name
	'
	' - (Variable SynchronousSleep2 cannot have the same name
	'    as the SynchronousSleep Sub)
	'
	Private SynchronousSleep2 As MySynchronousSleep
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
	'To ensure correct running functions order
	SynchronousSleep2.Initialize
	
End Sub

Public Sub Throw(Message As String)
	
	joClass.RunMethod("jThrow", Array(Message))
	
End Sub
#If Java
import java.lang.RuntimeException;
public static void jThrow(final String message) throws RuntimeException
{
	throw new RuntimeException(message);
}
#End If

Public Sub SynchronousSleep(Milliseconds As Int, OriginActivityCaller As Object, SubName As String)
	
	SynchronousSleep2.SynchronousSleep_Start(Milliseconds, Me, "SynchronousSleep")
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

Public Sub GetSquareIconSizeForDisplayScale As Int
	'
	'Get better-adapted icons according to device's display scale
	'
	Dim DisplayScale   As Float = GetDeviceLayoutValues.Scale
	Dim SquareIconSize As Int   = Application.Icon.Height
	
	If DisplayScale < 1.0 Then
		'If the display scale is 0.75 (120dpi / ldpi) etc
		SquareIconSize = 36 'Or 32
		
	Else If DisplayScale < 1.5 Then
		'If the display scale is 1.0 (160dpi / mdpi) etc
		SquareIconSize = 48
		
	Else If DisplayScale < 2.0 Then
		'If the display scale is 1.5 (240dpi / hdpi) etc
		SquareIconSize = 72 'or 64
		
	Else If DisplayScale < 3.0 Then
		'If the display scale is 2.0 (320dpi / xhdpi) etc
		SquareIconSize = 96
		
	Else If DisplayScale < 4.0 Then
		'If the display scale is 3.0 (480dpi / xxhdpi) etc
		SquareIconSize = 144
		
	Else If DisplayScale < 5.0 Then
		'If the display scale is 4.0 (640dpi / xxxhdpi) etc
		SquareIconSize = 192
		
	End If
	
	'If device scale is 5.0 or higher?
	'
	'Who knows, perhaps mobile devices in 2030 will have insane
	'display scales like that, but then you probably want to atleast
	'have the actual icon size as the recommended square icon for your display
	'
	'Let's hope that theapplication's current 256px size is enough
	'for your future 8K mobile phone displays I guess
	Return SquareIconSize
	
End Sub

'For correcting the flawed monospace font implementation of Android which
'does not correctly make the EditTexts monospace on some older devices
Public Sub ForceCorrectMonospaceFont(MyEditText As EditText)
	joClass.RunMethod("jForceCorrectMonospaceFont", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.widget.TextView;
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
import android.widget.TextView;
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
#If Java
//
// For caching purposes
// Their respective imports are located at the top their method
//
private Resources cachedContextResources = null;

import android.content.Context;
import android.app.Activity;
import android.content.res.Resources;
import android.content.res.Configuration;
public float jGetUserFontScale(Context ctx)
{
	Resources ctxRes;
	
	if ( cachedContextResources != null )
	{
		ctxRes = cachedContextResources;
	}
	else
	{
		ctxRes = ctx.getResources();
		cachedContextResources = ctxRes;
	}
	//
	// Don't cache this information
	//
	Configuration cfg = ctxRes.getConfiguration();
	return cfg.fontScale;
}
#End If


