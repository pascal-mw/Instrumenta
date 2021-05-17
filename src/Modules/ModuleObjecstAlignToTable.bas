Attribute VB_Name = "ModuleObjecstAlignToTable"
'MIT License

'Copyright (c) 2021 iappyx
'
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

Sub ObjectsAlignToTable()
    
    Set myDocument = Application.ActiveWindow
    
    If Not myDocument.Selection.Type = ppSelectionShapes Then
        MsgBox "No shapes selected."
        
    ElseIf myDocument.Selection.ShapeRange.Count > 1 Then
        
        Dim ShapeCount, TableIndex, TableDimensions  As Long
        
        TableIndex = 0
        TableDimensions = 0
        
        For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
            If myDocument.Selection.ShapeRange(ShapeCount).HasTable = True Then
                
                If (myDocument.Selection.ShapeRange(ShapeCount).Width * myDocument.Selection.ShapeRange(ShapeCount).Height) > TableDimensions Then
                    TableIndex = ShapeCount
                    TableDimensions = myDocument.Selection.ShapeRange(ShapeCount).Width * myDocument.Selection.ShapeRange(ShapeCount).Height
                    
                End If
                
            End If
        Next ShapeCount
        
        If TableIndex >= 1 Then
            
            Dim SlideShape() As Shape
            ReDim SlideShape(1 To myDocument.Selection.ShapeRange.Count - 1)
            Dim SlideShapeCounter As Integer
            
            SlideShapeCounter = 1
            
            For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
                If ShapeCount <> TableIndex Then
                    Set SlideShape(SlideShapeCounter) = myDocument.Selection.ShapeRange(ShapeCount)
                    SlideShapeCounter = SlideShapeCounter + 1
                End If
            Next ShapeCount
            
            Dim Rows    As Integer, Columns As Integer
            
            Rows = myDocument.Selection.ShapeRange(TableIndex).Table.Rows.Count
            Columns = myDocument.Selection.ShapeRange(TableIndex).Table.Columns.Count
            
            Dim TableXBorder, TableYBorder, TableCols(), TableRows(), TableXCenter(), TableYCenter() As Double
            
            ReDim TableCols(Columns), TableRows(Rows)
            ReDim TableXCenter(1 To Columns), TableYCenter(1 To Rows)
            
            TableXBorder = myDocument.Selection.ShapeRange(TableIndex).Left
            TableYBorder = myDocument.Selection.ShapeRange(TableIndex).Top
            
            TableRows(0) = TableYBorder
            TableCols(0) = TableXBorder
            
            For RowsCount = 1 To Rows
                TableYBorder = TableYBorder + myDocument.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height
                TableRows(RowsCount) = TableYBorder
                TableYCenter(RowsCount) = TableYBorder - (myDocument.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height / 2)
            Next RowsCount
            
            For ColsCount = 1 To Columns
                TableXBorder = TableXBorder + myDocument.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width
                TableCols(ColsCount) = TableXBorder
                TableXCenter(ColsCount) = TableXBorder - (myDocument.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width / 2)
            Next ColsCount
            
            For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count - 1
                
                ShapeXCenter = SlideShape(ShapeCount).Left + (SlideShape(ShapeCount).Width / 2)
                ShapeYCenter = SlideShape(ShapeCount).Top + (SlideShape(ShapeCount).Height / 2)
                
                For RowsCount = 1 To Rows
                    
                    If ShapeYCenter >= TableRows(RowsCount - 1) And ShapeYCenter < TableRows(RowsCount) Then
                        
                        SlideShape(ShapeCount).Top = TableYCenter(RowsCount) - (SlideShape(ShapeCount).Height / 2)
                        Exit For
                        
                    End If
                Next RowsCount
                
                For ColsCount = 1 To Columns
                    If ShapeXCenter >= TableCols(ColsCount - 1) And ShapeXCenter < TableCols(ColsCount) Then
                        
                        SlideShape(ShapeCount).Left = TableXCenter(ColsCount) - (SlideShape(ShapeCount).Width / 2)
                        Exit For
                        
                    End If
                Next ColsCount
            Next ShapeCount
            
        Else
            
            MsgBox "No table selected. Please Select a table."
            
        End If
        
    Else
    
        MsgBox "Select a table and some shapes."
        
    End If
    
