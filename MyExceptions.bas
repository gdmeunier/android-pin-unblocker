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
' * This class is for organizing the possible exceptions
'   that can be thrown by the application's various functions
'
' * This way you know more exactly at which point
'   a function failed or why it failed
'

Sub Class_Globals
	
	'For running Java native code
	Private joClass As JavaObject
	
	'
	'Exception types that can be thown below
	'
	Public Const EXCEPTION_GENERIC            As Int = 0x01
'	- ----- -
'	Public Const EXCEPTION_CAMERA             As Int = 0x02
'	- ----- -
	Public Const EXCEPTION_THREAD             As Int = 0x03
	Public Const EXCEPTION_SMARTCARDOPERATION As Int = 0x04
	Public Const EXCEPTION_NOTIFICATION       As Int = 0x05
	Public Const EXCEPTION_USBDEVICE          As Int = 0x06
	Public Const EXCEPTION_USBPERMISSION      As Int = 0x07
	Public Const EXCEPTION_SMARTCARDREADER    As Int = 0x08
	Public Const EXCEPTION_SMARTCARD          As Int = 0x09
	Public Const EXCEPTION_APDU               As Int = 0x0A
	Public Const EXCEPTION_APDUREPLY          As Int = 0x0B
	Public Const EXCEPTION_HASHING            As Int = 0x0C
	Public Const EXCEPTION_ENCRYPTION         As Int = 0x0D
	Public Const EXCEPTION_CONVERSION         As Int = 0x0E
	#If Java
	public static final int EXCEPTION_GENERIC            = 0x01;
	/* ***** *
	public static final int EXCEPTION_CAMERA             = 0x02;
	 * ***** */
	public static final int EXCEPTION_THREAD             = 0x03;
	public static final int EXCEPTION_SMARTCARDOPERATION = 0x04;
	public static final int EXCEPTION_NOTIFICATION       = 0x05;
	public static final int EXCEPTION_USBDEVICE          = 0x06;
	public static final int EXCEPTION_USBPERMISSION      = 0x07;
	public static final int EXCEPTION_SMARTCARDREADER    = 0x08;
	public static final int EXCEPTION_SMARTCARD          = 0x09;
	public static final int EXCEPTION_APDU               = 0x0A;
	public static final int EXCEPTION_APDUREPLY          = 0x0B;
	public static final int EXCEPTION_HASHING            = 0x0C;
	public static final int EXCEPTION_ENCRYPTION         = 0x0D;
	public static final int EXCEPTION_CONVERSION         = 0x0E;
	#End If
	
End Sub

'Initializes the object
'You can add parameters to this method if needed
Public Sub Initialize
	
	'For running Java native code:
	' - Self-initialization as a JavaObject with its current instance
	joClass = Me.As(JavaObject)
	
End Sub

'
'Helper functions (for being able to throw the exceptions from Basic code)
'

Public Sub ThrowException(ExceptionType As Int, Message As String)
	
	joClass.RunMethod("jThrowException", Array(ExceptionType, Message))
	
End Sub
#If Java
public static void jThrowException(final int exceptionType, final String message) throws GenericException,/* ***** * CameraException,* ***** */ ThreadException, SmartcardOperationException, NotificationException, UsbDeviceException, UsbPermisionException, SmartcardReaderException, SmartcardException, ApduException, ApduReplyException, HashingException, EncryptionException, ConversionException
{
	switch ( exceptionType )
	{
		case EXCEPTION_GENERIC:
			throw new GenericException(message);
		/* ***** *
		case EXCEPTION_CAMERA:
			throw new CameraException(message);
		 * ***** */
		case EXCEPTION_THREAD:
			throw new ThreadException(message);
		case EXCEPTION_SMARTCARDOPERATION:
			throw new SmartcardOperationException(message);
		case EXCEPTION_NOTIFICATION:
			throw new NotificationException(message);
		case EXCEPTION_USBDEVICE:
			throw new UsbDeviceException(message);
		case EXCEPTION_USBPERMISSION:
			throw new UsbPermisionException(message);
		case EXCEPTION_SMARTCARDREADER:
			throw new SmartcardReaderException(message);
		case EXCEPTION_SMARTCARD:
			throw new SmartcardException(message);
		case EXCEPTION_APDU:
			throw new ApduException(message);
		case EXCEPTION_APDUREPLY:
			throw new ApduReplyException(message);
		case EXCEPTION_HASHING:
			throw new HashingException(message);
		case EXCEPTION_ENCRYPTION:
			throw new EncryptionException(message);
		case EXCEPTION_CONVERSION:
			throw new ConversionException(message);
			
		default:
			break;
	}
	
	throw new GenericException(message);
}
#End If

'
'Java native code (the actual Exceptions available)
'

#If Java
/* This one is the generic template, all other custom
 * Exception types depend on it (they all extend it)
 */
import java.io.StringWriter;
import java.io.PrintWriter;
private static class TemplateException extends Exception
{
	// Empty logs by default
	public String logs = "";
	
	// Empty message storage by default
	public String message = "";
	
