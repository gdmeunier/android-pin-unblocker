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
'CCID object descriptors
'

#If Java
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.EnumSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
public static class CCIDDescriptor
{
	public static enum Voltage    { _5_0V, _3_0V, _1_8V }
	public static enum Protocol   { T0, T1 }
	public static enum Mechanical { Accept, Ejection, Capture, LockUnlock }
	
	public static enum Feature
	{
		AutoParamConfigViaATR,
		AutoActivationOnInsert,
		AutoVoltageSelection,
		AutoClockChange,
		AutoDataRateChange,
		AutoParamNego,
		AutoPPS,
		CanStopClock,
		NADAccepted,
		AutoIFSDExchange,
		TPDU,
		ShortAPDU,
		ShortAndExtendedAPDU,
		WakeOnCardAction
	}
	
	public static enum PINSupport { Verification, Modification }
	
	public static class ScreenSize
	{
		int lines;
		int charsPerLine;
		
		public ScreenSize(int lines, int charsPerLine)
		{
			this.lines = lines;
			this.charsPerLine = charsPerLine;
		}
	}
	
	public static Map<Integer, CCIDDescriptor> Parse(byte[] data) throws IOException
	{
		ByteBuffer bb = ByteBuffer.wrap(data);
		bb = bb.order(ByteOrder.LITTLE_ENDIAN);
		
		int i = -1;
		Map<Integer, CCIDDescriptor> ccids = new TreeMap<Integer, CCIDDescriptor>();
		
		while ( bb.hasRemaining() )
		{
			int len  = bb.get();
			int type = bb.get();
			
			if ( type == 0x04 )
			{
				if ( len != 0x09 )
				{
					throw new IllegalArgumentException("Invalid Interface descriptor (wrong length)");
				}
				
				i = bb.getShort();
				bb.position(bb.position() + len - 4);
			}
			else if ( type == 0x21 )
			{
				if ( len != 0x36 )
				{
					throw new IllegalArgumentException("Invalid Smart Card Device descriptor (wrong length)");
				}
				
				CCIDDescriptor ccid = new CCIDDescriptor();
				ccid.ccidVersion    = bb.getShort();
				ccid.maxSlotIndex   = bb.get();
				
				int vsData = bb.get();
				List<Voltage> vsList = new LinkedList<Voltage>();
				
				if ( (vsData & 0x01) == 0x01 )
				{
					vsList.add(Voltage._5_0V);
				}
				if ( (vsData & 0x02) == 0x02 )
				{
					vsList.add(Voltage._3_0V);
				}
				if ( (vsData & 0x04) == 0x04 )
				{
					vsList.add(Voltage._1_8V);
				}
				ccid.voltages = vsList.isEmpty() ? EnumSet.noneOf(Voltage.class) : EnumSet.copyOf(vsList);
				
				int pData = bb.getInt();
				List<Protocol> pList = new LinkedList<Protocol>();
				
				if ( (pData & 0x00000001) == 0x00000001 )
				{
					pList.add(Protocol.T0);
				}
				if ( (pData & 0x00000002) == 0x00000002 )
				{
					pList.add(Protocol.T1);
				}
				ccid.protocols = pList.isEmpty() ? EnumSet.noneOf(Protocol.class) : EnumSet.copyOf(pList);
				
				/* Whenever you call bb get methods it automatically gives you the
				 * next value on the next calls
				 *
				 * It's a 'data fetch offset' which automatically increases
				 * with every call
				 */
				ccid.defaultClock = bb.getInt();
				ccid.maxClock = bb.getInt();
				ccid.numClockSupported = bb.get();
				ccid.defaultDataRate = bb.getInt();
				ccid.maxDataRate = bb.getInt();
				ccid.numDataRatesSupported = bb.get();
				ccid.maxIFSD = bb.getInt();
				
				/* Make sure to avoid optimizing or shrinking this class with
				 * ProGuard / R8, otherwise this call will be removed
				 *
				 * Then you would get corrupt CCID descriptors due to this
				 */
				bb.getInt(); /* We ignore the synchProtocols (not relevant for USB) */
				
				int mData = bb.getInt();
				List<Mechanical> mList = new LinkedList<Mechanical>();
				
				if ( (mData & 0x00000001) == 0x00000001 )
				{
					mList.add(Mechanical.Accept);
				}
				if ( (mData & 0x00000002) == 0x00000002 )
				{
					mList.add(Mechanical.Ejection);
				}
				if ( (mData & 0x00000004) == 0x00000004 )
				{
					mList.add(Mechanical.Capture);
				}
				if ( (mData & 0x00000008) == 0x00000008 )
				{
					mList.add(Mechanical.LockUnlock);
				}
				ccid.mechanicals = mList.isEmpty() ? EnumSet.noneOf(Mechanical.class) : EnumSet.copyOf(mList);
				
				int fData = bb.getInt();
				List<Feature> fList = new LinkedList<Feature>();
				
				if ( (fData & 0x00000002) == 0x00000002 )
				{
					fList.add(Feature.AutoParamConfigViaATR);
				}
				if ( (fData & 0x00000004) == 0x00000004 )
				{
					fList.add(Feature.AutoActivationOnInsert);
				}
				if ( (fData & 0x00000008) == 0x00000008 )
				{
					fList.add(Feature.AutoVoltageSelection);
				}
				if ( (fData & 0x00000010) == 0x00000010 )
				{
					fList.add(Feature.AutoClockChange);
				}
				if ( (fData & 0x00000020) == 0x00000020 )
				{
					fList.add(Feature.AutoDataRateChange);
				}
				if ( (fData & 0x00000040) == 0x00000040 )
				{
					fList.add(Feature.AutoParamNego);
				}
				if ( (fData & 0x00000080) == 0x00000080 )
				{
					fList.add(Feature.AutoPPS);
				}
				if ( (fData & 0x00000100) == 0x00000100 )
				{
					fList.add(Feature.CanStopClock);
				}
				if ( (fData & 0x00000200) == 0x00000200 )
				{
					fList.add(Feature.NADAccepted);
				}
				if ( (fData & 0x00000400) == 0x00000400 )
				{
					fList.add(Feature.AutoIFSDExchange);
				}
				if ( (fData & 0x00010000) == 0x00010000 )
				{
					fList.add(Feature.TPDU);
				}
				if ( (fData & 0x00020000) == 0x00020000 )
				{
					fList.add(Feature.ShortAPDU);
				}
				if ( (fData & 0x00040000) == 0x00040000 )
				{
					fList.add(Feature.ShortAndExtendedAPDU);
				}
				if ( (fData & 0x00100000) == 0x00100000 )
				{
					fList.add(Feature.WakeOnCardAction);
				}
				ccid.features = fList.isEmpty() ? EnumSet.noneOf(Feature.class) : EnumSet.copyOf(fList);
				
				ccid.maxCCIDMessageLength = bb.getInt();
				ccid.classGetResponse     = bb.get();
				ccid.classEnvelope        = bb.get();
				
				int x = bb.get();
				int y = bb.get();
				ccid.lcdLayout = new ScreenSize(x, y);
				
				int psData = bb.get();
				List<PINSupport> psList = new LinkedList<PINSupport>();
				
				if ( (psData & 0x01) == 0x01 )
				{
					psList.add(PINSupport.Verification);
				}
				if ( (psData & 0x02) == 0x02 )
				{
					psList.add(PINSupport.Modification);
				}
				ccid.pinSupports = psList.isEmpty() ? EnumSet.noneOf(PINSupport.class) : EnumSet.copyOf(psList);
				
				ccid.maxCCIDBusySlots = bb.get();
				
				ccids.put(i, ccid);
				
				i = -1;
			}
			else
			{
				bb.position(bb.position() + len - 2);
			}
		}
		
		return ccids;
	}
	
