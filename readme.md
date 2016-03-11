# Introduction
SnapClipboardOCR:
* Displaying current weather in Toronto
* Predicting in real time when the next TTC bus of your choice will arrive

This web app is for Torontonians who are tired of switching between many platforms to know the weather and their bus time every morning before they leave the house. 


# Structure
## Frameworks and Libraries
* Tesseract
* AutoIt
* TOCOME: IMAGEMAGICK

## App Structure

```javascript
SnapClipboardOCR/
----- images/	// Screenshot folder of clipped area
---------- screenie.BMP	// saved last image
tesseract.exe // Tesseract (3.0.5)
screenie.au3	// Main Program, immediately triggers
screenie.exe	// Compiled Program
GUIFileSelector.au3 // Main Program with GUI for file selection and previewing

## Limitations
* You must set $stretchX = 1.5, $stretchY = 1.5 to appropriate values of your desktop scaling for windows 8+
* DoubleSize() is not working completely with the application, it works and doubles the size of images for clearing 
* OCR, but currently it mostly doesn't recognize the image afterwards for no reason.


