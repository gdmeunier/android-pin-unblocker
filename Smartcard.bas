B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=9.9
@EndOfDesignText@

#Region Service Attributes
	#StartAtBoot:        False
	#ExcludeFromLibrary: True
	
#End Region

#Region Module File Attributes
	'Ignore "Sub x is not used" warning (#12)
	'Ignore "Empty Catch block" warning (#19)
	#IgnoreWarnings: 12,19
	
#End Region

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Java native code
'

'General list of all Java native imports for this Service
'This way no need to figure out which functions need what
#If Java
import java.util.Iterator;
import java.util.Map;
import java.util.ArrayList;

import android.content.Context;
import android.app.Service;

import android.os.*;
import android.os.Process; // This one must be explicitly imported

import net.gdmeunier.pinunblocker.R; // Must match the application's package name

// For Android 8+ notifications support (API level 26+)
import android.app.NotificationChannel;

import android.app.NotificationManager;
import android.app.Notification;
import androidx.core.app.NotificationCompat;

import android.media.AudioManager;
import android.content.ContentResolver;

// For Android 5+ notifications support (API level 21+)
import android.media.AudioAttributes;
import android.net.Uri;

import android.widget.Toast;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.app.PendingIntent;

import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;

import com.acs.smartcard.Reader;
import com.acs.smartcard.Reader.OnStateChangeListener;
import com.acs.smartcard.ReaderException;

import net.gdmeunier.pinunblocker.myexceptions.GenericException;
import net.gdmeunier.pinunblocker.myexceptions.SmartcardOperationException;
import net.gdmeunier.pinunblocker.myexceptions.NotificationException;
import net.gdmeunier.pinunblocker.myexceptions.UsbDeviceException;
import net.gdmeunier.pinunblocker.myexceptions.UsbPermisionException;
import net.gdmeunier.pinunblocker.myexceptions.SmartcardReaderException;
import net.gdmeunier.pinunblocker.myexceptions.SmartcardException;
import net.gdmeunier.pinunblocker.myexceptions.ApduException;
import net.gdmeunier.pinunblocker.myexceptions.ApduReplyException;
#End If

#If Java
private String PACKAGE_NAME          = null;
private String ACTION_USB_PERMISSION = null;

// Must match the application's label name
private final String APPLICATION_NAME = "Android PIN Unblocker";

private static final long USB_TIMEOUT       = 20 * 1000; // 20s
private static final long CONFIRM_TIMEOUT   = 15 * 1000; // 15s
private static final long SMARTCARD_TIMEOUT = 20 * 1000; // 20s

private UsbManager mManager;
private UsbDevice  mDevice;

private static Reader mReader;
private        String deviceName;

private int iActualState = Reader.CARD_UNKNOWN;

private static int    iSlotNum = -1;
private        byte[] atr      = null;

private int actionNum          = Reader.CARD_COLD_RESET;
private int preferredProtocols = Reader.PROTOCOL_T0 | Reader.PROTOCOL_T1 | Reader.PROTOCOL_RAW;
private int activeProtocol     = Reader.PROTOCOL_UNDEFINED;

private mysmartcardreader.SmartcardReader SmartcardReaderProxy = null;

private NotificationManager notifyMgr;
private PowerManager        powerMgr;

// Temporary properties
private BroadcastReceiver detachReceiver;

private Object waitLockUsbDevice;
private Object waitLockUsbPermission;
private Object waitLockSmartcardInsert;

// Permanent properties
private Handler toastHandler         = null;
private Handler usbPermissionHandler = null;
private Handler broadcastHandler     = null;

private HandlerThread toastThread;
private HandlerThread usbPermissionThread;
private HandlerThread broadcastThread;

// To be able to cancel any displayed toast early
private Toast lastShownToast = null;

//
// Notification IDs for easier-to-read source code
//
private static final int NOTIFICATION_ID_NEW_OPERATION    = 1;
private static final int NOTIFICATION_ID_USB_DEVICE       = 2;
private static final int NOTIFICATION_ID_USB_PERMISSION   = 3;
private static final int NOTIFICATION_ID_SMARTCARD_INSERT = 4;

// Always list NOTIFICATION_ID_NEW_OPERATION first (index 0)
private static final int[] notificationsIdArray = new int[] {
	NOTIFICATION_ID_NEW_OPERATION,
	NOTIFICATION_ID_USB_DEVICE,
	NOTIFICATION_ID_USB_PERMISSION,
	NOTIFICATION_ID_SMARTCARD_INSERT
};

//
// For Android 8+ notifications support (API level 26+)
//
private       String notifyChannelId   = null;
private final String notifyChannelName = APPLICATION_NAME;
private final String notifyChannelDesc = "Smartcard Service notifications";

/* For checking whether notifications are allowed (Android 13+ - API level 33+):
 *  - Do note that notifications from startForeground are always allowed anyway
 */
private boolean areNotificationsAllowed = false; // false by default

#End If

#If Java
//
// This part is used by joService.RunMethod calls
//
private myadvanced myadvancedInstance = new myadvanced();

import android.content.Context;
public boolean jDeviceHasUsbOtgSupport()
{
	// Services actually have access to the PackageManager directly
	return myadvancedInstance.jDeviceHasUsbOtgSupport(this);
}
#End If

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Basic application code
'

Sub Process_Globals
	'These global variables will be declared once when the application starts
	'These variables can be accessed from all modules
	
	'For requesting JVM GC clears
	Private Security As MySecurity
	
	'For throwing Exceptions
	Private Exceptions As MyExceptions
	
	'For running native Java code
	Private joService As JavaObject
	
	'For doing APDU communications in a separate thread
	Private SmartcardMessageThread   As Thread
	Private SmartcardOperationThread As Thread
	
	'List of possible Service messaging values
	Public Const FIND_SMARTCARDREADER As Int = 0x100 'Range 0x100 (FIND)
	Public Const FIND_SMARTCARD       As Int = 0x101
	
	Public Const GET_ATR              As Int = 0x200 'Range 0x200 (GET)
	Public Const GET_PROTOCOL         As Int = 0x201
	
	Public Const SEND_APDU            As Int = 0x300 'Range 0x300 (SEND)
	#If Java
	private static final int FIND_SMARTCARDREADER = 0x100; // Range 0x100 (FIND)
	private static final int FIND_SMARTCARD       = 0x101;
	
	private static final int GET_ATR              = 0x200; // Range 0x200 (GET)
	private static final int GET_PROTOCOL         = 0x201;
	
	private static final int SEND_APDU            = 0x300; // Range 0x300 (SEND)
	#End If
	
	'For making sure that we don't simultaneously accept
	'running two service commands at the same time
	Private ActiveOperationInProgress As Boolean = False
	
	'Just incase to prevent any potential
	'duplicate Service_Start calls from Android
	Private ServiceAlreadyStarted As Boolean = False
	
