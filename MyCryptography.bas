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

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
'
'Important notice:
'
'This MyCryptography class contains encryption functions that are only intended for the
'generation of smartcard challenge-response unblock codes, and are not fit for any other
'potentially sensitive usage, because the cryptographic algorithms and their modes of
'operation in this class are insecure for any other real-world usage
'
'This MyCryptography class also doesn't provide decryption functions because this appllication
'doesn't make use for decryption (it only does encryption)
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

Sub Class_Globals
	
	Public Const ALGORITHM_2DES    As String = "2DES (DES-EDE2)"
	Public Const ALGORITHM_3DES    As String = "3DES (DES-EDE3)"
	Public Const ALGORITHM_AES128  As String = "AES (AES-128)"
	Public Const ALGORITHM_AES256  As String = "AES (AES-256)"
	
	Public Const ALGORITHM_UNKNOWN As String = "Unknown"
	
	Public Const ALGORITHM_SHA512  As String = "SHA-512"
	Public Const ALGORITHM_SHA256  As String = "SHA-256"
	
	'For running Java native code
	Private joClass As JavaObject
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
End Sub
Public Sub HashText(Plaintext As String, HashType As String) As String
	
	If Plaintext == Null Or HashType == Null Then
		Throw("One of the provided parameters is Null")
	End If
	
	If HashType == "" Then
		Throw("The requested hash type parameter is an empty string")
	End If
	
	If HashType <> ALGORITHM_SHA256 And HashType <> ALGORITHM_SHA512 Then
		Throw("The requested hash type is not a supported hashing algorithm")
	End If
	
	'
	'It's technically possible to generate an hash for
	'an empty string, which is actually a 0x00 byte
	'
	
	Dim TextHash As String
	
	Try
		TextHash = joClass.RunMethod("jHashText", Array(Plaintext, HashType))
	Catch
		Throw($"The hashing of the provided plaintext failed:
		${LastException}"$)
	End Try
	
	Return TextHash
	
End Sub
#If Java
import java.lang.RuntimeException;
import java.security.MessageDigest;
import java.io.StringWriter;
import java.io.PrintWriter;
public static String jHashText(final String plaintext, final String hashType) throws RuntimeException
{
	String textHash;
	
	try
	{
		byte[] plaintextBytes = plaintext.getBytes();
		MessageDigest md = MessageDigest.getInstance(hashType);
		
		byte[] textHashBytes = md.digest(plaintextBytes);
		textHash = jBytesToHexString(textHashBytes);
	}
	catch (Exception e)
	{
		StringWriter stackTrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stackTrace));
		
		throw new RuntimeException(stackTrace.toString());
	}
	
	return textHash;
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

'This encryption function uses ECB mode without padding
'That means the length of the plaintext must match the key's
Public Sub TripleDesEncrypt(PlaintextBytesString As String, KeyBytesString As String) As String
	
	If PlaintextBytesString == Null Or KeyBytesString == Null Then
		Throw("One of the provided parameters is Null")
	End If
	
	If PlaintextBytesString == ""   Or KeyBytesString == "" Then
		Throw("One of the provided parameters is an empty string")
	End If
	
	If Not(IsTextHexBytes(PlaintextBytesString) And IsTextHexBytes(KeyBytesString)) Then
		Throw("One of the provided parameters is not an key bytes string")
	End If
	
	If KeyBytesString.Length <> 48 And KeyBytesString.Length <> 32 Then
		Throw("The provided key bytes string is not a valid TripleDES key length")
	End If
	
	If KeyBytesString.Length <> KeyBytesString.Length Then
		Throw("The provided key bytes string is not the same length as the plaintext bytes string")
	End If
	
	Dim CiphertextBytesString As String
	
	Try
		CiphertextBytesString = joClass.RunMethod("jTripleDesEncrypt", Array(PlaintextBytesString, KeyBytesString))
	Catch
		Throw($"The TripleDES encryption operation with the provided parameters failed:
		${LastException}"$)
	End Try
	
	Return CiphertextBytesString
	
End Sub
#If Java
import java.lang.RuntimeException;
import java.security.spec.InvalidParameterSpecException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.DESedeKeySpec;
import java.security.InvalidAlgorithmParameterException;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
import javax.crypto.Cipher;
import java.io.StringWriter;
import java.io.PrintWriter;
public static String jTripleDesEncrypt(final String plaintextBytesString, final String keyBytesString) throws RuntimeException
{
	byte[] keyBytes = jHexBytesFromString(keyBytesString);
	
	// Specifically for 2DES (DES-EDE2)
	if ( keyBytesString.length() == 32 )
	{
		/* Automatically copy first 16 chars to the end of the 2DES key
		 * because it's actually required (must repeat them at the end)
		 *
		 * 2DES is just 3DES with KEY+1KEY2+KEY1 instead of KEY1+KEY2+KEY3
		 */
		byte[] tmpKeyBytes = new byte[24]; // 48 chars
		
		// 0-based index
		/* System.arraycopy(sourceArray, sourceOffset, targetArray, targetOffset, bytesCount); */
		
		// Copying the first two keys
		/* Copy first 32 chars (16 bytes) to temporary key at the start of it */
		System.arraycopy(keyBytes, 0, tmpKeyBytes, 0, 16);
		
		// Copying the first key
		/* Copy first 16 chars (8 bytes) to temporary key after the first 32 chars (16 bytes) */
		System.arraycopy(keyBytes, 0, tmpKeyBytes, 16, 8);
		
		// Replace the previous incomplete 2DES key with the equivalent 3DES one
		/* This new one will have the 48-chars required (24 bytes) for the 3DES algorithm */
		keyBytes = tmpKeyBytes;
	}
	
	byte[] plaintextBytes = jHexBytesFromString(plaintextBytesString);
	byte[] ciphertextBytes;
	
	try
	{
		final SecretKeyFactory desKeyFactory = SecretKeyFactory.getInstance("DESede");
		final SecretKey        tripleDesKey  = desKeyFactory.generateSecret(new DESedeKeySpec(keyBytes));
		
		final Cipher desEdeInstance = Cipher.getInstance("DESede/ECB/NoPadding");
		             desEdeInstance.init(Cipher.ENCRYPT_MODE, tripleDesKey);
		
		ciphertextBytes = desEdeInstance.doFinal(plaintextBytes);
	}
	catch (Exception e)
	{
		StringWriter stackTrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stackTrace));
		
		throw new RuntimeException(stackTrace.toString());
	}
	
	return jHexStringFromBytes(ciphertextBytes);
}

