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

'----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

'
'Java native code
'

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
	
	'For running native Java code
	Private joService As JavaObject
	
	'For doing APDU communications in a separate thread
	Private ServiceMessageThread As Thread
	
	'List of possible Service messaging values
	Public Const DO_CCID_DIAGNOSTICS As Int = 0x100
	Public Const SEND_APDU           As Int = 0x200
	#If Java
	private static final int DO_CCID_DIAGNOSTICS = 0x100;
	private static final int SEND_APDU           = 0x200;
	#End If
	
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
	
	'Initialize the PC/SC stack
	joService.RunMethod("jService_Create", Null)
	
	'For doing APDU communications in a separate thread
	ServiceMessageThread.Initialize("ServiceMessageThread")
	
End Sub
#If Java
public void jService_Create()
{
	Log.d(TAG, "SmartcardService onCreate "+this);
	
	usbManager = (UsbManager)getSystemService(Context.USB_SERVICE);
	
	notifyMgr = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
	powerMgr  = (PowerManager)getSystemService(Context.POWER_SERVICE);
	
	bcThread = new HandlerThread("SmartcardServiceBCThread", Process.THREAD_PRIORITY_BACKGROUND);
	bcThread.start();
	
	uiHandler = new Handler(Looper.getMainLooper());
	broadcast = new Handler(bcThread.getLooper());
}
#End If

Private Sub ServiceMessageThread_Ended(Failed As Boolean, ErrorIfAny As String)
	'
	'Nothing to do here
	'
End Sub

'
'Smartcard Service Basic code
'
'Services don't always start automatically when you launch the app,
'they actually have to be explicitly started, unless they
'start on boot (which is not the case here)
'

Sub Service_Start(StartingIntent As Intent)
	
	'Starter service can start in the foreground state in some edge cases
	Service.StopAutomaticForeground
	
	'This Service requires USB OTG support:
	' - Stop the service if USB OTG is not supported
	If Not(joService.RunMethod("jDeviceHasUsbOtgSupport", Null)) Then
		
		'Stop the Service
		StopService(Me)
		
	End If
	
	ServiceMessageThread.Start(Me, "Service_Message_NewThread", Null)
	
End Sub

'Inter-communication between the Service and Activities:
' - It's for letting this Service receive messages from
'   this application's Activities to this Service only
'
Sub Service_Message_NewThread
	
	Dim Caller       As Object
	Dim SubName      As String
	Dim Parameters() As Object
	
	Do While True
		Wait For Service_Message_To_NewThread(DoWhat As Int, CallerBundle() As Object)
		
		Select DoWhat
			Case DO_CCID_DIAGNOSTICS, SEND_APDU
				Caller     = CallerBundle(0) 'CallerBundle(0) = Caller     - Object
				SubName    = CallerBundle(1) 'CallerBundle(1) = SubName    - String
				Parameters = CallerBundle(2) 'CallerBundle(2) = Parameters - Object()
				
				Try
					Dim ServiceReply() As Object = joService.RunMethod("jService_Message_NewThread", Array(DoWhat, Parameters))
					Dim IsSuccessful   As Boolean = True
					
					'The MySmartcardReader class automatically handles APDU
					'request chaining transparently, so we can just simply
					'check for a 90 00 status code
					If DoWhat == SEND_APDU And Not(ServiceReply(0).As(String).EndsWith("9000")) Then
						IsSuccessful = False
					End If
					
					CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", IsSuccessful, ServiceReply)
					
				Catch
					Log(LastException)
					CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", False, Array As Object(LastException.Message))
					
				End Try
				
				Exit
				
			Case Else
				CallSubDelayed3(Caller, "Smartcard_"&SubName&"_Completed", False, Array As Object($"Unknown message type ${DoWhat} sent to this Service"$))
				Exit
				
		End Select
	Loop
	
