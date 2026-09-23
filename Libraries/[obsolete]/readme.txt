
----------------------------------
| ACS Smart Card Android Library |
|   Advanced Card Systems Ltd.   |
----------------------------------

Version:      1.1.8
Release Date: 25/11/2025

Old versions:
 - 1.1.1 <-> 1.1.5.8

New versions:
 - 1.1.6 <-> 1.1.8

---------------------
| Supported Readers |
---------------------

VID  PID  Reader
---- ---- ---------------------------
072F B301 ACR32U-A1
072F B304 ACR3201-A1
072F B305 ACR3201
072F 8300 ACR33U-A1
072F 8302 ACR33U-A2
072F 8307 ACR33U-A3
072F 8301 ACR33U
072F 9000 ACR38U
072F 90CF ACR38U-SAM
072F 90CC ACR38U-CCID/ACR100-CCID
072F 90D8 ACR3801
072F B100 ACR39U
072F B500 ACR39U BL
072F B101 ACR39K
072F B102 ACR39T
072F B103 ACR39F
072F B104 ACR39U-SAM
072F B10C ACR39U-U1
072F B113 ACR39U-W1 (Top)
072F B114 ACR39U-W1 (Edge)
072F B116 ACR39U-W1 (Top)
072F B117 ACR39U-W1 (Edge)
072F B000 ACR3901U
072F B501 ACR40T
072F B504 ACR40T BL
072F B506 ACR40U
072F B505 ACR40U BL
072F 90D2 ACR83U-A1
072F 2011 ACR88U
072F 8900 ACR89U-A1
072F 8901 ACR89U-A2
072F 8902 ACR89U-A3
072F 1205 ACR100I
072F 1204 ACR101
072F 1206 ACR102
072F 2200 ACR122U/ACR122U-SAM/ACR122T
072F 2266 ACR1333U
072F 2214 ACR1222U-C1
072F 1280 ACR1222U-C3
072F 2207 ACR1222U-C6
072F 222B ACR1222U-C8
072F 2206 ACR1222L-D1
072F 2225 ACR1222L
072F 222E ACR123U-A1
072F 2237 ACR123U
072F 2231 ACM123S1-Z1
072F 2203 ACR125
072F 221A ACR1251U-A1
072F 2229 ACR1251U-A2
072F 225F ACR1251T
072F 2260 ACR1251U-M1 (FARSAFE)
072F 2218 ACR1251U-C (SAM)
072F 221B ACR1251U-C
072F 2232 ACR1251UK
072F 2242 ACR1251U-C1
072F 2238 ACR1251U-C9
072F 224F ACM1251U-Z2
072F 223B ACR1252U-A1
072F 223E ACR1252U-A2
072F 2244 ACR1252U-A1 (PICC)
072F 2259 ACR1252U-A1 (IMP)
072F 223D ACR1252U Bootloader
072F 226B ACR1252U-MW/MV
072F 226A ACR1252U-MW/MV BL
072F 223F ACR1255U-J1
072F 2250 ACR1255U-J1 BL
072F 2239 ACR1256U
072F 2211 ACR1261U-C1
072F 2252 ACR1261U-A
072F 2100 ACR128U
072F 2224 ACR1281U-C1
072F 220F ACR1281U-C2 (qPBOC)
072F 2223 ACR1281U    (qPBOC)
072F 2208 ACR1281U-C3 (qPBOC)
072F 0901 ACR1281U-C4 (BSI)
072F 220A ACR1281U-C5 (BSI)
072F 2215 ACR1281U-C6
072F 2220 ACR1281U-C7
072F 2233 ACR1281U-K (PICC)
072F 2234 ACR1281U-K (PICC + ICC)
072F 2235 ACR1281U-K (PICC + ICC + SAM)
072F 2236 ACR1281U-K9 (PICC + ICC + 4SAM)
072F 2213 ACR1283L-D1
072F 222C ACR1283L-D2
072F 2258 ACR1311U-N1
072F 2303 ACR1552U-M1
072F 2308 ACR1552U-M2
072F 2302 ACR1552U BL
072F 2307 ACM1552U-ZW
072F 2306 ACM1552U-ZW BL
072F 2401 ACR1552U-MW
072F 2400 ACR1552U-MW BL
072F 230A ACR1555U
072F 2309 ACR1555U BL
072F 2301 ACR1581U-C1
072F 2300 ACR1581U-C1 BL
072F B308 AFD03
072F B30A AFD03-A1
072F B309 AFD03-A1 BL
072F 224A AMR220-C
072F 8201 APG8201-A1
072F 8206 APG8201-B2
072F 9006 CryptoMate
072F 90DB CryptoMate64
072F B200 CryptoMate T1
072F B106 CryptoMate T2
072F B112 CryptoMate EVO

