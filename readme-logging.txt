
RegEx for making logging conditional
------------------------------------

Search:  ^([\t ]*)Dim LogContextId As Int \= (.+?)$
Replace: $1#If LOGGING\r\n$1Dim LogContextId As Int \= $2\r\n$1#End If

Search:  ^([\t ]*)LogColor\((.+)\, (Colors\.[^\)]+?)\)$
Replace: $1#If LOGGING\r\n$1LogColor\($2\, $3\)\r\n$1#End If

RegEx for undoing the conditional logging
-----------------------------------------

Search:  ^[\t ]*\#If LOGGING\r\n([\t ]*)Dim LogContextId As Int \= (.+?)\r\n[\t ]*\#End If$
Replace: $1Dim LogContextId As Int \= $2

Search:  ^[\t ]*\#If LOGGING\r\n([\t ]*)LogColor\((.+)\, (Colors\.[^\)]+?)\)\r\n[\t ]*\#End If$
Replace: $1LogColor\($2\, $3\)

Important notes
---------------

 [i] Use Notepad++ for the RegEx replacement.
     This RegEx has been tested working with Notepad++.

 [i] The source code must use Windows newlines.
     Windows newlines are "CRLF" aka. "\r\n".