	private int ccidVersion;
	private int maxSlotIndex;
	private EnumSet<Voltage> voltages;
	private EnumSet<Protocol> protocols;
	private int defaultClock;
	private int maxClock;
	private int numClockSupported;
	private int defaultDataRate;
	private int maxDataRate;
	private int numDataRatesSupported;
	private int maxIFSD;
	private EnumSet<Mechanical> mechanicals;
	private EnumSet<Feature> features;
	private int maxCCIDMessageLength;
	private int classGetResponse;
	private int classEnvelope;
	private ScreenSize lcdLayout;
	private EnumSet<PINSupport> pinSupports;
	private int maxCCIDBusySlots;
	
	@Override
	public String toString()
	{
		return String.format("CCID: Version=%X, NumSlot=%d, Voltages=%s, Protocols=%s, "            +
						     "DefaultClock=%dKHz, MaxClock=%dKHz, NumClockSupported=%d, "           +
						     "DefaultDataRate=%dbps, MaxDataRate=%dpbs, NumDataRatesSupported=%d, " +
						     "MaxIFSD=%d, Mechanicals=%s, Features=%s, MaxCCIDMessageLength=%d, "   +
						     "ClassGetResponse=%X, classEnvelope=%X, lcdLayout=%dx%d, "             +
						     "PIN Support=%s, MaxCCIDBusySlots=%d",
				ccidVersion, maxSlotIndex +1, voltages, protocols,
				defaultClock, maxClock, numClockSupported,
				defaultDataRate, maxDataRate, numDataRatesSupported,
				maxIFSD, mechanicals, features, maxCCIDMessageLength,
				classGetResponse, classEnvelope, lcdLayout.charsPerLine, lcdLayout.lines,
				pinSupports, maxCCIDBusySlots
		);
	}
	
