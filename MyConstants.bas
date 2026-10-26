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
	
	'These are useful constants for getting a real CRLF & LF combo
	'Otherwise Basic4Android's built-in CRLF is acually "\n" (LF)
	Public Const TRUE_CRLF As String = BytesToString(Array As Byte(0x0D, 0x0A), 0, 2, "UTF-8")
	Public Const TRUE_LF   As String = BytesToString(Array As Byte(0x0A),       0, 1, "UTF-8")
	
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
	
	'Same constants as Android built-in ones
	Public Const ORIENTATION_UNDEFINED As Int = 0x0
	Public Const ORIENTATION_PORTRAIT  As Int = 0x1
	Public Const ORIENTATION_LANDSCAPE As Int = 0x2
	Public Const ORIENTATION_SQUARE    As Int = 0x3 'Deprecated since API level 16
	
	'
	'The constants below are critical for Smartcard operations
	'
	
	'-------------------------------------------------------
	'
	'The Gemalto IDPrime 930 v2 T=0 doesn't have a known
	'Card Manager Applet ID, or it's a different one than
	'the usual "A0 00 00 00 03 00 00" for a PKI smartcard
	'
	'-------------------------------------------------------
	
	'----- e.g. Gemalto IDPrime 830, IDPrime 930, eToken 5300 & eToken 5110+
	'
	'                                                            CLA (00 = ISO-7816)
	'                                                            |  Command SELECT FILE (INS=A4)
	'                                                            |  |  Type APPLET (P1=04 & P2=00)
	'                                                            |  |  |
	'                                                            |  |  |     Length of data / Applet ID (Lc=0B)
	'                                                            |  |  |     |  Data / Applet ID
	'                                                            |  |  |     |  |
	Public Const APDU_SELECT_GEMALTO_PKI_APPLET_ID  As String = "00 A4 04 00 0B A0 00 00 00 18 80 00 00 00 06 62" 'No Le set
	
	'----- e.g. HID Crescendo C1150 & similar cards from HID Global
	'
	'                                                            CLA (00 = ISO-7816)
	'                                                            |  Command SELECT FILE (INS=A4)
	'                                                            |  |  Type APPLET (P1=04 & P2=00)
	'                                                            |  |  |
	'                                                            |  |  |     Length of data / Applet ID (Lc=07)
	'                                                            |  |  |     |  Data / Applet ID
	'                                                            |  |  |     |  |                    Expected Response Data Length (Le=00)
	'                                                            |  |  |     |  |                    |
	Public Const APDU_SELECT_ACTIVID_PKI_APPLET_ID  As String = "00 A4 04 00 07 A0 00 00 00 79 10 00 00"
	
	'----- e.g. GIDS applet from vletoux's open-source project & also Microsoft's
	'
	'                                                            CLA (00 = ISO-7816)
	'                                                            |  Command SELECT FILE (INS=A4)
	'                                                            |  |  Type APPLET (P1=04 & P2=00)
	'                                                            |  |  |
	'                                                            |  |  |     Length of data / Applet ID (Lc=09)
	'                                                            |  |  |     |  Data / Applet ID
	'                                                            |  |  |     |  |                          Expected Response Data Length (Le=00)
	'                                                            |  |  |     |  |                          |
	Public Const APDU_SELECT_GIDS_APPLET_ID         As String = "00 A4 04 00 09 A0 00 00 03 97 42 54 46 59 00"
	
	'GIDS
	'----                                                        CLA (80 = Proprietary / Management)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2
	'                                                            |  |  |  |
	'                                                            |  |  |  |  Lc (3 bytes)
	'                                                            |  |  |  |  |  Template for Security Environment
	'                                                            |  |  |  |  |  |
	Public Const APDU_SET_SECURITY_ENVIRONMENT_GIDS As String = "00 22 81 A4 03 83 01 80" 'No Le set
	
	'Generic
	'-------                                                     CLA (80 = Proprietary / Management)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2
	'                                                            |  |  |  |
	Public Const APDU_GET_CHALLENGE_GENERIC         As String = "80 84 00 00"
	
	'GIDS
	'----                                                        CLA (80 = Proprietary / Management)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2
	'                                                            |  |  |  |
	'                                                            |  |  |  |  Lc (4 bytes)
	'                                                            |  |  |  |  |  Get Challenge command
	'                                                            |  |  |  |  |  |           Le
	'                                                            |  |  |  |  |  |           |
	Public Const APDU_GET_CHALLENGE_GIDS            As String = "00 87 00 00 04 7C 02 81 00 00"
	'                                                            |  |  |
	'This one is used for reply verification                     |  |  |
	Public Const APDU_GET_CHALLENGE_CHECK_GIDS      As String = "7C 0A 81"
	
	'GIDS
	'----                                                        CLA (00 = ISO-7816)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2
	'                                                            |  |  |  |
	Public Const APDU_EXTERNAL_AUTHENTICATE_GIDS    As String = "00 87 00 00 ?? 7C 0A 82" 'Leave the "??" placeholder as-is
	'                                                            |  |
	'                                                            |  |  P1 P2 (02 80 = User PIN, GIDS)
	'                                                            |  |  |  |
	Public Const APDU_SET_REFERENCE_DATA_GIDS       As String = "00 2C 02 80"
	'                                                            |  |
	'                                                            |  |  P1 (00 = Logout)
	'                                                            |  |  |  P2 (82 = Key ID, GIDS)
	'                                                            |  |  |  |
	Public Const APDU_EXTERNAL_AUTH_LOGOUT_GIDS     As String = "00 20 00 82"
	
	'Note about GIDS:
	' - The Role #3 for which the GIDS applet claims support,
	'   the Digital Signature PIN, actually doesn't work on it
	'
	' - The Role #3 on a GIDS applet is basically a symlink to
	'   the GIDS applet's Primary User PIN
	'
	' - As such, I consider that the GIDS applet does not have
	'   additional PKI smartcard PINs / additional roles
	'
	
	'Gemalto
	'-------                                                     CLA (80 = Proprietary / Management, 00 = ISO-7816)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2 (31 = Key ID, Gemalto)
	'                                                            |  |  |  |
	Public Const APDU_EXTERNAL_AUTHENTICATE_GEMALTO As String = "00 82 00 31"
	'                                                            |  |
	'                                                            |  |  P1 P2 (11 = User PIN, 8X = Role #X, Gemalto)
	'                                                            |  |  |  |
	Public Const APDU_SET_REFERENCE_DATA_GEMALTO    As String = "80 2C 90 ??" 'Leave the "??" placeholder as-is
	'                                                            |  |
	'                                                            |  |  P1 (FF = Logout)
	'                                                            |  |  |  P2 (31 = Key ID, Gemalto)
	'                                                            |  |  |  |
	Public Const APDU_EXTERNAL_AUTH_LOGOUT_GEMALTO  As String = "00 82 FF 31"
	
	'ActivID
	'-------                                                     CLA (80 = Proprietary / Management)
	'                                                            |  Command (INS)
	'                                                            |  |
	'                                                            |  |  P1 P2 (01 = Key ID, ActivID)
	'                                                            |  |  |  |
	Public Const APDU_EXTERNAL_AUTHENTICATE_ACTIVID As String = "80 82 00 01"
	'                                                            |  |
	'                                                            |  |  P1 P2 (02 00 = User PIN, ActivID)
	'                                                            |  |  |  |
	Public Const APDU_SET_REFERENCE_DATA_ACTIVID    As String = "80 2C 02 00"
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
End Sub


