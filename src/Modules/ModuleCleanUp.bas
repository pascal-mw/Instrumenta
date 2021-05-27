Attribute VB_Name = "ModuleCleanUp"
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

Sub CleanUpRemoveUnusedMasterSlides()
    Dim NumberOfDesigns, NumberOfCustomLayouts As Integer
    
    ProgressForm.Show
    
    On Error Resume Next
    
    DesignsCount = ActivePresentation.Designs.Count
        
    For NumberOfDesigns = ActivePresentation.Designs.Count To 1 Step -1
        
        SetProgress ((DesignsCount - NumberOfDesigns) / DesignsCount * 100)
        For NumberOfCustomLayouts = ActivePresentation.Designs(NumberOfDesigns).SlideMaster.CustomLayouts.Count To 1 Step -1
            ActivePresentation.Designs(NumberOfDesigns).SlideMaster.CustomLayouts(NumberOfCustomLayouts).Delete
        Next NumberOfCustomLayouts
        
        If ActivePresentation.Designs(NumberOfDesigns).SlideMaster.CustomLayouts.Count = 0 Then
            ActivePresentation.Designs(NumberOfDesigns).Delete
        End If
        
    Next NumberOfDesigns
    
    On Error GoTo 0
        
    ProgressForm.Hide
        
End Sub

Sub CleanUpRemoveAnimationsFromAllSlides()
    Dim PresentationSlide As Slide
    Dim AnimationCount As Long
    
    ProgressForm.Show
    
    For Each PresentationSlide In ActivePresentation.Slides
    
    SetProgress (PresentationSlide.SlideNumber / ActivePresentation.Slides.Count * 100)
    
        For AnimationCount = PresentationSlide.TimeLine.MainSequence.Count To 1 Step -1
            PresentationSlide.TimeLine.MainSequence.Item(AnimationCount).Delete
        Next AnimationCount
    Next PresentationSlide
    
    ProgressForm.Hide
    
End Sub

Sub CleanUpRemoveSpeakerNotesFromAllSlides()
    Dim PresentationSlide As Slide
    Dim SlideShape  As PowerPoint.Shape
    
    ProgressForm.Show
    
    For Each PresentationSlide In ActivePresentation.Slides
    
    SetProgress (PresentationSlide.SlideNumber / ActivePresentation.Slides.Count * 100)
    
        For Each SlideShape In PresentationSlide.NotesPage.Shapes
            If SlideShape.TextFrame.HasText Then
                SlideShape.TextFrame.TextRange = ""
            End If
        Next
    Next
    
    ProgressForm.Hide
    
End Sub

Sub CleanUpRemoveCommentsFromAllSlides()
    Dim PresentationSlide As Slide
    Dim CommentsCount As Long
    
    ProgressForm.Show
    
    For Each PresentationSlide In ActivePresentation.Slides
      
    SetProgress (PresentationSlide.SlideNumber / ActivePresentation.Slides.Count * 100)
      
        For CommentsCount = PresentationSlide.Comments.Count To 1 Step -1
            PresentationSlide.Comments(1).Delete
        Next
    Next
    
    ProgressForm.Hide
    
End Sub


Sub CleanUpRemoveSlideShowTransitionsFromAllSlides()
    Dim PresentationSlide As Slide
    
    ProgressForm.Show
    
    For Each PresentationSlide In ActivePresentation.Slides
        SetProgress (PresentationSlide.SlideNumber / ActivePresentation.Slides.Count * 100)
        PresentationSlide.SlideShowTransition.EntryEffect = 0
    Next
    
    ProgressForm.Hide
    
End Sub


