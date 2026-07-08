B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Module File Attributes
	
#End Region

'------------------------------------------------------------------
'Disclaimer: this cryptography class contains encryption functions
'            that are only intended for the generation of smartcard
'            challenge-response unblock codes, and aren't fit for
'            any other and potentially sensitive usage
'
'This cryptography class also doesn't provide decryption functions
'because this App doesn't make use for decryption, only encryption
'------------------------------------------------------------------

Sub Class_Globals
	
	Public Const CRYPTOGRAPHY_ALGORITHM_2DES    As String = "2DES (DES-EDE2)"
	Public Const CRYPTOGRAPHY_ALGORITHM_3DES    As String = "3DES (DES-EDE3)"
	Public Const CRYPTOGRAPHY_ALGORITHM_AES128  As String = "AES (AES-128)"
	Public Const CRYPTOGRAPHY_ALGORITHM_AES256  As String = "AES (AES-256)"
	Public Const CRYPTOGRAPHY_ALGORITHM_UNKNOWN As String = "Unknown"
	
	'For running Java native code
	Private joMyCryptography As JavaObject
	
End Sub

Public Sub Initialize
	
	'For running Java native code
	joMyCryptography.InitializeStatic(Application.PackageName&".mycryptography")
	
End Sub

'Verify that a string represents Hex bytes
'Not just an Hexadecimal number
Public Sub VerifyIfTextIsHexBytes(Text As String) As Boolean
	Return joMyCryptography.RunMethod("jVerifyIfTextIsHexBytes", Array(Text))
End Sub
'Java native helper code for verifying if text is Hex bytes
'
'This is both a dedicated MyCryptography class method
'and a Java native helper function for encryption
#If Java
public static boolean jVerifyIfTextIsHexBytes(final String s)
{
	return s.length()     >= 2 &&
	       s.length() % 2 == 0 &&
		   s.matches("^[0-9a-fA-F]+$");
}
#End If

'Returns empty string on failure
Public Sub TextToHash(Text As String, HashType As String) As String
	Return joMyCryptography.RunMethod("jTextToHash", Array(Text, HashType))
End Sub
#If Java
import java.security.MessageDigest;
import java.math.BigInteger;
public static String jTextToHash(final String text, final String hashType)
{
	String textHash;
	
	try
	{
		byte[] textBytes = text.getBytes();
		MessageDigest md = MessageDigest.getInstance(hashType);
		
		byte[] textHashBytes = md.digest(textBytes);
		textHash = jBytesToHexString(textHashBytes);
	}
	catch (Exception e)
	{
		textHash = "";
	}
	
	return textHash;
}
#End If

'Exact algorithm to use is determined by the caller of this function
'This function seamlessly handles 2DES (DES-EDE2) as well
'
'Returns empty string on failure
Public Sub TripleDesEncrypt(HexBytesStringInput As String, HexBytesStringKey As String) As String
	Return joMyCryptography.RunMethod("jTripleDesEncrypt", Array(HexBytesStringInput, HexBytesStringKey))
End Sub
#If Java
import javax.crypto.Cipher;
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
public static String jTripleDesEncrypt(final String hexBytesStringInput, final String hexBytesStringKey)
{
	// Verify the text & key input
	// Make sure that they are strings representing Hex bytes
	if ( !jVerifyIfTextIsHexBytes(hexBytesStringInput) ||
	     !jVerifyIfTextIsHexBytes(hexBytesStringKey)   ||
		 /* If key is not even 2DES nor 3DES
		    2DES is actually 3DES with 2 keys
		    
		    It just reuses the first encryption one
		    (DES-EDE as in Encrypt, Decrypt, Encrypt) */
		 (hexBytesStringKey.length() != 32 && hexBytesStringKey.length() != 48)
	   )
	{
		return "";
	}
	
	byte[] hexBytesKey = jHexToolFromString(hexBytesStringKey);
	
	// Specifically for 2DES (DES-EDE2)
	if ( hexBytesStringKey.length() == 32 )
	{
		// Automatically copy first 16 chars to the end of the 2DES key
		// because it's actually required (must repeat them at the end)
		//
		// 2DES is just 3DES with KEY+1KEY2+KEY1 instead of KEY1+KEY2+KEY3
		byte[] tmpHexBytesKey = new byte[24]; // 48 chars
		
		/* 0-based index: */
		/* System.arraycopy(sourceArray, sourceOffset, targetArray, targetOffset, bytesCount); */
		
		// Copying the first two keys
		// Copy first 32 chars (16 bytes) to temporary key at the start of it
		System.arraycopy(hexBytesKey, 0, tmpHexBytesKey, 0, 16);
		
		// Copying the first key
		// Copy first 16 chars (8 bytes) to temporary key after the first 32 chars (16 bytes)
		System.arraycopy(hexBytesKey, 0, tmpHexBytesKey, 16, 8);
		
		// Replace the previous incomplete 2DES key with the equivalent 3DES one
		// This new one will have the 48-chars required (24 bytes) for the 3DES algorithm
		hexBytesKey = tmpHexBytesKey;
	}
	
	byte[] hexBytesInput = jHexToolFromString(hexBytesStringInput);
	byte[] hexBytesCiphertext;
	
	try
	{
		final SecretKeyFactory secKeyFactory = SecretKeyFactory.getInstance("DESede");
		final SecretKey        secKey        = secKeyFactory.generateSecret(new DESedeKeySpec(hexBytesKey));
		
		final Cipher desEdeInstance = Cipher.getInstance("DESede/ECB/NoPadding");
		             desEdeInstance.init(Cipher.ENCRYPT_MODE, secKey);
		
		hexBytesCiphertext = desEdeInstance.doFinal(hexBytesInput);
	}
	catch (Exception e)
	{
		return "";
	}
	
	return jHexToolToString(hexBytesCiphertext);
}
#End If

