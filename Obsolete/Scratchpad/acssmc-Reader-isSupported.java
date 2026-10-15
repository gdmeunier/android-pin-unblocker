
/* This function has now been directly integrated
 * into the modified acssmc library JAR file
 *
 * This function was basically compiled with
 * the application once so that I could get
 * the corresponding Java bytecode to replace
 * the original acssmc isSupported() function
 * with this better and generic version
 */
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbConstants;
public boolean isSupported(UsbDevice usbDevice)
{
	if ( usbDevice == null )
	{
		return false;
	}
	
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

//
// Even more optimized version below
//

import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbConstants;
public boolean isSupported(UsbDevice ud)
{
	if ( ud != null )
	{
		switch ( ud.getDeviceClass() )
		{
			case UsbConstants.USB_CLASS_CSCID:
				return true;
				
			case UsbConstants.USB_CLASS_PER_INTERFACE:
				for ( int i = 0; i < ud.getInterfaceCount(); i++ )
				{
					if ( ud.getInterface(i).getInterfaceClass() == UsbConstants.USB_CLASS_CSCID )
					{
						return true;
					}
				}
				
			default:
				/* Nothing to do here */
		}
	}
	
    return false;
}