-----------------------
| System Requirements |
-----------------------

Android 3.1 (Honeycomb) or later (API level 12+)

-----------
| History |
-----------

v1.1.8 (25/11/2025)
- Add the following readers support:
  ACR1255U-J1 BL
  ACR1552U-MW
  ACR1552U-MW BL
  AFD03
  AFD03-A1
  AFD03-A1 BL
- Migrate the build to version catalogs.

v1.1.7 (16/2/2024)
- Add the following readers support:
  ACM1552U-ZW
  ACM1552U-ZW BL
  ACR1555U
  ACR1555U BL
- Update :material to 1.11.0 in build.gradle.

v1.1.6 (21/12/2023)
- Convert the project to Android Studio.
- Provide consumer proguard files in build.gradle.
- Clear internal buffers for sensitive data.
- Enable code shrinking, obfuscation and optimization in build.gradle.
- Reduce the timeout for USB read error to 100 ms.

v1.1.5.10 (7/7/2023)
- Add the following readers support:
  ACR40U
  ACR40U BL
  ACR1552U-M1
  ACR1552U-M2
  ACR1552U BL

v1.1.5.9 (11/5/2023)
- Add the following readers support:
  ACR1581U-C1
  ACR1581U-C1 BL
- Allow the reader without interrupt pipe in open() method of Reader class.

v1.1.5.8 (31/3/2023)
- Add the following readers support:
  ACR39U BL
  ACR39U-W1 (Top)
  ACR39U-W1 (Edge)
  ACR40T
  ACR40T BL
  ACR1252U-MW/MV
  ACR1252U-MW/MV BL

v1.1.5.7 (21/6/2022)
- Add the following readers support:
  ACR39U-W1 (Top)
  ACR39U-W1 (Edge)

v1.1.5.6 (28/10/2021)
- Add the following readers support:
  ACR1333U

v1.1.5.5 (25/5/2021)
- Remove 1 ms delay.
- Fix T=1 sequence number issue after IFS response.

v1.1.5.4 (8/2/2021)
- Restore ACR39U maximum data rate.
- Delay 1 ms before sending a data block in T=1.

v1.1.5.3 (29/1/2021)
- Adjust ACR39U maximum data rate to 412903 bps.

v1.1.5.2 (26/1/2021)
- Add CardTimeoutException class.
- Handle CardTimeoutException as invalid T=1 packet.
- Throw UnresponseCardException if CardTimeoutException occurred in powering on
  the ICC on the CCID readers.

v1.1.5.1 (19/7/2019)
- Add the following readers support:
  ACR1252U Bootloader

v1.1.5 (25/6/2019)
- Add the following readers support:
  ACR1251T
  ACR1251U-M1 (FARSAFE)
  ACR3201
  CryptoMate EVO
- Fix null reader name problem in Reader class.
- Fix ArrayIndexOutOfBoundsException and InsufficientBufferException for
  extended APDU in transmit() method of Reader class.
- Enable ICC extended APDU for ACR1281U-C1 >= v526.