End Sub

Sub ObjectsAlignToTableColumn()
    
    Set myDocument = Application.ActiveWindow
    
    If Not myDocument.Selection.Type = ppSelectionShapes Then
        MsgBox "No shapes selected."
        
    ElseIf myDocument.Selection.ShapeRange.Count > 1 Then
        
        Dim ShapeCount, TableIndex, TableDimensions  As Long
        
        TableIndex = 0
        TableDimensions = 0
        
        For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
            If myDocument.Selection.ShapeRange(ShapeCount).HasTable = True Then
                
                If myDocument.Selection.ShapeRange(ShapeCount).Height > TableDimensions Then
                    TableIndex = ShapeCount
                    TableDimensions = myDocument.Selection.ShapeRange(ShapeCount).Height
                    
                End If
                
            End If
        Next ShapeCount
        
        If TableIndex >= 1 Then
            
            TableTop = myDocument.Selection.ShapeRange(TableIndex).Top
            TableLeft = myDocument.Selection.ShapeRange(TableIndex).Left
            
            AlignmentColumn = CInt(InputBox("Enter column number To align shapes to:", "Align objects To column", 1))
            SkipRows = CInt(InputBox("Enter first number of rows To skip (e.g. 1 If your table has a header row):", "Align objects To column", 1))
            
            SortOrder = MsgBox("Do you want use the top position of the shapes?" & vbNewLine & vbNewLine & "If you click Yes the top position of the shape will be used To distribute the different shapes" & vbNewLine & vbNewLine & "If you click No the order of selecting the different shapes will be used To distribute the different shapes", vbYesNo + vbQuestion, "Align objects To column")
            
            Dim SlideShape() As Shape
            Dim SlideShapeOrdered() As Shape
            ReDim SlideShape(1 To myDocument.Selection.ShapeRange.Count - 1)
            ReDim SlideShapeOrdered(1 To myDocument.Selection.ShapeRange.Count)
            
            Shapes = 0
            
            For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
                
                If ShapeCount = TableIndex Then
                    
                Else
                    Shapes = Shapes + 1
                    Set SlideShape(Shapes) = myDocument.Selection.ShapeRange(ShapeCount)
                    
                End If
                
            Next ShapeCount
            
            If SortOrder = vbYes Then
                ObjectsSortByTopPosition SlideShape
            End If
            
            Set SlideShapeOrdered(1) = myDocument.Selection.ShapeRange(TableIndex)
            For ShapeCount = 2 To myDocument.Selection.ShapeRange.Count
                Set SlideShapeOrdered(ShapeCount) = SlideShape(ShapeCount - 1)
            Next ShapeCount
            
            For RowsCount = 1 To myDocument.Selection.ShapeRange(TableIndex).Table.Rows.Count
                
                For ColsCount = 1 To myDocument.Selection.ShapeRange(TableIndex).Table.Columns.Count
                    
                    If (ColsCount = AlignmentColumn) And RowsCount > SkipRows And (RowsCount < (myDocument.Selection.ShapeRange.Count + SkipRows)) Then
                        
                        With SlideShapeOrdered(RowsCount + 1 - SkipRows)
                            
                            .Left = TableLeft + myDocument.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width / 2 - .Width / 2
                            .Top = TableTop + myDocument.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height / 2 - .Height / 2
                            
                        End With
                        
                    End If
                    
                    TableLeft = TableLeft + Application.ActiveWindow.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width
                    
                Next ColsCount
                
                TableLeft = Application.ActiveWindow.Selection.ShapeRange(TableIndex).Left
                TableTop = TableTop + Application.ActiveWindow.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height
                
            Next RowsCount
            
        Else
            
            MsgBox "The selection contains no table."
            
        End If
        
    Else
    
        MsgBox "Select a table and some shapes."
        
    End If
    
