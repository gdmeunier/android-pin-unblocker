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
'This is a Java-only class, it does not offer Basic-code:
' - Functions that require a Context must not be static
' - Fields related to Context-dependent resources must not be static
'

Sub Class_Globals
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
End Sub

'
'Class fields etc
'

#If Java

private static final String TAG = "net.gdmeunier.pinunblocker";

#End If

'
'PC/SC APDU Exception objects
'

#If Java
import java.io.IOException;
public static class APDUException extends IOException
{
	private byte SW1;
	private byte SW2;
	
	public APDUException(String msg, byte SW1, byte SW2)
	{
		super(msg);
		this.SW1 = SW1;
		this.SW2 = SW2;
	}
	
	public byte getSW1()
	{
		return SW1;
	}
	
	public byte getSW2()
	{
		return SW2;
	}
}

public static class UserCancelException extends Exception
{
	public UserCancelException(String msg)
	{
		super(msg);
	}
}

public static class AbortException extends Exception
{
	public AbortException(String msg)
	{
		super(msg);
	}
}

import java.io.IOException;
public static class CardBlockedException extends IOException
{
	public CardBlockedException(String msg)
	{
		super(msg);
	}
}
#End If

'
'PC/SC smartcard callbacks
'

#If Java
public interface CardCallback
{
	void inserted();
	void removed();
}

public interface PinCallback
{
    /* Called to get the PIN from the user.
     * The method may throw an exception to cancel.
     * @param retries The number of retries left, -1 is unknown
     * @return The PIN as chars ('0', '1', ...)
     */
    char[] getPin(int retries) throws UserCancelException;

    void pinPadStart(int retries);
    void pinPadEnd();
}
#End If

'
'PC/SC Smartcard class code
'

#If Java
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.SystemClock;
import android.util.Log;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Map;
public static class SmartcardReader implements Closeable
{
	// More info:
	//  - https://www.eftlab.com.au/index.php/site-map/knowledge-base/118-apdu-response-list
	//
	private static enum ApduSwCode
	{
		OK,
		OkGetRsp,
		OkMoreExpected,
		VerifyFail,
		MemoryUnchanged,
		CommandTimeout,
		SecConNotSatisfied,
		AuthBlocked,
		WrongParamP1P2,
		BadLengthLeCorrectIsXX,
		InitialSwCode, /* Just a default value so that "status" variable isn't null on init */
	}
	
	/* Values higher than 0x7F (127) should probably be explicitly casted as bytes */
	//
	//                                          CLA         INS         P1----------P2          Lc
	//                                          |           |           |           |           |
	private static final byte[] VERIFY_PIN  = { (byte)0x00, (byte)0x20, (byte)0x00, (byte)0x01, (byte)0x08, /* <-- ISO/IEC 7816 header */
	//                                    /* vv ISO/IEC 7816 data below vv */
	//                                          |
	                                            (byte)0x20, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF };
	//
	//                                          CLA          INS         P1----------P2          Lc
	//                                          |            |           |           |           |
	private static final byte[] GET_RESPONSE = { (byte)0x00, (byte)0xC0, (byte)0x00, (byte)0x00, (byte)0x00}; /* Don't remove the last 0x00 byte */	
	/* ^^ Don't remove the last 0x00 byte even if GET_RESPONSE should be 4 bytes,
	 *    it's just so that we get a 5-bytes array length to request specific
	 *    length of data from the card later when there are more bytes available
	 */
	 