	public EnumSet<PINSupport> getPinSupports()
	{
		return pinSupports;
	}
	
	public EnumSet<Feature> getFeatures()
	{
		return features;
	}
}

import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import java.util.Map;
public static class DeviceDescriptor
{
	private UsbManager m;
	private UsbDevice  d;
	
	private boolean hasCard;
	private boolean hasCCID;
	
	private String msg;
	
	public boolean hasCard()
	{
		return hasCard;
	}
	
	public boolean hasCCID()
	{
		return hasCCID;
	}
	
	public DeviceDescriptor(UsbManager usbManager, UsbDevice usbDevice)
	{
		this.m = usbManager;
		this.d = usbDevice;
		
		populate();
	}
	
	public void populate()
	{
		StringBuilder builder = new StringBuilder();
		builder.append(
			String.format("Device: Name=%s, VendorId=%X, ProductId=%X, Class=%X, Subclass=%X, Protocol=%X",
				d.getDeviceName(),
				d.getVendorId(),
				d.getProductId(),
				d.getDeviceClass(),
				d.getDeviceSubclass(),
				d.getDeviceProtocol()
			)
		);
		
		Map<Integer, CCIDDescriptor> cds = null;
		UsbDeviceConnection connection = m.openDevice(d);
		
		try
		{
			cds = CCIDDescriptor.Parse(connection.getRawDescriptors());
		}
		catch (Exception e)
		{
			/* Nothing to do here */
		}
		finally
		{
			connection.close();
		}
		
		for ( int i = 0; i < d.getInterfaceCount(); i++ )
		{
			UsbInterface in = d.getInterface(i);
			
			builder.append("\r\n");
			builder.append(new InterfaceDescriptor(in).toString());
			
			for ( int j = 0; j < in.getEndpointCount(); j++ )
			{
				builder.append("\r\n");
				builder.append(new EndPointDescriptor(in.getEndpoint(j)).toString());
			}
			
			CCIDDescriptor cd = cds == null ? null : cds.get(in.getId());
			if ( cd != null )
			{
				builder.append("\r\n");
				builder.append(cd.toString());
			}
			
			if ( in.getInterfaceClass() == UsbConstants.USB_CLASS_CSCID )
			{
				hasCCID = true;
				builder.append("\r\n");
				
				CCID c = new CCID(m, d, in);
				try
				{
					c.open();
					
					try
					{
						//                             IccPowerOn,       DataBlock
						CCID.Response rsp = c.transmit((byte)0x62, null, (byte)0x80, false);
						
						hasCard = rsp.data != null && rsp.data.length > 0;
						
						builder.append(
							String.format("ICC PowerOn Rsp: Param=%X, Data=%s",
								rsp.param,
								jHexStringFromBytes(rsp.data)
							)
						);
					}
					catch (Exception e)
					{
						builder.append(String.format("ICC PowerOn Failed: %s", e));
					}
					finally
					{
						c.close();
					}
				}
				catch (Exception e)
				{
					builder.append(String.format("ICC Open Failed: %s", e));
				}
			}
		}
		
		msg = builder.toString();
	}
	
