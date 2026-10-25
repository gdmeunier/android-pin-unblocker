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
	
	'For throwing Exceptions
	Private Exceptions As MyExceptions
	
	'For converting between numbers, Hex, etc
	Private Converters As MyConverters
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
	'For throwing Exceptions
	Exceptions.Initialize
	
	'For converting between numbers, Hex, etc
	Converters.Initialize
	
End Sub

Public Sub HashText(Plaintext As String, HashType As String) As String
	
	If Plaintext == Null Or HashType == Null Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_HASHING, "One of the provided parameters is Null")
	End If
	
	If HashType == "" Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_HASHING, "The requested hash type parameter is an empty string")
	End If
	
	If HashType <> ALGORITHM_SHA256 And HashType <> ALGORITHM_SHA512 Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_HASHING, "The requested hash type is not a supported hashing algorithm")
	End If
	
	'
	'It's technically possible to generate an hash for
	'an empty string, which is actually a 0x00 byte
	'
	
	Dim TextHash As String
	
	Try
		TextHash = joClass.RunMethod("jHashText", Array(Plaintext, HashType))
	Catch
		Exceptions.ThrowException(Exceptions.EXCEPTION_HASHING, "The hashing of the provided plaintext failed")
	End Try
	
	Return TextHash
	
End Sub
#If Java
import net.gdmeunier.pinunblocker.myexceptions.HashingException;
import java.security.MessageDigest;
public static String jHashText(final String plaintext, final String hashType) throws HashingException
{
	String textHash;
	
	try
	{
		byte[]        plaintextBytes = plaintext.getBytes();
		MessageDigest md             = MessageDigest.getInstance(hashType);
		
		byte[] textHashBytes = md.digest(plaintextBytes);
		
		textHash = myconverters.jBytesToHexString(textHashBytes);
	}
	catch (Exception e)
	{
		throw new HashingException(
			String.format("Failed to generate a %s hash for the provided plaintext",
				hashType
			)
		);
	}
	
	return textHash;
}
#End If

'This encryption function uses ECB mode without padding
'That means the length of the plaintext must match the key's
Public Sub TripleDesEncrypt(PlaintextBytesString As String, KeyBytesString As String) As String
	
	If PlaintextBytesString == Null Or KeyBytesString == Null Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is Null")
	End If
	
	If PlaintextBytesString == "" Or KeyBytesString == "" Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is an empty string")
	End If
	
	If Not(Converters.IsTextHexBytes(PlaintextBytesString) And Converters.IsTextHexBytes(KeyBytesString)) Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is not an key bytes string")
	End If
	
	If KeyBytesString.Length <> 48 And KeyBytesString.Length <> 32 Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The provided key bytes string is not a valid TripleDES key length")
	End If
	
	'DES-EDE2 & DES-EDE3 block sizes are 8 bytes for both (16 Hex chars)
	'Since we use ECB without padding, length must match the block size
	If PlaintextBytesString.Length Mod 16 <> 0 Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The provided plaintext bytes string is not a length multiple of 8 bytes (16 chars)")
	End If
	
	Dim CiphertextBytesString As String
	
	Try
		CiphertextBytesString = joClass.RunMethod("jTripleDesEncrypt", Array(PlaintextBytesString, KeyBytesString))
	Catch
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The TripleDES encryption operation with the provided parameters failed")
	End Try
	
	Return CiphertextBytesString
	
End Sub
#If Java
import net.gdmeunier.pinunblocker.myexceptions.EncryptionException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.DESKeySpec;
import javax.crypto.spec.DESedeKeySpec;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import javax.crypto.Cipher;
public static String jTripleDesEncrypt(final String plaintextBytesString, final String keyBytesString) throws EncryptionException
{
	byte[] keyBytes = myconverters.jHexBytesFromString(keyBytesString);
	
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
	
	byte[] plaintextBytes = myconverters.jHexBytesFromString(plaintextBytesString);
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
		throw new EncryptionException("Failed to perform the 3DES/2DES operation (ECB mode)");
	}
	
	return myconverters.jHexStringFromBytes(ciphertextBytes);
}

#End If

'This encryption function uses ECB mode without padding
'That means the length of the plaintext must match the key's
Public Sub AesEncrypt(PlaintextBytesString As String, KeyBytesString As String) As String
	
	If PlaintextBytesString == Null Or KeyBytesString == Null Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is Null")
	End If
	
	If PlaintextBytesString == "" Or KeyBytesString == "" Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is an empty string")
	End If
	
	If Not(Converters.IsTextHexBytes(PlaintextBytesString) And Converters.IsTextHexBytes(KeyBytesString)) Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "One of the provided parameters is not an key bytes string")
	End If
	
	If KeyBytesString.Length <> 32 And KeyBytesString.Length <> 64 Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The provided key bytes string is not a supported AES key length")
	End If
	
	'AES-128 & AES-256 block sizes are 16 bytes for both (32 Hex chars)
	'Since we use ECB without padding, length must match the block size
	If PlaintextBytesString.Length Mod 32 <> 0 Then
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The provided plaintext bytes string is not a length multiple of 16 bytes (32 chars)")
	End If
	
	Dim CiphertextBytesString As String
	
	Try
		CiphertextBytesString = joClass.RunMethod("jAesEncrypt", Array(PlaintextBytesString, KeyBytesString))
	Catch
		Exceptions.ThrowException(Exceptions.EXCEPTION_ENCRYPTION, "The AES encryption operation with the provided parameters failed")
	End Try
	
	Return CiphertextBytesString
	
End Sub
#If Java
import net.gdmeunier.pinunblocker.myexceptions.EncryptionException;
import java.security.AlgorithmParameterGenerator;
import java.security.AlgorithmParameters;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
public static String jAesEncrypt(final String plaintextBytesString, final String keyBytesString) throws EncryptionException
{
	byte[] keyBytes       = myconverters.jHexBytesFromString(keyBytesString);
	byte[] plaintextBytes = myconverters.jHexBytesFromString(plaintextBytesString);
	
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
		throw new EncryptionException("Failed to perform the AES-128/AES-256 operation (ECB mode)");
	}
	
	return myconverters.jHexStringFromBytes(ciphertextBytes);
}
#End If


