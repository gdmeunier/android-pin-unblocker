B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Class File Attributes
	
#End Region

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
'/!\ Don't use the MyExceptions class from Java native code here:
'     - Only use it in Basic code
'

Sub Class_Globals
	
	'For running Java native code
	Private joClass As JavaObject
	
	'For throwing Exceptions
	Private Exceptions As MyExceptions
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
	'For throwing Exceptions
	Exceptions.Initialize
	
End Sub

'"1234" to "31323334"
Public Sub StringToASCIIHex(Text As String) As String
	
	If Text == Null Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_CONVERSION, "The provided text is Null")
	End If
	
	If Text == "" Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_CONVERSION, "The provided text is an empty string")
	End If
	
	Return joClass.RunMethod("jStringToASCIIHex", Array(Text))
	
End Sub
#If Java
public static String jStringToASCIIHex(final String string)
{
    char[]        chars = string.toCharArray();
    StringBuilder hex   = new StringBuilder();
	
    for (char ch : chars)
	{
        hex.append(Integer.toHexString((int)ch));
    }
	
    return hex.toString();
}
#End If

'15 to "0F"
Public Sub NumberToStringHex(Number As Int) As String
	
	Dim StringHexNumber As String = joClass.RunMethod("jNumberToStringHex", Array(Number))
	
	'Check if the length is even, if not add 0 padding at start of string
	If StringHexNumber.Length < 2 Or StringHexNumber.Length Mod 2 <> 0 Then
		Do While StringHexNumber.Length < 2 Or StringHexNumber.Length Mod 2 <> 0
			StringHexNumber = "0" & StringHexNumber
			
		Loop
		
	End If
	
	Return StringHexNumber
	
End Sub
#If Java
public static String jNumberToStringHex(final int number)
{
	return Integer.toHexString(number);
}
#End If

'"0F" to 15
'Don't give any "0x" prefix to this function
Public Sub StringHexToNumber(HexString As String) As Int
	
	If Not(IsTextHexBytes(HexString)) Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_CONVERSION, "The provided Hex number String has invalid Hex characters")
	End If
	
	Return joClass.RunMethod("jStringHexToNumber", Array(HexString))
	
End Sub
#If Java
// Don't give any "0x" prefix to this function
public static int jStringHexToNumber(final String hexString)
{
	return Integer.parseInt(hexString, 16);
}
#End If

Public Sub IsTextHexBytes(Text As String) As Boolean
	
	Return Text.Length       >= 2 And _
		   Text.Length Mod 2 == 0 And _
		   Regex.IsMatch2("^[0-9A-F]+$", Regex.CASE_INSENSITIVE, Text)
	
End Sub
#If Java
public static boolean jIsTextHexBytes(final String string)
{
	//
	// Make sure that this function stays standalone
	//
	return string.length()     >= 2 &&
	       string.length() % 2 == 0 &&
		   string.matches("^[0-9a-fA-F]+$");
}
#End If

'
'Java native code
'

#If Java
//
// This faster method should only be used on small inputs like hashes
//
import java.math.BigInteger;
public static String jBytesToHexString(final byte[] bytes)
{
	BigInteger bigInt = new BigInteger(1, bytes);
	
	// "X" = UPPERCASE hash
	// "x" = lowercase hash
	return String.format("%0"+(bytes.length << 1)+"X", bigInt);
}

public static byte[] jHexBytesFromString(final String string)
{
	final int    length = string.length();
	final byte[] array  = new byte[(length + 1) / 2];
	
	int i = 0;
	int n = 0;
	
	if ( length % 2 == 1 )
	{
		array[n++] = (byte)jHexBytesFromDigit(string.charAt(i++));
	}
	while ( i < length )
	{
		array[n++] = (byte)(jHexBytesFromDigit(string.charAt(i++)) << 4 | jHexBytesFromDigit(string.charAt(i++)));
	}
	
	return array;
}

public static int jHexBytesFromDigit(final char c)
{
	if ( c >= '0' && c <= '9' )
	{
		return c - '0';      // 0x30
	}
	if ( c >= 'A' && c <= 'F' )
	{
		return c - 'A' + 10; // 0x41
	}
	if ( c >= 'a' && c <= 'f' )
	{
		return c - 'a' + 10; // 0x61
	}
	
	return 0;
}

public static String jHexStringFromBytes(final byte[] array)
{
	return jHexStringFromBytesTwo(array, 0, array.length);
}

public static String jHexStringFromBytesTwo(final byte[] array, final int n, final int n2)
{
	char[] hexDigits = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	
	final char[] hexChars = new char[n2 * 2];
	int n3 = 0;
	
	for ( int i = n; i < n + n2; ++i )
	{
		final byte b = array[i];
		hexChars[n3++] = hexDigits[b >>> 4 & 0xF];
		hexChars[n3++] = hexDigits[b & 0xF];
	}
	
	return new String(hexChars);
}
#End If


