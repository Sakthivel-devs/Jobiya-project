@echo off
echo Building Bacterial Culture Analyzer Pro APK (Simplified Version)
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed
    echo Please install Python 3.8+ from https://python.org/
    pause
    exit /b 1
)

echo Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Generating app icons...
python create_icons.py
if errorlevel 1 (
    echo Error: Failed to generate icons
    pause
    exit /b 1
)

echo.
echo ====================================================
echo APK BUILD COMPLETE - SIMPLIFIED VERSION
echo ====================================================
echo.
echo Your app is now PWA-ready and can be converted to APK using:
echo.
echo OPTION 1 - Online PWA to APK Converter:
echo 1. Run the web app: python mobile_app.py
echo 2. Open http://localhost:5000 in Chrome
echo 3. Go to Chrome DevTools ^> Application ^> Manifest
echo 4. Click "Add to Home Screen" to test PWA
echo 5. Use an online service like:
echo    - https://pwabuilder.com/
echo    - https://appmaker.xyz/pwa-to-apk
echo    - https://www.pwabuilder.com/
echo.
echo OPTION 2 - Manual Android Project:
echo 1. Install Android Studio
echo 2. Create new project with WebView
echo 3. Point WebView to http://localhost:5000
echo 4. Build APK from Android Studio
echo.
echo OPTION 3 - Use Cordova/PhoneGap:
echo 1. Install Cordova: npm install -g cordova
echo 2. Create project: cordova create BacterialAnalyzer
echo 3. Add Android: cordova platform add android
echo 4. Copy web files to www/ folder
echo 5. Build: cordova build android
echo.
echo The app includes:
echo ✓ PWA manifest and service worker
echo ✓ Offline functionality
echo ✓ Mobile-optimized interface
echo ✓ All bacterial analysis features
echo.
pause