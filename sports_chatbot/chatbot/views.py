from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json


@csrf_exempt
def chat(request):
    # if request.method == 'POST':
    #     user_message = request.POST.get('message', '').lower()  # convert to lowercase
    if request.method == 'POST':
        try:
            # Try to parse JSON data (for Postman / fetch API)
            data = json.loads(request.body)
            user_message = data.get('message', '').lower()
        except json.JSONDecodeError:
            # Fallback: try form data (for HTML forms)
            user_message = request.POST.get('message', '').lower()

        # Keyword-based predefined responses
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

        # Lowercase user message
        user_message_lower = user_message.lower()

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

        return JsonResponse({'reply': bot_reply})
    
    return JsonResponse({'reply': 'Invalid request method.'}, status=400)