v1.1.4 (18/1/2018)
- Add the following readers support:
  ACR1261U-A
  ACR1311U-N1
  ACR1252U-A1 (IMP)
  AMR220-C
  APG8201-B2
- Try 10 times for USB read error.
- Set default PTS if PC_to_RDR_SetParameters failed in setProtocol() method of
  Reader class.
- Fix incorrect slot number for reader with multiple CCID interfaces.
- Fix missing PCB in T1 IFS response.
- Fix missing PCB in T1 RESYNCH request.
- Enable specific I/O controls and TLV properties for APG8201-B2 in control()
  method of Reader class.
- Process IOCTL_IFD_DISPLAY_PROPERTIES, IOCTL_GET_KEY for APG8201-B2 and
  IOCTL_WRITE_DISPLAY for APG8201-B2 in control() method of Reader class.
- Throw communication error in processing ACR83 specific I/O controls in
  control() method of Reader class.

v1.1.3 (31/3/2016)
- Add the following readers support:
  ACR1251U-C9
  ACR1255U-J1
  ACR3201-A1
  ACM1251U-Z2
  ACR39U-U1
- Update the target to Android 5.1.1.
- Remove WTX delay in transmit() method of Reader class.
- Fix incorrect Fl/Dl value in setProtocol() method of Reader class.
- Allow non-CCID interfaces in open() method of Reader class.
- Set card present if it is SAM slot.
- Force to claim the interface if it failed in open() method of Reader class.
- Read the card state from the interrupt endpoint asynchronously.
- Trigger the state change on the thread.

v1.1.2 (30/6/2014)
- Fix a bug that the card state of SAM slot is changed to absent if power down
  action is applied.
- Add the following readers support:
  ACR32U-A1
  ACR38U
  ACR38U-SAM
  ACR3901U
  ACR1222L
  ACR123U-A1
  ACR123U
  ACM123S1-Z1
  ACR1251U-C (SAM)
  ACR1251U-C
  ACR1251UK
  ACR1251U-C1
  ACR1252U-A1
  ACR1252U-A2
  ACR1252U-A1 (PICC)
  ACR1256U
  ACR1261U-C1
  ACR1281U-K (PICC)
  ACR1281U-K (PICC + ICC)
  ACR1281U-K (PICC + ICC + SAM)
  ACR1281U-K9 (PICC + ICC + 4SAM)
  CryptoMate
  CryptoMate T1
  CryptoMate T2
- Do not fall through to cold reset when doing the warm reset.
- Change the delay of cold reset to 10 ms.
- Set the parameters if the card state is specific in power() method of Reader
  class.
- Retry the warm reset if it failed.
- Handle the time extension request from reader.
- Exit if the default PTS values is tried in setProtocol() method of Reader
  class.
- Update the target to Android 4.4.

v1.1.1 (12/7/2012)
- Add the following readers support:
  ACR39U
  ACR39K
  ACR39T
  ACR39F
  ACR39U-SAM
  ACR88U
  ACR89U-A1
  ACR89U-A2
  ACR89U-A3
  ACR125
  ACR1251U-A1
  ACR1251U-A2
  ACR1281U-C2 (qPBOC)
  ACR1281U    (qPBOC)
  ACR1281U-C3 (qPBOC)
  ACR1281U-C4 (BSI)
  ACR1281U-C5 (BSI)
  ACR1281U-C6
  ACR1281U-C7
  ACR1283L-D1
  ACR1283L-D2
  CryptoMate64

v1.1.0 (18/5/2012)
- Add the following readers support:
  ACR83U-A1
  APG8201-A1
- Add utility classes Features, PinVerify, PinModify, PinProperties,
  TlvProperties and ReadKeyOption to support PC/SC 2.0 Part 10 and
  ACR83/APG8201 specific controls.
- Handle PC/SC 2.0 Part 10 and ACR83/APG8201 specific controls in
  Reader.control().

v1.0.0 (30/12/2011)
- New Release

