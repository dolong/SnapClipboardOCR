


ocr()


Func ocr()

	Local $image1 = @ScriptDir & "\images\2.bmp"
ShellExecuteWait(@ScriptDir & "\Tesseract.exe", '"' & $image1 &'" "' &@ScriptDir & "\Result" & '"', "", "", @SW_HIDE)

If @error Then
	Exit MsgBox(0, "Error", @error)
EndIf

MsgBox(0, "Result", FileRead(@ScriptDir & "\Result.txt"))

FileDelete(@ScriptDir & "\Result.txt")


EndFunc