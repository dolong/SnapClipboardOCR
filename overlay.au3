;==============================================
; Author: Toady
;
; Purpose: Takes screenshot of
; a user selected region and saves
; the screenshot in ./images directory.
;
; Rewrite by Ashaman42 for latest UDF's
;
; How to use:
; Press "s" key to select region corners.
; NOTE: Must select top-left of region
; first, then select bottom-right of region.
;=============================================

#include <ScreenCapture.au3>
#include <misc.au3>
#include <GuiConstants.au3>
#include <WinAPI.au3>
#Include <GuiListBox.au3>
#Include <GuiStatusBar.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>

_Singleton("cap")

Global $format = ".jpg"
Global $filename = ""
Global $title = "Screen Region Capture"

DirCreate(@ScriptDir & "/images/")

$GUI = GUICreate($title,610,210,-1,-1)
GUICtrlCreateGroup("Select Format",18,80,210,50)
$radio1 = GUICtrlCreateRadio("JPG",30,100,40)
GuiCtrlSetState(-1, $GUI_CHECKED)
$radio2 = GUICtrlCreateRadio("BMP",80,100,45)
$radio3 = GUICtrlCreateRadio("GIF",130,100,45)
$radio4 = GUICtrlCreateRadio("PNG",180,100,45)
GUICtrlCreateGroup ("",-99,-99,1,1)
GUICtrlCreateLabel("Name of image",20,20)
$gui_img_input = GUICtrlCreateInput("",20,40,200,20)
$go_button = GUICtrlCreateButton("Select region",20,140,200,30)
$list = GUICtrlCreateList("",240,20,150,150)
$editbutton = GUICtrlCreateButton("Edit", 400,60,40)
$deletebutton = GUICtrlCreateButton("Delete", 400,100,40)
$exitbutton = GUICtrlCreateButton("Exit", 400,140,40)
Global $a_PartsRightEdge[5] = [240,320,400,480,-1]
Global $a_PartsText[5] = [@TAB & "Your Name Here!","","","",""]
Global $hImage
$statusbar = _GUICtrlStatusBar_Create($GUI,$a_PartsRightEdge,$a_PartsText)
GUISetState(@SW_SHOW,$GUI)

$SELECT_H =  GUICreate( "AU3SelectionBox", 0 , 0 , 0, 0,  $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW)
GUISetBkColor(0x00FFFF,$SELECT_H)
WinSetTrans("AU3SelectionBox","",60)
GUISetState(@SW_SHOW,$SELECT_H)

_ListFiles()

