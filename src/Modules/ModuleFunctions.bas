Attribute VB_Name = "ModuleFunctions"
'MIT License

'Copyright (c) 2021 iappyx

'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights
'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
'copies of the Software, and to permit persons to whom the Software is
'furnished to do so, subject to the following conditions:

'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.

'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
'SOFTWARE.

#If Mac Then

#Else
Private Declare PtrSafe Function WindowsColorDialog Lib "comdlg32.dll" Alias "ChooseColorA" (pcc As CHOOSECOLOR_TYPE) As LongPtr
    
    Private Type CHOOSECOLOR_TYPE
        lStructSize As LongPtr
        hwndOwner   As LongPtr
        hInstance   As LongPtr
        rgbResult   As LongPtr
        lpCustColors As LongPtr
        flags       As LongPtr
        lCustData   As LongPtr
        lpfnHook    As LongPtr
        lpTemplateName As String
    End Type
    
    Private Const CC_ANYCOLOR = &H100
    Private Const CC_ENABLEHOOK = &H10
    Private Const CC_ENABLETEMPLATE = &H20
    Private Const CC_ENABLETEMPLATEHANDLE = &H40
    Private Const CC_FULLOPEN = &H2
    Private Const CC_PREVENTFULLOPEN = &H4
    Private Const CC_RGBINIT = &H1
    Private Const CC_SHOWHELP = &H8
    Private Const CC_SOLIDCOLOR = &H80
#End If

Function RemoveDuplicates(InputArray) As Variant
    
    Dim OutputArray, InputValue, OutputValue As Variant
    Dim MatchFound  As Boolean
    
    On Error Resume Next
    OutputArray = Array("")
    For Each InputValue In InputArray
        MatchFound = False
        
        If IsEmpty(InputValue) Then GoTo ForceNext
        For Each OutputValue In OutputArray
            If OutputValue = InputValue Then
                MatchFound = True
                Exit For
            End If
        Next OutputValue
        
        If MatchFound = False Then
            ReDim Preserve OutputArray(UBound(OutputArray, 1) + 1)
            OutputArray(UBound(OutputArray, 1) - 1) = InputValue
        End If
        
ForceNext:
    Next
    RemoveDuplicates = OutputArray
    
End Function

Sub SetProgress(PercentageCompleted As Single)

    ProgressForm.ProgressBar.Width = PercentageCompleted * 2
    ProgressForm.ProgressLabel.Caption = Round(PercentageCompleted, 0) & "% completed"
    DoEvents
    
End Sub

Function MacFileDialog(filepath As String) As String
  MacFileDialogMacScript = "set applescript's text item delimiters to "","" " & vbNewLine & "try " & vbNewLine & "set selectedFile to (choose file " & _
    "with prompt ""Please select a file"" default location alias """ & filepath & """ multiple selections allowed false) as string" & vbNewLine & "set applescript's text item delimiters to """" " & vbNewLine & _
    "on error errStr number errorNumber" & vbNewLine & "return errorNumber " & vbNewLine & "end try " & vbNewLine & "return selectedFile"
  MacFileDialog = MacScript(MacFileDialogMacScript)
  
  If MacFileDialog = "-128" Then
  MacFileDialog = ""
  Else
      If CInt(Split(Application.Version, ".")(0)) >= 15 Then
    MacFileDialog = Replace(MacFileDialog, ":", "/")
    MacFileDialog = Replace(MacFileDialog, "Macintosh HD", "", Count:=1)
        End If
  End If
  
End Function


Function CheckIfAppleScriptPluginIsInstalled() As Double

#If Mac Then

Dim AppleScriptPluginVersion As String

On Error GoTo NotInstalled
AppleScriptPluginVersion = AppleScriptTask("InstrumentaAppleScriptPlugin.applescript", "CheckIfAppleScriptPluginIsInstalled", "")
CheckIfAppleScriptPluginIsInstalled = CDbl(AppleScriptPluginVersion)
On Error Resume Next
Exit Function

#Else
CheckIfAppleScriptPluginIsInstalled = 0
Exit Function
#End If

NotInstalled:
On Error Resume Next
CheckIfAppleScriptPluginIsInstalled = 0

End Function

