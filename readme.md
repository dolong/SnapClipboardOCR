# Introduction
SnapClipboardOCR:
* Takes a Screenshot of the desktop. Press "S" for first coordinate, "S" again for second portion.
![select](https://raw.githubusercontent.com/dolong/SnapClipboardOCR/master/limitations.png)
* Opens a pop-up to display text
![ocr](https://raw.githubusercontent.com/dolong/SnapClipboardOCR/master/limitations2.png)

# Structure
## Frameworks and Libraries
* Tesseract
* AutoIt
* TOCOME: IMAGEMAGICK

## App Structure

SnapClipboardOCR/
----- images/	// Screenshot folder of clipped area
---------- screenie.BMP	// saved last image
tesseract.exe // Tesseract (3.0.5)
screenie.au3	// Main Program, immediately triggers
screenie.exe	// Compiled Program
GUIFileSelector.au3 // Main Program with GUI for file selection and previewing

## Limitations
* You must set $stretchX = 1.5, $stretchY = 1.5 to 
appropriate values of your desktop scaling for windows 8+
* DoubleSize() is not working completely with the application, 
it works and doubles the size of images for clearing 
  the images so the OCR can better read it, but currently it 
  mostly does not recognize the image afterwards for no apparent reason.


