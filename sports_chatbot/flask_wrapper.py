from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Import your existing chatbot logic
def get_chatbot_response(user_message):
    """Wrapper for your existing chatbot logic"""
    user_message_lower = user_message.lower()
    
    # Your existing predefined keywords from views.py
    predefined_keywords = {
        # Greetings
        "hi": "Hello! How can I assist you today?",
        "hello": "Hi there! Need any help?",
        "hey": "Hey! How can I help you?",
        "good morning": "Good morning! Hope you have a productive day!",
        "good afternoon": "Good afternoon! How can I assist you?",
        "good evening": "Good evening! What can I do for you?",
        "you": "I'm just a bot, but I'm functioning perfectly! How can I assist you?",
        "your": "I'm just a bot, but I'm functioning perfectly! How can I assist you?",
        "what can you do": "I can help you with your queries, just ask me something!",
        "who are you": "I'm your virtual assistant, here to help you out!",
        "help": "Sure, I'm here to help. Please tell me your question.",
        "support": "You can ask your question here, and I'll do my best to assist you.",
        "thanks": "You're welcome!",
        "thank you": "Glad I could help!",
        "bye": "Goodbye! Have a nice day!",
        "goodbye": "See you later! Stay safe!",
        "name": "Nice Name! How can I assist you today?",
        "ok": "Alright! Feel free to ask more about our app or services.",
        "okay": "Alright! Feel free to ask more about our app or services.",
    }

    # Sort predefined_keywords by keyword length
    sorted_keywords = sorted(predefined_keywords.items(), key=lambda x: len(x[0]), reverse=True)

    # Matching logic — check if any keyword is in the user message
    matched = False
    for keyword, answer in sorted_keywords:
        if keyword in user_message_lower:
            bot_reply = answer
            matched = True
            break

    # Fallback if nothing matched
    if not matched:
        bot_reply = "Thanks for your question! We help you find sports, food, and travel companions. Ask me anything related!"

    return bot_reply

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({'error': 'No message provided'}), 400
        
        response = get_chatbot_response(user_message)
        
        return jsonify({
            'response': response,
            'status': 'success'
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Sports Chatbot is running!'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True) 