End Sub

Private Sub SmartcardMessageThread_Ended(Failed As Boolean, ErrorIfAny As String)
	'
	'Nothing to do here
	'
End Sub

Private Sub SmartcardOperationThread_Ended(Failed As Boolean, ErrorIfAny As String)
	'Better Thread exception handling for the Smartcard service
	'
	'Only the Smartcard service currently needs this method of
	'handling Thread exceptions (such as noClassDefFoundError)
	If Failed Or (ErrorIfAny <> Null And ErrorIfAny <> "") Then
		CallSubDelayed3(Me, "RunInSmartcardOperationThread_Completed", Failed, Array As Object(SmartcardOperationThread.Error))
		
	End If
	
End Sub

Sub Service_Create
	'This is the program entry point
	'This is a good place to load resources that are not specific to a single activity
	
	'For running native Java code
	joService.InitializeContext
	
	'This Service requires USB OTG support:
	' - Stop the service if USB OTG is not supported
	If Not(joService.RunMethod("jDeviceHasUsbOtgSupport", Null)) Then
		'Stop the automatic foreground Service state if
		'USB-OTG is not supported on the device
		Service.StopAutomaticForeground
		
		'Stop the Service itself too
		StopService(Me)
		
	End If
	
	'For requesting JVM GC clears
	Security.Initialize
	
	'For throwing Exceptions
	Exceptions.Initialize
	
	'Initialize the PC/SC stack
	joService.RunMethod("jService_Create", Null)
	
	'For doing APDU communications in a separate thread
	SmartcardMessageThread.Initialize("SmartcardMessageThread")
	SmartcardOperationThread.Initialize("SmartcardOperationThread")
	
End Sub
#If Java
/* Card state constants:
 * - CARD_UNKNOWN    = 0
 * - CARD_ABSENT     = 1
 * - CARD_PRESENT    = 2
 * - CARD_SWALLOWED  = 3
 * - CARD_POWERED    = 4
 * - CARD_NEGOTIABLE = 5
 * - CARD_SPECIFIC   = 6
 */
public void jService_Create()
{
	// Must match the application's package name
	PACKAGE_NAME          = this.getPackageName();
	ACTION_USB_PERMISSION = PACKAGE_NAME+".USB_PERMISSION";
	
	// Provide the package name directly to the MySmartcardReader class
	SmartcardReaderProxy = new mysmartcardreader.SmartcardReader();
	
	// e.g. "net.gdmeunier.pinunblocker$smartcard"
	notifyChannelId = PACKAGE_NAME+"$smartcard";
	
	notifyMgr = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
	powerMgr  = (PowerManager)getSystemService(Context.POWER_SERVICE);
	
	toastThread         = new HandlerThread("SmartcardServiceToastThread",         Process.THREAD_PRIORITY_BACKGROUND);
	usbPermissionThread = new HandlerThread("SmartcardServiceUsbPermissionThread", Process.THREAD_PRIORITY_FOREGROUND);
	broadcastThread     = new HandlerThread("SmartcardServiceBroadcastThread",     Process.THREAD_PRIORITY_FOREGROUND);
	
	toastThread.start();
	usbPermissionThread.start();
	broadcastThread.start();
	
	toastHandler         = new Handler(toastThread.getLooper());
	usbPermissionHandler = new Handler(usbPermissionThread.getLooper());
	broadcastHandler     = new Handler(broadcastThread.getLooper());
	
    mManager = (UsbManager)getSystemService(Context.USB_SERVICE);
    mReader  = new Reader(mManager);
	
    mReader.setOnStateChangeListener(new OnStateChangeListener()
    {
        @Override
        public void onStateChange(int slotNum, int prevState, int currState)
        {
            if (prevState < Reader.CARD_UNKNOWN || prevState > Reader.CARD_SPECIFIC)
            {
                prevState = Reader.CARD_UNKNOWN;
            }
            if (currState < Reader.CARD_UNKNOWN || currState > Reader.CARD_SPECIFIC)
            {
                currState = Reader.CARD_UNKNOWN;
            }
			
			/* Check which smartcard reader slot the change is for
			 * incase we actually have a multi-slot smartcard reader
			 */
			if ( slotNum == iSlotNum || iSlotNum < 0 )
			{
				/* If the slot number is not -1 then that means
				 * it was already initialized prior,
				 * so we should verify whether the state change
				 * is actually about the slot number we're connected to
				 *
				 * Otherwise ignore the slot number's state change event
				 * because it's not the one we're connected to
				 *
				 * However if the slot number is -1 (less than 0)
				 * then that means we're not currently connected to
				 * any specific smartcard reader slot,
				 * so we can take state change events for any slot number
				 */
				if ( iSlotNum >= 0 )
				{
					/* Only update global state if there's already a valid slot number,
					 * otherwise don't update it just yet, we will do it in the
					 * synchronized code block instead, if a smartcard is present now
					 */
					iActualState = currState; // 1 = insert card, 2 = a card is inserted
				}
				
				/* Notify if necessary about smartcard insert to any
				 * potentially running wait timer that needs it
				 *
				 * Make sure to verify exactly that the state is CARD_PRESENT,
				 * so that we don't try to notify again when the card gets
				 * powered on, then yet again when its protocol type is set
				 *
				 * Otherwise it would happen 4 times:
				 * - CARD_PRESENT (2),
				 * - CARD_POWERED (4),
				 * - CARD_NEGOCIABLE (5),
				 * - CARD_SPECIFIC (6)
				 */
				if ( currState == Reader.CARD_PRESENT && waitLockSmartcardInsert != null )
				{
					if ( iSlotNum < 0 )
					{
						/* If last slot number is -1 then notify
						 * the code looking for a smartcard that
						 * the correct slot where one as inserted
						 * is now the "slotNum" one (write it to "iSlotNum")
						 */
						iSlotNum = slotNum;
						
						// Copy current state again just incase
						iActualState = currState;
					}
					
					broadcastHandler.post(
						new Runnable()
						{
							@Override
							public void run()
							{
								if ( waitLockSmartcardInsert != null )
								{
									try
									{
										synchronized(waitLockSmartcardInsert)
										{
					                		waitLockSmartcardInsert.notify();
										}
									}
									catch (Exception e)
									{
										/* Nothing to do here */
									}
								}
							}
						}
					);
	            }
			}
        }
    });
}
#End If

'
'Smartcard Service Basic code
'
'Services don't always start automatically when you launch the app,
'they actually have to be explicitly started, unless they
'start on boot (which is not the case here)
'

