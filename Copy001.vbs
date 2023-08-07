Option Explicit

Dim FolderToCheck, FolderDestination, FileExt, mostRecent, noFiles, fso, fileList, file, filecounter, oShell, strHomeFolder

' Enumerate current user's home path - we will use that by default later if nothing specified in commandline
Set oShell = CreateObject("WScript.Shell")
strHomeFolder = oShell.ExpandEnvironmentStrings("%USERPROFILE%")

'Variables -----
folderToCheck = strHomeFolder & "\Desktop\MY\MMS"           ' Folder Source to check for recent files to copy FROM
folderDestination = strHomeFolder & "\Desktop\New"          ' Destination Folder where to copy files TO

fileExt = "txt"     ' Extension we are searching for
mostRecent = 2      ' Most Recent number of files to copy
' --------------


PreProcessing()     ' Retrieve Command Line Parameters

' Display what we are intending on doing
wscript.echo "Checking Source: " & FolderToCheck 
wscript.echo "For Files of type: " & FileExt
wscript.echo "Copying most recent "& mostRecent &" file(s) to: " & FolderDestination & "."
wscript.echo 

noFiles = TRUE

Set fso = CreateObject("Scripting.FileSystemObject")

Set fileList = CreateObject("ADOR.Recordset")
fileList.Fields.append "name", 200, 255
fileList.Fields.Append "date", 7
fileList.Open

If fso.FolderExists(FolderToCheck) Then 
    For Each file In fso.GetFolder(FolderToCheck).files
     If LCase(fso.GetExtensionName(file)) = LCase(FileExt) then
       fileList.AddNew
       fileList("name").Value = File.Path
       fileList("date").Value = File.DateLastModified
       fileList.Update
       If noFiles Then noFiles = FALSE
     End If
    Next
    If Not(noFiles) Then 
        wscript.echo fileList.recordCount & " File(s) found. Sorting and copying last " & mostRecent &"..."
        fileList.Sort = "date DESC"
        If Not(fileList.EOF) Then 
            fileList.MoveFirst
            If fileList.recordCount < mostRecent Then 
                wscript.echo "WARNING: " & mostRecent &" file(s) specified but only " & fileList.recordcount & " file(s) match criteria. Adjusted to " & fileList.RecordCount & "."
                mostRecent = fileList.recordcount
            End If

            fileCounter = 0
            Do Until fileList.EOF Or fileCounter => mostRecent
                If Not(fso.FolderExists(folderDestination)) Then 
                    wscript.echo "Destination Folder did not exist. Creating..."
                    fso.createFolder folderDestination
                End If
                fso.copyfile fileList("name"), folderDestination & "\", True
                wscript.echo  fileList("date").value & vbTab & fileList("name")
                fileList.moveNext
                fileCounter = fileCounter + 1
            Loop
        Else
            wscript.echo "An unexpected error has occured."
        End If
    Else
        wscript.echo "No matching """ & FileExt &""" files were found in """ & foldertocheck & """ to copy."
    End If
Else
    wscript.echo "Error: Source folder does not exist """ & foldertocheck & """."
End If

fileList.Close

Function PreProcessing
    Dim source, destination, ext, recent

    ' Initialize some variables
    Set source = Nothing
    Set destination = Nothing
    Set ext = Nothing
    Set recent = Nothing

    'Get Command Line arguments
    ' <scriptname>.vbs /Source:"C:\somepath\somefolder" /Destination:"C:\someotherpath\somefolder" /ext:txt /recent:2

    source = wscript.arguments.Named.Item("source")
    destination = wscript.arguments.Named.Item("destination")
    ext = wscript.arguments.Named.Item("ext")
    recent = wscript.arguments.Named.Item("recent")

    If source <> "" Then FolderToCheck = source
    If destination <> "" Then FolderDestination = destination
    If ext <> "" Then FileExt = ext
    If recent <> "" Then mostRecent = int(recent)

End Function