End Sub
#If Java
import java.lang.RuntimeException;
import java.io.StringWriter;
import java.io.PrintWriter;
public Object[] jService_Message_NewThread(int doWhat, Object[] parameters) throws RemoteException, IOException, RuntimeException
{
	/* Don't use SCREEN_DIM_WAKE_LOCK:
	 *  - Many phones lower the USB power output or suspend it on screen dimming
	 */
	PowerManager.WakeLock wl = powerMgr.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG);
	wl.acquire();
	
	NotificationCompat.Builder builder = new NotificationCompat.Builder(smartcard.this)
		.setSmallIcon(R.drawable.ic_stat_card)
		.setContentTitle("Android PIN Unblocker")
		.setContentText("Accessing smartcard reader...")
		.setCategory(Notification.CATEGORY_SERVICE);
	startForeground(1, builder.build());
	
	Object[] reply = null;
	
	try
	{
		if ( doWhat == DO_CCID_DIAGNOSTICS )
		{
			reply = new Object[] { jDoCcidDiagnostics() };
			return reply;
		}
		
		jObtainUsbDevice();
		jObtainUsbPermission();
		
		jObtainSmartcardReader();
		jObtainSmartcard();
		
		switch ( doWhat )
		{
			case SEND_APDU:
				reply = new Object[] { cardReader.sendSpecificAPDU(String.valueOf(parameters[0])) };
				break;
				
			default:
				throw new RuntimeException("You requested a message type that this Service does not know nor support");
		}
	}
	catch (Exception e)
	{
		StringWriter stackTrace = new StringWriter();
		e.printStackTrace(new PrintWriter(stackTrace));
		
		Log.e(TAG, "Failed to process message", e);
		processError(e);
		
		throw new RuntimeException(stackTrace.toString());
	}
	finally
	{
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

Sub Service_Message(DoWhat As Int, CallerBundle() As Object)
	
	'Send all requests to the dedicated background thread
	CallSubDelayed3(Me, "Service_Message_To_NewThread", DoWhat, CallerBundle)
	
End Sub

Sub Service_Destroy
	
	Security.TriggerJvmGarbageCollection
	
	'This Service requires USB OTG support:
	' - Return early if USB-OTG is not supported
	If Not(joService.RunMethod("jDeviceHasUsbOtgSupport", Null)) Then
		
		'Return early (no need to run the jService_Destroy function code)
		Return
		
	End If
	
	ServiceMessageThread.Interrupt
	joService.RunMethod("jService_Destroy", Null)
	
End Sub
#If Java
public void jService_Destroy()
{
	try
	{
		cardReader.close();
		
		if ( detachReceiver != null )
		{
			try
			{
				unregisterReceiver(detachReceiver);
			}
			catch (IllegalArgumentException iae)
			{
				Log.i(TAG, "Android claims the receiver isn't registered", iae);
			}
			
			detachReceiver = null;
		}
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	try
	{
		if ( !bcThread.quit() )
		{
			Log.w(TAG, "Failed to quit broadcast thread loop");
		}
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	try
	{
		if ( !messageThread.quit() )
		{
			Log.w(TAG, "Failed to quit main thread loop");
		}
	}
	catch (Exception e)
	{
		/* Nothing to do here */
	}
	
	try
	{
		// Remove any lock to allow the loopers to quit
		if ( wait != null )
		{
			synchronized ( wait )
			{
				wait.notify();
			}
		}
	}
	catch (Exception e)
	{
		/* Nothing to do here */
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

'General list of all Java native imports for this Service
'This way no need to figure out which functions need what
#If Java
import android.app.Notification;
import android.app.NotificationManager;
import androidx.core.app.NotificationCompat;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.net.Uri;
import android.os.*;
import android.os.Process; // This one must be explicitly imported
import android.util.Log;
import android.widget.Toast;
import java.io.IOException;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import net.gdmeunier.pinunblocker.R; // Must match the application's package name
#End If

#If Java
private static final long USB_TIMEOUT       = 1 * 10 * 1000; // 10s
private static final long SMARTCARD_TIMEOUT = 1 * 10 * 1000; // 10s
private static final long CONFIRM_TIMEOUT   = 1 * 30 * 1000; // 30s

private UsbManager usbManager;
private UsbDevice  ccidDevice;

private mysmartcardreader.SmartcardReader cardReader;

private NotificationManager notifyMgr;
private PowerManager        powerMgr;

// Temporary properties
private BroadcastReceiver detachReceiver;
private Object wait;

// Permanent properties
private Handler uiHandler = null;
private Handler broadcast = null;

private HandlerThread bcThread;
private HandlerThread messageThread;

private static final String TAG = "net.gdmeunier.pinunblocker";
private static final String ACTION_USB_PERMISSION = "net.gdmeunier.pinunblocker.USB_PERMISSION";

#End If

#If Java
public String jDoCcidDiagnostics() throws RemoteException
{
	boolean foundDevice = false;
	boolean foundCCID   = false;
	boolean foundCard   = false;
	
	StringBuilder builder = new StringBuilder();
	builder.append("Diagnostics result:");
	builder.append("\r\n\r\n");
	
	Map<String, UsbDevice> deviceList     = usbManager.getDeviceList();
	Iterator<UsbDevice>    deviceIterator = deviceList.values().iterator();
	
	while ( deviceIterator.hasNext() )
	{
		ccidDevice = deviceIterator.next();
		
		try
		{
			jObtainUsbPermission();
			myccid.DeviceDescriptor dd = new myccid.DeviceDescriptor(usbManager, ccidDevice);
			
			builder.append(dd.toString());
			builder.append("\r\n\r\n");
			
			foundDevice = true;
			
			if ( dd.hasCCID() )
			{
				foundCCID = true;
			}
			if ( dd.hasCard() )
			{
				foundCard = true;
			}
			
			builder.append("\r\n\r\n");
			builder.append(String.format("Is CCID: %s\r\nHas card: %s", foundCCID, foundCard));
		}
		catch (Exception e)
		{
			Log.w(TAG, "Failed to diagnose device", e);
		}
		finally
		{
			ccidDevice = null;
		}
	}
	
	return builder.toString();
}
#End If

#If Java
public void jObtainUsbDevice() throws mysmartcardreader.AbortException
{
	if ( ccidDevice != null && myccid.CCID.isCCIDCompliant(ccidDevice) )
	{
		// We already have a connected USB-CCID device
		// No need to obtain it again
		return;
	}
	
	ccidDevice     = null;
	detachReceiver = null;
	
	Map<String, UsbDevice> deviceList     = usbManager.getDeviceList();
	Iterator<UsbDevice>    deviceIterator = deviceList.values().iterator();
	
	while ( ccidDevice == null && deviceIterator.hasNext() )
	{
		UsbDevice device = deviceIterator.next();
		
		if ( myccid.CCID.isCCIDCompliant(device) )
		{
			ccidDevice = device;
		}
	}
	
	if ( ccidDevice == null )
	{
		final BroadcastReceiver attachReceiver = new BroadcastReceiver()
		{
			@Override
			public void onReceive(Context context, Intent intent)
			{
				UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
				
				if ( myccid.CCID.isCCIDCompliant(device) )
				{
					ccidDevice = device;
					
					if ( wait == null )
					{
						Log.w(TAG, "Obtained USB device without wait handler");
						return;
					}
					
					synchronized ( wait )
					{
						wait.notify();
					}
				}
				else
				{
					final String product = getProductName(device);
					
					uiHandler.post(new Runnable()
						{
							@Override
							public void run()
							{
								Toast.makeText(smartcard.this, String.format("The connected device (%1$s) is not recognized", product), Toast.LENGTH_LONG).show();
							}
						}
					);
				}
			}
		};
		
		// Android 13+ require explicitly exporting the receiver
		// (Android 13+ is API level 33+)
		if ( Build.VERSION.SDK_INT >= 33 )
		{
			registerReceiver(attachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED), null, broadcast, Context.RECEIVER_EXPORTED);
		}
		else
		{
			registerReceiver(attachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED), null, broadcast);
		}
		
		NotificationCompat.Builder builder = new NotificationCompat.Builder(this)
				.setSmallIcon(R.drawable.ic_stat_card)
				.setContentTitle("Android PIN Unblocker")
				.setContentText("Connect your smartcard reader")
				.setCategory(Notification.CATEGORY_SERVICE)
				.setPriority(NotificationCompat.PRIORITY_MAX)
				.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_LIGHTS);
		
		uiHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, "Connect your smartcard reader...", Toast.LENGTH_LONG).show();
				}
			}
		);
		
		wait = new Object();
		notifyMgr.notify(1, builder.build());
		
		synchronized ( wait )
		{
			try
			{
				wait.wait(USB_TIMEOUT);
			}
			catch (InterruptedException e)
			{
				Log.e(TAG, "Interrupted while waiting for USB insert", e);
			}
		}
		wait = null;
		
		try
		{
			unregisterReceiver(attachReceiver);
		}
		catch (IllegalArgumentException iae)
		{
			Log.i(TAG, "Android claims the receiver isn't registered", iae);
		}
		if ( ccidDevice == null )
		{
			throw new mysmartcardreader.AbortException("No reader connected");
		}
	}
	
	// Listen to detach
	detachReceiver = new BroadcastReceiver()
	{
		@Override
		public void onReceive(Context context, Intent intent)
		{
			UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
			
			if ( device.getDeviceName().equals(ccidDevice.getDeviceName()) )
			{
				/* Clear the current connected device handle
				 *
				 * This way the next jObtainUsbDevice call will
				 * re-acquire a new USB-CCID device
				 */
				ccidDevice = null;
				
				// End the ongoing wait
				if ( wait != null )
				{
					synchronized ( wait )
					{
						wait.notify();
					}
				}
			}
		}
	};
	
	// Android 13+ require explicitly exporting the receiver
	// (Android 13+ is API level 33+)
	if ( Build.VERSION.SDK_INT >= 33 )
	{
		registerReceiver(detachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_DETACHED), null, broadcast, Context.RECEIVER_EXPORTED);
	}
	else
	{
		registerReceiver(detachReceiver, new IntentFilter(UsbManager.ACTION_USB_DEVICE_DETACHED), null, broadcast);
	}
}
#End If