Sub Service_Start(StartingIntent As Intent)
	
	'Just incase Android might want to
	'call Service_Start multiple times
	If ServiceAlreadyStarted Then
		Return
	Else
		ServiceAlreadyStarted = True
	End If
	
	'Starter service can start in the foreground state in some edge cases
	Service.StopAutomaticForeground
	
	'This Service requires USB OTG support:
	' - Stop the service if USB OTG is not supported
	If Not(joService.RunMethod("jDeviceHasUsbOtgSupport", Null)) Then
		
		'Stop the Service
		StopService(Me)
		
	End If
	
	'For doing APDU communications in a separate Thread
	SmartcardMessageThread.Start(Me, "Service_Message_Looper", Null)
	
End Sub

'Inter-communication between the Service and Activities:
' - It's for letting this Service receive messages from
'   this application's Activities to this Service only
'
Public Sub Service_Message(DoWhat As Int, CallerBundle() As Object)
	
	CallSubDelayed3(Me, "Service_Message_Posted", DoWhat, CallerBundle)
	
End Sub

Private Sub Service_Message_Looper
	
	Dim Caller       As Object
	Dim SubName      As String
	Dim Parameters() As Object
	
	Do While True
		Wait For Service_Message_Posted(DoWhat As Int, CallerBundle() As Object)
		
		Caller     = CallerBundle(0) 'CallerBundle(0) = Caller     - Object
		SubName    = CallerBundle(1) 'CallerBundle(1) = SubName    - String
		Parameters = CallerBundle(2) 'CallerBundle(2) = Parameters - Object()
		
		'Avoid getting potential race condition calls
		If ActiveOperationInProgress Then
			'
			'Deliberately throw then catch an Exception so that
			'we can have a stacktrace of it
			'
			Try
				Exceptions.ThrowException(Exceptions.EXCEPTION_SMARTCARDOPERATION, "An ongoing Smartcard operation is already in progress")
				
			Catch
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", False, Array As Object(LastException.Message))
				
			End Try
			
			'Skip further processing but don't return, because that would
			'return the entire function and stop the Smartcard service's
			'message looper thread
			'
			'So we use a "Continue" statement instead of "Return" and that
			'will jump back to the beginning of the While loop,
			'thus allowing the "Wait For" statement to be executed again
			Continue
			
		End If
		
		Select DoWhat
			'
			'Need to request notifications permission for "FIND_" & "SEND_" commands
			'
			Case FIND_SMARTCARDREADER
				ActiveOperationInProgress = True
				
				RequestNotificationsPermissions
				Wait For RequestNotificationsPermissions_Finished
				
				SmartcardOperationThread.Start(Me, "RunInSmartcardOperationThread", Array(DoWhat, Parameters))
				Wait For RunInSmartcardOperationThread_Completed(Failed As Boolean, ServiceReply() As Object)
				
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", Not(Failed), ServiceReply)
				
				ActiveOperationInProgress = False
				Exit
				
			Case FIND_SMARTCARD
				ActiveOperationInProgress = True
				
				RequestNotificationsPermissions
				Wait For RequestNotificationsPermissions_Finished
				
				SmartcardOperationThread.Start(Me, "RunInSmartcardOperationThread", Array(DoWhat, Parameters))
				Wait For RunInSmartcardOperationThread_Completed(Failed As Boolean, ServiceReply() As Object)
				
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", Not(Failed), ServiceReply)
				
				ActiveOperationInProgress = False
				Exit
				
			Case GET_ATR
				ActiveOperationInProgress = True
				
				SmartcardOperationThread.Start(Me, "RunInSmartcardOperationThread", Array(DoWhat, Parameters))
				Wait For RunInSmartcardOperationThread_Completed(Failed As Boolean, ServiceReply() As Object)
				
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", Not(Failed), ServiceReply)
				
				ActiveOperationInProgress = False
				Exit
				
			Case GET_PROTOCOL
				ActiveOperationInProgress = True
				
				SmartcardOperationThread.Start(Me, "RunInSmartcardOperationThread", Array(DoWhat, Parameters))
				Wait For RunInSmartcardOperationThread_Completed(Failed As Boolean, ServiceReply() As Object)
				
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", Not(Failed), ServiceReply)
				
				ActiveOperationInProgress = False
				Exit
				
			Case SEND_APDU
				ActiveOperationInProgress = True
				
				RequestNotificationsPermissions
				Wait For RequestNotificationsPermissions_Finished
				
				SmartcardOperationThread.Start(Me, "RunInSmartcardOperationThread", Array(DoWhat, Parameters))
				Wait For RunInSmartcardOperationThread_Completed(Failed As Boolean, ServiceReply() As Object)
				
				'The MySmartcardReader class automatically handles APDU
				'request chaining transparently, so we can just simply
				'check for a 90 00 status code
				If Not(Failed) And Not(ServiceReply(0).As(String).EndsWith("9000")) Then
					'
					'Deliberately throw then catch an Exception so that
					'we can have a stacktrace of it
					'
					Try
						Dim LastReplyAPDU As String = ServiceReply(0).As(String)
						Exceptions.ThrowException(Exceptions.EXCEPTION_APDUREPLY, $"The Smartcard replied with an APDU SW status code that indicates failure (${LastReplyAPDU.SubString(LastReplyAPDU.Length - 4)})"$)
						
					Catch
						Failed       = True
						ServiceReply = Array As Object(LastException.Message)
						
					End Try
					
				End If
				
				'Callers use IsSuccessful instead of e.g. IsFailed
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", Not(Failed), ServiceReply)
				
				ActiveOperationInProgress = False
				Exit
				
			Case Else
				'Deliberately throw then catch an Exception so that
				'we can have a stacktrace of it
				Try
					Exceptions.ThrowException(Exceptions.EXCEPTION_SMARTCARDOPERATION, $"An unknown message type ${DoWhat} was sent to this Service"$)
					
				Catch
					'Callers use IsSuccessful instead of e.g. IsFailed
					CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", False, Array As Object(LastException.Message))
					
				End Try
				
				Exit
			
		End Select
		
	Loop
	
End Sub

'Helper functions for updating areNotificationsAllowed
'which is used by Java native code
Private Sub RequestNotificationsPermissions
	
	'Return immediately and let the function with
	'the _DelayedSub suffix do the job
	CallSubDelayed(Me, "RequestNotificationsPermissions_DelayedSub")
	
End Sub

Private Sub RequestNotificationsPermissions_DelayedSub
	
	'Check that the Main Activity isn't paused already
	'
	'If it's paused then that means we were already
	'able to call it before during the Direct Unblock
	'introducy message, so no need to redo it again then
	If Not(IsPaused(Main)) Then
		'Android 13+ only (API level 33+):
		' - Request the ability to post notifications
		' - It's not a problem if the user denies it though
		'
		CallSub(Main, "RequestPostNotificationsPermissions")
		Wait For RequestPostNotificationsPermissions_Completed(AreNotificationsAllowed As Boolean)
		
		SetNotificationsAllowed(AreNotificationsAllowed)
		
	End If
	
	CallSubDelayed(Me, "RequestNotificationsPermissions_Finished")
	
