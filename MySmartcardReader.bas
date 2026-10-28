B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=12.5
@EndOfDesignText@

#Region Class File Attributes
	
#End Region

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
'PC/SC Smartcard class code
'

#If Java
import com.acs.smartcard.ReaderException;
import com.acs.smartcard.Reader.OnStateChangeListener;
import com.acs.smartcard.Reader;
import net.gdmeunier.pinunblocker.myexceptions.SmartcardReaderException;
import net.gdmeunier.pinunblocker.myexceptions.SmartcardException;
import net.gdmeunier.pinunblocker.myexceptions.ApduException;
import net.gdmeunier.pinunblocker.myexceptions.ApduReplyException;
import java.io.ByteArrayOutputStream;
import java.util.Arrays;
public static class SmartcardReader
{
	public SmartcardReader()
	{
		/* Nothing to do here */
	}
	
	// More info:
	//  - https://www.eftlab.com.au/index.php/site-map/knowledge-base/118-apdu-response-list
	//
	private static enum ApduSwCode /* Only the unimportant aka. non-critical error codes */
	{
		OK,
		OkMoreExpected,
		OkGetRsp,
		BadLengthLeCorrectIsXX,
		InitialSwCode /* Just a default value so that "status" variable isn't null on init */
	}
	
	/* - Don't remove the last 0x00 byte even if GET_RESPONSE should be 4 bytes,
	 *   it's just so that we get a 5-bytes array length to request specific
	 *   length of data from the card later when there are more bytes available
	 */
	//                                           CLA         INS         P1----------P2          Lc
	//                                           |           |           |           |           |
	private static final byte[] GET_RESPONSE = { (byte)0x00, (byte)0xC0, (byte)0x00, (byte)0x00, (byte)0x00}; /* Don't remove the last 0x00 byte */	
	
	private boolean isCardReady(Reader mReader, final int iSlotNum)
	{
		return mReader.getState(iSlotNum) == Reader.CARD_SPECIFIC;
	}
	
	/* For sending any APDU that we wish to send to the smartcards:
	 *  - It's for sending arbitrary APDUs
	 */
	public String sendSpecificAPDU(String apduHexString, Reader mReader, final int iSlotNum) throws SmartcardReaderException, SmartcardException, ApduException, ApduReplyException
	{
		if ( !isCardReady(mReader, iSlotNum) )
		{
			throw new SmartcardException("No smartcard was ready to receive APDUs");
		}
		
		// Remove spaces from the APDU Hex string if any
		apduHexString = apduHexString.replaceAll(" ", "");
		
		if ( !myconverters.jIsTextHexBytes(apduHexString) )
		{
			throw new ApduException("The APDU string is invalid (not Hex bytes string, uneven length, or contains characters that are not 0-9 and A-F)");
		}
		
		byte[]     cmd    = myconverters.jHexBytesFromString(apduHexString);
		byte[]     rsp    = new byte[0];              /* Just so that the Java compiler is happy */
		ApduSwCode status = ApduSwCode.InitialSwCode; /* Just so that it's not null at first     */
		
		ByteArrayOutputStream rspOut = new ByteArrayOutputStream();
		
		int offset = 0; /* Incase we get SW status 63F1 (More Data Expected) */
		
		int currentCLA;
		int currentP1;
		int currentP2;
		
		byte[] responseBuffer = new byte[0]; /* Just so that the Java compiler is happy */
		int    responseLength = 0;
		
		do
		{
			if ( status != ApduSwCode.OkGetRsp ) /* The OkGetRsp branch already does it */
			{
				try
				{
					// Reset response buffer before next APDU command
					responseBuffer = new byte[258]; // Max APDU response length for T0 / T1 (256+2)
					
					// This function returns only the response length
					responseLength = mReader.transmit(iSlotNum, cmd, cmd.length, responseBuffer, responseBuffer.length);
				}
				catch (Exception e)
				{
					throw new SmartcardReaderException("Failed to transmit the provided APDU to the smartcard");
				}
				
				// The real response object "rsp" gets only correct bytes length copied (responseLength)
				rsp = Arrays.copyOf(responseBuffer, responseLength);
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
					
					// Request the next response data (SW1)
					// rsp[rsp.length - 1] = last byte index (CorrectLengthIsXX value)
					rsp = getResponse(rsp[rsp.length - 1], mReader, iSlotNum);
					break;
					
				case BadLengthLeCorrectIsXX:
					cmd[4] = rsp[1]; // Correct the length field (2-bytes return APDU)
					break;
					
				default:
					throw new ApduReplyException(
						String.format("APDU response indicates failure (%s)",
							myconverters.jHexStringFromBytes(new byte[] {rsp[rsp.length - 2], rsp[rsp.length - 1]})
						)
					);
			}
		}
		while
		(
			status == ApduSwCode.BadLengthLeCorrectIsXX || status == ApduSwCode.OkGetRsp || status == ApduSwCode.OkMoreExpected
		);
		
		return myconverters.jHexStringFromBytes(rspOut.toByteArray());
	}
	
