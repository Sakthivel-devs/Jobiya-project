@echo off
echo Building Bacterial Culture Analyzer Pro APK...
echo.

REM Check prerequisites
echo Checking prerequisites...

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo Error: Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if Java JDK is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo Error: Java JDK is not installed
    echo Please install Java JDK 11+ from https://adoptium.net/
    pause
    exit /b 1
)

REM Check if Android SDK is available (optional but recommended)
if not exist "%ANDROID_HOME%" (
    echo Warning: ANDROID_HOME not set. Android SDK may not be available.
    echo Consider installing Android Studio for full Android development support.
)

echo Prerequisites check complete.
echo.

REM Install Node.js dependencies
echo Installing Node.js dependencies...
npm install
if errorlevel 1 (
    echo Error: Failed to install Node.js dependencies
    pause
    exit /b 1
)

echo.

REM Install Python dependencies
echo Installing Python dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install Python dependencies
    pause
    exit /b 1
)

echo.

REM Generate icons
echo Generating app icons...
python create_icons.py
if errorlevel 1 (
    echo Error: Failed to generate icons
    pause
    exit /b 1
)

echo.

REM Build Capacitor project
echo Building Capacitor project...
npx cap add android
if errorlevel 1 (
    echo Error: Failed to add Android platform
    pause
    exit /b 1
)

npx cap sync android
if errorlevel 1 (
    echo Error: Failed to sync Android project
    pause
    exit /b 1
)

echo.

REM Build APK
echo Building APK...
cd android
if not exist "gradlew" (
    echo Error: Gradle wrapper not found
    cd ..
    pause
    exit /b 1
)

REM Build debug APK
./gradlew assembleDebug
if errorlevel 1 (
    echo Error: Failed to build debug APK
    cd ..
    pause
    exit /b 1
)

cd ..
echo.

REM Copy APK to root directory
if exist "android\app\build\outputs\apk\debug\app-debug.apk" (
    copy "android\app\build\outputs\apk\debug\app-debug.apk" "BacterialAnalyzer-debug.apk"
    echo.
    echo SUCCESS! APK created: BacterialAnalyzer-debug.apk
    echo.
    echo To install on Android device:
    echo 1. Enable "Install from unknown sources" in Android settings
    echo 2. Transfer the APK to your device
    echo 3. Open the APK file on your device to install
    echo.
    echo For release APK, run: npm run android:release
    echo (Note: Release build requires signing configuration)
) else (
    echo Error: APK not found in expected location
    echo Check android\app\build\outputs\apk\debug\ for the APK file
)

echo.
pause