#!/usr/bin/env python3
"""
Startup script for the Sports Chatbot Flask server
"""
import os
import sys
import subprocess

def install_requirements():
    """Install required packages"""
    print("Installing required packages...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Packages installed successfully!")
    except subprocess.CalledProcessError:
        print("❌ Failed to install packages. Please install manually:")
        print("pip install flask flask-cors django")
        return False
    return True

def start_server():
    """Start the Flask server"""
    print("Starting Sports Chatbot server...")
    print("Server will be available at: http://localhost:8000")
    print("For Flutter Android emulator, use: http://10.0.2.2:8000")
    print("Press Ctrl+C to stop the server")
    print("-" * 50)
    
    try:
        from flask_wrapper import app
        app.run(host='0.0.0.0', port=8000, debug=True)
    except ImportError as e:
        print(f"❌ Error importing Flask app: {e}")
        print("Make sure flask_wrapper.py exists in the current directory")
    except Exception as e:
        print(f"❌ Error starting server: {e}")

if __name__ == "__main__":
    print("🏈 Sports Chatbot Server Setup")
    print("=" * 40)
    
    # Install requirements
    if install_requirements():
        # Start server
        start_server()
    else:
        print("Please fix the installation issues and try again.") 