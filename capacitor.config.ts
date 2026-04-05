import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.labtools.bacterialanalyzer',
  appName: 'Bacterial Culture Analyzer Pro',
  webDir: 'templates',
  bundledWebRuntime: false,
  server: {
    url: 'http://localhost:5000',
    cleartext: true
  },
  android: {
    allowMixedContent: true,
    webContentsDebuggingEnabled: true
  }
};

export default config;