'Exact algorithm to useis determined by the caller of this function
'This function seamlessly handles both AES-128 & AES-256 as well
'
'Returns empty string on failure
Public Sub AesEncrypt(HexBytesStringInput As String, HexBytesStringKey As String) As String
	Return joMyCryptography.RunMethod("jAesEncrypt", Array(HexBytesStringInput, HexBytesStringKey))
End Sub
#If Java
import javax.crypto.Cipher;
import java.security.spec.InvalidParameterSpecException;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidAlgorithmParameterException;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
public static String jAesEncrypt(final String hexBytesStringInput, final String hexBytesStringKey)
{
	// Verify the text & key input
	// Make sure that they are strings representing Hex bytes
	if ( !jVerifyIfTextIsHexBytes(hexBytesStringInput) ||
	     !jVerifyIfTextIsHexBytes(hexBytesStringKey)   ||
		 /* If key is not even AES-128 nor AES-256 */
		 (hexBytesStringKey.length() != 32 && hexBytesStringKey.length() != 64)
	   )
	{
		return "";
	}
	
	byte[] hexBytesKey   = jHexToolFromString(hexBytesStringKey);
	byte[] hexBytesInput = jHexToolFromString(hexBytesStringInput);
	
	byte[] hexBytesCiphertext;
	
	try
	{
		final SecretKey genAesKey = new SecretKeySpec(hexBytesKey, "AES");
		
		final Cipher aesInstance = Cipher.getInstance("AES/ECB/NoPadding");
		             aesInstance.init(Cipher.ENCRYPT_MODE, genAesKey);
		
		hexBytesCiphertext = aesInstance.doFinal(hexBytesInput);
	}
	catch (Exception e)
	{
		return "";
	}
	
	return jHexToolToString(hexBytesCiphertext);
}
#End If

'Java native helper code for hashing
#If Java
private static String jBytesToHexString(final byte[] hexBytes)
{
	//
	// Internal Class use only
	//
	BigInteger bigInt = new BigInteger(1, hexBytes);
	
	// "X" = UPPERCASE hash
	// "x" = lowercase hash
	return String.format("%0"+(hexBytes.length << 1)+"X", bigInt);
}
#End If

'Java native helper code for encryption
#If Java
private static byte[] jHexToolFromString(final String s)
{
	//
	// Internal Class use only
	//
	final int length   = s.length();
	final byte[] array = new byte[(length + 1) / 2];
	
	int i = 0;
	int n = 0;
	
	if ( length % 2 == 1 )
	{
		array[n++] = (byte)jHexToolFromDigit(s.charAt(i++));
	}
	while ( i < length )
	{
		array[n++] = (byte)(jHexToolFromDigit(s.charAt(i++)) << 4 | jHexToolFromDigit(s.charAt(i++)));
	}
	
	return array;
}
private static int jHexToolFromDigit(final char c)
{
	//
	// Internal Class use only
	//
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
private static String jHexToolToString(final byte[] array)
{
	//
	// Internal Class use only
	//
	return jHexToolToStringTwo(array, 0, array.length);
}
private static String jHexToolToStringTwo(final byte[] array, final int n, final int n2)
{
	//
	// Internal Class use only
	//
	char[] HexToolHexDigits = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	
	final char[] value = new char[n2 * 2];
	int n3 = 0;
	
	for ( int i = n; i < n + n2; ++i )
	{
		final byte b = array[i];
		value[n3++] = HexToolHexDigits[b >>> 4 & 0xF];
		value[n3++] = HexToolHexDigits[b & 0xF];
	}
	
	return new String(value);
}
#End If