	@Override
	public String toString()
	{
		return msg;
	}
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

import android.hardware.usb.UsbEndpoint;
public static class EndPointDescriptor
{
	private UsbEndpoint ep;
	
	public EndPointDescriptor(UsbEndpoint ep)
	{
		this.ep = ep;
	}
	
	@Override
	public String toString()
	{
		return String.format("EndPoint: Address=%X, Number=%d, Direction=%X, Attributes=%X, Type=%X, Interval=%X, MaxPacketSize=%X",
			ep.getAddress(),
			ep.getEndpointNumber(),
			ep.getDirection(),
			ep.getAttributes(),
			ep.getType(),
			ep.getInterval(),
			ep.getMaxPacketSize()
		);
	}
}

import android.hardware.usb.UsbInterface;
public static class InterfaceDescriptor
{
	private UsbInterface i;
	
	public InterfaceDescriptor(UsbInterface i)
	{
		this.i = i;
	}
	
	@Override
	public String toString()
	{
		return String.format("Interface: Id=%d, Class=%X, Subclass=%X, Protocol=%X",
			i.getId(),
			i.getInterfaceClass(),
			i.getInterfaceSubclass(),
			i.getInterfaceProtocol()
		);
	}
}
#End If

'
'CCID class callbacks
'

#If Java
public interface CardCallback
{
	void inserted();
	void removed();
}
#End If


'
'CCID class code
'

#If Java
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import android.util.Log;
import java.io.Closeable;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
public static class CCID implements Closeable
{
    private static final ScheduledExecutorService StateListenerPool = Executors.newScheduledThreadPool(1);
	
    public static enum SlotStatus
	{
        Active,
        Inactive,
        Missing
    }
	
    public static class Response
	{
        public byte   param;
        public byte[] data;
    }
	
    public static boolean isCCIDCompliant(UsbDevice usbDevice)
	{
        if ( usbDevice.getDeviceClass() == UsbConstants.USB_CLASS_CSCID )
		{
            return true;
        }
		else if ( usbDevice.getDeviceClass() == UsbConstants.USB_CLASS_PER_INTERFACE )
		{
            for ( int i = 0; i < usbDevice.getInterfaceCount(); i++ )
			{
                if ( usbDevice.getInterface(i).getInterfaceClass() == UsbConstants.USB_CLASS_CSCID )
				{
                    return true;
                }
            }
        }
		
        return false;
    }
	
    // Input properties
    private UsbDevice    usbDevice;
    private UsbManager   usbManager;
    private UsbInterface usbInterface;
	
    // Connection
    private boolean pinPad;
    private boolean supportApdu;
    private boolean autoInit;
	
    private UsbDeviceConnection usbConnection;
	
    // USB streams
    private UsbEndpoint usbOut;
    private UsbEndpoint usbIn;
    private UsbEndpoint usbInterrupt;
	
    // State properties
    private int sequence;
    private ScheduledFuture stateRequester;
	
    // Callback
    private CardCallback callback;
	
    public CardCallback getCallback()
    {
        return callback;
    }
	
    public void setCallback(CardCallback value)
    {
        callback = value;
        setupStateListener();
    }
	
    public synchronized boolean isOpen()
	{
        return usbConnection != null;
    }
	
    public boolean hasPinPad()
	{
        return pinPad;
    }
	
    public CCID(UsbManager usbManager, UsbDevice usbDevice)
    {
        this.usbManager = usbManager;
        this.usbDevice  = usbDevice;
    }
	
    public CCID(UsbManager usbManager, UsbDevice usbDevice, UsbInterface usbInterface)
	{
        this(usbManager, usbDevice);
        this.usbInterface = usbInterface;
    }
	
    public boolean isCCIDCompliant()
	{
        return CCID.isCCIDCompliant(usbDevice);
    }
	
