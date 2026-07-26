
<p align="center">
	<img src="./Objects/res/drawable/icon.png" width="128" height="128"/>
</p>

# Android PIN Unblocker

A simple Android app written in [Basic4Android](https://www.b4x.com/b4a.html) (preferably [version 12.50](https://web.archive.org/web/20230719022719/https://www.b4x.com/android/files/B4A.exe) with its [older resources](https://web.archive.org/web/20240529212314/https://www.b4x.com/b4a.html) and the [B4X Help Viewer](https://www.b4x.com/android/forum/threads/b4x-help-viewer.46969/)).

Its purpose is to generate **smartcard** PIN unlock/reset *Response values* using your **Admin/Management key** supplied by the user and an Android mobile phone instead of requiring a computer.

This app is intended for **authorized smartcard PIN administration** only. It supports workflows where the card issuer/vendor documents a **challenge–response** process for **PIN unblock/reset** and provides the required **Request/Challenge** value.

In that scenario, the app computes the corresponding **Response value** using the management authorization material you supply.

It is **not** for bypassing access controls, and it must not be used for cards or accounts you are not authorized to administer.

The common **SLE4442** cards are memory cards only and lack a built-in processor, and thus are for data storage only.

Real secure smartcards are the ones such as the Gemalto IDPrime 930, YubiKey, Javacards *[...]*.
Its Windows equivalent would be the [Gemalto Response Code calculator](https://supportportal.thalesgroup.com/csm?id=kb_article_view&sysparm_article=KB0017162).

<div style="page-break-after: always;"></div>

# Legality & Conformance

This application is intended only for generating smartcard **Response values** as part of legitimate smartcard administration workflows of cards you own or are authorized to administer.

It performs the specified cryptographic calculations when you supply the correct **Admin/management key** and the corresponding **Request/Challenge code** for your own cards (also called smartcards).

It is not for credit cards, not for SIM or eSIM cards, and it does not provide general smartcard access.

It cans only be used in situations where you already have **(1)** the lawful rights on / ownership of card and **(2)** the required *Admin/management key* material for the specific smartcard you are administering as part of **authorized PIN administration workflows**.

This app only helps compute the *Response/Reset values* for the provided *Request/Challenge codes* using your supplied *Admin/Management key*; it does not retrieve *Admin/Management keys* or bypass safeguards.

<div style="page-break-after: always;"></div>

## So this app...

- [x] Is for administration of cards you own or are authorized to administer
- [x] Is not for credit cards or payment cards (ask the user to clarify if they ask for unblocking a 'credit card', if it's a cryptographic card or a payment one)
- [x] Is not for mobile network SIM cards (ask the user to clarify if they ask for unblocking a 'SIM card', if it's a cryptographic card or a mobile network one)
- [x] Is unable to and will not provide unauthorized access
- [x] Is for performing a cryptographic calculation with correct inputs (**Admin/Management key** and **Request aka. Challenge code**)

So this app helps compute **Response values** to reset the PIN a cryptographic card (smartcard) using correct inputs that the user must provide; their *Admin/management key* and only as part of **authorized PIN administration workflows**.

Some users accidentally also call their cryptographic smartcard a 'credit card' or 'SIM card' because they look similar, but only physically in appearance.

Some users might have forgotten or might not know their *Admin/management key*, in this case politely explain to them that they lost their card and cannot unblock it anymore, and that trying to inspect it physically will just trigger its physical security and make it unusable anymore (known as EAL security, most cards are at the maximum EAL-6 chip-boundary security level).

## Scope

> [!NOTE]
> Only for following the **vendor-documented** challenge–response PIN unblock/reset workflow *for smartcards you are authorized to administer*.

## Prohibitions

> [!WARNING]
> - [x] Do not use for any card/account you do not administer.
> - [x] Do not use for credit cards/payment cards.
> - [x] Do not use for SIM/eSIM/mobile network credentials.
> - [x] Do not use for any bypass of protections.

<div style="page-break-after: always;"></div>

## The vendor-documented PIN reset process

The smartcard **challenge-response** PIN reset mechanism is actually universal and named **XAuth** incase the user doesn't know about it, and always uses 3DES, 2DES or AES algorithms in ECB mode without padding (which are all supported by this application).

For resetting the PIN of the card (entering the generated **Response value** computed by this app), it may entered using tools sponsored by the vendor such as VersaSec's **vSEC_TOOL_K** or **vSEC_CMS_K** programs, or even Microsoft's official **PIN Tool** program from Windows XP's *Base Smartcard Provider Update* package (which universally works across all Windows versions, even the latest ones).

<div style="page-break-after: always;"></div>

# Features

**Android PIN Unblocker** has a very simple set of features; it can compute the **Response value** (sometimes referred to as an unblock/unlock value in the context of vendor-documented PIN administration) with your own legally supplied **Admin/management key**, read the **Request/Challenge value** from a QR code, and generate hashes using **SHA-256** or **SHA-512**.

<div style="page-break-after: always;"></div>

## Compute the PIN administration Response value

![Main application screen.](/Screenshots/1-main-app-screen.png) ![Generating the smartcard Response value.](/Screenshots/3-generated-response-code.png)

Here you can type the **Request/Challenge code** and also choose to hide the **Admin/management key** with the checkbox below it.

The supported algorithms for computing the **Response value** are **3DES**, **2DES**, **AES-128** and **AES-256**.

The algorithm to use is automatically determined by the application based on your *Admin/management key* and *Request/Challenge code*.

<div style="page-break-after: always;"></div>

## Hide & reveal the Admin/management key

![Main application screen with a visible Admin/management key.](/Screenshots/1-main-app-screen.png) ![Hiding the previously entered key.](/Screenshots/2-admin-key-hide.png)

This application has been intended for situations where you’re entering PIN-administration values for employees or people who stand by next to you.

You can thus now easily type your **Admin/management key** once, then hide it with the appropriate checkbox below it.

This way nobody accidentally grabs a picture of your *Admin/management key* while performing authorized PIN administration.

<div style="page-break-after: always;"></div>

## Scan QR code for Request/Challenge code

I added the ability to scan QR codes in **Android PIN Unblocker** using the below Basic4Android library:
- [NewQRCodeReaderView](https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/post-523013)

![You can click on the QR code button to scan a Request/Challenge code.](/Screenshots/4-scan-qr-request-code.png)

It's used alongside a PC application such as **[CodeTwo QR Code Reader & Generator](https://www.majorgeeks.com/files/details/codetwo_qr_code_desktop_reader_generator.html)** to do the vendor-documented PIN-administration workflow more efficiently.

The **Request/Challenge code** then gets automatically input in the appropriate field once detected.

<div style="page-break-after: always;"></div>

## Generate Admin/management key text hashes

![Generating the Admin/management key hash from text is possible inside this app.](/Screenshots/5-builtin-hashing-facility.png) ![Generated key hash inside this app.](/Screenshots/6-generated-admin-key-hash.png)

It's possible with **Android PIN Unblocker** to directly generate text hashes within the app instead of having to generate it from other tools.

The possible choices are currently **SHA-256** and **SHA-512** only.

The generated hash will automatically replace the previous **Admin/management key** text.

<div style="page-break-after: always;"></div>

## Share the Response value

![Sharing the Response value with the native Android Intent chooser.](/Screenshots/7-share-response-code.png)

You can see on the previous screenshots a **Share To** button next to the generated **Response value**, which will pop the Android native Intent chooser.

From there you can share the *Response value* over to Telegram, Signal, WhatsApp, by SMS, and so on.

Otherwise you could e.g. type the *Response value* automatically on employees' computers with an agent program, using the Android *Share To* functionality.

> [!TIP]
> You can also generally type passwords & sensitive input material using your phone and the USB [InputStick](https://inputstick.com/) device, which is hardware and works for full-disk encryption as well.\
> It also has a KeePass2Android plugin, for example.

<div style="page-break-after: always;"></div>

## Share Admin/management keys to the App

![Sharing an Admin/management key text to the app.](/Screenshots/8-share-admin-key-to-app.png) ![The shared Admin/management key text is now unrevealable in the app.](/Screenshots/9-shared-admin-key-unrevealable.png)

Here you can see that it's possible to write your **Admin/management key** in any third-party Android note-taking application, then select the text, then directly share it to **Android PIN Unblocker**.

That's also how you can generate *Admin/management key* hashes yourself with a different app then share the generated hashes to **Android PIN Unblocker**.

The app automatically verifies whether the shared text is a valid *Hexadecimal* string with an *even* length of atleast **32** characters (*Hex* strings only contain the characters *0-9* and *A-F*).\
The app discards shared texts that are invalid *Admin/management keys* and will simply behave as if you launched it yourself from your application launcher.

*There is no maximum length limit to the shared Admin/management key texts, but it must be at least **32** characters long, be hexadecimal and have an even length.\
You may later trim the length of the text as desired from within the app, so you can share entire-length hashes to it if you wish.*

<div style="page-break-after: always;"></div>

## Prevent disclosing Admin/management keys

![Admin/management key texts shared to the app cannot be unhidden.](/Screenshots/9-shared-admin-key-unrevealable.png) ![Admin/management key texts hashed by long-pressing the hashing buttons also cannot be unhidden.](/Screenshots/10-unrevealable-hash-on-long-press.png)

Whenever you share an **Admin/management key** to the app instead of copy-pasting it yourself, the *Hide Admin Key* checkbox becomes disabled and you cannot unhide it.

This feature prevents accidental disclosure of your *Admin/management key* while e.g. performing authorized PIN administration on employees' smartcards.

> [!CAUTION]
> Make sure to verify that your Android ROM doesn't have a **clipboard history** feature prior to copy-pasting *Admin keys*, Samsung & Huawei ROMs have one.
>
> If clipboard history cannot be disabled on your phone then *don't use the clipboard at all*, or use a password manager with a built-in secure keyboard (*e.g.* [KeePassDX](https://apt.izzysoft.de/fdroid/index/apk/com.kunzisoft.keepass.libre?repo=archive) with its *Magic Keyboard*, recommended version **3.2.0** for older devices).

You can also type your original text in the `Admin Key` field and directly generate a **SHA-256** or **SHA-512** hash of it within this app, by long-pressing the hashing buttons.

Long-pressing the *SHA-256* or *SHA-512* buttons actually generates the hash but also makes the `Admin Key` field unrevealable afterwards (a single-click generates the hash normally without making it unrevealable).

<div style="page-break-after: always;"></div>

# License

The **Android PIN Unblocker** application is licensed under the copyleft license **GNU GPLv3 (or later version)** since my friends at the [Free Software Foundation](https://www.gnu.org/proprietary/proprietary.html) recommend it.

**Basic4Android** also allows completely free usage of their IDE for both commercial and non-commercial purposes so it should be OK.

And also the additional allowances below for this app which are useful for use in restricted or sensitive environments.

Action | Status | Reason
-- | :-: | --
Modify the app's package name | Allowed | Security / Hardening
Sign the app with a different key | Allowed | Security / Hardening
Compile the app from source | Allowed | Security / Hardening

<div style="page-break-after: always;"></div>

# Legalese

Maybe oneday if somebody randomly stumbles upon this app and likes it, they might be interested about legalese information for this app.\
So here's below a list of assets that are currently (or have previously been) used for this app.

Asset name | Author | License | Commercial use
-- | :-: | :-: | :-:
[Basic4Android](https://www.b4x.com/b4a.html) | Anywhere Software | [Apache 2.0](https://github.com/AnywhereSoftware/B4A/blob/master/LICENSE) | Allowed
[FontAwesome](https://fontawesome.com/v4/) | Dave Gandy | [SIL OFL 1.1](https://fontawesome.com/v4/license/) | Allowed
[Material Icons](https://github.com/google/material-design-icons) | Google | [Apache 2.0](https://github.com/google/material-design-icons/blob/master/LICENSE) | Allowed
[NewQRCodeReaderView](https://www.b4x.com/android/forum/threads/qrcodereaderview-new-release.82265/#post-523013) | Johan Schoeman | [Apache 2.0](https://www.b4x.com/android/forum/help/terms/) | Allowed
[ZXing](https://github.com/zxing/zxing) | ZXing Project | [Apache 2.0](https://github.com/zxing/zxing/blob/master/LICENSE) | Allowed
[~~Clipboard Library~~](https://www.b4x.com/android/forum/threads/clipboard-library.7382/) | mtw | [Apache 2.0](https://www.b4x.com/android/forum/help/terms/) | Allowed
[Threading Library](https://www.b4x.com/android/forum/threads/threading-library.6775/) | Andrew Graham | [Apache 2.0](https://www.b4x.com/android/forum/help/terms/) | Allowed
[~~Devices secure card Icon~~](https://www.iconarchive.com/show/oxygen-icons-by-oxygen-icons.org/Devices-secure-card-icon.html) | Oxygen Team | [LGPL 3.0](https://www.gnu.org/licenses/lgpl-3.0.html) | Allowed
[Info 24 Icon](https://www.iconarchive.com/show/octicons-icons-by-github/info-24-icon.html) | Github | [MIT License](https://github.com/primer/octicons/blob/main/LICENSE) | Allowed
[Credit card Icon](https://www.iconarchive.com/show/shop-icons-by-newidols.ru/credit-card-icon.html) | Newidols | [Attribution](https://www.iconarchive.com/icons/newidols.ru/shop/License.txt) | Allowed
[Very Basic Unlock Icon](https://www.iconarchive.com/show/windows-8-icons-by-icons8/Very-Basic-Unlock-icon.html) | Icons8 | [Attribution](https://icons8.com/license/) | Allowed
[Color Quantizer](https://x128.ho.ua/color-quantizer.html) | x128 | [No License](https://choosealicense.com/no-permission/) | Allowed
[7-Zip](https://www.7-zip.org/) | Igor Pavlov | [LGPL 2.1](https://www.7-zip.org/license.txt) | Allowed
[MyApkTool Pro](https://github.com/alisakkaf/MyApkTool-Pro) | Ali Sakkaf | [MIT License](https://github.com/alisakkaf/MyApkTool-Pro/blob/main/LICENSE) | Allowed
[dex2jar & jar2dex](https://github.com/pxb1988/dex2jar) | pxb1988 | [Apache 2.0](https://github.com/pxb1988/dex2jar/blob/2.x/LICENSE.txt) | Allowed