	/* Replace the default exception message fetching
	 * with an improved version which already has
	 * the full stacktrace, in the message itself
	 */
	@Override
	public String getMessage()
	{
		/* Do note that I want to use Windows newlines
		 * because it will be easier to copy-paste logs
		 * on websites and local text files if the user
		 * later wants to open log files on a Windows PC
		 *
		 * Any "\n" newlines will become "\r\n" afterwards
		 * (Converting Linux newlines to Windows ones)
		 */
		
		// Create the base Exception message first (remove any newlines)
		StringBuilder messageBuilder = new StringBuilder(this.message.replace("\r\n", "").replace("\n", ""));
		
		/* This part of this function allows removing the duplicate line
		 * "net.gdmeunier.pinunblocker.myexceptions$TheExceptionType: ..."
		 * from the output of the Exception message
		 *
		 * That's because this getMessage() function is hooked to
		 * return the entire log as the message without requiring
		 * the caller to explicitly query the stacktrace itself
		 * on its own (manually via its own PrintWriter, etc)
		 *
		 * Also do note that in order to safely match
		 * both "\r\n" (CRLF, Windows) and "\n" newlines (LF, Linux),
		 * I convert any Windows newline to Linux format,
		 * then I convert it all back to the Windows one
		 *
		 * So incase there are mixed CRLF and LF newlines,
		 * then turn them all the same into LF before
		 * finally turning them all into CRLF
		 */
		StringBuilder logsBuilder = new StringBuilder(this.logs.replace("\r\n", "\n").replace("\n", "\r\n"));
		
		/* In order to remove the next (duplicate) log line,
		 * we have to also remove its "\r\n" character too,
		 * so we do: logsBuilder.indexOf("\r\n") + 2 // Notice the "+2"
		 *
		 * "As you can read in the docs the delete function treats
		 *  the ending index as exclusive.
		 *
		 *  So when you do sb.delete(0, sb.indexOf("\n")) 3 times,
		 *  the "\n" stays because it's not included in the deleted part,
		 *  the second and third time you delete from index 0 to 0."
		 *
		 * Thanks to:
		 *  - https://stackoverflow.com/questions/55684585/how-can-i-remove-first-3-lines-from-a-stringbuilder-obj-in-java
		 *
		 * Remember that we use "\r\n" now instead of "\n",
		 * and ".indexOf()" will return "-1" if it's not found
		 */
		int firstLogCrLfFoundIndex = logsBuilder.indexOf("\r\n");
		
		if ( firstLogCrLfFoundIndex > -1 )
		{
			/* Remove first line of the log because it's a duplicate one
			 *
			 * It's also "+2" (not "+1") because we're removing up to
			 * "\r\n" inclusive, and "+1" would only remove "\r" instead
			 */
			logsBuilder.delete(0, firstLogCrLfFoundIndex + 2);
		}
		
		// Append the stacktrace to the Exception message
		messageBuilder.append("\r\n");
		messageBuilder.append(logsBuilder.toString());
		
		/* Return the modified message with stacktrace inside
		 *
		 * Just one more tweak though, we remove empty lines
		 * (they will be "\r\n\r\n" aka. "{CRLF}{CRLF}")
		 */
		return messageBuilder.toString().replace("\r\n\r\n", "\r\n");
	}
	
	// The constructors must always be public
	public TemplateException(String msg)
	{
		this.message = msg;
		
		/* Built-in ability to fetch the stacktrace:
		 *  - In Java, stacktraces are generated when the Exception
		 *    is constructed, not when it's thrown [1]
		 *
		 * [1] StackOverflow:
		 *     https://stackoverflow.com/questions/69065097/why-java-stack-traces-are-generated-when-exceptions-are-constructed
		 */
		StringWriter sw = new StringWriter();
		
		this.printStackTrace(new PrintWriter(sw));
		this.logs = sw.toString();
	}
}

//
// Generic Exceptions
//
public static class GenericException extends TemplateException
{
	public GenericException(String msg)
	{
		super(msg);
	}
}

//
// Camera Exceptions (e.g. QR code scanner)
//
/* ***** *
public static class CameraException extends TemplateException
{
	public CameraException(String msg)
	{
		super(msg);
	}
}
 * ***** */

//
// Thread Exceptions (multi-threading)
//
public static class ThreadException extends TemplateException
{
	public ThreadException(String msg)
	{
		super(msg);
	}
}

//
// Smartcard operation Exceptions (Smartcard service)
//
public static class SmartcardOperationException extends TemplateException
{
	public SmartcardOperationException(String msg)
	{
		super(msg);
	}
}

//
// Notification Exceptions (NotificationManager, NotificationChannel...)
//
public static class NotificationException extends TemplateException
{
	public NotificationException(String msg)
	{
		super(msg);
	}
}

//
// USB device Exceptions (e.g. Smartcard reader)
//
public static class UsbDeviceException extends TemplateException
{
	public UsbDeviceException(String msg)
	{
		super(msg);
	}
}

//
// USB Permission Exceptions
//
public static class UsbPermisionException extends TemplateException
{
	public UsbPermisionException(String msg)
	{
		super(msg);
	}
}

//
// Smartcard reader Exceptions
//
public static class SmartcardReaderException extends TemplateException
{
	public SmartcardReaderException(String msg)
	{
		super(msg);
	}
}
//
// Smartcard Exceptions (Smartcard, eg. command timed out etc)
//
public static class SmartcardException extends TemplateException
{
	public SmartcardException(String msg)
	{
		super(msg);
	}
}

//
// APDU Exceptions (the APDU itself)
//
public static class ApduException extends TemplateException
{
	public ApduException(String msg)
	{
		super(msg);
	}
}

//
// APDU reply Exceptions (reply only, e.g. non-9000 SW code)
//
public static class ApduReplyException extends TemplateException
{
	public ApduReplyException(String msg)
	{
		super(msg);
	}
}

//
// Hashing Exceptions
//
public static class HashingException extends TemplateException
{
	public HashingException(String msg)
	{
		super(msg);
	}
}

//
// Encryption Exceptions (encryption, decryption...)
//
public static class EncryptionException extends TemplateException
{
	public EncryptionException(String msg)
	{
		super(msg);
	}
}

//
// Conversion Exceptions (Converting numbers to String or Hex, etc...)
//
public static class ConversionException extends TemplateException
{
	public ConversionException(String msg)
	{
		super(msg);
	}
}
#End If