    public synchronized void open() throws IOException
	{
        if ( usbDevice == null )
		{
			throw new IllegalArgumentException("Device can't be null");
		}
		
        if ( usbInterface == null )
		{
            for ( int i = 0; i < usbDevice.getInterfaceCount(); i++ )
			{
                UsbInterface usbIf = usbDevice.getInterface(i);
				
                if ( usbIf.getInterfaceClass() == UsbConstants.USB_CLASS_CSCID )
				{
                    usbInterface = usbIf;
                }
            }
            if ( usbInterface == null )
			{
				throw new IllegalStateException("The device hasn't a smart card reader");
			}
        }
		
        usbConnection = usbManager.openDevice(usbDevice);
        usbConnection.claimInterface(usbInterface, true);
		
        sequence = 0;
		
        // Get the interfaces
        for ( int i = 0; i < usbInterface.getEndpointCount(); i++ )
		{
            UsbEndpoint usbEp = usbInterface.getEndpoint(i);
			
            if ( usbEp.getDirection() == UsbConstants.USB_DIR_IN &&
				 usbEp.getType() == UsbConstants.USB_ENDPOINT_XFER_INT )
			{
                usbInterrupt = usbEp;
            }
            if ( usbEp.getDirection() == UsbConstants.USB_DIR_OUT &&
				 usbEp.getType() == UsbConstants.USB_ENDPOINT_XFER_BULK )
			{
                usbOut = usbEp;
            }
            if ( usbEp.getDirection() == UsbConstants.USB_DIR_IN &&
				 usbEp.getType() == UsbConstants.USB_ENDPOINT_XFER_BULK )
			{
                usbIn = usbEp;
            }
        }
		
        // Check for pinPad
        CCIDDescriptor desc = CCIDDescriptor.Parse(
			usbConnection.getRawDescriptors()
		).get(
			usbInterface.getId()
		);
		
        pinPad = desc.getPinSupports().contains(CCIDDescriptor.PINSupport.Verification);
		
        supportApdu = desc.getFeatures().contains(CCIDDescriptor.Feature.ShortAPDU) ||
			desc.getFeatures().contains(CCIDDescriptor.Feature.ShortAndExtendedAPDU);
		
        autoInit = desc.getFeatures().contains(CCIDDescriptor.Feature.AutoParamConfigViaATR);
		
        // Listen for state changes
        setupStateListener();
    }
	
    private void setupStateListener()
	{
        if ( usbInterrupt != null )
		{
            if ( callback != null && stateRequester == null )
			{
                stateRequester = StateListenerPool.scheduleWithFixedDelay(
					new StateRequesterTask(), 100, 1000, TimeUnit.MILLISECONDS
				);
            }
			else if ( callback == null && stateRequester != null )
			{
                stateRequester.cancel(false);
                stateRequester = null;
            }
        }
    }
	
    @Override
    public synchronized void close() throws IOException
	{
        if ( stateRequester != null )
		{
            stateRequester.cancel(false);
            stateRequester = null;
        }
        if ( usbInterface != null )
		{
            usbConnection.releaseInterface(usbInterface);
            usbConnection.close();
			
            usbConnection = null;
            usbInterface  = null;
        }
    }
	
    private class StateRequesterTask implements Runnable
	{
        @Override
        public void run()
		{
            byte[] buffer = new byte[10];
            int count = usbConnection.bulkTransfer(usbInterrupt, buffer, buffer.length, 100);
			
            if ( count < 0 )
			{
				return; /* No info */
			}
			
            if ( count < 2 )
			{
                Log.w(TAG, "CCID interrupt read returned an invalid length: "+count);
                return;
            }
			
            if ( buffer[0] == (byte)0x51 )
			{
                Log.w(TAG, String.format("CCID interrupt read returned an error : %x", buffer[3]));
            }
			
            if ( buffer[0] != (byte)0x50 )
			{
                Log.w(TAG, String.format("CCID interrupt read returned an invalid type: %x", buffer[0]));
                return;
            }
			
            Log.i(TAG, String.format("CCID interrupt read returned the following status: %x", buffer[1]));
			
            if ( (buffer[1] & (byte)0x03) == (byte)0x02 )
			{
                callback.removed();
			}
            else if ( (buffer[1] & (byte)0x03) == (byte)0x03 )
			{
                callback.inserted();
			}
        }
    }
	
    public synchronized byte[] powerOn() throws IOException
	{
		//                    IccPowerOn        DataBlock
        return transmit((byte)0x62, null, (byte)0x80, false).data;
    }
	