While 1
    $msg = GUIGetMsg()
    Select
        Case $msg = $GUI_EVENT_CLOSE
            Exit
        Case $msg = $GUI_EVENT_RESTORE
            _ListFiles()
        Case $msg = $radio1
            $format = ".jpg"
        Case $msg = $radio2
            $format = ".bmp"
        Case $msg = $radio3
            $format = ".gif"
        Case $msg = $radio4
            $format = ".png"
        Case $msg = $editbutton
            ShellExecute(_GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)),"",@ScriptDir & "\images\","edit")
        Case $msg = $deletebutton
            Local $msgbox = MsgBox(4,"Delete image","Are you sure?")
            If $msgbox = 6 Then
                FileDelete(@ScriptDir & "\images\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
                _ListFiles()
            EndIf
        Case $msg = $exitbutton
            Exit
        Case $msg = $list
            _ListClick()
        Case $msg = $go_button
            $filename = GUICtrlRead($gui_img_input)
            If $filename <> "" Then
                Local $msgbox = 6
                If FileExists(@ScriptDir & "\images\" & $filename & $format) Then
                    $msgbox = MsgBox(4,"Already Exists","File name already exists, do you want to overwrite it?")
                EndIf
                If $msgbox = 6 Then
                    GUISetState(@SW_HIDE,$GUI)
                    _WinAPI_MoveWindow($SELECT_H,1,1,2,2)
                    GUISetState(@SW_RESTORE,$SELECT_H)
                    GUISetState(@SW_SHOW,$SELECT_H)
                    _TakeScreenShot()
                    GUICtrlSetData($gui_img_input,"")
                    GUISetState(@SW_SHOW,$GUI)
                    _ListFiles()
                EndIf
            Else
                MsgBox(0,"Error","Enter a filename")
            EndIf
    EndSelect
WEnd

Func _ConvertSize($size_bytes)
    If $size_bytes < 1024*1024 Then
        Return Round($size_bytes/1024,2) & " KB"
    Else
        Return Round($size_bytes/1024/1024,2) & " MB"
    EndIf
EndFunc

Func _ConvertTime($time)
    Local $time_converted = $time
    Local $time_data = StringSplit($time, ":")
    If $time_data[1] > 12 Then
        $time_converted = $time_data[1] - 12 & ":" & $time_data[2] & " PM"
    ElseIf $time_data[1] = 12 Then
        $time_converted = $time & " PM"
    Else
        $time_converted &= " AM"
    EndIf
    Return $time_converted
EndFunc

Func _ocr($hImage)

Local $ImageToReadPath = @ScriptDir & "\2.jpg"
Local $ResultTextPath = @ScriptDir & "\Result"
Local $OutPutPath = $ResultTextPath & ".txt"
Local $TesseractExePath = @ScriptDir & "\Tesseract.exe"
ShellExecuteWait(@ScriptDir & "\Tesseract.exe", '"' & $ImageToReadPath & '" "' & $ResultTextPath & '"', "", "", @SW_HIDE)

	If @error Then
		Exit MsgBox(0, "Error", @error)
	EndIf

	MsgBox(0, "Result", FileRead($OutPutPath))


FileDelete($OutPutPath)
EndFunc

Func _ListClick()
    If _GUICtrlListBox_GetCurSel($list) = -1 Then ;List clicked but nothing selected
        Return
    EndIf
    GUICtrlSetState($deletebutton, $GUI_ENABLE)
    GUICtrlSetState($editbutton, $GUI_ENABLE)
    Local $date = FileGetTime(@ScriptDir & "\images\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Size: " & _ConvertSize(FileGetSize(@ScriptDir & "\images\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))),1)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Date: " & $date[1] & "/" & $date[2] & "/" & StringTrimLeft($date[0],2) & " " & _ConvertTime($date[3] & ":" & $date[4]),4)
    _GDIPlus_StartUp()
    $hImage  = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\images\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
    $hGraphic = _GDIPlus_GraphicsCreateFromHWND($gui)
    $iWidth  = _GDIPlus_ImageGetWidth ($hImage)
    $iHeight = _GDIPlus_ImageGetHeight($hImage)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Width: " & $iWidth,2)
    _GUICtrlStatusBar_SetText($statusbar,@tab & "Height: " & $iHeight,3)
    Local $destW = 150
    Local $destH = 150
    _GDIPlus_GraphicsDrawImageRectRect($hGraphic, $hImage, 0, 0,$iWidth,$iHeight,450,20,$destW ,$destH)
    _GDIPlus_GraphicsSetSmoothingMode($hGraphic, 0)
    _GDIPlus_GraphicsDrawRect($hGraphic, 450, 20, $destW, $destH)
	 _GUICtrlStatusBar_SetText($statusbar,@tab & "Width: " & $iWidth,2)
	 Local $textOCR = ""
		_ocr(@ScriptDir & "\images\" & _GUICtrlListBox_GetText($list,_GUICtrlListBox_GetCurSel($list)))
	 _GUICtrlStatusBar_SetText($statusbar,@tab & "Word: " & "hi1",2)


    _GDIPlus_GraphicsDispose($hGraphic)
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_ShutDown()
EndFunc

Func _TakeScreenShot()
    Local $x, $y
    HotKeySet("s","_DoNothing")
    While Not _IsPressed(Hex(83,2))
        Local $currCoord = MouseGetPos()
        Sleep(10)
        ToolTip("Select top-left coord with 's' key" & @CRLF & "First coord: " & $currCoord[0] & "," & $currCoord[1])
        If _IsPressed(Hex(83,2)) Then
            While _IsPressed(Hex(83,2))
                Sleep(10)
            WEnd
            ExitLoop 1
        EndIf
    WEnd
    Local $firstCoord = MouseGetPos()
    _WinAPI_MoveWindow($SELECT_H,$firstCoord[0],$firstCoord[1],1,1)
    While Not _IsPressed(Hex(83,2))
        Local $currCoord = MouseGetPos()
        Sleep(10)
        ToolTip("Select bottom-right coord with 's' key" & @CRLF & "First coord: " & $firstCoord[0] & "," & $firstCoord[1] _
        & @CRLF & "Second coord: " & $currCoord[0] & "," & $currCoord[1] & @CRLF & "Image size: " & _
        Abs($currCoord[0]-$firstCoord[0]) & "x" & Abs($currCoord[1]-$firstCoord[1]))
        $x = _RubberBand_Select_Order($firstCoord[0],$currCoord[0])
        $y = _RubberBand_Select_Order($firstCoord[1],$currCoord[1])
        _WinAPI_MoveWindow($SELECT_H,$x[0],$y[0],$x[1],$y[1])
        If _IsPressed(Hex(83,2)) Then
            While _IsPressed(Hex(83,2))
                Sleep(10)
            WEnd
            ExitLoop 1
        EndIf
    WEnd
    ToolTip("")
    Local $secondCoord = MouseGetPos()
    _WinAPI_MoveWindow($SELECT_H,1,1,2,2)
    GUISetState(@SW_HIDE,$SELECT_H)
    Sleep(100)
    _ScreenCapture_SetJPGQuality(80)
    _ScreenCapture_Capture(@ScriptDir & "\images\" & $filename & $format,$x[0], $y[0], $x[1]+$x[0], $y[1]+$y[0])
    HotKeySet("s")
EndFunc

Func _ListFiles()
    _GUICtrlListBox_ResetContent($list)
    $search = FileFindFirstFile(@ScriptDir & "\images\*.*")
    If $search <> -1 Then
        While 1
            Local $file = FileFindNextFile($search)
            If @error Then ExitLoop
            If StringRegExp($file,"(.bmp)|(.jpg)|(.gif)|(.png)") Then
                $test_error = _GUICtrlListBox_AddFile($list, @ScriptDir & "\images\" & $file)
            EndIf
        WEnd
    EndIf
    FileClose($search)
    If _GUICtrlListBox_GetCurSel($list) = -1 Then  ; No selection
        GUICtrlSetState($deletebutton, $GUI_DISABLE)
        GUICtrlSetState($editbutton, $GUI_DISABLE)
        _GUICtrlStatusBar_SetText($statusbar,"",1)
        _GUICtrlStatusBar_SetText($statusbar,"",2)
        _GUICtrlStatusBar_SetText($statusbar,"",3)
        _GUICtrlStatusBar_SetText($statusbar,"",4)
        _GDIPlus_Startup()
        $hGraphicss = _GDIPlus_GraphicsCreateFromHWND($GUI)
        _GDIPlus_GraphicsFillRect($hGraphicss, 450, 20, 150, 150)
        _GDIPlus_GraphicsDispose($hGraphicss)
        _GDIPlus_Shutdown()
        _DrawText("Preview",495, 80)
    Else
        GUICtrlSetState($deletebutton, $GUI_ENABLE)
        GUICtrlSetState($editbutton, $GUI_ENABLE)
        _GUICtrlListBox_GetCurSel($list)
        WinWaitActive("Screen Region Capture")
        _ListClick()
    EndIf
EndFunc

Func _DrawText($text,$x, $y)
    _GDIPlus_Startup()
    $hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
    $hBrush   = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
    $hFormat  = _GDIPlus_StringFormatCreate()
    $hFamily  = _GDIPlus_FontFamilyCreate("Arial")
    $hFont    = _GDIPlus_FontCreate($hFamily, 12, 2)
    $tLayout  = _GDIPlus_RectFCreate($x, $y, 0, 0)
    $aInfo    = _GDIPlus_GraphicsMeasureString($hGraphic, $text, $hFont, $tLayout, $hFormat)
    _GDIPlus_GraphicsDrawStringEx($hGraphic, $text, $hFont, $aInfo[0], $hFormat, $hBrush)
    _GDIPlus_FontDispose        ($hFont   )
    _GDIPlus_FontFamilyDispose  ($hFamily )
    _GDIPlus_StringFormatDispose($hFormat )
    _GDIPlus_BrushDispose       ($hBrush  )
    _GDIPlus_GraphicsDispose    ($hGraphic)
    _GDIPlus_Shutdown()
EndFunc

Func _RubberBand_Select_Order($a,$b)
    Dim $res[2]
    If $a < $b Then
        $res[0] = $a
        $res[1] = $b - $a
    Else
        $res[0] = $b
        $res[1] = $a - $b
    EndIf
    Return $res
EndFunc

Func _DoNothing()
EndFunc