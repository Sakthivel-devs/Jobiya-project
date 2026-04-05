#!/usr/bin/env python3
"""
Bacterial Culture Analyzer Pro - Launcher Script
"""

import os
import sys
import subprocess

def check_dependencies():
    """Check if required packages are installed"""
    try:
        import flask
        import numpy
        import pandas
        import matplotlib
        import scipy
        print("✓ All dependencies are installed")
        return True
    except ImportError as e:
        print(f"✗ Missing dependency: {e}")
        print("Run: pip install -r requirements.txt")
        return False

def main():
    """Main launcher function"""
    print("Bacterial Culture Analyzer Pro")
    print("=" * 40)

    if not check_dependencies():
        return

    print("\nStarting Flask server...")
    print("Open your browser to: http://localhost:5000")
    print("Press Ctrl+C to stop the server\n")

    # Run the Flask app
    try:
        subprocess.run([sys.executable, "app.py"], check=True)
    except KeyboardInterrupt:
        print("\nServer stopped.")
    except subprocess.CalledProcessError as e:
        print(f"Error running server: {e}")

if __name__ == "__main__":
    main()