#If Java
public void jObtainUsbPermission() throws mysmartcardreader.AbortException
{
	if ( !usbManager.hasPermission(ccidDevice) )
	{
		BroadcastReceiver grantReceiver = new BroadcastReceiver()
		{
			@Override
			public void onReceive(Context context, Intent intent)
			{
				if ( wait == null )
				{
					Log.w(TAG, "Obtained USB permission without wait handler");
					return;
				}
				
				synchronized ( wait )
				{
					wait.notify();
				}
			}
		};
		
		wait = new Object();
		
		// Android 13+ require explicitly exporting the receiver
		// (Android 13+ is API level 33+)
		if ( Build.VERSION.SDK_INT >= 33 )
		{
			registerReceiver(grantReceiver, new IntentFilter(ACTION_USB_PERMISSION), null, broadcast, Context.RECEIVER_EXPORTED);
		}
		else
		{
			registerReceiver(grantReceiver, new IntentFilter(ACTION_USB_PERMISSION), null, broadcast);
		}
		
		usbManager.requestPermission(
			ccidDevice,
			PendingIntent.getBroadcast(this, 0, new Intent(ACTION_USB_PERMISSION), 0)
		);
		
		synchronized ( wait )
		{
			try
			{
				wait.wait(CONFIRM_TIMEOUT);
			}
			catch (InterruptedException e)
			{
				Log.e(TAG, "Interrupted while waiting for USB grant permission", e);
			}
		}
		wait = null;
		
		try
		{
			unregisterReceiver(grantReceiver);
		}
		catch (IllegalArgumentException iae)
		{
			Log.i(TAG, "Android claims the receiver isn't registered", iae);
		}
		if ( !usbManager.hasPermission(ccidDevice) )
		{
			throw new mysmartcardreader.AbortException("No USB permission granted");
		}
	}
}
#End If

