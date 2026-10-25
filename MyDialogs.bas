B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

Sub Class_Globals
	
	'Convenience constants stored inside this class
	Private Constants As MyConstants
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'Convenience constants stored inside this class
	Constants.Initialize
	
End Sub

Private Sub GetSquareIconSizeForDisplayScale As Int
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

'
'Generic helpers to help create application dialogs more easily
'

Public Sub GetIdeallySizedDialogIcon(SourceIcon As Bitmap) As Bitmap
	
	Dim Icon As Bitmap = SourceIcon
	
	'Get better-adapted About icons according to screen DPI & scale
	Dim SquareIconSize As Int = GetSquareIconSizeForDisplayScale
	
	If Icon.Height <> SquareIconSize Then
		Icon = Icon.Resize(SquareIconSize, SquareIconSize, Constants.BITMAP_RESIZE_KEEP_ASPECT_RATIO)
	End If
	
	Return Icon
	
End Sub

Public Sub GetBaseDialogTextHeader(Title As String, Subtitle As String) As CSBuilder
	'
	'CSBuilder (CharSequenceBuilder) allows building CharSequence-based strings
	'Such char sequences can contain better formatting options for strings
	'
	'More info:
	' - https://www.b4x.com/android/forum/threads/charsequence-csbuilder-tutorial.76226/
	'
	'About Pop & PopAll:
	' - "Calling Pop ends the last span that was added (and not ended yet).
	'    Calling PopAll ends all open spans.
	'    It's convenient to always call PopAll at the end to ensure that all spans are closed."
	'
	Dim CharSequenceBuilder As CSBuilder
	CharSequenceBuilder.Initialize
	
	'Basic4Android's CRLF is actually a LF char
	'In its source code, CRLF resolves to "\n"
	CharSequenceBuilder.Bold
		CharSequenceBuilder.Append(Title&CRLF)
	CharSequenceBuilder.Pop
	
	'Make the subtitle 10% smaller
	CharSequenceBuilder.RelativeSize(0.9)
		CharSequenceBuilder.Append(Subtitle)
	CharSequenceBuilder.Pop
	
	Return CharSequenceBuilder
	
End Sub

Public Sub AddTextBadgeToDialogText(CharSequenceBuilder As CSBuilder, LabelText As String, LabelColor As Int, BackgroundColor As Int, LoadedLayoutScale As Float)
	
	CharSequenceBuilder.BackgroundColor(BackgroundColor)
		CharSequenceBuilder.Color(LabelColor)
			'25% smaller than the previous text
			CharSequenceBuilder.RelativeSize(0.75)
				'Vertically align the version label text
				'by adjusting the offset, to be more
				'visually pleasing aka. better-aligned
				'for the Human eye when the user sees it
				CharSequenceBuilder.VerticalAlign(-1dip * LoadedLayoutScale) '-1dip higher (calibrated value)
					'Append the label text:
					' - Notice the spaces before & after in order to
					'   have left & right padding in the warning label
					CharSequenceBuilder.Append(" "&LabelText&" ")
				CharSequenceBuilder.Pop
			CharSequenceBuilder.Pop
		CharSequenceBuilder.Pop
	CharSequenceBuilder.Pop 
	
End Sub


