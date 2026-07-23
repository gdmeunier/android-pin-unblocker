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
	Private joMySecurity As JavaObject
	
	'
	'For safely ignoring multiple-Share To attempts
	'by Android for the same Intent
	'
	
	'For running Java native code
	Private joMyCryptography As JavaObject
	
	'We need a safe algorithm that avoids hashing collisions
	Private REHASH_TRUNCATION_HASHING_ALGORITHM As String = "SHA-512"
	
	'Make sure that trying to crack the truncated hashes is even harder
	'Incase of memory dump analysis of a phone's live RAM
	Private REHASH_TRUNCATION_HASHING_ROUNDS    As Int    = Rnd(3, 10)
	
	'Make sure that hashes cannot be the same across two App lifecycles
	'Makes sure it's not possible to easily find what the hashes will be
	Private REHASH_TRUNCATION_HASHING_SALT      As String = Rnd(1000000000, 2147483646).As(String)
	
End Sub

Public Sub Initialize
	
	'For running Java native code
	joMySecurity.InitializeStatic(Application.PackageName&".mysecurity")
	joMyCryptography.InitializeStatic(Application.PackageName&".mycryptography")
	
End Sub

'Try asking the JVM to clear traces of variable contents as soon as possible
Public Sub TriggerJvmGarbageCollection
	joMySecurity.RunMethod("jTriggerJvmGarbageCollection", Null)
End Sub
#If Java
public static void jTriggerJvmGarbageCollection()
{
	System.gc();
}
#End If

'
'Intent TextExtra protection -----------------------------------------
'

'Returns empty string on failure
Sub GenerateTextTruncatedRehash(MyText As String) As String
	
	Dim GeneratedTextTruncatedRehash As String = ""
	
	If MyText == Null Then
		Return GeneratedTextTruncatedRehash
		
	End If
	
	Dim TextToGenerateTruncatedRehashFor As String = MyText
	
	For i = 1 To REHASH_TRUNCATION_HASHING_ROUNDS
		TextToGenerateTruncatedRehashFor = joMyCryptography.RunMethod("jTextToHash", Array(TextToGenerateTruncatedRehashFor&REHASH_TRUNCATION_HASHING_SALT, REHASH_TRUNCATION_HASHING_ALGORITHM))
	Next
	
	'The text hashing function returns empty string on failure
	If TextToGenerateTruncatedRehashFor <> "" Then
		'We add .As(Int) because otherwise it was
		'a Float or Double value, not Integer
		GeneratedTextTruncatedRehash = TextToGenerateTruncatedRehashFor.SubString2(0, (TextToGenerateTruncatedRehashFor.Length / 2).As(Int))
		
	End If
	
	Return GeneratedTextTruncatedRehash
	
End Sub

'Return: ReturnValue(0) = whether it's a different truncated rehash (True / False)
'        ReturnValue(1) = the truncated rehash, empty if verification
'                         returns a False status
'
Sub GetTruncatedHashDifferentStatusAndGetNewHash(MyText As String, MyTextTruncatedHash As String) As String()
	
	'Default status if False (same truncated text rehash)
	'With empty string too
	Dim TruncatedHashDifferentStatusAndNewHash() As String = Array As String(False, "")
	
	'This one will be Null for each Activity that uses
	'it on first start, so it's OK to allow returning
	'True for it (with its own Null value)
	If MyTextTruncatedHash == Null Then
		Return Array As String(True, Null) 'That means there's no previously shared text at all, so it's OK
		
	Else If MyText == Null Or MyText == "" Then
		'We cannot generate an hash for Null
		'so why even try to do it,
		'just return that the rehash is the
		'same one (the safer option here)
		'
		'And if the text is empty, then why
		'even accept it in the first place
		'
		'We cannot accept empty texts for
		'our purposes, which is validating
		'Admin key texts shared to the App
		Return TruncatedHashDifferentStatusAndNewHash 'Return default False value & empty string
		
	End If
	
	Dim GeneratedTextTruncatedRehash As String = GenerateTextTruncatedRehash(MyText)
	
	'If the truncated text rehash generation failed
	'Returns empty string on failure
	If GeneratedTextTruncatedRehash == "" Then
		Return TruncatedHashDifferentStatusAndNewHash 'Return default False value & empty string
		
	End If
	
	'Check if the text truncated rehash is different
	'from the one we were provided to verify against
	If Not(GeneratedTextTruncatedRehash.EqualsIgnoreCase(MyTextTruncatedHash)) Then
		'The truncated text rehash is not the same
		'Now mark the new status in the
		'TruncatedHashDifferentStatusAndNewHash
		'array (True = different + the new hash)
		TruncatedHashDifferentStatusAndNewHash(0) = True
		TruncatedHashDifferentStatusAndNewHash(1) = GeneratedTextTruncatedRehash
		
	End If
	
	Return TruncatedHashDifferentStatusAndNewHash
	
End Sub

'
'EditText security hardening functions -------------------------------
'

'Set the PasswordMode on any EdiText, with the benefit that even if you don't
'hide the EditText field it will stay a password field anyway (but visible)
Public Sub SetAdvancedPasswordMode(MyEditText As EditText, VisiblePassword As Boolean)
	joMySecurity.RunMethod("jSetAdvancedPasswordMode", Array(MyEditText, VisiblePassword))