#If Java
public void jObtainSmartcardReader() throws IOException
{
	cardReader = new mysmartcardreader.SmartcardReader(usbManager, ccidDevice);
	cardReader.open();
}
#End If

#If Java
public void jObtainSmartcard() throws mysmartcardreader.AbortException
{
	NotificationCompat.Builder builder = new NotificationCompat.Builder(smartcard.this)
			.setSmallIcon(R.drawable.ic_stat_card)
			.setContentTitle("Android PIN Unblocker")
			.setContentText("Accessing your smartcard...")
			.setCategory(Notification.CATEGORY_SERVICE);
	
	notifyMgr.notify(1, builder.build());
	
	if ( !cardReader.isCardPresent() )
	{
		cardReader.setCardCallback(
			new mysmartcardreader.CardCallback()
			{
				@Override
				public void inserted()
				{
					if ( wait == null )
					{
						Log.w(TAG, "Obtained smartcard device without wait handler");
						return;
					}
					synchronized ( wait )
					{
						wait.notify();
					}
				}
				
				@Override
				public void removed()
				{
					/* Nothing */
				}
			}
		);
		
		final String msg = String.format("Insert your smartcard in your %1$s reader...", getProductName(ccidDevice));
		
		builder = new NotificationCompat.Builder(this)
				.setSmallIcon(R.drawable.ic_stat_card)
				.setContentTitle("Android PIN Unblocker")
				.setContentText(msg)
				.setCategory(Notification.CATEGORY_SERVICE)
				.setPriority(NotificationCompat.PRIORITY_MAX)
				.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_LIGHTS);
		
		uiHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, msg, Toast.LENGTH_LONG).show();
				}
			}
		);
		
		wait = new Object();
		notifyMgr.notify(1, builder.build());
		
		synchronized ( wait )
		{
			try
			{
				wait.wait(SMARTCARD_TIMEOUT);
			}
			catch (InterruptedException e)
			{
				Log.e(TAG, "Interrupted while waiting for smartcard", e);
			}
		}
		wait = null;
		cardReader.setCardCallback(null);
		
		if ( !cardReader.isCardPresent() )
		{
			throw new mysmartcardreader.AbortException("No Smartcard present");
		}
	}
}
#End If