    public synchronized void powerOff() throws IOException
	{
		//             IccPowerOff       SlotStatus
        transmit((byte)0x63, null, (byte)0x81, false);
    }
	
    public synchronized void init() throws IOException
	{
        if ( !autoInit )
		{
			/* TODO: determine Fi/Di from ATR (for now we assume 0x13 for all eID)
             * See: 9.2 http://read.pudn.com/downloads132/doc/comm/563504/ISO-IEC%207816/ISO%2BIEC%207816-3-2006.pdf
			 */
            if ( !supportApdu )
			{
                // TPDU for PPS
				transmit((byte)0x6F, new byte[]{(byte)0xFF, 0x10, 0x13, (byte)0xFC}, (byte)0x80, false);
            }
			
            // Set params
            byte[] pds = new byte[5];
            
			pds[0] = 0x13; // bmFindexDindex: Fi/f(max) = 372/5, Di = 4
			
            pds[1] = 0x00; // bmTCCKST0:         ignored (PCSC compatibility issue)
            pds[2] = 0x00; // bGuardTimeT0:      default
            pds[3] = 0x0A; // bWaitingIntegerT0: WI value
			
            pds[4] = 0x00; // bClockStop: no clock stop
			
			//             SetParameters    Parameters
            transmit((byte)0x61, pds, (byte)0x82, true);
        }
    }
	
    public synchronized byte[] transmitApdu(byte[] apdu) throws IOException
	{
		//                    XfrBlock         DataBlock
        return transmit((byte)0x6F, apdu,(byte)0x80, true).data;
    }
	
    public synchronized byte[] transmitApduWithPin(byte[] apdu) throws IOException
	{
        // See CCID 1.10:  8.1.3 (PIN uses a BCD format conversion with PIN length insertion)
        // See USB_LANGID: http://www.usb.org/developers/docs/USB_LANGIDs.pdf
		
        byte[] pvds = new byte[15 + apdu.length];
        pvds[0]  = 0x00;       // bPINOperation: PIN Verification
        pvds[1]  = 0x00;       // bTimeOut:      default
		
        pvds[2]  = (byte)0x89; // bmFormatString: PIN Value Offset = byte 1, left justify, BCD format
		
        pvds[3]  = (byte)0x47; // bmPINBlockString:  PIN Len Size = 4 bits, Encode PIN Len = 7 bytes
        pvds[4]  = (byte)0x04; // bmPINLengthFormat: PIN Len Offset = 4 bits
		
		/* The wPINMaxExtraDigit one was originally 4 somehow
		 * However pinpads should support any arbitrary PIN length,
		 * so let's increase it to atleast 16 (0x10)
		 *
		 * Atleast this way it will support most smartcards
		 * in the market that support the "Secure PIN Entry" PIN policy
		 */
        pvds[5]  = (byte)0x04; // wPINMaxExtraDigit:        Min PIN Len = 4
        pvds[6]  = (byte)0x10; // wPINMaxExtraDigit, cont.: Max PIN Len = 16 (was originally 4)
		
        pvds[7]  = (byte)0x03; // bEntryValidationCondition: Validate on Max PIN Size | Validate Key Press
        pvds[8]  = (byte)0xFF; // bNumberMessage:            Number of messages = default
		
        pvds[9]  = (byte)0x04; // wLangId:        Country  = US
        pvds[10] = (byte)0x09; // wLangId, cont.: Language = EN
		
        pvds[11] = (byte)0x00; // bMsgIndex: ignored number of messages is default
		
        pvds[12] = (byte)0x00; // bTeoPrologue:        T=1 only
        pvds[13] = (byte)0x00; // bTeoPrologue, cont.: T=1 only
        pvds[14] = (byte)0x00; // bTeoPrologue, cont.: T=1 only
		
        System.arraycopy(apdu, 0, pvds, 15, apdu.length);
		
		//                    Secure
        return transmit((byte)0x69, pvds, (byte)0x80, true).data;
    }
	