End Sub

Private Sub SetNotificationsAllowed(IsAllowed As Boolean)
	
	Try
		joService.RunMethod("jSetNotificationsAllowed", Array(IsAllowed))
	Catch
		'
		'Nothing to do here
		'
	End Try
	
End Sub
#If Java
public void jSetNotificationsAllowed(final boolean isAllowed)
{
	areNotificationsAllowed = isAllowed;
}
#End If

'Helper function to make it easier to invoke APDU operations
'in yet another separate thread, perhaps it will help with
'the USB permission prompt to make it much faster
'
'Sorry that it looks convoluted, that's simply what works
'to make USB permission prompts instantaneous
Private Sub RunInSmartcardOperationThread(DoWhat As Int, Parameters() As Object)
	
	Dim Failed         As Boolean = False
	Dim ServiceReply() As Object  = Array As Object(Null)
	
	Try
		'This part will cause Exception if necessary
		ServiceReply = joService.RunMethod("jRunInSmartcardOperationThread", Array(DoWhat, Parameters))
		
	Catch
		Failed       = True
		ServiceReply = Array As Object(LastException.Message)
		
	End Try
	
	CallSubDelayed3(Me, "RunInSmartcardOperationThread_Completed", Failed, ServiceReply)
	
End Sub
#If Java
public Object[] jRunInSmartcardOperationThread(final int doWhat, final Object[] parameters) throws GenericException, NotificationException, UsbDeviceException, UsbPermisionException, SmartcardReaderException, SmartcardException, ApduException, ApduReplyException
{
	/* Don't use SCREEN_DIM_WAKE_LOCK:
	 *  - Many phones lower the USB power output or suspend it on screen dimming
	 */
	PowerManager.WakeLock wl = powerMgr.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, PACKAGE_NAME);
	wl.acquire();
	
	Object[] reply = null;
	
	/* withSound  = false
	 * useHeadsUp = true [required for this one]
	 * useLights  = (omitted - automatically set to false)
	 */
	jShowNotification(NOTIFICATION_ID_NEW_OPERATION, "Smartcard service operation", false, true);
	
	try
	{
		switch ( doWhat )
		{
			case FIND_SMARTCARDREADER:
				jObtainUsbDevice();
				jObtainUsbPermission();
				jObtainSmartcardReader();
				
				break;
				
			case FIND_SMARTCARD:
				jObtainUsbDevice();
				jObtainUsbPermission();
				jObtainSmartcardReader();
				jObtainSmartcard();
				
				break;
				
			case GET_ATR:
				if ( atr == null )
				{
					throw new SmartcardException("Could not get the smartcard ATR because the smartcard is not connected");
				}
				
				reply = new Object[] { myconverters.jBytesToHexString(atr) };
				
				break;
				
			case GET_PROTOCOL:
				if ( activeProtocol == Reader.PROTOCOL_UNDEFINED )
				{
					throw new SmartcardException("Could not get the smartcard protocol because the smartcard is not connected");
				}
				
				reply = new Object[] { "T=?" };
				
				if ( activeProtocol == Reader.PROTOCOL_T0 )
				{
					reply[0] = "T=0";
				}
				else if ( activeProtocol == Reader.PROTOCOL_T1 )
				{
					reply[0] = "T=1";
				}
				else if ( activeProtocol == Reader.PROTOCOL_RAW )
				{
					reply[0] = "T=RAW";
				}
				else if ( activeProtocol == Reader.PROTOCOL_TX )
				{
					reply[0] = "T=TX";
				}
				
				break;
				
			case SEND_APDU: /* This command cans be used in one go directly too */
				jObtainUsbDevice();
				jObtainUsbPermission();
				jObtainSmartcardReader();
				jObtainSmartcard();
				
				reply = new Object[] { SmartcardReaderProxy.sendSpecificAPDU(String.valueOf(parameters[0]), mReader, iSlotNum) };
				
				break;
				
			default:
				throw new GenericException("You requested a message type that this Service does not know nor support");
		}
	}
	catch (GenericException|NotificationException|UsbDeviceException|UsbPermisionException|SmartcardReaderException|SmartcardException|ApduException|ApduReplyException ex)
	{
		// Re-throw the exception
		throw ex;
	}
	finally
	{
		// Clear any currently shown toast if any
		jCancelCurrentlyShownToastIfAny();
		
		// Cancel all notifications
		jCancelAllNotifications(); // This call preserves the core Service notification
		
		if ( wl != null && wl.isHeld() )
		{
			try
			{
				wl.release();
			}
			catch (Exception e)
			{
				/* Nothing to do here */
			}
		}
		
		stopForeground(true);
	}
	
	return reply;
}
#End If

Sub Service_Destroy
	
	Security.TriggerJvmGarbageCollection
	
	'This Service requires USB OTG support:
	' - Return early if USB-OTG is not supported
	If Not(joService.RunMethod("jDeviceHasUsbOtgSupport", Null)) Then
		
		'Return early (no need to run the jService_Destroy function code)
		Return
		
	End If
	
	joService.RunMethod("jService_Destroy", Null)
	
	If Not(SmartcardMessageThread.IsInterrupted) Then
		SmartcardMessageThread.Interrupt
	End If
	
	If Not(SmartcardOperationThread.IsInterrupted) Then
		SmartcardOperationThread.Interrupt
	End If
	
	ServiceAlreadyStarted = False
	
