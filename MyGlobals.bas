B4A=true
Group=Code Modules
ModulesStructureVersion=1
Type=StaticCode
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

Sub Process_Globals
	#If Java
	//
	// Let Java code know when Activities are launched
	// for the first time, one for each Activity
	//
	// The active instance of this class in
	// Java native code will be named "_myglobals"
	//
	// Values are true by default, then set to false
	// by each Activity after their first-time launch
	//
	public static boolean Main_IsFirstLaunch = true;
	public static boolean Scan_IsFirstLaunch = true;
	#End If
End Sub


