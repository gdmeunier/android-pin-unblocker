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
'This class is only used to store constant values,
'most of which are used for convenience purposes:
' - This class doesn't offer code or functions
'

Sub Class_Globals
	
	'Application source, origin URL & licensing
	Public Const APPLICATION_HOMEPAGE_NAME As String = "GitHub Homepage"
	Public Const APPLICATION_HOMEPAGE_URL  As String = "https://github.com/gdmeunier/android-pin-unblocker"
	Public Const APPLICATION_LICENSE       As String = "GNU GPL 3.0+"
	
	'Copyright status icons (raw glyph from an icon font):
	' - These are actually important
	' - They belong to the MaterialIcons font
	'
	'Use these constants instead of directly writing using raw glyphs in
	'your code, which might accidentally be lost due to text encoding [...]
	Public Const COPYLEFT_ICON  As String = Chr(0xEB4D) 'Custom glyph addition (unofficial)
	'Public Const COPYRIGHT_ICON As String = Chr(0xE90C) 'Currently unused, for reference purposes only
	
	'Flashlight state icons (raw glyph from an icon font):
	' - These are actually important
	' - They belong to the MaterialIcons font
	'
	'Use these constants instead of directly writing using raw glyphs in
	'your code, which might accidentally be lost due to text encoding [...]
	Public Const FLASH_ICON_ON  As String = Chr(0xE3E7)
	Public Const FLASH_ICON_OFF As String = Chr(0xE3E6)
	
	'For special Hotfix logging purposes
	Public Const COLORS_ORANGE As Int = Colors.RGB(0xFF, 0x66, 0x00) 'Web-safe 256-indexed color
	
	'
	'These constants below only exist to make reading the source code easier
	'
	Public Const INTENT_NO_SPECIFIC_TARGET As String = ""
	
	Public Const BITMAP_RESIZE_KEEP_ASPECT_RATIO      As Boolean = True
	Public Const BITMAP_RESIZE_DONT_KEEP_ASPECT_RATIO As Boolean = False
	
	Public Const MSGBOX_HIDE_POSITIVE As String = ""
	Public Const MSGBOX_HIDE_CANCEL   As String = ""
	Public Const MSGBOX_HIDE_NEGATIVE As String = ""
	
	Public Const MSGBOX_CANCELLABLE     As Boolean = True
	Public Const MSGBOX_NON_CANCELLABLE As Boolean = False
	
	Public Const TOAST_DURATION_SHORT As Boolean = False
	Public Const TOAST_DURATION_LONG  As Boolean = True
	
	Public Const CAMERA_ANY   As Int = 0x0
	Public Const CAMERA_REAR  As Int = 0x0
	Public Const CAMERA_FRONT As Int = 0x1
	
	Public Const CAMERA_NO_SPECIFIC_ONE As Boolean = False
	Public Const CAMERA_SPECIFIC_ONE    As Boolean = True
	
	Public Const FLASH_ON                As Boolean = True
	Public Const FLASH_OFF               As Boolean = False
	Public Const FLASH_TOGGLE            As Boolean = False
	
	Public Const FLASH_NO_SPECIFIC_STATE As Boolean = False
	Public Const FLASH_SPECIFIC_STATE    As Boolean = True
	
	Public Const EDITTEXT_SPECIFIC_ONE    As Boolean  = True
	Public Const EDITTEXT_NO_SPECIFIC_ONE As Boolean  = False
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
End Sub