End Sub
#If Java
public void jService_Destroy()
{
	if ( detachReceiver != null )
	{
		try
		{
			unregisterReceiver(detachReceiver);
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		
		detachReceiver = null;
	}
	
	jResetSmartcardReaderState();
	
	SmartcardReaderProxy = null;
	
	jNotifyAllWaitLocks();
	
	//
	// Stopping additional threads
	//
	ArrayList<HandlerThread> additionalThreadsList = new ArrayList<HandlerThread>(3); // 3 elements inside
	additionalThreadsList.add(toastThread);
	additionalThreadsList.add(usbPermissionThread);
	additionalThreadsList.add(broadcastThread);
	
	for (HandlerThread additionalThread : additionalThreadsList)
	{
		try
		{
			additionalThread.quit();
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
	}
	
	// Clear any currently shown toast if any
	jCancelCurrentlyShownToastIfAny();
	
	// Cancel all notifications on Service_Destroy (include NOTIFICATION_ID_NEW_OPERATION = true)
	jCancelAllNotifications(true);
}

private void jResetSmartcardReaderState()
{
	/* Call the mReader.close() method just incase
	 * This way we make fully sure that the next
	 * call to mReader.isOpened() will return false
	 */
	try
	{
		mReader.close();
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	/* Clear the current connected device handle
	 *
	 * This way the next jObtainUsbDevice call will
	 * re-acquire a new USB-CCID device
	 */
	mDevice = null;
	
	iSlotNum = -1;
	atr      = null;
	
	iActualState   = Reader.CARD_UNKNOWN;
	activeProtocol = Reader.PROTOCOL_UNDEFINED;
}

private void jNotifyAllWaitLocks()
{
	//
	// These ones need to be done in order (synchronized)
	//
	ArrayList<Object> waitLocksList = new ArrayList<Object>(3); // 3 elements inside
	waitLocksList.add(waitLockUsbDevice);
	waitLocksList.add(waitLockUsbPermission);
	waitLocksList.add(waitLockSmartcardInsert);
	
	for (Object waitLock : waitLocksList)
	{
	    if ( waitLock != null )
		{
			try
			{
		        synchronized(waitLock)
				{
					waitLock.notify();
				}
			}
			catch (Exception e)
			{
				/* Nothing to do here */
			}
	    }
	}
}
#End If

'This event will be raised when the user removes the app from the recent apps list
Sub Service_TaskRemoved
	
	'Stop the Service
	StopService(Me)
	
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception
Sub Application_Error(Error As Exception, StackTrace As String) As Boolean
	
	Return True
	
End Sub

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Java native code
'

#If Java
//
// Toast notification helpers
//
private void jShowToast(final String msg)
{
	// Cancel currently displayed toast if any
    jCancelCurrentlyShownToastIfAny();
	
	toastHandler.post(
		new Runnable()
		{
			@Override
			public void run()
			{
				// Always using long toast notifications
				// Use "smartcard.this" here, not directly "this"
				lastShownToast = Toast.makeText(smartcard.this, msg, Toast.LENGTH_LONG);
				lastShownToast.show();
			}
		}
	);
}
private void jCancelCurrentlyShownToastIfAny()
{
    if ( lastShownToast == null )
	{
		return;
	}
	
	toastHandler.post(
		new Runnable()
		{
			@Override
			public void run()
			{
				// Cancel currently displayed toast if any
			    if ( lastShownToast != null )
				{
					try
					{
						lastShownToast.cancel();
					}
					catch (Exception e)
					{
						/* Nothing to do here */
					}
				}
			}
		}
	);
}

//
// System notification helpers
//
private void jShowNotification(final int notificationID, final String msg) throws NotificationException
{
	/* Overload helper function:
	 *  - withSound  = false,
	 *  - useHeadsUp = false,
	 *  - useLights  = false
	 */
	jShowNotification(notificationID, msg, false, false, false);
}
private void jShowNotification(final int notificationID, final String msg, final boolean withSound) throws NotificationException
{
	/* Overload helper function:
	 *  - useHeadsUp = false,
	 *  - useLights  = false
	 */
	jShowNotification(notificationID, msg, withSound, false, false);
}
private void jShowNotification(final int notificationID, final String msg, final boolean withSound, final boolean useHeadsUp) throws NotificationException
{
	/* Overload helper function:
	 *  - useLights  = false
	 */
	jShowNotification(notificationID, msg, withSound, useHeadsUp, false);
}
private void jShowNotification(final int notificationID, final String msg, final boolean withSound, final boolean useHeadsUp, final boolean useLights) throws NotificationException
{
	/* Android 3.1+ only (API level 11+)
	 * Also includes a check to verify if notifications are allowed (if not heads-up one)
	 */
	if ( Build.VERSION.SDK_INT < 11 || (!useHeadsUp && !areNotificationsAllowed) )
	{
		return;
	}
	
	// Cancel currently shown notification if any
	jCancelAllNotifications(); // This call preserves the core Service notification
	
	Uri soundUri = null;
	
	if ( withSound )
	{
		//
		// API level 1+ (Android Base 1.x)
		//
		Uri.Builder soundUriBuilder = new Uri.Builder();
		            soundUriBuilder.scheme(ContentResolver.SCHEME_ANDROID_RESOURCE);
		            soundUriBuilder.authority(PACKAGE_NAME);
		            soundUriBuilder.path("raw/notification_sound");
		
		soundUri = soundUriBuilder.build();
	}
	
	NotificationCompat.Builder builder = new NotificationCompat.Builder(smartcard.this);
	
	try
	{
		/* Large icons didn't exit before Android 5 (API level 21):
		 *  - Before Android 5 (Lollipop) the large notification icon
		 *    was directly set with "setSmallIcon" and a Bitmap of 64x64
		 */
		if ( Build.VERSION.SDK_INT >= 21 )
		{
			// Set the large icon first before the small one
			builder.setLargeIcon(myadvancedInstance.jGetBitmapFromResourceId(this, R.mipmap.ic_launcher));
		}
		builder.setSmallIcon(R.drawable.ic_stat_card);
		builder.setContentTitle(APPLICATION_NAME);
		builder.setContentText(msg);
		builder.setCategory(Notification.CATEGORY_SERVICE);
		builder.setOngoing(true); // Always make Service notifications 'ongoing'
	}
	catch (Exception e)
	{
		throw new NotificationException("Failed to prepare the generic NotificationCompat.Builder properties");
	}
	
	/* Android 7.1 and earlier (API levels <= 25):
	 *  - Newer versions likeAndroid 8+ (API level 26+)
	 *    don't need these attributes to be set,
	 *    it's set on a notification channel instead
	 */
	if ( Build.VERSION.SDK_INT <= 25 )
	{
		try
		{
			//
			// Deprecated since API level 26+ (Android 8+)
			//
			builder.setPriority(NotificationCompat.PRIORITY_MAX);
			
		    if ( withSound )
			{
				// STREAM_ALARM (API level 1+) or STREAM_NOTIFICATION (API level 3+)
				builder.setSound(soundUri, AudioManager.STREAM_NOTIFICATION);
		    }
			if ( useLights )
			{
				builder.setDefaults(Notification.DEFAULT_LIGHTS);
			}
		}
		catch (Exception e)
		{
			throw new NotificationException("Failed to prepare the NotificationCompat.Builder sound & led light properties");
		}
	}
	else if ( Build.VERSION.SDK_INT >= 26 )
	{
		NotificationChannel notifyChannel = new NotificationChannel(
			notifyChannelId,
			notifyChannelName,
			NotificationManager.IMPORTANCE_HIGH
		);
		
		try
		{
		    notifyChannel.setDescription(notifyChannelDesc);
			notifyChannel.enableLights(useLights);
			notifyChannel.enableVibration(false);
		}
		catch (Exception e)
		{
			throw new NotificationException("Failed to prepare the NotificationChannel and its various properties");
		}
		
	    if ( withSound )
		{
	        AudioAttributes audioAttributes = new AudioAttributes.Builder()
	            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION) /* This is a real Android typo */
	            .setUsage(AudioAttributes.USAGE_NOTIFICATION)        /* USAGE_ALARM or USAGE_NOTIFICATION */
	            .build();
			
			notifyChannel.setSound(soundUri, audioAttributes);
	    }
		
		try
		{
			notifyMgr.createNotificationChannel(notifyChannel);
			
			/* For Android 8+ notifications support (API level 26+):
			 *  - NotificationChannel is only available on Android 8+ (API level 26+)
			 */
			// For the NotificationCompat.Builder Object
			builder.setChannelId(notifyChannelId);
		}
		catch (Exception e)
		{
			throw new NotificationException("Failed to prepare the NotificationChannel and its various properties");
		}
	}
	
	if ( useHeadsUp ) // If heads-up notification is required
	{
		try
		{
			/* startForeground makes notifications become
			 * heads-up notifications
			 */
			startForeground(notificationID, builder.build());
		}
		catch (Exception e)
		{
			throw new NotificationException("Failed to actually broadcast the notification with startForeground");
		}
	}
	else
	{
		try
		{
			notifyMgr.notify(notificationID, builder.build());
		}
		catch (Exception e)
		{
			throw new NotificationException("Failed to actually broadcast the notification with NotificationManager.notify");
		}
	}
}

private void jCancelAllNotifications()
{
	/* Overload helper function:
	 *  - includeCoreServiceNotification = false
	 */
	jCancelAllNotifications(false);
}
private void jCancelAllNotifications(final boolean includeCoreServiceNotification)
{
	if ( notifyMgr != null )
	{
		// The core Service notification is always index 0
		int startIndex = ( includeCoreServiceNotification == true ) ? 0 : 1;
		
		for (int i = startIndex; i < notificationsIdArray.length; i++ )
		{
			try
			{
				notifyMgr.cancel(notificationsIdArray[i]);
			}
			catch (Exception e)
			{
				/* Nothing to do here */
			}
		}
	}
}

private final int maxSleepRoundsUsbDevice = (int)((USB_TIMEOUT / 1000) * 2) * 5; // e.g. 30000ms = 30x 1s = 60x 0.5s = 300x 0.1s
private       int sleepRoundsUsbDevice    = 0;

public void jObtainUsbDevice() throws NotificationException, UsbDeviceException
{
	if ( mDevice != null && mReader.isSupported(mDevice) )
	{
		// We already have a connected USB-CCID device
		// No need to obtain it again
		return;
	}
	
	mDevice        = null;
	detachReceiver = null;
	
	Map<String, UsbDevice> deviceList     = mManager.getDeviceList();
	Iterator<UsbDevice>    deviceIterator = deviceList.values().iterator();
	
	while ( mDevice == null && deviceIterator.hasNext() )
	{
		UsbDevice device = deviceIterator.next();
		
		if ( mReader.isSupported(device) )
		{
			mDevice = device;
		}
	}
	
	if ( mDevice == null )
	{
		final String msg = "Connect your smartcard reader";
		
		jShowToast(msg+"...");
		
		/* withSound  = true
		 * useHeadsUp = (omitted - automatically set to false)
		 * useLights  = (omitted - automatically set to false)
		 */
		jShowNotification(NOTIFICATION_ID_USB_DEVICE, msg, true);
		
		// Reset the sleep rounds counter to initial zero value
		sleepRoundsUsbDevice = 0;
		
		waitLockUsbDevice = new Object();
		
		final BroadcastReceiver attachReceiver = new BroadcastReceiver()
		{
			@Override
			public void onReceive(Context context, Intent intent)
			{
				UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
				
				if ( mReader.isSupported(device) )
				{
					mDevice = device;
					
					/* Interrupt the USB device sleep cycle by
					 * deliberately increasing the sleep rounds counter
					 * to the maximum number of sleep calls
					 */
					sleepRoundsUsbDevice = maxSleepRoundsUsbDevice;
					
	                if ( waitLockUsbDevice != null )
					{
						try
						{
							synchronized(waitLockUsbDevice)
							{
								waitLockUsbDevice.notify();
							}
						}
						catch (Exception e)
						{
							/* Nothing to do here */
						}
					}
				}
				else
				{
					jShowToast(String.format("The connected device (%1$s) is not recognized", getProductName(device)));
				}
			}
		};
		
		// Android 13+ require explicitly exporting the receiver
		// (Android 13+ is API level 33+)
		if ( Build.VERSION.SDK_INT >= 33 )
		{
			registerReceiver(attachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED), null, broadcastHandler, Context.RECEIVER_EXPORTED);
		}
		else
		{
			registerReceiver(attachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED), null, broadcastHandler);
		}
		
		/* This method of sleeping multiple times in 500ms chunks is done
		 * to avoid having the 'Application Not Responding' pop-up (ANR)
		 * when the application is waiting for the user to do something
		 *
		 * So don't simplify it with a single "waitLockXXX.wait(XXX_TIMEOUT);"
		 */
		try
		{
			synchronized(waitLockUsbDevice)
			{
				while ( mDevice == null )
				{
					if ( sleepRoundsUsbDevice >= maxSleepRoundsUsbDevice || mDevice != null )
					{
						break;
					}
					
					waitLockUsbDevice.wait(100);
					sleepRoundsUsbDevice += 1;
				}
				
				waitLockUsbDevice.notify();
			}
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		
		waitLockUsbDevice = null;
		
		try
		{
			unregisterReceiver(attachReceiver);
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		
		// Reset the sleep rounds counter to initial zero value
		sleepRoundsUsbDevice = 0;
		
		if ( mDevice == null )
		{
			throw new UsbDeviceException("No supported USB device found");
		}
	}
	
	/* Unregister previous detach receiver
	 *
	 * Make sure to check if it's null, because on the very first run of
	 * this function it could very well have never been initialized yet
	 */
	if ( detachReceiver != null )
	{
		try
		{
			unregisterReceiver(detachReceiver);
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
	}
	
	// Listen to detach
	detachReceiver = new BroadcastReceiver()
	{
		@Override
		public void onReceive(Context context, Intent intent)
		{
			UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
			
			/* Added a "mDevice == null" check here incasse
			 * the device handle might already be null,
			 * to avoid any potential crash when unplugging
			 * the smartcard reader / token while the app
			 * is running and still in the Direct Unblock
			 * Activity dialog
			 */
			if ( mDevice == null || device.getDeviceName().equals(mDevice.getDeviceName()) )
			{
				jResetSmartcardReaderState();
				jNotifyAllWaitLocks();
			}
		}
	};
	
	// Android 13+ require explicitly exporting the receiver
	// (Android 13+ is API level 33+)
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		registerReceiver(detachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_DETACHED), null, broadcastHandler, Context.RECEIVER_EXPORTED);
	}
	else
	{
		registerReceiver(detachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_DETACHED), null, broadcastHandler);
	}
}
#End If