	/* For sending any APDU that we wish to send to the smartcards:
	 *  - It's for sending arbitrary APDUs
	 */
	public String sendSpecificAPDU(String apduHexString) throws IOException
	{
		if ( !cardPresent )
		{
			throw new IOException("No card present");
		}
		
		// Remove spaces from the APDU Hex string if any
		apduHexString = apduHexString.replaceAll(" ", "");
		
		if ( !jIsTextHexBytes(apduHexString) )
		{
			throw new IOException("Your APDU string is not valid (not Hex bytes string of even length and 0-9 A-F chars)");
		}
		
		byte[] apdu = jHexBytesFromString(apduHexString);
		byte[] cmd  = Arrays.copyOf(apdu, apdu.length);
		
		byte[]     rsp    = new byte[0];              // Just so that the Java compiler is happy
		ApduSwCode status = ApduSwCode.InitialSwCode; // Just so that it's not null at first
		
		ByteArrayOutputStream rspOut = new ByteArrayOutputStream();
		
		// Incase we get SW status 63F1 (More Data Expected)
		int offset = 0;
		
		int currentCLA;
		int currentP1;
		int currentP2;
		
		do
		{
			if ( status != ApduSwCode.OkGetRsp ) /* The OkGetRsp branch already does it */
			{
				rsp = cardReader.transmitApdu(cmd);
			}
			status = validateResponse(rsp);
			
			switch ( status )
			{
				case OK:
					/* The 0's in these write calls are the offset of
					 * the data in the new response, not that of rspOut
					 *
					 * So no worries, we're not writing at the index 0
					 * of our rspOut byte array stream
					 */
					rspOut.write(rsp, 0, rsp.length); // Return status code too (last 2 bytes)
					break;
					
				case OkMoreExpected:
					/* ********************************** *
					 * Stream current response data first *
					 * ********************************** */
					rspOut.write(rsp, 0, rsp.length - 2);
					
					/* We make the handling of chained APDUs transparent for the caller,
					 * so that they don't have to chain command APDUs themselves
					 */
					// Check what the original command was (what INS was)
					switch ( rsp[1] ) // Index 1 = INS byte
					{
						case (byte)0xB0: // READ BINARY
							// Check if it's a Short File Identifier (SFI)
							if ( (cmd[2] & 0x80) != 0 )
							{
								// SFI: Increase P2 only in command (request APDU)
								currentP2 = (cmd[3] & 0xFF) + (rsp.length - 2);
								
								// Correct the offset to the new one in the command (request APDU)
								cmd[3] = (byte)currentP2;
							}
							else
							{
								/* Compute what the current offset is
								 *
								 * Note: In Java we have to make sure our bytes don't get
								 *       accidentally trimmed as signed bytes,
								 *       so we always mask them with 0xFF
								 */
								currentP1 = cmd[2] & 0xFF; // Index 2 = P1 (in request APDU)
								currentP2 = cmd[3] & 0xFF; // Index 3 = P2 (in request APDU)
								offset    = (currentP1 << 8) | currentP2;
								
								// Increment the computed offset by (response data length) [without status]
								offset += rsp.length - 2;
								
								// Correct the offset to the new one in the command (request APDU)
								cmd[2] = (byte)(offset >> 8);
								cmd[3] = (byte)offset;
							}
							break;
							
						case (byte)0xA4: // SELECT FILE (if FCP - File Control Parameter was too big)
							/* Must switch from SELECT FILE to GET RESPONSE
							 *
							 * Replacing the original request APDU with a GET RESPONSE one
							 * Also setting the requested response length to 256 bytes:
							 *  - By setting the value to 0x00 (0x00 = 256 in ISO-7816),
							 *    it's not 0xFF because 0xFF = 255 (not 256)
							 *
							 *  - 256 would be 0x0100 but because the length must be 1 byte,
							 *    ISO-7816 considers that 0x00 = 256 always
							 */
							cmd    = Arrays.copyOf(GET_RESPONSE, GET_RESPONSE.length);
							cmd[4] = (byte)0x00;
							break;
							
						case (byte)0xCA: // GET DATA
							/* Same as the default action:
							 *  - So we don't add "break;" here
							 */
						default:
							/* Note: If a smartcard returns 63F1 (More Data Expected),
							 *       and yet the request APDU was neither of these:
							 *        - READ BINARY
							 *        - GET DATA
							 *        - SELECT FILE
							 *
							 *       Then you must only set a CLA chaining bit in the
							 *       request APDU's CLA byte (Index 0), and never alter
							 *       any of the INS, P1 and P2 bytes (Indexes 1, 2 & 3)
							 */
							// Get the current CLA value from the command (request APDU)
							currentCLA = cmd[0] & 0xFF;
							
							/* Correct the CLA byte in the command (request APDU):
							 *  - Set the bit 5 (chaining bit) in the CLA (bitOR with 0x10)
							 */
							cmd[0] = (byte)(currentCLA | 0x10);
							break;
					}
					break;
					
				case OkGetRsp: /*** T=0 protocol only ***/
					rspOut.write(rsp, 0, rsp.length - 2);   // Stream current response data first
					rsp = getResponse(rsp[rsp.length - 1]); // Request the next response data
					break;
					
				case BadLengthLeCorrectIsXX:
					cmd[4] = rsp[1]; // Correct the length field
					break;
					
				default:
					throw new APDUException("The card returned an error: "+jHexStringFromBytes(rsp), rsp[0], rsp[1]);
			}
		}
		while
		(
			status == ApduSwCode.BadLengthLeCorrectIsXX || status == ApduSwCode.OkGetRsp || status == ApduSwCode.OkMoreExpected
		);
		
		Log.d(TAG, String.format("Response APDU received (len %d)", rspOut.toByteArray().length));
		return jHexStringFromBytes(rspOut.toByteArray());
	}
	