private static byte[] jHexBytesFromString(final String string)
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

private static int jHexBytesFromDigit(final char c)
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

private static String jHexStringFromBytes(final byte[] array)
{
	return jHexStringFromBytesTwo(array, 0, array.length);
}

private static String jHexStringFromBytesTwo(final byte[] array, final int n, final int n2)
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

Public Sub IsTextHexBytes(Text As String) As Boolean
	
	Return Text.Length >= 2       And _
		   Text.Length Mod 2 == 0 And _
		   Regex.IsMatch2("^[0-9A-F]+$", Regex.CASE_INSENSITIVE, Text)
	
End Sub

'This encryption function uses ECB mode without padding
'That means the length of the plaintext must match the key's
Public Sub AesEncrypt(PlaintextBytesString As String, KeyBytesString As String) As String
	
	If PlaintextBytesString == Null Or KeyBytesString == Null Then
		Throw("One of the provided parameters is Null")
	End If
	
	If PlaintextBytesString == ""   Or KeyBytesString == "" Then
		Throw("One of the provided parameters is an empty string")
	End If
	
	If Not(IsTextHexBytes(PlaintextBytesString) And IsTextHexBytes(KeyBytesString)) Then
		Throw("One of the provided parameters is not an key bytes string")
	End If
	
	If KeyBytesString.Length <> 32 And KeyBytesString.Length <> 64 Then
		Throw("The provided key bytes string is not a supported AES key length")
	End If
	
	If KeyBytesString.Length <> KeyBytesString.Length Then
		Throw("The provided key bytes string is not the same length as the plaintext bytes string")
	End If
	
	Dim CiphertextBytesString As String
	
	Try
		CiphertextBytesString = joClass.RunMethod("jAesEncrypt", Array(PlaintextBytesString, KeyBytesString))
	Catch
		Throw($"The AES encryption operation with the provided parameters failed:
		${LastException}"$)
	End Try
	
	Return CiphertextBytesString
	
End Sub
#If Java
import java.lang.RuntimeException;
import java.security.spec.InvalidParameterSpecException;
import java.security.InvalidAlgorithmParameterException;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.io.StringWriter;
import java.io.PrintWriter;
public static String jAesEncrypt(final String plaintextBytesString, final String keyBytesString) throws RuntimeException
{
	byte[] keyBytes       = jHexBytesFromString(keyBytesString);
	byte[] plaintextBytes = jHexBytesFromString(plaintextBytesString);
	
	byte[] ciphertextBytes;
	
	try
	{
		final SecretKey aesKey = new SecretKeySpec(keyBytes, "AES");
		
		final Cipher aesInstance = Cipher.getInstance("AES/ECB/NoPadding");
		             aesInstance.init(Cipher.ENCRYPT_MODE, aesKey);
		
		ciphertextBytes = aesInstance.doFinal(plaintextBytes);
	}
	catch (Exception e)
	{
		StringWriter stackTrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stackTrace));
		
		throw new RuntimeException(stackTrace.toString());
	}
	
	return jHexStringFromBytes(ciphertextBytes);
}
#End If