#If Java
/* Android API level 31+ (Android 12+) require explicit FLAG_IMMUTABLE or FLAG_MUTABLE
 * Initial value below (API level 1+)
 */
private int pendingIntentFlags = PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_CANCEL_CURRENT;

// e.g. 30000ms = 30x 1s [-> x2] = 60x 500ms [-> x5] = 300x 100ms
private final int maxSleepRoundsUsbPermission = (int)((CONFIRM_TIMEOUT / 1000) * 2) * 5; // 300x 100ms
private       int sleepRoundsUsbPermission    = 0;

public void jObtainUsbPermission() throws NotificationException, UsbPermisionException
{
	if ( !mManager.hasPermission(mDevice) )
	{
		// Reset the sleep rounds counter to initial zero value
		sleepRoundsUsbPermission = 0;
		
		final String msg = "Please grant USB permission";
		
		jShowToast(msg+"...");
		
		/* withSound  = true
		 * useHeadsUp = (omitted - automatically set to false)
		 * useLights  = (omitted - automatically set to false)
		 */
		jShowNotification(NOTIFICATION_ID_USB_PERMISSION, msg, true);
		
		waitLockUsbPermission = new Object();
		
		BroadcastReceiver grantReceiver = new BroadcastReceiver()
		{
			@Override
			public void onReceive(Context context, Intent intent)
			{
				broadcastHandler.post(
					new Runnable()
					{
						@Override
						public void run()
						{
							/* Interrupt the USB permission sleep cycle by
							 * deliberately increasing the sleep rounds counter
							 * to the maximum number of sleep calls
							 */
							sleepRoundsUsbPermission = maxSleepRoundsUsbPermission;
							
			                if ( waitLockUsbPermission != null )
							{
								try
								{
									synchronized(waitLockUsbPermission)
									{
										waitLockUsbPermission.notify();
									}
								}
								catch (Exception e)
								{
									/* Nothing to do here */
								}
							}
						}
					}
				);
			}
		};
		
		/* Trying to make the USB permission pop-up faster
		 * I think making the IntentFilter higher-priority
		 * will work to improve the delay between
		 * accepting the USB permission pop-up and
		 * the application actually knowing that it has
		 * the USB permission
		 */
		IntentFilter intentFilter = new IntentFilter(ACTION_USB_PERMISSION);
		
		/* Must be lower  (<) than SYSTEM_HIGH_PRIORITY (1000)
		 * Must be higher (>) than SYSTEM_LOW_PRIORITY  (-1000)
		 *
		 * Default value is 0 (normal priority)
		 */
		intentFilter.setPriority((int)IntentFilter.SYSTEM_HIGH_PRIORITY / 2);
		
		/* Android 13+ require explicitly exporting the receiver
		 * (Android 13+ is API level 33+)
		 *
		 * Tryig to improve the USB permission prompt time by
		 * offloading the broadcast of the grantReceiver to
		 * "broadcastHandler" instead of "usbPermissionHandler",
		 * so that I make sure that it's not the cause of
		 * slow USB permission prompts on some older devices
		 */
		if ( Build.VERSION.SDK_INT >= 33 )
		{
			registerReceiver(grantReceiver, intentFilter, null, broadcastHandler, Context.RECEIVER_EXPORTED);
		}
		else
		{
			registerReceiver(grantReceiver, intentFilter, null, broadcastHandler);
		}
		
		/* Faster USB device permission request:
		 * Run the permission request on the "usbPermissionHandler" thread
		 */
		usbPermissionHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					int flags = pendingIntentFlags;
					
					// Update the PendingIntent flags if Android 12+
					if ( Build.VERSION.SDK_INT >= 31 )
					{
						/* API level 31+ (Android 12+) */
						flags |= PendingIntent.FLAG_MUTABLE;
					}
					
					/* Specifically target this Intent at this application,
					 * by specifying the package name
					 *
					 * This way the broadcast process is quicker
					 */
					Intent intent = new Intent(ACTION_USB_PERMISSION);
					intent.setPackage(PACKAGE_NAME);
					
					mManager.requestPermission(
						mDevice,
						PendingIntent.getBroadcast(smartcard.this, 0, intent, flags)
					);
				}
			}
		);
		
		/* It's possible that the device was disconnected during
		 * the USB permission prompt
		 *
		 * For such cases we check if mDevice didn't become null,
		 * because it gets set to null on the device's detached event
		 */
		if ( mDevice != null && !mManager.hasPermission(mDevice) )
		{
			/* This method of sleeping multiple times in 100ms chunks is done
			 * to avoid having the 'Application Not Responding' pop-up (ANR)
			 * when the application is waiting for the user to do something
			 *
			 * Make sure to never sleep / wait 5000ms or longer,
			 * because that's when Android thinks that the application
			 * is no longer responding, and will display the ANR pop-up
			 */
			try
			{
				synchronized(waitLockUsbPermission)
				{
					while ( mDevice != null && !mManager.hasPermission(mDevice) )
					{
						//
						// e.g. 30000ms = 30x 1s [-> x2] = 60x 500ms [-> x5] = 300x 100ms
						//
						if ( sleepRoundsUsbPermission >= maxSleepRoundsUsbPermission )
						{
							break;
						}
						
						waitLockUsbPermission.wait(100); // Wait for 100ms
						sleepRoundsUsbPermission += 1;
					}
					
					waitLockUsbPermission.notify();
				}
			}
			catch (Exception e)
			{
				/* Nothing to do here */
			}
		}
		
		waitLockUsbPermission = null;
		
		try
		{
			unregisterReceiver(grantReceiver);
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		
		// Reset the sleep rounds counter to initial zero value
		sleepRoundsUsbPermission = 0;
		
		if ( mDevice == null || !mManager.hasPermission(mDevice) )
		{
			throw new UsbPermisionException("No USB permission was granted for the supported device");
		}
	}
}
#End If