	public void verifyPin() throws IOException, UserCancelException
	{
		int retries = -1;
		
		while ( true )
		{
			byte[] rsp;
			
			if ( cardReader.hasPinPad() )
			{
				pinCallback.pinPadStart(retries);
				
				try
				{
					rsp = cardReader.transmitApduWithPin(VERIFY_PIN);
				}
				finally
				{
					pinCallback.pinPadEnd();
				}
			}
			else
			{
				char[] pin = pinCallback.getPin(retries);
				byte[] cmd = Arrays.copyOf(VERIFY_PIN, VERIFY_PIN.length);
				
				cmd[5] = (byte)(cmd[5] | pin.length);
				
				for ( int idx = 0; idx < pin.length; idx += 2 )
				{
					byte digit1 = (byte)((pin[idx] - '0') << 4);
					byte digit2 = idx + 1 < pin.length ? (byte)(pin[idx + 1] - '0') : 0x0F;
					cmd[idx / 2 + 6] = (byte)(digit1 | digit2);
				}
				
				// Erase pin from memory
				Arrays.fill(pin, (char)0x00);
				
				try
				{
					rsp = cardReader.transmitApdu(cmd);
				}
				finally
				{
					Arrays.fill(cmd, (byte)0x00);
				}
			}
			switch ( validateResponse(rsp) )
			{
				case OK:
					return;
					
				case VerifyFail:
					retries = rsp[1] & 0x0F;
					break;
					
				case MemoryUnchanged:
					throw new UserCancelException("PIN Timeout");
					
				case CommandTimeout:
					throw new UserCancelException("User canceled PIN entry");
					
				case AuthBlocked:
					throw new CardBlockedException("The key on the card is blocked (too many tries)");
					
				default:
					throw new APDUException("The card returned an error: "+jHexStringFromBytes(rsp), rsp[0], rsp[1]);
			}
		}
	}
	
	private myccid.CCID  cardReader;
	private CardCallback cardCallback;
    private PinCallback  pinCallback;
	
	private boolean cardPresent;
	
	public CardCallback getCardCallback()
	{
		return cardCallback;
	}
	
	public void setCardCallback(CardCallback value)
	{
		this.cardCallback = value;
	}
	
	public PinCallback getPinCallback()
	{
		return pinCallback;
	}
	
	public void setPinCallback(PinCallback value)
	{
		this.pinCallback = value;
	}
	
	public boolean isOpen()
	{
		return cardReader.isOpen();
	}
	
	public boolean isCardPresent()
	{
		return cardPresent;
	}
	
	public SmartcardReader(UsbManager manager, final UsbDevice device)
	{
		cardPresent = false;
		
		this.cardReader = new myccid.CCID(manager, device);
		this.cardReader.setCallback(new CardReaderCallback());
	}
	
	private byte[] cardATR;
	
	public byte[] getCardATR()
	{
		return this.cardATR;
	}
	
	private void setCardATR(byte[] atr)
	{
		this.cardATR = atr;
	}
	
	public synchronized void open() throws IOException
	{
		if ( cardReader.isOpen() )
		{
			Log.d(TAG, "Card reader is already open");
			return;
		}
		
		cardPresent = false;
		cardReader.open();
		
		try
		{
			cardReader.powerOff();
		}
		catch (Exception e)
		{
			Log.d(TAG, "Failed power off after open", e);
		}
		
		try
		{
			setCardATR(cardReader.powerOn());
			processAtr(getCardATR());
		}
		catch (IOException io)
		{
			Log.d(TAG, "Failed power on after open");
		}
	}
	
	private class CardReaderCallback implements myccid.CardCallback
	{
		@Override
		public void inserted()
		{
			try
			{
				setCardATR(cardReader.powerOn());
				processAtr(getCardATR());
				
				if ( cardPresent && cardCallback != null )
				{
					cardCallback.inserted();
				}
			}
			catch (IOException io)
			{
				Log.d(TAG, "Failed to handle card insert", io);
			}
		}
		
		@Override
		public void removed()
		{
			if ( cardPresent )
			{
				cardPresent = false;
				
				if ( cardCallback != null )
				{
					cardCallback.removed();
				}
			}
		}
	}
	
	private void processAtr(byte[] atr) throws IOException
	{
		/* If card is present */
		if ( atr != null )
		{
			cardPresent = true;
			cardReader.init(atr);
		}
		else
		{
			cardPresent = false;
		}
	}
	
