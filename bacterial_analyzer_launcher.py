#!/usr/bin/env python3
"""
Bacterial Culture Analyzer Pro - APK Launcher
This script creates a standalone executable that runs the bacterial analyzer.
"""

import sys
import os
import subprocess
import webbrowser
import time
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
import socketserver
import zipfile

class QuietHTTPRequestHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress log messages

def extract_web_files():
    """Extract web files from the embedded ZIP"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    web_dir = os.path.join(script_dir, 'web_app')

    if not os.path.exists(web_dir):
        os.makedirs(web_dir)

    # For now, we'll assume the files are in the same directory
    # In a real APK, these would be embedded
    return script_dir

def start_server(port=8080):
    """Start a simple HTTP server"""
    web_dir = extract_web_files()

    os.chdir(web_dir)

    try:
        with socketserver.TCPServer(("", port), QuietHTTPRequestHandler) as httpd:
            print(f"Server running at http://localhost:{port}")
            print("Opening app in browser...")
            webbrowser.open(f"http://localhost:{port}/mobile_launcher.html")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")

def main():
    print("🧬 Bacterial Culture Analyzer Pro")
    print("=================================")
    print()

    # Check if Python Flask server is available
    try:
        import flask
        print("✓ Flask available - starting full server...")

        # Try to start the Flask server
        script_dir = os.path.dirname(os.path.abspath(__file__))
        app_path = os.path.join(script_dir, 'mobile_app.py')

        if os.path.exists(app_path):
            print("Starting Flask server...")
            subprocess.run([sys.executable, app_path])
        else:
            print("Flask app not found, starting simple server...")
            start_server()

    except ImportError:
        print("Flask not available, starting simple web server...")
        start_server()

if __name__ == "__main__":
    main()