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

'
'This class only offers security-related functionality
'
'And while the MyCommon class contains common code shared across
'all the application's Activities & Services, it doesn't contain
'security-related code:
' - Only this one contains such functionality
'
'Additionally, this class is actually a common one possible accessed by
'multiple Activities in this application
'

#Region Class File Attributes
	'Ignore "Empty Catch block. You should at least add Log(LastException.Message)" warning (#19)
	#IgnoreWarnings: 19
	
#End Region

Sub Class_Globals
	
	'For running Java native code
	Private joClass As JavaObject
	
	'
	'Below globals are for safely ignoring Android's multiple
	'Share To attempts for a same given Intent,
	'Activities that receive Intents can use this functionality
	'to safely filter duplicate re-sent Intents
	'
	
	'We need a safe algorithm for the purpose of preventing hash collisions (as much as possible)
	Private TruncatedRehashAlgorithm As String = "SHA-512"
	
	'Make sure that trying to crack the truncated text rehashes is even harder
	'in cases of extracted memory dumps analysis from a mobile device
	Private TruncatedRehashRounds As Int = Rnd(10, 50) 'Sensitive value
	
	'Make sure that text rehashes cannot be the same across two application lifecycles:
	' - This makes sure that it's not possible to get the same value across relaunches
	'   of the application, so that a new 'seed' is provided upon every run
	'
	Private TruncatedRehashSalt As String = Rnd(1000000000, 2147483646).As(String) 'Sensitive value
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
End Sub

'JVM garbage collection is when memory of remnant data is cleared,
'to make sure that an application's memory doesn't keep sensitive data in
'live memory space for too long, which helps make RAM analysis more difficult
Public Sub TriggerJvmGarbageCollection
	joClass.RunMethod("jTriggerJvmGarbageCollection", Null)
End Sub
#If Java
public static void jTriggerJvmGarbageCollection()
{
	System.gc();
}
#End If
Public Sub GenerateTruncatedTextRehash(Plaintext As String) As String
	
	If Plaintext == Null Then
		Throw("The plaintext to generate a truncated text rehash for is Null")
	End If
	
	'
	'It's technically possible to generate a text rehash for
	'an empty string, which is actually a 0x00 byte
	'
	
	Dim GeneratedTruncatedTextRehash As String = Plaintext
	
	Try
		For i = 1 To TruncatedRehashRounds
			GeneratedTruncatedTextRehash = joClass.RunMethod("jGenerateTextTruncatedRehash", Array(GeneratedTruncatedTextRehash&TruncatedRehashSalt, TruncatedRehashAlgorithm))
		Next
	Catch
		Throw($"The generation of a truncated text rehash for the provided plaintext failed:
		${LastException}"$)
	End Try
	
	Return GeneratedTruncatedTextRehash.SubString2(0, (GeneratedTruncatedTextRehash.Length / 2).As(Int))
	
End Sub
#If Java
import java.lang.RuntimeException;
import java.security.MessageDigest;
import java.io.StringWriter;
import java.io.PrintWriter;
public static String jGenerateTruncatedTextRehash(final String plaintext, final String hashType) throws RuntimeException
{
	String truncatedTextRehash;
	
	try
	{
		byte[] plaintextBytes = plaintext.getBytes();
		MessageDigest md = MessageDigest.getInstance(hashType);
		
		byte[] truncatedTextRehashBytes = md.digest(plaintextBytes);
		truncatedTextRehash = jBytesToHexString(truncatedTextRehashBytes);
	}
	catch (Exception e)
	{
		StringWriter stackTrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stackTrace));
		
		throw new RuntimeException(stackTrace.toString());
	}
	
	return truncatedTextRehash;
}

import java.math.BigInteger;
private static String jBytesToHexString(final byte[] bytes)
{
	BigInteger bigInt = new BigInteger(1, bytes);
	
	// "X" = UPPERCASE hash
	// "x" = lowercase hash
	return String.format("%0"+(bytes.length << 1)+"X", bigInt);
}
#End If

Private Sub Throw(Message As String)
	
	joClass.RunMethod("jThrow", Array(Message))
	
End Sub
#If Java
import java.lang.RuntimeException;
public static void jThrow(final String message) throws RuntimeException
{
	throw new RuntimeException(message);
}
#End If

