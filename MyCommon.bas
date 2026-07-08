B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

Sub Class_Globals
	
	'For running Java native code
	Private joMyCommon As JavaObject
	
End Sub

Public Sub Initialize
	
	'For running Java native code
	joMyCommon.InitializeStatic(Application.PackageName&".mycommon")
	
End Sub

'For getting the Android SDK version without
'bundling the big Phone library
Public Sub GetAndroidSdkVersion As Int
	Return joMyCommon.RunMethod("jGetAndroidSdkVersion", Null)
End Sub
#If Java
import android.os.Build;
public static int jGetAndroidSdkVersion() {
	return Build.VERSION.SDK_INT;
}
#End If

'For getting the number of device Cameras without
'bundling the big Phone library
Public Sub GetNumberOfDeviceCameras As Int
	Return joMyCommon.RunMethod("jGetNumberOfDeviceCameras", Null)
End Sub
#If Java
import android.os.Build;
import android.hardware.Camera;
public static int jGetNumberOfDeviceCameras()
{
	int numCameras;
	
	// Check if Android API level 9+ (Android 2.3+)
	if ( Build.VERSION.SDK_INT >= 9 )
	{
		/* Android 2.3+ */
		try
		{
			numCameras = Camera.getNumberOfCameras();
		}
		catch (Exception e)
		{
			// Consider that there's no device Camera
			// if this function fails
			numCameras = 0;
		}
	}
	else
	{
		// Consider that there's no device Camera
		// on devices that are too old for getting
		// the number of device Cameras via API
		numCameras = 0;
	}
	
	return numCameras;
}
#End If

'For truly exiting the App
Public Sub TrueApplicationExit
	joMyCommon.RunMethod("jTrueApplicationExit", Null)
End Sub
#If Java
public static void jTrueApplicationExit() {
	System.exit(0);
}
#End If

Public Sub GetSquareIconSizeForDeviceScale As Int
	
	'Get better-adapted icons according to screen DPI & scale
	Dim DeviceScale    As Float = GetDeviceLayoutValues.Scale
	Dim SquareIconSize As Int   = Application.Icon.Height
	
	If DeviceScale < 1.0 Then
		'If the device scale is 0.75 (120dpi / ldpi) etc
		SquareIconSize = 36 'Or 32
		
	Else If DeviceScale < 1.5 Then
		'If the device scale is 1.0 (160dpi / mdpi) etc
		SquareIconSize = 48
		
	Else If DeviceScale < 2.0 Then
		'If the device scale is 1.5 (240dpi / hdpi) etc
		SquareIconSize = 72 'or 64
		
	Else If DeviceScale < 3.0 Then
		'If the device scale is 2.0 (320dpi / xhdpi) etc
		SquareIconSize = 96
		
	Else If DeviceScale < 4.0 Then
		'If the device scale is 3.0 (480dpi / xxhdpi) etc
		SquareIconSize = 144
		
	Else If DeviceScale < 5.0 Then
		'If the device scale is 4.0 (640dpi / xxxhdpi) etc
		SquareIconSize = 192
		
	End If
	
	'If device scale is 5.0 or higher?
	'
	'Who knows, perhaps mobile devices in 2030
	'will have insane device scales like that,
	'but then you probably want atleast the
	'actual icon size as the recommended
	'square icon size for your device
	'
	'Let's hope that the current App icon's
	'256px square size is enough for your
	'future 8K resolution mobile phone then!
	
	Return SquareIconSize
	
End Sub