#If Java
private String getVendor()
{
	if ( ccidDevice == null )
	{
		return "unknown";
	}
	
	return String.format("%X", ccidDevice.getVendorId());
}

private String getProduct()
{
	if ( ccidDevice == null )
	{
		return "unknown";
	}
	
	return String.format("%X", ccidDevice.getProductId());
}

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
				
				if (builder.length() > 0)
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

private void processError(Exception e)
{
	Throwable root = e;
	
	while ( root.getCause() != null )
	{
		root = root.getCause();
	}
	
	if ( root instanceof mysmartcardreader.UserCancelException )
	{
		uiHandler.post(new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, "Smartcard action canceled", Toast.LENGTH_SHORT).show();
				}
			}
		);
	}
	else if ( root instanceof mysmartcardreader.AbortException )
	{
		uiHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, "Smartcard action aborted", Toast.LENGTH_SHORT).show();
				}
			}
		);
	}
	else if ( root instanceof mysmartcardreader.CardBlockedException )
	{
		uiHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, "Smartcard is blocked!", Toast.LENGTH_LONG).show();
				}
			}
		);
	}
	else
	{
		uiHandler.post(
			new Runnable()
			{
				@Override
				public void run()
				{
					Toast.makeText(smartcard.this, "Smartcard action failed", Toast.LENGTH_LONG).show();
				}
			}
		);
	}
}
#End If


