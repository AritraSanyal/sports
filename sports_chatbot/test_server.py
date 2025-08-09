#!/usr/bin/env python3
"""
Test script for the Flask chatbot server
"""
import requests
import json
import time

def test_server():
    """Test the chatbot server"""
    base_url = "http://localhost:8000"
    
    print("🧪 Testing Sports Chatbot Server")
    print("=" * 40)
    
    # Test health endpoint
    try:
        print("1. Testing health endpoint...")
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            print("✅ Health check passed!")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure it's running on port 8000")
        return False
    
    # Test chat endpoint
    try:
        print("\n2. Testing chat endpoint...")
        test_message = "hello"
        response = requests.post(
            f"{base_url}/chat",
            headers={"Content-Type": "application/json"},
            data=json.dumps({"message": test_message})
        )
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Chat endpoint working!")
            print(f"   Message: {test_message}")
            print(f"   Response: {data.get('response', 'No response')}")
        else:
            print(f"❌ Chat endpoint failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to chat endpoint")
        return False
    
    print("\n🎉 All tests passed! Server is working correctly.")
    return True

if __name__ == "__main__":
    test_server() 