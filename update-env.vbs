Option Explicit
On Error Resume Next
Dim WshShell, strCommand, stdOut, currentVersion, latestVersion, strURL, downloadURL, fileName, downloadPath, errorLevel

Set WshShell = CreateObject("WScript.Shell")

Function validateRegex(strInput, strPattern)
    Dim regObj
    Set regObj = New RegExp
    With regObj
        .Pattern = strPattern
        .IgnoreCase = True
        .Global = False
    End With
    If regObj.Test(strInput) Then
        validateRegex = regObj.Execute(strInput).Item(0)
    Else
        validateRegex = strInput
    End If
End Function

Function executeShell(command)
    Dim oExec
    Set oExec = WshShell.Exec(command)
    Do While oExec.Status = 0
        WScript.Sleep 100
    Loop
    Select case oExec.Status
        Case 1 'Finished
            executeShell = oExec.StdOut.ReadAll
        Case 2 'Failed
            executeShell = "Failed: " + oExec.StdErr.ReadAll
    End Select
End Function

strCommand = WScript.Arguments(0) + " " + WScript.Arguments(1) 'app version
stdOut = executeShell(strCommand)
currentVersion = validateRegex(stdOut, Wscript.Arguments(2)) 'version pattern
Wscript.Echo "  Installed version: " + currentVersion

With CreateObject("Msxml2.XMLHTTP.6.0") 'curl replacement due to WshShell.Exec freezing main thread and not able to grab WshShell.Run Stdout without further ado
    .open "GET", WScript.Arguments(3), False 'using download url
    .send
    stdOut = .responseText
End With

strURL = validateRegex(stdOut, Wscript.Arguments(4)) ' validate downloadURL

If InStr(strURL, "http") > 0 Then
    downloadURL = strURL
Else
    downloadURL = Wscript.Arguments(3) + strURL ' append due to missing downloadURL
End If

latestVersion = validateRegex(downloadURL, Wscript.Arguments(2)) 'version pattern

fileName = validateRegex(downloadURL, Wscript.Arguments(5)) ' filename pattern

WScript.Echo "  Latest version: " + latestVersion
WScript.Echo "  Download URL: " + downloadURL
Wscript.Echo "  File name: " + fileName

If StrComp(currentVersion, latestVersion, vbTextCompare) = 0 Then
    WScript.Echo "Congratulations! You own the latest " + WScript.Arguments(0) + " version " + latestVersion + "!"
Else
    WScript.Echo "New " + + WScript.Arguments(0) + " version available (" + latestVersion+ ")! Downloading setup file (" + fileName + ")..."
    
    errorLevel = WshShell.Run("curl -LO " + downloadURL, 5, True)

    If errorLevel <> 0 Then
        WScript.Echo "Error: " + errorLevel
        WScript.Quit 1
    End If

    WScript.Echo "Download successful. Installing ..."

    errorLevel = WshShell.Run(fileName, 5, True)

    If errorLevel <> 0 Then
        WScript.Echo "Error: " + errorLevel
        WScript.Quit 1
    End If

    'https://stackoverflow.com/questions/14968342/how-to-capitalize-first-letter-of-a-string-in-vbscript
    Wscript.Echo UCase(Left(WScript.Arguments(0), 1)) + Mid(WScript.Arguments(0),2) + " app update has been successfully installed. Upgrade from " + currentVersion + " to " + latestVersion + " done."

End If