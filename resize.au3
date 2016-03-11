
;Func doubleSize()

;	$CMD = '"C:\Program Files\ImageMagick-6.9.3-Q16\convert.exe" ' & 'out.bmp' & ' -resize 200% out.bmp'
;RunWait('"' & @ComSpec & '" /k ' & $CMD, @ScriptDir)

;EndFunc
;doubleSize ()


Func doubleSize($img)

$dir = FileGetShortname("C:\Program Files\ImageMagick-6.9.3-Q16\convert.exe")
	$CMD = '"' & $dir & '" ' & $img & ' -resize 200x150% ' & $img
RunWait('"' & @ComSpec & '" /k ' & $CMD, @ScriptDir)

EndFunc
$img = FileGetShortname("C:\Users\Long\Google Drive\icmclipboard\TesseractExample\images\screenie.bmp")
doubleSize($img)
