@echo off
echo Creating Bacterial Culture Analyzer Pro APK Package...
echo.

cd "f:\New folder"

REM Create APK package directory
if exist "apk_package" rmdir /s /q "apk_package"
mkdir "apk_package"

REM Copy web files
echo Copying web files...
copy "templates\index.html" "apk_package\index.html"
copy "static\manifest.json" "apk_package\manifest.json"
copy "static\sw.js" "apk_package\sw.js"
copy "static\icon-192.png" "apk_package\icon-192.png"
copy "static\icon-512.png" "apk_package\icon-512.png"
copy "static\mobile_launcher.html" "apk_package\mobile_launcher.html"

REM Create a simple server launcher for APK
echo Creating APK server launcher...
(
echo @echo off
echo echo Starting Bacterial Culture Analyzer Pro Server...
echo cd /d "%%~dp0"
echo python mobile_app.py
echo pause
) > "apk_package\start_server.bat"

REM Create README for APK
echo Creating APK instructions...
(
echo # Bacterial Culture Analyzer Pro - APK Package
echo.
echo This package contains everything needed to create an Android APK.
echo.
echo ## Method 1: Online APK Converter (Recommended)
echo.
echo 1. Start the server: double-click start_server.bat
echo 2. Open http://localhost:5000 in your browser
echo 3. Use one of these online services:
echo.
echo    PWABuilder: https://www.pwabuilder.com/
echo    App Maker: https://appmaker.xyz/pwa-to-apk
echo    Digital Inspiration: https://www.labnol.org/pwa-to-apk
echo.
echo 4. Upload this entire folder to the converter
echo 5. Download your APK
echo.
echo ## Method 2: Manual Android Project
echo.
echo 1. Install Android Studio
echo 2. Create new project with WebView
echo 3. Copy files to assets/www/
echo 4. Point WebView to local server
echo 5. Build APK
echo.
echo ## Features
echo - Bacterial growth analysis
echo - Interactive charts
echo - Data import/export
echo - Offline functionality
echo - Mobile optimized
) > "apk_package\README.md"

REM Create package ZIP
echo Creating ZIP package...
powershell "Compress-Archive -Path 'apk_package\*' -DestinationPath 'BacterialAnalyzer_APK_Package.zip' -Force"

echo.
echo ====================================================
echo APK PACKAGE CREATED SUCCESSFULLY!
echo ====================================================
echo.
echo Files created:
echo - BacterialAnalyzer_APK_Package.zip (ready for online converters)
echo - apk_package\ (source files)
echo.
echo Next steps:
echo 1. Extract BacterialAnalyzer_APK_Package.zip
echo 2. Run start_server.bat to start the app
echo 3. Use an online APK converter service
echo.
echo Your APK will include:
echo ✓ Bacterial analysis tools
echo ✓ Interactive charts
echo ✓ Data management
echo ✓ Offline functionality
echo ✓ Mobile-optimized UI
echo.
pause