End Sub
#If Java
import android.widget.EditText;
import android.text.method.TransformationMethod;
import android.text.method.PasswordTransformationMethod;
public static void jSetAdvancedPasswordMode(EditText myEditText, final boolean visiblePassword)
{
	//
	// API level 1+
	//
	if ( visiblePassword )
	{
		myEditText.setTransformationMethod(null); // null = normal default transform
	}
	else
	{
		myEditText.setTransformationMethod(PasswordTransformationMethod.getInstance());
	}
}
#End If

'Public Sub DisableFullscreenKeyboard(MyEditText As EditText)
'	joMySecurity.RunMethod("jDisableFullscreenKeyboard", Array(MyEditText))
'End Sub
'#If Java
'import android.widget.EditText;
'import android.os.Build;
'import android.view.inputmethod.EditorInfo;
'public static void jDisableFullscreenKeyboard(EditText myEditText)
'{
'	// It's a safety measure to avoid showing the Admin keys in clear
'	// when the Fullscreen keyboard appears instead of the normal one
'	//
'	// IME_FLAG_NO_EXTRACT_UI is only available on Android 1.5+ (API level 3+)
'	// IME_FLAG_NO_FULLSCREEN is only available on Android 3.0+ (API level 11+)
'	//
'	if ( Build.VERSION.SDK_INT >= 3 )
'	{
'		/* Android 1.5+ */
'		int imeOptions = myEditText.getImeOptions();
'		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_EXTRACT_UI;
'		
'		if ( Build.VERSION.SDK_INT >= 11 )
'		{
'			/* Android 3.0+ */
'			imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_FULLSCREEN;
'		}
'		
'		myEditText.setImeOptions(imeOptions);
'	}
'}
'#End If

Public Sub DisableAutoComplete(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableAutoComplete", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoComplete(EditText myEditText)
{
	// TYPE_TEXT_FLAG_AUTO_COMPLETE is only available on Android 1.5+ (API level 3+)
	//
	if ( Build.VERSION.SDK_INT >= 3 )
	{
		/* Android 1.5+ */
		int inputType = myEditText.getInputType();
		    inputType = inputType & ~InputType.TYPE_TEXT_FLAG_AUTO_COMPLETE;
		
		myEditText.setInputType(inputType);
	}
}
#End If

Public Sub DisableAutoCorrect(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableAutoCorrect", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoCorrect(EditText myEditText)
{
	// TYPE_TEXT_FLAG_AUTO_CORRECT is only available on Android 1.5+ (API level 3+)
	//
	if ( Build.VERSION.SDK_INT >= 3 )
	{
		/* Android 1.5+ */
		int inputType = myEditText.getInputType();
		    inputType = inputType & ~InputType.TYPE_TEXT_FLAG_AUTO_CORRECT;
		
		myEditText.setInputType(inputType);
	}
}
#End If

'Public Sub DisableAutoSuggestions(MyEditText As EditText)
'	joMySecurity.RunMethod("jDisableAutoSuggestions", Array(MyEditText))
'End Sub
'#If Java
'import android.widget.EditText;
'import android.os.Build;
'import android.text.InputType;
'public static void jDisableAutoSuggestions(EditText myEditText)
'{
'	// TYPE_TEXT_FLAG_NO_SUGGESTIONS is only available on Android 2.0+ (API level 5+)
'	//
'	if ( Build.VERSION.SDK_INT >= 5 )
'	{
'		/* Android 2.0+ */
'		int inputType = myEditText.getInputType();
'		    inputType = inputType | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
'		
'		myEditText.setInputType(inputType);
'	}
'}
'#End If

'Public Sub DisablePersonalizedLearning(MyEditText As EditText)
'	joMySecurity.RunMethod("jDisablePersonalizedLearning", Array(MyEditText))
'End Sub
'#If Java
'import android.widget.EditText;
'import android.os.Build;
'import android.view.inputmethod.EditorInfo;
'public static void jDisablePersonalizedLearning(EditText myEditText)
'{
'	// IME_FLAG_NO_PERSONALIZED_LEARNING is only available on Android 8.0+ (API level 26+)
'	//
'	if ( Build.VERSION.SDK_INT >= 26 )
'	{
'		/* Android 8.0+ */
'		int imeOptions = myEditText.getImeOptions();
'		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_PERSONALIZED_LEARNING;
'		
'		myEditText.setImeOptions(imeOptions);
'	}
'}
'#End If

Public Sub DisableTextConversionSuggestions(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableTextConversionSuggestions", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableTextConversionSuggestions(EditText myEditText)
{
	// TYPE_TEXT_FLAG_ENABLE_TEXT_CONVERSION_SUGGESTIONS only on Android 13+ (API level 33+)
	//
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		/* Android 13+ */
		int inputType = myEditText.getInputType();
		    inputType = inputType & ~InputType.TYPE_TEXT_FLAG_ENABLE_TEXT_CONVERSION_SUGGESTIONS;
		
		myEditText.setInputType(inputType);
	}
}
#End If

Public Sub DisableTextSelectionSuggestions(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableTextSelectionSuggestions", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableTextSelectionSuggestions(EditText myEditText)
{
	// TYPE_TEXT_FLAG_ENABLE_TEXT_SUGGESTION_SELECTED is only on Android 17+ (API level 37+)
	//
	if ( Build.VERSION.SDK_INT >= 37 )
	{
		/* Android 17+ */
		int inputType = myEditText.getInputType();
		    inputType = inputType & ~InputType.TYPE_TEXT_FLAG_ENABLE_TEXT_SUGGESTION_SELECTED;
		
		myEditText.setInputType(inputType);
	}
}
#End If