	@Override
	public synchronized void close() throws IOException
	{
		if ( !cardReader.isOpen() )
		{
			Log.d(TAG, "Card reader is already closed");
			return;
		}
		
		if ( cardPresent )
		{
			try
			{
				cardReader.powerOff();
			}
			catch (Exception e)
			{
				Log.d(TAG, "Card reader can't power down the card", e);
			}
			
			cardPresent = false;
		}
		
		cardReader.close();
	}
	
	private byte[] getResponse(int len) throws IOException
	{
		byte[] cmd = Arrays.copyOf(GET_RESPONSE, GET_RESPONSE.length);
		
		// Check if requested byte length is 256 bytes
		if ( len == 256 )
		{
			/* Correct the length to zero, because in Javacards
			 * a length of 256 exceeds 0xFF (it's actually 0x100),
			 * so the Javacards actually condider that it's 0x00  that is
			 * a 256-bytes length, not 0x100:
			 *
			 *  - 0x100 (256) would take 01 00 or 00 01 as bytes,
			 *    depending on Little Endian vs. Big Endian,
			 *    whereas it's only allowed to use one byte for the length
			 */
			 len = 0;
		}
		cmd[4] = (byte)len;
		
		byte[] rsp = cardReader.transmitApdu(cmd);
		
		switch ( validateResponse(rsp) )
		{
			// Basically same as if it was "case (OK || OkGetRsp || OkMoreExpected):"
			case OK:
			case OkGetRsp:
			case OkMoreExpected:
				return rsp;
				
			default:
				throw new APDUException("The card returned an error: "+jHexStringFromBytes(rsp), rsp[0], rsp[1]);
		}
	}
	
	private ApduSwCode validateResponse(byte[] rsp) throws IOException
	{
		if ( rsp.length < 2 )
		{
			Log.e(TAG, "APDU command did not return atleast 2 bytes: "+rsp.length);
			throw new IOException("The card returned an invalid response");
		}
		else if ( rsp[rsp.length - 2] == (byte)0x90 &&
				  rsp[rsp.length - 1] == 0x00 )
		{
			return ApduSwCode.OK;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x61 ) /* T=0 protocol only */
		{
			Log.d(TAG, String.format("(T=0 protocol) APDU OK, still %X bytes available", rsp[rsp.length-1]));
			return ApduSwCode.OkGetRsp;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x63 &&
				  rsp[rsp.length - 1] == (byte)0xF1 )
		{
			Log.d(TAG, "(T=1 protocol) APDU OK, more bytes expected");
			return ApduSwCode.OkMoreExpected;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x63 &&
				  (rsp[rsp.length - 1] & 0xF0) == 0xC0 )
		{
			Log.i(TAG, String.format("Verify fail, %X tries left.", rsp[1] & 0x0F));
			return ApduSwCode.VerifyFail;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x64 &&
				  (rsp[rsp.length -1] == 0x00) )
		{
			Log.i(TAG, "Memory Unchanged");
			return ApduSwCode.MemoryUnchanged;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x64 &&
				  (rsp[rsp.length -1] == 0x01) )
		{
			Log.i(TAG, "Command timeout");
			return ApduSwCode.CommandTimeout;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x69 &&
				  rsp[rsp.length - 1] == (byte)0x82 )
		{
			Log.w(TAG, "Security condition not satisfied");
			return ApduSwCode.SecConNotSatisfied;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x69 &&
				  rsp[rsp.length - 1] == (byte)0x83 )
		{
			Log.w(TAG, "Authentication method blocked");
			return ApduSwCode.AuthBlocked;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x6B &&
				  rsp[rsp.length - 1] == 0x00 )
		{
			Log.w(TAG, "APDU wrong parameter(s) P1-P2");
			return ApduSwCode.WrongParamP1P2;
		}
		else if ( rsp[rsp.length - 2] == (byte)0x6C )
		{
			Log.d(TAG,
				String.format("APDU Bad length value in Le; 'xx' is the correct exact Le",
					rsp[rsp.length-1]
				)
			);
			return ApduSwCode.BadLengthLeCorrectIsXX;
		}
		else
		{
			Log.w(TAG,
				String.format("APDU command failed: %X %X",
					rsp[rsp.length - 2], rsp[rsp.length - 1]
				)
			);
			throw new APDUException("The card returned an error: "+jHexStringFromBytes(rsp), rsp[rsp.length - 2], rsp[rsp.length - 1]);
		}
	}
}

private static boolean jIsTextHexBytes(final String string)
{
	return string.length()     >= 2 &&
	       string.length() % 2 == 0 &&
		   string.matches("^[0-9a-fA-F]+$");
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