Public Sub DisableFullscreenKeyboard(EditText As EditText)
	joClass.RunMethod("jDisableFullscreenKeyboard", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.view.inputmethod.EditorInfo;
public static void jDisableFullscreenKeyboard(EditText editText)
{
	/* It's a safety measure to avoid showing the Admin keys in clear
	 * when the Fullscreen keyboard appears instead of the normal one
	 *
	 * IME_FLAG_NO_EXTRACT_UI is only available on Android 1.5+ (API level 3+)
	 * IME_FLAG_NO_FULLSCREEN is only available on Android 3.0+ (API level 11+)
	 */
	if ( Build.VERSION.SDK_INT >= 3 ) /* Android 1.5+ */
	{
		int imeOptions = editText.getImeOptions();
		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_EXTRACT_UI;
		
		if ( Build.VERSION.SDK_INT >= 11 ) /* Android 3.0+ */
		{
			imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_FULLSCREEN;
		}
		
		editText.setImeOptions(imeOptions);
	}
}
#End If

Public Sub DisableAutoComplete(EditText As EditText)
	joClass.RunMethod("jDisableAutoComplete", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoComplete(EditText editText)
{
	// TYPE_TEXT_FLAG_AUTO_COMPLETE is only available on Android 1.5+ (API level 3+)
	if ( Build.VERSION.SDK_INT >= 3 ) /* Android 1.5+ */
	{
		int imeOptions = editText.getImeOptions(); /* Backup imeOptions */
		
		int inputType  = editText.getInputType();
		    inputType  = inputType & ~InputType.TYPE_TEXT_FLAG_AUTO_COMPLETE;
		
		editText.setInputType(inputType);
		
		editText.setImeOptions(imeOptions); /* Restore imeOptions */
	}
}
#End If

Public Sub DisableAutoCorrect(EditText As EditText)
	joClass.RunMethod("jDisableAutoCorrect", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoCorrect(EditText editText)
{
	// TYPE_TEXT_FLAG_AUTO_CORRECT is only available on Android 1.5+ (API level 3+)
	if ( Build.VERSION.SDK_INT >= 3 ) /* Android 1.5+ */
	{
		int imeOptions = editText.getImeOptions(); /* Backup imeOptions */
		
		int inputType  = editText.getInputType();
		    inputType  = inputType & ~InputType.TYPE_TEXT_FLAG_AUTO_CORRECT;
		
		editText.setInputType(inputType);
		
		editText.setImeOptions(imeOptions); /* Restore imeOptions */
	}
}
#End If

Public Sub DisableAutoSuggestions(EditText As EditText)
	joClass.RunMethod("jDisableAutoSuggestions", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoSuggestions(EditText editText)
{
	// TYPE_TEXT_FLAG_NO_SUGGESTIONS is only available on Android 2.0+ (API level 5+)
	if ( Build.VERSION.SDK_INT >= 5 ) /* Android 2.0+ */
	{
		int imeOptions = editText.getImeOptions(); /* Backup imeOptions */
		
		int inputType  = editText.getInputType();
		    inputType  = inputType | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
		
		editText.setInputType(inputType);
		
		editText.setImeOptions(imeOptions); /* Restore imeOptions */
	}
}
#End If

Public Sub DisablePersonalizedLearning(EditText As EditText)
	joClass.RunMethod("jDisablePersonalizedLearning", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.view.inputmethod.EditorInfo;
public static void jDisablePersonalizedLearning(EditText editText)
{
	// IME_FLAG_NO_PERSONALIZED_LEARNING is only available on Android 8.0+ (API level 26+)
	if ( Build.VERSION.SDK_INT >= 26 ) /* Android 8.0+ */
	{
		int imeOptions = editText.getImeOptions();
		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_PERSONALIZED_LEARNING;
		
		editText.setImeOptions(imeOptions);
	}
}
#End If

Public Sub DisableTextConversionSuggestions(EditText As EditText)
	joClass.RunMethod("jDisableTextConversionSuggestions", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableTextConversionSuggestions(EditText editText)
{
	// TYPE_TEXT_FLAG_ENABLE_TEXT_CONVERSION_SUGGESTIONS only on Android 13+ (API level 33+)
	if ( Build.VERSION.SDK_INT >= 33 ) /* Android 13+ */
	{
		int imeOptions = editText.getImeOptions(); /* Backup imeOptions */
		
		int inputType  = editText.getInputType();
		    inputType  = inputType & ~InputType.TYPE_TEXT_FLAG_ENABLE_TEXT_CONVERSION_SUGGESTIONS;
		
		editText.setInputType(inputType);
		
		editText.setImeOptions(imeOptions); /* Restore imeOptions */
	}
}
#End If

Public Sub DisableTextSelectionSuggestions(EditText As EditText)
	joClass.RunMethod("jDisableTextSelectionSuggestions", Array(EditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableTextSelectionSuggestions(EditText editText)
{
	// TYPE_TEXT_FLAG_ENABLE_TEXT_SUGGESTION_SELECTED is only on Android 17+ (API level 37+)
	if ( Build.VERSION.SDK_INT >= 37 ) /* Android 17+ */
	{
		int imeOptions = editText.getImeOptions(); /* Backup imeOptions */
		
		int inputType  = editText.getInputType();
		    inputType  = inputType & ~InputType.TYPE_TEXT_FLAG_ENABLE_TEXT_SUGGESTION_SELECTED;
		
		editText.setInputType(inputType);
		
		editText.setImeOptions(imeOptions); /* Restore imeOptions */
	}
}
#End If


