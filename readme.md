# Android PIN Unblocker

A simple Android app written in [Basic4Android](https://www.b4x.com/b4a.html).

Its purpose is to generate **smartcard** unblock codes using your *Admin Key* and your phone instead of requiring a computer.

The common **SLE4442** cards are memory cards only and lack a built-in processor, and thus are for data storage only.

Real smartcards are the ones such as the Gemalto IDPrime 930, YubiKey, JavacardOS *[...]*.
Its Windows equivalent would be the [Gemalto Response Code calculator](https://supportportal.thalesgroup.com/csm?id=kb_article_view&sysparm_article=KB0017162).

# Features

**Android PIN Unblocker** has a very simple set of features, it cans generate the *Response Code*, get the *Request Code* from QR code and hash text using *sha256* or *sha512*.

![Main application screen.](https://todo/)

## Generate the Unblock Code

![Generating the smartcard response code.](https://todo/)

Here you can type the *Request Code* and also choose to hide the *Admin Key* with the checkbox below it.

## Hide & reveal the Admin Key

![Main App screen with visible Admin Key.](https://todo/) ![Hiding the previously entered Admin Key.](https://todo/)

This application has been intended for situations where you're entering unblock codes for employees or people who stand-by next to you.

You can thus now easily type your *Admin Key* once, then hide it with the appropriate checkbox below it.

This way nobody accidentally grabs a picture of your *Admin Key* while unblocking your employees' smartcards.

## Scan QR Code for Request Code

I added the ability to scan QR codes in **Android PIN Unblocker** using the below Basic4Android library:
- [NewQRCodeReaderView](https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013)

![You can click the QR code button to scan the Request Code.](https://todo/)

It's used alongside a PC application such as **[CodeTwo QR Code Reader & Generator](https://www.codetwo.com/freeware/qr-code-desktop-reader/)** to do the card unblocking more efficiently.

The *Request Code* then automatically gets input in the appropriate field once detected.

## Generate Admin Key text hashes

![Generating the Admin Key hash from text is possible inside the App.](https://todo/) ![Generated Admin Key hash inside the App.](https://todo/)

It's possible with **Android PIN Unblocker** (starting with version 3) to directly generate hashes within the App instead of having to write it in other ones.

The possible choices are currently *sha256* and *sha512* only.

The generated hash will automatically replace the previous *Admin Key* text.

## Share the Response Code

![Sharing the Response Code with the native Android Intent chooser.](https://todo/)

You can see on the previous screenshots a Share To button next to the generated *Response Code*, which will pop the native Android Intent chooser.

From there you can share the *Response Code* over to Telegram, Signal, WhatsApp, SMS, and so on.

Otherwise you could type the *Response Code* automatically on e.g. employees' computers with an agent program, using the Android *Share To* functionality.

*You can also generally type passwords & sensitive input material using your phone and an [USB InputStick](http://inputstick.com/) device, which is hardware and works for full-disk encryption as well. It has a KeePass2Android plugin, for example.*

## Share Admin Key to the App

![Sharing an Admin Key text to the App (Android PIN Unblocker).](https://todo/) ![Shared Admin Key is now unrevealable in the App.](https://todo/)

Here you can see that it's possible to write your *Admin Key* on a native Android note-taking application then select the text, which you can directly share to **Android PIN Unblocker**.

That's also where you can generate *Admin Key* hashes yourself with a different Android app then share the generated hash to **Android PIN Unblocker**.

The App automatically verifies whether the shared text is a valid *32* or *48* digits string and is made of *0-9 A-F* characters only (*hex chars*).
The App discards shared texts that are invalid *Admin Keys* and will simply behave as if you launched it yourself.

*I decided to allow 32-digits Admin Keys since that's what some smartcard manufacturers actually use (AES challenge/response instead of 3DES).*

## Prevent disclosing Admin Keys

![Admin Keys shared to the App cannot be unhidden.](https://todo/) ![Admin Keys hashed by long-pressing the hashing buttons are unrevealable as well.](https://todo/)

Whenever you share an Admin Key to the app instead of copy-pasting it yourself, the *Hide Admin Key* checkbox becomes disabled and you cannot unhide it.

This feature prevents accidental disclosure of your *Admin Key* while unblocking cards on your employees' computers.

> Make sure to verify whether your Android ROM doesn't have a clipboard history prior to copy-pasting Admin Keys (Samsung & Huawei have one).

> If clipboard history cannot be disabled then use a different keyboard application instead of your Android built-in one.

You can also type your original text in the Admin Key field and directly generate a *sha256* or *sha512* hash from within the app, by long-pressing the hashing buttons.

Long-pressing the SHA-256 or SHA-512 buttons actually generated the hash but also makes them unrevealable afterwards (single-click generates the hash normally without hiding it).

# License

Well I don't care about legalese anyway but let's pick **GNU GPLv3 (or later version)** since my friends at the [Free Software Foundation](https://www.gnu.org/proprietary/proprietary.html) recommend it.

**Basic4Android** also allows completely free usage of their IDE for both commercial and non-commercial purposes so it should be OK.