    public Response transmit(byte cmd, byte[] data, byte rtn, boolean waitIcc) throws IOException
	{
        sequence = (sequence + 1) % 0xFF;
		
        byte[] req = new byte[(data == null ? 0 : data.length) + 10];
        req[0] = cmd;
        req[1] = (byte)(req.length - 10); // Length (of data)
		
        req[2] = 0x00; // Length, continued (we don't support long lenghts)
        req[3] = 0x00; // Length, continued (we don't support long lenghts)
        req[4] = 0x00; // Length, continued (we don't support long lenghts)
		
        req[5] = (byte)0x00; // Slot
		
        req[6] = (byte)sequence;
        req[7] = (byte)( (cmd == (byte)0x6F) ? 0x01 : 0x00 ); // Not used (Xfr: Block Waiting Timeout)
		
        req[8] = 0x00; // Not used (Xfr: Param (short APDU))
        req[9] = 0x00; // Not used (Xfr: Param, continued (short APDU))
		
        if ( data != null )
		{
            System.arraycopy(data, 0, req, 10, data.length);
		}
		
        int count;
        count = usbConnection.bulkTransfer(usbOut, req, req.length, 5000);
        if ( count < 0 )
		{
            throw new IOException("Failed to send data to the CCID reader");
        }
        Log.v(TAG, String.format("Sent %d bytes to BULK-OUT: %s", count, jHexStringFromBytes(req)));
		
        SlotStatus status;
        byte[] rsp = new byte[271];
		
        do
		{
            count = usbConnection.bulkTransfer(usbIn, rsp, rsp.length, 10000);
			
            if ( count < 0 )
			{
                throw new IOException("Failed to read data from the CCID reader");
            }
			
            Log.v(TAG, String.format("Read %d bytes from BULK-IN: %s", count, jHexStringFromBytes(rsp)));
            status = validateResponse(rsp, rtn);
        }
		while (waitIcc && status != SlotStatus.Active);
		
        Response retVal = new Response();
        retVal.param = rsp[9];
		
        if ( count > 10 )
		{
            retVal.data = new byte[count - 10];
            System.arraycopy(rsp, 10, retVal.data, 0, count - 10);
        }
		else
		{
            retVal.data = new byte[0];
        }
		
        return retVal;
    }
	
    private SlotStatus validateResponse(byte[] rsp, byte type) throws IOException
	{
        if ( rsp.length < 10 )
		{
            throw new IOException("The response is too short");
        }
		
        if ( rsp[0] != type )
		{
            Log.w(TAG,
				String.format("Unexpected CCID reader response: %X (should be %X)",
					rsp[0], type
				)
			);
			
            throw new IOException(
				String.format("Illegal CCID reader response (wrong type: %X)",
					rsp[0]
				)
			);
        }
		
        if ( rsp[6] != (byte)sequence )
		{
            throw new IOException("Illegal CCID reader response (wrong sequence)");
        }
		
        if ( (rsp[7] & (byte)0x03) == 0x01 &&
			 rsp[8] == 0x00 )
		{
            throw new UnsupportedOperationException("Command not supported by the reader");
        }
        // No need to check errors like PIN_TIMEOUT (0xF0) and PIN_CANCELLED (0xEF), they aren't returned.
        if ( (rsp[7] & (byte)0x03) != 0x00 )
		{
            throw new CCIDException(
				String.format("Command Error returned by the CCID reader: %x",
					rsp[8]
				),
				rsp[7], rsp[8]);
        }
		
        switch( (byte)(rsp[7] & (byte)0xC0) )
		{
            case (byte)0x80:
                return SlotStatus.Missing;
				
            case (byte)0x40:
                return SlotStatus.Inactive;
				
            case (byte)0x00:
                return SlotStatus.Active;
				
            default:
                throw new IOException(
					String.format("Invalid slot status received from the CCID reader: %X",
						(byte)(rsp[7] & (byte)0xC0)
					)
				);
        }
    }
}
#End If

'
'CCID Exception class
'

#If Java
import java.io.IOException;
public static class CCIDException extends IOException
{
	private byte status;
	private byte error;
	
	public CCIDException(String msg, byte status, byte error)
	{
		super(msg);
		this.status = status;
		this.error  = error;
	}
	
	public byte getStatus()
	{
		return this.status;
	}
	
	public byte getError()
	{
		return this.error;
	}
}
#End If


