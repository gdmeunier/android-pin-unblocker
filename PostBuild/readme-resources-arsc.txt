
The "resources.arsc" file of the generated APKs must
not be compressed (use "Store" compression method),
otherwise your APK cannot be installed on Android 11+

It must be stored uncompressed and be aligned with
zipalign and a 4-bytes alignment (default value)

Relevant patch notes:
---------------------

Applications targeting Android 11 or higher
(API level 30+) are not allowed to compress
the resources.arsc file inside the APK.

It has to be stored uncompressed a 4-bytes aligned.


