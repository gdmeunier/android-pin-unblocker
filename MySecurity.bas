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
	Public Const PASSWORD_HIDDEN_PASSWORD  As Boolean = False
	Public Const PASSWORD_VISIBLE_PASSWORD As Boolean = True
	
	'For running Java native code
	Private joMySecurity As JavaObject
	
End Sub

Public Sub Initialize
	
	joMySecurity.InitializeStatic(Application.PackageName&".mysecurity")
	
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

'Set the PasswordMode on any EdiText, with the benefit that even if you don't
'hide the EditText field it will stay a password field anyway (but visible)
Public Sub SetAdvancedPasswordMode(MyEditText As EditText, VisiblePassword As Boolean)
	joMySecurity.RunMethod("jSetAdvancedPasswordMode", Array(MyEditText, VisiblePassword))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jSetAdvancedPasswordMode(EditText myEditText, final boolean visiblePassword)
{
	// TYPE_TEXT_VARIATION_PASSWORD         is only available on Android 1.5+ (API level 3+)
	// TYPE_TEXT_VARIATION_VISIBLE_PASSWORD is only available on Android 1.5+ (API level 3+)
	//
	if ( Build.VERSION.SDK_INT >= 3 )
	{
		/* Android 1.5+ */
		int inputType = myEditText.getInputType();
		
		if (visiblePassword)
		{
			// Visible password
			inputType = inputType & ~InputType.TYPE_TEXT_VARIATION_PASSWORD;
			inputType = inputType |  InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD;
		}
		else
		{
			// Normal password
			inputType = inputType & ~InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD;
			inputType = inputType |  InputType.TYPE_TEXT_VARIATION_PASSWORD;
		}
		
		myEditText.setInputType(inputType);
	}
}
#End If

'
'EditText security hardening functions -------------------------------
'

Public Sub DisableFullscreenKeyboard(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableFullscreenKeyboard", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.view.inputmethod.EditorInfo;
public static void jDisableFullscreenKeyboard(EditText myEditText)
{
	// It's a safety measure to avoid showing the Admin keys in clear
	// when the Fullscreen keyboard appears instead of the normal one
	//
	// IME_FLAG_NO_EXTRACT_UI is only available on Android 1.5+ (API level 3+)
	// IME_FLAG_NO_FULLSCREEN is only available on Android 3.0+ (API level 11+)
	//
	if ( Build.VERSION.SDK_INT >= 3 )
	{
		/* Android 1.5+ */
		int imeOptions = myEditText.getImeOptions();
		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_EXTRACT_UI;
		
		if ( Build.VERSION.SDK_INT >= 11 )
		{
			/* Android 3.0+ */
			imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_FULLSCREEN;
		}
		
		myEditText.setImeOptions(imeOptions);
	}
}
#End If

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

Public Sub DisableAutoSuggestions(MyEditText As EditText)
	joMySecurity.RunMethod("jDisableAutoSuggestions", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.text.InputType;
public static void jDisableAutoSuggestions(EditText myEditText)
{
	// TYPE_TEXT_FLAG_NO_SUGGESTIONS is only available on Android 2.0+ (API level 5+)
	//
	if ( Build.VERSION.SDK_INT >= 5 )
	{
		/* Android 2.0+ */
		int inputType = myEditText.getInputType();
		    inputType = inputType | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
		
		myEditText.setInputType(inputType);
	}
}
#End If

Public Sub DisablePersonalizedLearning(MyEditText As EditText)
	joMySecurity.RunMethod("jDisablePersonalizedLearning", Array(MyEditText))
End Sub
#If Java
import android.widget.EditText;
import android.os.Build;
import android.view.inputmethod.EditorInfo;
public static void jDisablePersonalizedLearning(EditText myEditText)
{
	// IME_FLAG_NO_PERSONALIZED_LEARNING is only available on Android 8.0+ (API level 26+)
	//
	if ( Build.VERSION.SDK_INT >= 26 )
	{
		/* Android 8.0+ */
		int imeOptions = myEditText.getImeOptions();
		    imeOptions = imeOptions | EditorInfo.IME_FLAG_NO_PERSONALIZED_LEARNING;
		
		myEditText.setImeOptions(imeOptions);
	}
}
#End If

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