	private byte[] getResponse(int len, Reader mReader, final int iSlotNum) throws SmartcardReaderException, SmartcardException, ApduReplyException
	{
		if ( !isCardReady(mReader, iSlotNum) )
		{
			throw new SmartcardException("No smartcard was ready to receive APDUs");
		}
		
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
		
		byte[] responseBuffer = new byte[258]; // Max APDU response length for T0 / T1 (256+2)
		int    responseLength = 0;
		
		try
		{
			// This function returns only the response length
			responseLength = mReader.transmit(iSlotNum, cmd, cmd.length, responseBuffer, responseBuffer.length);
		}
		catch (Exception e)
		{
			throw new SmartcardReaderException("Failed to transmit the provided APDU to the smartcard");
		}
		
		// The real response object "rsp" gets only correct bytes length copied (responseLength)
		byte[] rsp = Arrays.copyOf(responseBuffer, responseLength);
		
		switch ( validateResponse(rsp) )
		{
			// Basically same as if it was "case (OK || OkGetRsp || OkMoreExpected):"
			case OK:
			case OkGetRsp:
			case OkMoreExpected:
				return rsp;
				
			default:
				throw new ApduReplyException(
					String.format("APDU response indicates failure (%s)",
						myconverters.jHexStringFromBytes(new byte[] {rsp[rsp.length - 2], rsp[rsp.length - 1]})
					)
				);
		}
	}
	
	private ApduSwCode validateResponse(final byte[] rsp) throws ApduReplyException
	{
		if ( rsp.length >= 2 )
		{
			if ( rsp[rsp.length - 2] == (byte)0x90 &&
			     rsp[rsp.length - 1] == (byte)0x00 )
			{
				return ApduSwCode.OK;
			}
			else if ( rsp[rsp.length - 2] == (byte)0x61 )
			{
				/* T=0 protocol only */
				return ApduSwCode.OkGetRsp;
			}
			else if ( rsp[rsp.length - 2] == (byte)0x63 &&
			          rsp[rsp.length - 1] == (byte)0xF1 )
			{
				/* T=1 protocol only */
				return ApduSwCode.OkMoreExpected;
			}
			else if ( rsp[rsp.length - 2] == (byte)0x6C )
			{
				return ApduSwCode.BadLengthLeCorrectIsXX;
			}
		}
		else
		{
			throw new ApduReplyException("APDU response is not atleast 2 bytes (length = "+rsp.length+" bytes)");
		}
		
		/* Anything else is considered as APDU reply error
		 * even if the APDU SW status code considers some
		 * SW status code ranges as warnings only
		 *
		 * "How are APDU status word ranges organised?
		 *
		 *  SW1 partitions the space:
		 *   - 90 is success,
		 *   - 61 is success with data pending,
		 *   - 62 and 63 are warnings (distinguishing non-volatile memory unchanged from changed)
		 *   - 64 through 66 are execution errors,
		 *   - 67 is wrong length,
		 *   - 68 marks functions in the class byte that are not supported,
		 *   - 69 means the command is not allowed,
		 *   - 6A indicates wrong P1-P2 parameters,
		 *   - 6B through 6F cover the remaining error conditions."
		 *
		 * Thanks to: https://smartcardfyi.com/glossary/apdu-response-codes/
		 */
		
		ApduReplyException apduEx = new ApduReplyException(
			String.format("APDU response indicates failure (%s)",
				myconverters.jHexStringFromBytes(new byte[] {rsp[rsp.length - 2], rsp[rsp.length - 1]})
			)
		);
		/*
		apduEx.setSwStatusCode(rsp);
		
		if ( rsp[rsp.length - 2]         == (byte)0x63 &&
		    (rsp[rsp.length - 1] & 0xF0) == (byte)0xC0 )
		{
			apduEx.prependLineToLogs(String.format("Verify failed (63Cx): %X tries left", rsp[rsp.length - 1] & 0x0F));
		}
		else if ( rsp[rsp.length - 2] == (byte)0x69 &&
		          rsp[rsp.length - 1] == (byte)0x83 )
		{
			apduEx.prependLineToLogs("Authentication blocked (6983)");
		}
		*/
		
		throw apduEx;
	}
}

#End If


