# Sports Chatbot Integration

This folder contains the Python backend for the Sports Chatbot that integrates with your Flutter app.

## Quick Start

### 1. Install Python Dependencies

```bash
cd sports_chatbot
pip install -r requirements.txt
```

### 2. Start the Server

**Option A: Using the startup script (Recommended)**
```bash
python start_server.py
```

**Option B: Direct Flask server**
```bash
python flask_wrapper.py
```

### 3. Test the Server

The server will be running at:
- **Local**: http://localhost:8000
- **Flutter Android Emulator**: http://10.0.2.2:8000
- **Physical Device**: Use your computer's IP address (e.g., http://192.168.1.100:8000)

### 4. Test the API

You can test the chatbot API using curl:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "hello"}'
```

## Flutter Integration

The Flutter app is already configured to connect to the chatbot server. The chatbot screen will appear as a new card on your home screen.

### URL Configuration

If you need to change the server URL in your Flutter app, update the URL in `lib/screen/chatbot_screen.dart`:

```dart
// For Android emulator
Uri.parse('http://10.0.2.2:8000/chat')

// For physical device (replace with your computer's IP)
Uri.parse('http://192.168.1.100:8000/chat')
```

## Features

- **Keyword-based responses**: The chatbot responds to greetings, questions, and sports-related queries
- **Fallback responses**: Default responses for unrecognized messages
- **CORS enabled**: Allows Flutter app to communicate with the server
- **Error handling**: Graceful error handling for connection issues

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port in `flask_wrapper.py`
2. **Connection refused**: Make sure the server is running and the URL is correct
3. **CORS errors**: The server has CORS enabled, but check if your firewall is blocking connections

### Getting Your Computer's IP Address

**On macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**On Windows:**
```bash
ipconfig | findstr "IPv4"
```

## Development

The chatbot logic is in `flask_wrapper.py`. You can modify the `predefined_keywords` dictionary to add new responses or change existing ones.

## Files Structure

```
sports_chatbot/
├── flask_wrapper.py      # Flask server with chatbot logic
├── start_server.py       # Startup script
├── requirements.txt      # Python dependencies
├── README.md            # This file
├── manage.py            # Django management script
├── chatbot/             # Original Django app
└── sports_chatbot/      # Django project settings
``` 