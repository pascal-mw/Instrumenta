Attribute VB_Name = "ModulePicturesCropToSlide"
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

Sub PictureCropToSlide()
    
    Set myDocument = Application.ActiveWindow
    
    If Not myDocument.Selection.Type = ppSelectionShapes Then
        MsgBox "No picture or shape selected."
        
    ElseIf myDocument.Selection.ShapeRange.Count = 1 Then
        
        Set PictureShape = Application.ActiveWindow.Selection.ShapeRange(1)
        
        Select Case PictureShape.Type
        Case msoEmbeddedOLEObject, msoLinkedOLEObject, msoOLEControlObject, msoLinkedPicture, msoPicture
            
            Set TemporaryShape = PictureShape.Duplicate
            
            TemporaryShape.ScaleHeight 1, msoTrue
            ScaledHeight = TemporaryShape.Height / PictureShape.Height
            
            TemporaryShape.ScaleWidth 1, msoTrue
            ScaledWidth = TemporaryShape.Width / PictureShape.Width
            
            TemporaryShape.Delete
            
            With PictureShape
                
                .PictureFormat.CropLeft = 0
                .PictureFormat.CropTop = 0
                .PictureFormat.CropBottom = 0
                .PictureFormat.CropRight = 0
                
                If .Left < 0 Then
                    .PictureFormat.CropLeft = 0 - (.Left * ScaledWidth)
                End If
                
                If .Top < 0 Then
                    .PictureFormat.CropTop = 0 - (.Top * ScaledHeight)
                End If
                
                If (.Left + .Width) > Application.ActivePresentation.PageSetup.SlideWidth Then
                    .PictureFormat.CropRight = (.Left + .Width - Application.ActivePresentation.PageSetup.SlideWidth) * ScaledWidth
                End If
                
                If (.Top + .Height) > Application.ActivePresentation.PageSetup.SlideHeight Then
                    .PictureFormat.CropBottom = (.Top + .Height - Application.ActivePresentation.PageSetup.SlideHeight) * ScaledHeight
                End If
                
            End With
            
        Case msoAutoShape, msoFreeform
            
            Dim CroppedAreaFound As Boolean
            CroppedAreaFound = False
            
            With PictureShape
                
                If .Left < 0 Then
                    Set CropArea = Application.ActiveWindow.Selection.SlideRange.Shapes.AddShape(msoShapeRectangle, .Left - 10, .Top - 10, 0 - .Left + 10, .Height + 20)
                    CropArea.Select (msoFalse)
                    CroppedAreaFound = True
                End If
                
                If .Top < 0 Then
                    Set CropArea = Application.ActiveWindow.Selection.SlideRange.Shapes.AddShape(msoShapeRectangle, .Left - 10, .Top - 10, .Width + 20, -.Top + 10)
                    CropArea.Select (msoFalse)
                    CroppedAreaFound = True
                End If
                
                If (.Left + .Width) > Application.ActivePresentation.PageSetup.SlideWidth Then
                    
                    Set CropArea = Application.ActiveWindow.Selection.SlideRange.Shapes.AddShape(msoShapeRectangle, Application.ActivePresentation.PageSetup.SlideWidth, .Top - 10, .Left + .Width - Application.ActivePresentation.PageSetup.SlideWidth + 10, .Height + 20)
                    CropArea.Select (msoFalse)
                    CroppedAreaFound = True
                    
                End If
                
                If (.Top + .Height) > Application.ActivePresentation.PageSetup.SlideHeight Then
                    
                    Set CropArea = Application.ActiveWindow.Selection.SlideRange.Shapes.AddShape(msoShapeRectangle, .Left - 10, Application.ActivePresentation.PageSetup.SlideHeight, .Width + 20, .Top + .Height - Application.ActivePresentation.PageSetup.SlideHeight + 10)
                    CropArea.Select (msoFalse)
                    CroppedAreaFound = True
                    
                End If
                
            End With
            
            If CroppedAreaFound = True Then
                CommandBars.ExecuteMso ("ShapesSubtract")
            End If
            
        Case Else
            
            MsgBox "Selected shape is not a picture or compatible shape."
            
        End Select
        
    Else
        
        MsgBox "Please select one picture or shape."
        
    End If
    
End Sub