End Sub
Sub ObjectsAlignToTableRow()
    
    Set myDocument = Application.ActiveWindow
    
    If Not myDocument.Selection.Type = ppSelectionShapes Then
        MsgBox "No shapes selected."
        
    ElseIf myDocument.Selection.ShapeRange.Count > 1 Then
        
        Dim ShapeCount, TableIndex, TableDimensions  As Long
        
        TableIndex = 0
        TableDimensions = 0
        
        For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
            If myDocument.Selection.ShapeRange(ShapeCount).HasTable = True Then
                
                If myDocument.Selection.ShapeRange(ShapeCount).Width > TableDimensions Then
                    TableIndex = ShapeCount
                    TableDimensions = myDocument.Selection.ShapeRange(ShapeCount).Width
                    
                End If
                
            End If
        Next ShapeCount
        
        If TableIndex >= 1 Then
            
            TableTop = myDocument.Selection.ShapeRange(TableIndex).Top
            TableLeft = myDocument.Selection.ShapeRange(TableIndex).Left
            
            AlignmentRow = CInt(InputBox("Enter row number To align shapes to:", "Align objects To row", 1))
            SkipColumns = CInt(InputBox("Enter first number of columns To skip:", "Align objects To row", 0))
            
            SortOrder = MsgBox("Do you want use the left position of the shapes?" & vbNewLine & vbNewLine & "If you click Yes the left position of the shape will be used To distribute the different shapes" & vbNewLine & vbNewLine & "If you click No the order of selecting the different shapes will be used To distribute the different shapes", vbYesNo + vbQuestion, "Align objects To row")
            
            Dim SlideShape() As Shape
            Dim SlideShapeOrdered() As Shape
            ReDim SlideShape(1 To myDocument.Selection.ShapeRange.Count - 1)
            ReDim SlideShapeOrdered(1 To myDocument.Selection.ShapeRange.Count)
            
            Shapes = 0
            
            For ShapeCount = 1 To myDocument.Selection.ShapeRange.Count
                
                If ShapeCount = TableIndex Then
                    
                Else
                    Shapes = Shapes + 1
                    Set SlideShape(Shapes) = myDocument.Selection.ShapeRange(ShapeCount)
                    
                End If
                
            Next ShapeCount
            
            If SortOrder = vbYes Then
                ObjectsSortByLeftPosition SlideShape
            End If
            
            Set SlideShapeOrdered(1) = myDocument.Selection.ShapeRange(TableIndex)
            For ShapeCount = 2 To myDocument.Selection.ShapeRange.Count
                Set SlideShapeOrdered(ShapeCount) = SlideShape(ShapeCount - 1)
            Next ShapeCount
            
            For RowsCount = 1 To myDocument.Selection.ShapeRange(TableIndex).Table.Rows.Count
                
                For ColsCount = 1 To myDocument.Selection.ShapeRange(TableIndex).Table.Columns.Count
                    
                    If (RowsCount = AlignmentRow) And ColsCount > SkipColumns And (ColsCount < (myDocument.Selection.ShapeRange.Count + SkipColumns)) Then
                        
                        With SlideShapeOrdered(ColsCount + 1 - SkipColumns)
                            
                            .Left = TableLeft + myDocument.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width / 2 - .Width / 2
                            .Top = TableTop + myDocument.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height / 2 - .Height / 2
                            
                        End With
                        
                    End If
                    
                    TableLeft = TableLeft + Application.ActiveWindow.Selection.ShapeRange(TableIndex).Table.Columns(ColsCount).Width
                    
                Next ColsCount
                
                TableLeft = Application.ActiveWindow.Selection.ShapeRange(TableIndex).Left
                TableTop = TableTop + Application.ActiveWindow.Selection.ShapeRange(TableIndex).Table.Rows(RowsCount).Height
                
            Next RowsCount
            
        Else
            
            MsgBox "The selection contains no table."
            
        End If
        
    Else
    
        MsgBox "Select a table and some shapes."
        
    End If
    
End Sub
