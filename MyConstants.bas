B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

Sub Class_Globals
	'These constants only exist to make reading
	'the source code easier to read
	Public Const INTENT_NO_SPECIFIC_TARGET As String = ""
	
	'Application source / origin
	Public Const APPLICATION_HOMEPAGE_NAME As String = "GitHub Homepage"
	Public Const APPLICATION_HOMEPAGE_URL  As String = "https://github.com/gdmeunier/android-pin-unblocker"
	Public Const APPLICATION_LICENSE       As String = "GNU GPL 3.0+"
	
	'These constants only exist to make reading
	'the source code easier to read
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
	
	'Copyright status icons (raw glyph from an icon font)
	'These ones are actually important
	'
	'These belong to the MaterialIcons font
	'Use these Constants instead of directly using the glyphs
	Public Const COPYLEFT_ICON  As String = Chr(0xEB4D)  'Custom glyph addition (unofficial)
	'Public Const COPYRIGHT_ICON As String = Chr(0xE90C) 'Currently unused, for reference purposes only
	
	'Flashlight state icons (raw glyph from an icon font)
	'These ones are actually important
	'
	'These belong to the MaterialIcons font
	'Use these Constants instead of directly using the glyphs
	Public Const FLASH_ICON_ON  As String = Chr(0xE3E7)
	Public Const FLASH_ICON_OFF As String = Chr(0xE3E6)
	
	'These constants match Android's own ones
	'
	'This copy of the constants here is for
	'convenience purposes and Basic code access
	Public Const ORIENTATION_UNKNOWN   As Int = 0x0 'Android calls it 'UNDEFINED' though
	Public Const ORIENTATION_PORTRAIT  As Int = 0x1
	Public Const ORIENTATION_LANDSCAPE As Int = 0x2
	
	'These constants only exist to make reading
	'the source code easier to read
	Public Const EDITTEXT_SPECIFIC_ONE    As Boolean  = True
	Public Const EDITTEXT_NO_SPECIFIC_ONE As Boolean  = False
	
	Public Const PASSWORD_HIDDEN_PASSWORD  As Boolean = False
	Public Const PASSWORD_VISIBLE_PASSWORD As Boolean = True
	
	'For special Hotfix logging purposes
	Public Const COLORS_ORANGE As Int = Colors.RGB(0xFF, 0x66, 0x00) 'Web-safe 256-indexed color
	
End Sub

Public Sub Initialize
	
End Sub