'This does not work well in all cases
'Function MacSendMailViaOutlook(subject As String, filepath As String)
'MacSendMailViaOutlookMacScript = "tell application ""Microsoft Outlook""" & vbNewLine & "set NewMail to (make new outgoing message with properties {subject:""" & subject & """})" & vbNewLine & _
'"tell NewMail" & vbNewLine & "set AttachmentPath to POSIX file """ & filepath & """" & vbNewLine & "make new attachment with properties {file:AttachmentPath as alias}" & vbNewLine & "Delay 0.5" & vbNewLine & _
'"end tell" & vbNewLine & "open NewMail" & vbNewLine & "Activate NewMail" & vbNewLine & "end tell" & vbNewLine & "return ""Done"""
'MacSendMailViaOutlook = MacScript(MacSendMailViaOutlookMacScript)
'End Function


#If Mac Then
    
Function ColorDialog(StandardColor As Variant) As Variant
    Dim ReturnColorString As String
    Dim ReturnColor As Variant
    
    ReturnColorString = MacScript("try" & vbNewLine & "set the ColorPicked To (choose color default color {0, 65535, 0})" & vbNewLine & _
                        "on error" & vbNewLine & "set the ColorReturned To -128" & vbNewLine & "return ColorReturned" & vbNewLine & "end try" & vbNewLine & _
                        "set the ColorReturned To my ColorToRGB(ColorPicked)" & vbNewLine & "return ColorReturned" & vbNewLine & _
                        "on ColorToRGB({r, g, b})" & vbNewLine & "set r To (r ^ 0.5) div 1" & vbNewLine & "set g To (g ^ 0.5) div 1" & vbNewLine & "set b To (b ^ 0.5) div 1" & _
                        vbNewLine & "return r & "","" & g & "","" & b As string" & vbNewLine & "end ColorToRGB")
    
    ReturnColor = Split(ReturnColorString, ",")
    
    If ReturnColor(0) = "-128" Then
        ColorDialog = StandardColor
    Else
        ColorDialog = RGB(CInt(ReturnColor(0)), CInt(ReturnColor(1)), CInt(ReturnColor(2)))
    End If

End Function

#Else
    
Function ColorDialog(StandardColor As Variant) As Variant
    
    Dim ChooseColorType As CHOOSECOLOR_TYPE
    Dim ReturnColor As Variant
    
    Static PredefinedColors(16)  As Long
    PredefinedColors(0) = StandardColor
    
    If ActivePresentation.ExtraColors.Count > 0 Then
        For ExtraColorCount = 1 To ActivePresentation.ExtraColors.Count
            PredefinedColors(ExtraColorCount) = ActivePresentation.ExtraColors(ExtraColorCount)
        Next
    End If
    
    If ActivePresentation.ExtraColors.Count > 0 Then
        For ExtraColorCount = 1 To ActivePresentation.ExtraColors.Count
            PredefinedColors(ExtraColorCount) = ActivePresentation.ExtraColors(ExtraColorCount)
        Next
    End If
    
    If ActivePresentation.ColorSchemes.Count > 0 Then
    
        PredefinedColors(11) = ActivePresentation.ColorSchemes(1).Colors(ppAccent1).RGB
        PredefinedColors(12) = ActivePresentation.ColorSchemes(1).Colors(ppAccent2).RGB
        PredefinedColors(13) = ActivePresentation.ColorSchemes(1).Colors(ppAccent3).RGB
        PredefinedColors(14) = ActivePresentation.ColorSchemes(1).Colors(ppForeground).RGB
        PredefinedColors(15) = ActivePresentation.ColorSchemes(1).Colors(ppBackground).RGB
    
    End If
    
    
    With ChooseColorType
        .lStructSize = Len(ChooseColorType)
        .flags = CC_RGBINIT Or CC_ANYCOLOR Or CC_FULLOPEN Or CC_PREVENTFULLOPEN
        .rgbResult = StandardColor
        .lpCustColors = VarPtr(PredefinedColors(0))
    End With
    
    ReturnColor = WindowsColorDialog(ChooseColorType)
    
    If Not ReturnColor = 0 Then
        ColorDialog = ChooseColorType.rgbResult
    Else
        ColorDialog = StandardColor
    End If
    
End Function

#End If