#If Java
public void jObtainSmartcardReader() throws SmartcardReaderException
{
	if ( !mReader.isOpened() )
	{
		try
		{
			mReader.open(mDevice);
			
			// Just incase for consistency
			iSlotNum = -1;
		}
		catch (Exception e)
		{
			jResetSmartcardReaderState();
			throw new SmartcardReaderException("Failed to connect to the smartcard reader");
		}
	}
}
#End If

#If Java
/* Card state constants:
 * - CARD_UNKNOWN    = 0
 * - CARD_ABSENT     = 1
 * - CARD_PRESENT    = 2
 * - CARD_SWALLOWED  = 3
 * - CARD_POWERED    = 4
 * - CARD_NEGOTIABLE = 5
 * - CARD_SPECIFIC   = 6
 */
public void jObtainSmartcard() throws NotificationException, SmartcardException
{
	/* Check all card slots for any inserted smartcard
	 * incase we actually have a multi-slot smartcard reader,
	 * add if we find any inserted smartcard, then return
	 * the state of the first slot found with a card inside
	 */
	for ( int i = 0; i < mReader.getNumSlots(); i++ )
	{
		iActualState = mReader.getState(i);
		
		if ( iActualState >= Reader.CARD_PRESENT )
		{
			iSlotNum = i;
			break;
		}
	}
	
	if ( iActualState < Reader.CARD_PRESENT )
	{
		final String msg = String.format("Insert a smartcard in your %1$s reader", getProductName(mDevice));
		
		jShowToast(msg+"...");
		
		/* withSound  = true
		 * useHeadsUp = (omitted - automatically set to false)
		 * useLights  = (omitted - automatically set to false)
		 */
		jShowNotification(NOTIFICATION_ID_SMARTCARD_INSERT, msg, true);
		
		waitLockSmartcardInsert = new Object();
		
		/* This method of sleeping multiple times in 500ms chunks is done
		 * to avoid having the 'Application Not Responding' pop-up (ANR)
		 * when the application is waiting for the user to do something
		 *
		 * So don't simplify it with a single "waitLockXXX.wait(XXX_TIMEOUT);"
		 */
		int maxSleepRounds = (int)((SMARTCARD_TIMEOUT / 1000) * 2) * 5; // e.g. 30000ms = 30x 1s = 60x 0.5s = 300x 0.1s
		int sleepRounds    = 0;
		
		try
		{
			synchronized(waitLockSmartcardInsert)
			{
				/* If card is already present inside the reader when
				 * the reader was connected to the phone,
				 * then no need to wait at all
				 */
				while ( iActualState < Reader.CARD_PRESENT )
				{
					/* iSlotNum will always be -1 here unless something
					 * worthy was found (smartcard inserted event),
					 * in which case it will immediately be updated by
					 * the onStateChanged callback of the acssmc library
					 * to a proper slot number
					 *
					 * So if it's no longer -1 then directly skip the
					 * for-loop that searches all the slots individually
					 */
					if ( iSlotNum < 0 )
					{
						/* Check all card slots for any inserted smartcard
						 * incase we actually have a multi-slot smartcard reader,
						 * add if we find any inserted smartcard, then return
						 * the state of the first slot found with a card inside
						 */
						for ( int i = 0; i < mReader.getNumSlots(); i++ )
						{
							iActualState = mReader.getState(i);
							
							if ( iActualState >= Reader.CARD_PRESENT )
							{
								iSlotNum = i;
								break;
							}
						}
					}
					
					if ( sleepRounds >= maxSleepRounds || iActualState >= Reader.CARD_PRESENT )
					{
						break;
					}
					
					waitLockSmartcardInsert.wait(100); // Wait 100ms
					sleepRounds += 1;
				}
				
				waitLockSmartcardInsert.notify();
			}
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		
		waitLockSmartcardInsert = null;
		
		if ( iActualState < Reader.CARD_PRESENT || iActualState == Reader.CARD_SWALLOWED )
		{
			throw new SmartcardException("No smartcard present or it was unresponsive");
		}
	}
	
	if ( iActualState == Reader.CARD_SWALLOWED )
	{
		throw new SmartcardException("The smartcard is swallowed by your reader?");
	}
	
	if ( iActualState < Reader.CARD_SPECIFIC ) // Reader.CARD_SPECIFIC = 6
	{
		//
		// Poweron the smartcard and get ATR
		//
		try
		{
			atr = mReader.power(iSlotNum, actionNum);
			
			/* Check if the card reader automatically did the
			 * protocol selection for us directly,
			 * otherwise explicitly do the protocol negociation again
			 *
			 * (If needed then do the setProtocol function call)
			 */
			if ( iActualState < Reader.CARD_SPECIFIC )
			{
				activeProtocol = mReader.setProtocol(iSlotNum, preferredProtocols);
			}
		}
		catch (Exception e)
		{
			throw new SmartcardException("Failed to connect to the smartcard");
		}
		
		/* Now check if the smartcard was correctly put in operation
		 *
		 * if the smartcard is still not in CARD_SPECIFIC state,
		 * then there was a problem; the smartcard rejected all the
		 * offered communication protocols from the setProtocol call
		 */
		iActualState = mReader.getState(iSlotNum);
		
		if ( iActualState < Reader.CARD_SPECIFIC )
		{
			throw new SmartcardException("The smartcard did not accept any of the offered communication protocols: RAW, T1 and T0");
		}
	}
}
#End If

#If Java
private String getProductName(UsbDevice device)
{
	if ( Build.VERSION.SDK_INT >= 21 )
	{
		return getProductNameFromOs(device);
	}
	else
	{
		int deviceClass = device.getDeviceClass();
		
		if (deviceClass != UsbConstants.USB_CLASS_PER_INTERFACE)
		{
			return getClassName(deviceClass);
		}
		else
		{
			StringBuilder builder = new StringBuilder();
			
			for ( int i = 0; i < device.getInterfaceCount(); i++ )
			{
				deviceClass = device.getInterface(i).getInterfaceClass();
				
				if ( builder.length() > 0 )
				{
					builder.append('/');
				}
				builder.append(getClassName(deviceClass));
			}
			
			return builder.toString();
		}
	}
}

private static String getProductNameFromOs(UsbDevice device)
{
	if ( Build.VERSION.SDK_INT >= 21 )
	{
		return device.getProductName();
	}
	return "";
}

private String getClassName(int deviceClass)
{
	switch ( deviceClass )
	{
		case UsbConstants.USB_CLASS_AUDIO:
			return "audio device";
			
		case UsbConstants.USB_CLASS_CDC_DATA:
			return "(CDC) communication device";
			
		case UsbConstants.USB_CLASS_COMM:
			return "communication device";
			
		case UsbConstants.USB_CLASS_CONTENT_SEC:
			return "security device";
			
		case UsbConstants.USB_CLASS_HID:
			return "human interface device";
			
		case UsbConstants.USB_CLASS_HUB:
			return "USB hub";
			
		case UsbConstants.USB_CLASS_MASS_STORAGE:
			return "mass storage device";
			
		case UsbConstants.USB_CLASS_MISC:
			return "(miscellaneous) wireless device";
			
		/* This is a real typo in the Android source code since API level 12+ (Android 3.1+) */
		case UsbConstants.USB_CLASS_PHYSICA:
			return "physical device";
			
		case UsbConstants.USB_CLASS_PRINTER:
			return "printer";
			
		case UsbConstants.USB_CLASS_STILL_IMAGE:
			return "still image device";
			
		case UsbConstants.USB_CLASS_VIDEO:
			return "video device";
			
		case UsbConstants.USB_CLASS_WIRELESS_CONTROLLER:
			return "wireless controller device";
		
		default:
			return "unknown";
	}
}
#End If


