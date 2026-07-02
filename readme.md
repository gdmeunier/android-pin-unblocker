
<p align="center">
	<img src="./icon.png" width="128" height="128"/>
</p>

# Android PIN Unblocker

A simple Android app written in [Basic4Android](https://www.b4x.com/b4a.html) (preferably [version 12.50](https://web.archive.org/web/20230719022719/https://www.b4x.com/android/files/B4A.exe) with its [older resources](https://web.archive.org/web/20240529212314/https://www.b4x.com/b4a.html) and the [B4X Help Viewer](https://www.b4x.com/android/forum/threads/b4x-help-viewer.46969/)).

Its purpose is to generate **smartcard** unblock codes using your *Admin Key* and your phone instead of requiring a computer.

The common **SLE4442** cards are memory cards only and lack a built-in processor, and thus are for data storage only.

Real smartcards are the ones such as the Gemalto IDPrime 930, YubiKey, JavacardOS *[...]*.
Its Windows equivalent would be the [Gemalto Response Code calculator](https://supportportal.thalesgroup.com/csm?id=kb_article_view&sysparm_article=KB0017162).

# Features

**Android PIN Unblocker** has a very simple set of features, it cans generate the *Response Code*, get the *Request Code* from QR code and hash text using *sha256* or *sha512*.

## Generate the Unblock Code

![Main application screen.](/Screenshots/1-main-app-screen.png) ![Generating the smartcard response code.](/Screenshots/3-generated-response-code.png)

Here you can type the *Request Code* and also choose to hide the *Admin Key* with the checkbox below it.

The supported algorithms for unblock code generation are 3DES, 2DES, AES-128 & AES-256.

The algorithm to be used is automatically determined by the Application based on your Admin key and Challenge code.

## Hide & reveal the Admin Key

![Main App screen with visible Admin Key.](/Screenshots/1-main-app-screen.png) ![Hiding the previously entered Admin Key.](/Screenshots/2-admin-key-hide.png)

This application has been intended for situations where you're entering unblock codes for employees or people who stand-by next to you.

You can thus now easily type your *Admin Key* once, then hide it with the appropriate checkbox below it.

This way nobody accidentally grabs a picture of your *Admin Key* while unblocking your employees' smartcards.

## Scan QR Code for Request Code

I added the ability to scan QR codes in **Android PIN Unblocker** using the below Basic4Android library:
- [NewQRCodeReaderView](https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013)

![You can click the QR code button to scan the Request Code.](/Screenshots/4-scan-qr-request-code.png)

It's used alongside a PC application such as **[CodeTwo QR Code Reader & Generator](https://www.majorgeeks.com/files/details/codetwo_qr_code_desktop_reader_generator.html)** to do the card unblocking more efficiently.

The *Request Code* then automatically gets input in the appropriate field once detected.

## Generate Admin Key text hashes

![Generating the Admin Key hash from text is possible inside the App.](/Screenshots/5-builtin-hashing-facility.png) ![Generated Admin Key hash inside the App.](/Screenshots/6-generated-admin-key-hash.png)

It's possible with **Android PIN Unblocker** (starting with version 3) to directly generate hashes within the App instead of having to write it in other ones.

The possible choices are currently *sha256* and *sha512* only.

The generated hash will automatically replace the previous *Admin Key* text.

## Share the Response Code

![Sharing the Response Code with the native Android Intent chooser.](/Screenshots/7-share-response-code.png)

You can see on the previous screenshots a Share To button next to the generated *Response Code*, which will pop the native Android Intent chooser.

From there you can share the *Response Code* over to Telegram, Signal, WhatsApp, SMS, and so on.

Otherwise you could type the *Response Code* automatically on e.g. employees' computers with an agent program, using the Android *Share To* functionality.

*You can also generally type passwords & sensitive input material using your phone and an [USB InputStick](https://inputstick.com/) device, which is hardware and works for full-disk encryption as well. It has a KeePass2Android plugin, for example.*

## Share Admin Key to the App

![Sharing an Admin Key text to the App (Android PIN Unblocker).](/Screenshots/8-share-admin-key-to-app.png) ![Shared Admin Key is now unrevealable in the App.](/Screenshots/9-shared-admin-key-unrevealable.png)

Here you can see that it's possible to write your *Admin Key* on a native Android note-taking application then select the text, which you can directly share to **Android PIN Unblocker**.

That's also where you can generate *Admin Key* hashes yourself with a different Android app then share the generated hash to **Android PIN Unblocker**.

The App automatically verifies whether the shared text is a valid *32*, *48* or *64* digits string and is made of *0-9 A-F* characters only (*hex chars*).
The App discards shared texts that are invalid *Admin Keys* and will simply behave as if you launched it yourself.

*I decided to allow 32- & 64-digits Admin Keys since that's what some smartcard manufacturers actually use (AES challenge/response instead of 3DES).*

## Prevent disclosing Admin Keys

![Admin Keys shared to the App cannot be unhidden.](/Screenshots/9-shared-admin-key-unrevealable.png) ![Admin Keys hashed by long-pressing the hashing buttons are unrevealable as well.](/Screenshots/10-unrevealable-hash-on-long-press.png)

Whenever you share an Admin Key to the app instead of copy-pasting it yourself, the *Hide Admin Key* checkbox becomes disabled and you cannot unhide it.

This feature prevents accidental disclosure of your *Admin Key* while unblocking cards on your employees' computers.

> [!CAUTION]
> Make sure to verify that your Android ROM doesn't have a clipboard history feature prior to copy-pasting Admin Keys, Samsung & Huawei ROMs have one.
>
> If clipboard history cannot be disabled on your phone then don't use the clipboard at all, or use a password manager with a built-in secure Keyboard (e.g. [KeePassDX](https://apt.izzysoft.de/fdroid/index/apk/com.kunzisoft.keepass.libre?repo=archive) with its *Magic Keyboard*, recommended version 3.2.0 for older devices).

You can also type your original text in the Admin Key field and directly generate a *sha256* or *sha512* hash from within the app, by long-pressing the hashing buttons.

Long-pressing the SHA-256 or SHA-512 buttons actually generates the hash but also makes them unrevealable afterwards (single-click generates the hash normally without hiding it).

# License

Well I don't care about legalese anyway but let's pick **GNU GPLv3 (or later version)** since my friends at the [Free Software Foundation](https://www.gnu.org/proprietary/proprietary.html) recommend it.

**Basic4Android** also allows completely free usage of their IDE for both commercial and non-commercial purposes so it should be OK.

And also the additional allowances below for this App which are useful for use in restricted & sensitive environments.

Action Type | Status | Reason for Status
-- | :-: | --
Modify the App's package name | Allowed | Security / Hardening
Sign the App with a different key | Allowed | Security / Hardening
Compile the App from source | Allowed | Security / Hardening

# Legalese

Perhaps oneday if somebody randomly stumbles upon this App and likes it, they might actually care about legalese before using it.\
So here's below a list of assets that have previously been, or are currently being used, for this App.

Asset Name | Author | License | Commercial Use
-- | :-: | :-: | :-: |
[Basic4Android](https://www.b4x.com/b4a.html) | Anywhere Software | [Apache 2.0](https://github.com/AnywhereSoftware/B4A/blob/master/LICENSE) | Allowed
[Color Quantizer](https://x128.ho.ua/color-quantizer.html) | x128 | [No License](https://choosealicense.com/no-permission/) | Allowed
[7-Zip](https://www.7-zip.org/) | Igor Pavlov | [LGPL 2.1](https://www.7-zip.org/license.txt) | Allowed
[MyApkTool Pro](https://github.com/alisakkaf/MyApkTool-Pro) | Ali Sakkaf | [MIT License](https://github.com/alisakkaf/MyApkTool-Pro/blob/main/LICENSE) | Allowed
[Devices secure card Icon](https://www.iconarchive.com/show/oxygen-icons-by-oxygen-icons.org/Devices-secure-card-icon.html) | Oxygen Team | [LGPL 3.0](https://www.gnu.org/licenses/lgpl-3.0.html) | Allowed
[Credit card Icon](https://www.iconarchive.com/show/shop-icons-by-newidols.ru/credit-card-icon.html) | Newidols | [Attribution](https://www.iconarchive.com/icons/newidols.ru/shop/License.txt) | Allowed
[Very Basic Unlock Icon](https://www.iconarchive.com/show/windows-8-icons-by-icons8/Very-Basic-Unlock-icon.html) | Icons8 | [Attribution](https://icons8.com/license/) | Allowed
