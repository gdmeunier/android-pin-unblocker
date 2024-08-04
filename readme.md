# Android PIN Unblocker

A simple Android app written in [Basic4Android](https://www.b4x.com/b4a.html).

Its purpose is to generate **smartcard** unblock codes using your *Admin key* and your phone instead of requiring a computer.

The common **SLE4442** cards are memory cards only and lack a built-in processor, and thus are for data storage only.

Real smartcards are the ones such as the Gemalto IDPrime 930, YubiKey, JavacardOS *[...]*.
Its Windows equivalent would be the [Gemalto Response Code calculator](https://supportportal.thalesgroup.com/csm?id=kb_article_view&sysparm_article=KB0017162).

# Features

**Android PIN Unblocker** has a very simple set of features, it doesn't do anything else than generating the *Response Code*.

If you need to generate *sha256*, *sha384* or *sha512* hashes for your *Admin key* then you can use a different existing Android application to generate it.

## Scan QR codes (for Request Code)

I added the ability to scan QR codes in **Android PIN Unblocker** using the below Basic4Android library:
- [NewQRCodeReaderView](https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013)

![You can click the QR code button to scan the Request Code.](https://i.postimg.cc/kD848BPn/7-ability-to-scan-request-qr-code.png)

It's used alongside a PC application such as **[CodeTwo QR Code Reader & Generator](https://www.codetwo.com/freeware/qr-code-desktop-reader/)** to do the card unblocking more efficiently.

You can later install an agent program into e.g. employees' computers to type the unblock code with the Android *Share To* functionality.

## Generate the Unblock Code

![Generating the smartcard unblock code.](https://i.postimg.cc/sBBz5z2T/1-generate-unblock-key.png)

On a real Android phone the display has an higher resolution and thus you'll have more space to type the *Admin key* than on this screenshot.

Here you can type the *Request Code* and also choose to hide the *Admin key* with the checkbox below it.

## Hide & reveal the Admin key

![Unhiding the previously entered Admin key.](https://i.postimg.cc/rdvkJH0M/2-unhide-admin-key.png)

This application has been intended for situations where you're entering unblock codes for employees or people who stand-by next to you.

You can thus now easily type your *Admin key* once, then hide it with the appropriate checkbox below it.

This way nobody accidentally grabs a picture of your *Admin key* while unblocking your employees' smartcards.

## Share the Response Code

![Sharing the Response Code with the native Android Intent chooser.](https://i.postimg.cc/fSsh40fP/3-share-response-code.png)

You can see on the previous screenshot a Share To button next to the generated *Response Code*, which will pop the native Android Intent chooser.

From there you can share the *Response Code* over to Telegram, Signal, WhatsApp, SMS, and so on.

## Share Admin Key to the App

![Sharing an Admin key text to the App (Android PIN Unblocker).](https://i.postimg.cc/140QGJ91/4-share-admin-key-to-unblocker.png)

Here you can see that it's possible to write your *Admin key* on a native Android note-taking application then select the text, which you can directly share to **Android PIN Unblocker**.

That's also where you can generate *Admin key* hashes yourself with a different Android app then share the generated hash to **Android PIN Unblocker**.

The App automatically verifies whether the shared text is a valid *42* to *48* digits string and is made of *0-9 A-F* characters only (*hex chars*).
The App discards shared texts that are invalid *Admin keys* and will simply behave as if you launched it yourself.

*I decided to allow 42-digits Admin keys since that's what some smartcard manufacturers actually use.*

## Prevent disclosing Admin keys

![Admin keys shared to the App cannot be unhidden.](https://i.postimg.cc/Q91rnq15/5-admin-key-shared-to-unblocker.png) ![Admin keys shared to the App stay hidden after generating unblock codes.](https://i.postimg.cc/n91fncdh/6-unblock-code-generated-after-sharing-admin-key.png)

Whenever you share an Admin key to the app instead of copy-pasting it yourself, the *Hide Admin Key* checkbox becomes disabled and you cannot unhide it.

This feature prevents accidental disclosure of your *Admin key* while unblocking cards on your employees' computers.

> Make sure to verify whether your Android ROM doesn't have a clipboard history prior to copy-pasting Admin keys (Samsung & Huawei have one).

> If clipboard history cannot be disabled then use a different keyboard application instead of your Android built-in one.

# License

Well I don't care about legalese anyway but let's pick **GNU GPLv3 (or later version)** since my friends at the [Free Software Foundation](https://www.gnu.org/proprietary/proprietary.html) recommend it.

**Basic4Android** also allows completely free usage of their IDE for both commercial and non-commercial purposes so it should be OK.
