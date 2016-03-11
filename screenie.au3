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

Global $format = ".bmp"
Global $filename = ""
Global $title = "Screen Region Capture"

DirCreate(@ScriptDir & "/images/")
$go_button = GUICtrlCreateButton("Select region",20,140,200,30)
$exitbutton = GUICtrlCreateButton("Exit", 400,140,40)
Global $a_PartsRightEdge[5] = [240,320,400,480,-1]
Global $hImage
$stretchX = 1.5
$stretchY = 1.5
$SELECT_H =  GUICreate( "AU3SelectionBox", 0 , 0 , 0, 0,  $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW)
GUISetBkColor(0x00FFFF,$SELECT_H)
WinSetTrans("AU3SelectionBox","",60)
GUISetState(@SW_SHOW,$SELECT_H)

            $filename = "screenie.bmp"
                    _WinAPI_MoveWindow($SELECT_H,1,1,2,2)
                    GUISetState(@SW_RESTORE,$SELECT_H)
                    GUISetState(@SW_SHOW,$SELECT_H)
                    _TakeScreenShot()

	Local $img = @ScriptDir & "\images\" & "screenie.bmp"
	; doubleSize (FileGetShortname($img))

	; MsgBox("","",$img)
	ocr($img)

Func ocr($image1)
ShellExecuteWait(@ScriptDir & "\Tesseract.exe", '"' & $image1 &'" "' & @ScriptDir & "\Result" & '"', "", "", @SW_HIDE)

	If @error Then
		Exit MsgBox(0, "Error", @error)
	EndIf
	$result1 = FileRead(@ScriptDir & "\Result.txt")
	; MsgBox(0, "Result", $result1)
	GUICreate("Text Value", 240,125,200,120)
	ClipPut ( $result1 )
	$gui_img_input = GUICtrlCreateLabel("Clipped Text",20,5)
	$gui_img_input = GUICtrlCreateEdit($result1, 20, 25, 200, 85)
	GUISetState(@SW_SHOW)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idOK
                ExitLoop

        EndSwitch
    WEnd

	FileDelete(@ScriptDir & "\Result.txt")



EndFunc   ;==>ocrsss

Func _TakeScreenShot()
	Local $x, $y
	HotKeySet("s", "_DoNothing")
	While Not _IsPressed(Hex(83, 2))
		Local $currCoord = MouseGetPos()
		Sleep(10)
		ToolTip("Select top-left coord with 's' key" & @CRLF & "First coord: " & $currCoord[0] & "," & $currCoord[1])
		If _IsPressed(Hex(83, 2)) Then
			While _IsPressed(Hex(83, 2))
				Sleep(10)
			WEnd
			ExitLoop 1
		EndIf
	WEnd
	Local $firstCoord = MouseGetPos()
	_WinAPI_MoveWindow($SELECT_H, $firstCoord[0], $firstCoord[1], 1, 1)
	While Not _IsPressed(Hex(83, 2))
		Local $currCoord = MouseGetPos()
		Sleep(10)
		ToolTip("Select bottom-right coord with 's' key" & @CRLF & "First coord: " & $firstCoord[0] & "," & $firstCoord[1] _
				 & @CRLF & "Second coord: " & $currCoord[0] & "," & $currCoord[1] & @CRLF & "Image size: " & _
				Abs($currCoord[0] - $firstCoord[0]) & "x" & Abs($currCoord[1] - $firstCoord[1]))
		$x = _RubberBand_Select_Order($firstCoord[0], $currCoord[0])
		$y = _RubberBand_Select_Order($firstCoord[1], $currCoord[1])
		_WinAPI_MoveWindow($SELECT_H, $x[0], $y[0], $x[1], $y[1])
		If _IsPressed(Hex(83, 2)) Then
			While _IsPressed(Hex(83, 2))
				Sleep(10)
			WEnd
			ExitLoop 1
		EndIf
	WEnd
	ToolTip("")
	Local $secondCoord = MouseGetPos()
	_WinAPI_MoveWindow($SELECT_H, 1, 1, 2, 2)
	GUISetState(@SW_HIDE, $SELECT_H)
	Sleep(100)
	_ScreenCapture_SetJPGQuality(80)

	;MsgBox($MB_SYSTEMMODAL, "Mouse x, y:", $x[1] & ", " & $y[1])
	_ScreenCapture_Capture(@ScriptDir & "\images\" & $filename, $x[0] * $stretchX, $y[0] * $stretchY, ($x[1] + $x[0]) * $stretchX, ($y[1] + $y[0]) * $stretchY)
	$img = '"' & @ScriptDir & '\images\' & $filename & '"'

	;	MsgBox("","",$img)
	HotKeySet("s")

EndFunc   ;==>_TakeScreenShot

Func doubleSize($img)

$dir = FileGetShortname("C:\Program Files\ImageMagick-6.9.3-Q16\convert.exe")
	$CMD = '"' & $dir & '" ' & $img & ' -resize 200% ' & $img
RunWait('"' & @ComSpec & '" /k ' & $CMD, @ScriptDir)

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