# Bacterial Culture Analyzer Pro - Android APK

This project converts the Bacterial Culture Analyzer Pro web application into an Android APK using Capacitor.

## Prerequisites

Before building the APK, ensure you have the following installed:

1. **Node.js** (v16 or higher) - https://nodejs.org/
2. **Python 3.8+** - https://python.org/
3. **Java JDK 11+** - https://adoptium.net/
4. **Android Studio** (recommended) - https://developer.android.com/studio

## Quick Build

1. **Clone/Download** this project
2. **Run the build script**:
   ```batch
   build_apk.bat
   ```

The script will:
- Install all dependencies
- Generate app icons
- Create the Android project
- Build the debug APK

## Manual Build Steps

If you prefer to build manually:

1. **Install Python dependencies**:
   ```batch
   pip install -r requirements.txt
   ```

2. **Install Node.js dependencies**:
   ```batch
   npm install
   ```

3. **Generate icons**:
   ```batch
   python create_icons.py
   ```

4. **Add Android platform**:
   ```batch
   npx cap add android
   ```

5. **Sync project**:
   ```batch
   npx cap sync android
   ```

6. **Build APK**:
   ```batch
   cd android
   ./gradlew assembleDebug
   ```

## Running the App

### Development Mode
```batch
python mobile_app.py
```

### Production APK
The built APK will be in the root directory as `BacterialAnalyzer-debug.apk`

## Features

- **Progressive Web App (PWA)**: Works offline with service worker
- **Native Android App**: Built with Capacitor for native performance
- **Bacterial Analysis**: Complete growth curve analysis tools
- **Interactive Charts**: Matplotlib-generated charts with real-time updates
- **Data Management**: Import/export CSV, session management
- **Mobile Optimized**: Responsive design for mobile devices

## App Permissions

The app may request the following permissions:
- **Internet**: For API communication
- **Storage**: For saving analysis data and sessions

## Troubleshooting

### Build Issues
- Ensure all prerequisites are installed
- Check that `ANDROID_HOME` environment variable is set
- Try running `npx cap doctor` to diagnose issues

### Runtime Issues
- Enable "Install from unknown sources" in Android settings
- Check device storage space
- Ensure stable internet connection for initial load

## Development

### Project Structure
```
├── app.py                 # Main Flask backend
├── mobile_app.py          # Mobile-optimized Flask app
├── templates/
│   └── index.html         # Main web interface (PWA)
├── static/
│   ├── manifest.json      # PWA manifest
│   ├── sw.js             # Service worker
│   └── icon-*.png        # App icons
├── android/               # Generated Android project
├── capacitor.config.ts    # Capacitor configuration
└── package.json          # Node.js dependencies
```

### Adding New Features
1. Modify the web interface in `templates/index.html`
2. Add backend endpoints in `app.py`
3. Test on web first: `python app.py`
4. Rebuild APK: `build_apk.bat`

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Android Studio logs during build
3. Ensure all dependencies are up to date
- **CSV Export**: Download processed data
- **Session Save**: Save entire analysis sessions as JSON
- **Print Reports**: Generate printable reports

## API Endpoints

- `GET /api/data` - Get current dataset
- `GET /api/chart/<type>` - Get chart image (growth, heatmap, radar)
- `GET /api/analyze/<condition>` - Analyze specific growth condition
- `POST /api/upload` - Upload CSV data
- `GET /api/export/<format>` - Export data (csv)

## Dependencies

- **Flask**: Web framework
- **NumPy & SciPy**: Scientific computing
- **Pandas**: Data manipulation
- **Matplotlib**: Chart generation
- **Plotly**: Interactive visualizations
- **scikit-learn**: Machine learning utilities

## Browser Support

- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

## Data Format

CSV files should be formatted as:
```csv
Time,Control,TreatmentA,TreatmentB
0,0.01,0.01,0.01
0.5,0.015,0.012,0.014
1.0,0.025,0.018,0.022
...
```

## Troubleshooting

- **No charts displayed**: Ensure all Python dependencies are installed
- **Import errors**: Check CSV format matches the expected structure
- **Performance issues**: Large datasets may take longer to process

## License

This project is open source and available under the MIT License.