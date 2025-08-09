import 'package:flutter_app/model/unified_model.dart';

class LocalChatbotService {
  // Exact predefined responses from your sports_chatbot/chatbot/views.py
  static final Map<String, String> _predefinedKeywords = {
    // Greetings
    "hi": "Hello! How can I assist you today?",
    "hello": "Hi there! Need any help?",
    "hey": "Hey! How can I help you?",
    "good morning": "Good morning! Hope you have a productive day!",
    "good afternoon": "Good afternoon! How can I assist you?",
    "good evening": "Good evening! What can I do for you?",
    "you":
        "I'm just a bot, but I'm functioning perfectly! How can I assist you?",
    "your":
        "I'm just a bot, but I'm functioning perfectly! How can I assist you?",
    "what can you do":
        "I can help you with your queries, just ask me something!",
    "who are you": "I'm your virtual assistant, here to help you out!",
    "help": "Sure, I'm here to help. Please tell me your question.",
    "support":
        "You can ask your question here, and I'll do my best to assist you.",
    "thanks": "You're welcome!",
    "thank you": "Glad I could help!",
    "bye": "Goodbye! Have a nice day!",
    "goodbye": "See you later! Stay safe!",
    "name": "Nice Name! How can I assist you today?",
    "ok": "Alright! Feel free to ask more about our app or services.",
    "okay": "Alright! Feel free to ask more about our app or services.",

    // Keyword-based responses
    "find sports buddy":
        "Looking for someone to play your favorite sport? Go to the Sports Companion and apply filters like city, sport, gender, and date to find your perfect companion.",
    "buddy":
        "Looking for someone to play your favorite sport? Go to the Sports Companion and apply filters like city, sport, gender, and date to find your perfect companion.",
    "find sport buddy":
        "Looking for someone to play your favorite sport? Go to the Sports Companion and apply filters like city, sport, gender, and date to find your perfect companion.",

    "gym buddy":
        "Searching for a gym partner to stay fit and motivated? 🏋‍♂ Head over to the Sports Companion section, select 'Gym' as your activity, apply location filters, and find your perfect workout buddy!",
    "gym persion":
        "Searching for a gym partner to stay fit and motivated? 🏋‍♂ Head over to the Sports Companion section, select 'Gym' as your activity, apply location filters, and find your perfect workout buddy!",
    "gym partner":
        "Searching for a gym partner to stay fit and motivated? 🏋‍♂ Head over to the Sports Companion section, select 'Gym' as your activity, apply location filters, and find your perfect workout buddy!",

    "food buddy":
        "Looking for someone to explore new dishes or cafes with? 🍜 Visit the Food Companion section, choose your favorite cuisine and city, and connect with fellow foodies today!",
    "food person":
        "Looking for someone to explore new dishes or cafes with? 🍜 Visit the Food Companion section, choose your favorite cuisine and city, and connect with fellow foodies today!",
    "breakfast":
        "Looking for someone to explore new dishes or cafes with? 🍜 Visit the Food Companion section, choose your favorite cuisine and city, and connect with fellow foodies today!",
    "dinner":
        "Looking for someone to explore new dishes or cafes with? 🍜 Visit the Food Companion section, choose your favorite cuisine and city, and connect with fellow foodies today!",
    "lunch":
        "Looking for someone to explore new dishes or cafes with? 🍜 Visit the Food Companion section, choose your favorite cuisine and city, and connect with fellow foodies today!",

    "travel buddy":
        "Want to travel the world but not alone? 🌍 Go to the Travel Companion section, enter your dream destination, budget, and trip dates to find like-minded travel partners instantly!",
    "travel person":
        "Want to travel the world but not alone? 🌍 Go to the Travel Companion section, enter your dream destination, budget, and trip dates to find like-minded travel partners instantly!",
    "travel member":
        "Want to travel the world but not alone? 🌍 Go to the Travel Companion section, enter your dream destination, budget, and trip dates to find like-minded travel partners instantly!",
    "travel partner":
        "Want to travel the world but not alone? 🌍 Go to the Travel Companion section, enter your dream destination, budget, and trip dates to find like-minded travel partners instantly!",
    "travel people":
        "Want to travel the world but not alone? 🌍 Go to the Travel Companion section, enter your dream destination, budget, and trip dates to find like-minded travel partners instantly!",

    "create sports session":
        "Want to organize a match or game? Head to Create Sport Requirement and fill in the sport, location, group name, and time. Let the fun begin!",
    "create sports requirements":
        "Want to organize a match or game? Head to Create Sport Requirement and fill in the sport, location, group name, and time. Let the fun begin!",
    "create sports companion":
        "Want to organize a match or game? Head to Create Sport Requirement and fill in the sport, location, group name, and time. Let the fun begin!",

    "join food meetup":
        "Craving a good conversation over delicious food? Explore the Food Companion section and find people who love the same cuisines as you.",
    "find foodies in my city":
        "Simply enter your city and preferred cuisine in the Food Companion filter to discover nearby foodie buddies.",

    "start a travel plan":
        "Planning your next adventure? Go to Travel Partner > Create Trip, fill in your destination, date, and budget, and get ready to explore with new friends.",
    "find travel partners":
        "To find like-minded travel companions, visit Travel Partner and use filters like destination, date, and trip type. Adventure awaits!",

    "show nearby sessions":
        "You can see upcoming sports, food, or travel meetups near you by selecting your city and adjusting the distance slider.",
    "show nearby companion":
        "You can see upcoming sports, food, or travel meetups near you by selecting your city and adjusting the distance slider.",
    "nearby":
        "You can see upcoming sports, food, or travel meetups near you by selecting your city and adjusting the distance slider.",
    "show nearby events":
        "You can see upcoming sports, food, or travel meetups near you by selecting your city and adjusting the distance slider.",
    "events":
        "You can see upcoming sports, food, or travel meetups near you by selecting your city and adjusting the distance slider.",

    "reset filters":
        "To remove all current selections and start fresh, just tap on the Reset button in any companion section.",
    "rapply filters":
        "After selecting your preferences like location, type, age, and more, click on Apply to get customized results.",
    "filters":
        "You can find companions and create groups based on your preferences by applying different filters.",

    "sports chatbot help":
        "Hey! I’m your AI Sports Assistant 🧠. Ask me anything about finding or creating sports meetups, joining groups, or managing your sessions!",
    "food chatbot help":
        "Hungry for foodie fun? 🍕 Ask me anything about creating or finding food meetups, companions, or dining groups in your area.",
    "travel chatbot help":
        "Ready to explore? 🌍 I can help you plan trips, find companions, or join travel groups based on your dream destinations.",

    "cost":
        "Here's our pricing in both directions:\n\n"
        "💰 Price → Connections:\n"
        "₹50 = 10 companions\n"
        "₹75 = 15 companions\n"
        "₹100 = 20 companions\n"
        "Free = 5 companions\n\n"
        "🔢 Connections → Price:\n"
        "5 companions = Free\n"
        "10 companions = ₹50\n"
        "15 companions = ₹75\n"
        "20 companions = ₹100\n\n"
        "All plans work across Sports, Food & Travel.",

    "plan":
        "Our pricing works both ways:\n\n"
        "➡️ By Price:\n"
        "- ₹50: 10 companions\n"
        "- ₹75: 15 companions\n"
        "- ₹100: 20 companions\n"
        "- Free: 5 companions\n\n"
        "⬅️ By Companions Needed:\n"
        "- Need 5? Free plan\n"
        "- Need 10? ₹50 plan\n"
        "- Need 15? ₹75 plan\n"
        "- Need 20? ₹100 plan",

    "upgrade":
        "Upgrade options in both directions:\n\n"
        "Price → Connections:\n"
        "₹50 → 10\n"
        "₹75 → 15\n"
        "₹100 → 20\n\n"
        "Connections → Price:\n"
        "5 → Free\n"
        "10 → ₹50\n"
        "15 → ₹75\n"
        "20 → ₹100",

    // Specific number queries
    "5":
        "You can connect with 5 companions for free!\n"
        "This is our Free Plan offering.\n"
        "Want more? Upgrade to:\n"
        "• 10 companions = ₹50\n"
        "• 15 companions = ₹75\n"
        "• 20 companions = ₹100",
    "5 companions":
        "You can connect with 5 companions for free!\n"
        "This is our Free Plan offering.\n"
        "Want more? Upgrade to:\n"
        "• 10 companions = ₹50\n"
        "• 15 companions = ₹75\n"
        "• 20 companions = ₹100",
    "five companions":
        "You can connect with 5 companions for free!\n"
        "This is our Free Plan offering.\n"
        "Want more? Upgrade to:\n"
        "• 10 companions = ₹50\n"
        "• 15 companions = ₹75\n"
        "• 20 companions = ₹100",
    "five":
        "5 companion connections come with our Free Plan at no cost!\n"
        "Upgrade options:\n"
        "₹50 = 10 (+5 more)\n"
        "₹75 = 15 (+10 more)\n"
        "₹100 = 20 (+15 more)",

    "10":
        "To get 10 companion connections, choose the ₹50 plan.\n"
        "Comparison:\n"
        "Free = 5\n"
        "₹50 = 10\n"
        "₹75 = 15\n"
        "₹100 = 20",
    "10 companions":
        "To get 10 companion connections, choose the ₹50 plan.\n"
        "Comparison:\n"
        "Free = 5\n"
        "₹50 = 10\n"
        "₹75 = 15\n"
        "₹100 = 20",
    "ten companions":
        "10 connections are available in the ₹50 plan.\n"
        "That's double the free plan!\n"
        "Other options:\n"
        "15 = ₹75\n"
        "20 = ₹100",

    "15":
        "For 15 companion connections, select the ₹75 plan.\n"
        "This gives you:\n"
        "+10 over free (5)\n"
        "+5 over ₹50 plan (10)\n"
        "Maximum is 20 at ₹100",
    "fifteen":
        "15 connections come with the ₹75 plan.\n"
        "That's 3× the free plan capacity!\n"
        "Other options:\n"
        "10 = ₹50\n"
        "20 = ₹100",
    "15 companions":
        "For 15 companion connections, select the ₹75 plan.\n"
        "This gives you:\n"
        "+10 over free (5)\n"
        "+5 over ₹50 plan (10)\n"
        "Maximum is 20 at ₹100",
    "fifteen companions":
        "15 connections come with the ₹75 plan.\n"
        "That's 3× the free plan capacity!\n"
        "Other options:\n"
        "10 = ₹50\n"
        "20 = ₹100",

    "20":
        "The maximum 20 companion connections come with the ₹100 plan.\n"
        "This is 4× the free plan capacity!\n"
        "Lower options:\n"
        "15 = ₹75\n"
        "10 = ₹50\n"
        "5 = Free",
    "twenty":
        "20 connections are available in our top ₹100 plan.\n"
        "Comparison:\n"
        "Free = 5\n"
        "₹50 = 10\n"
        "₹75 = 15\n"
        "₹100 = 20",
    "free plan":
        "With the Free Plan, you can connect with up to 5 companions across any category. Upgrade anytime for more access!",
    "free cost":
        "With the Free Plan, you can connect with up to 5 companions across any category. Upgrade anytime for more access!",
    "free":
        "With the Free Plan, you can connect with up to 5 companions across any category. Upgrade anytime for more access!",

    "50":
        "Great choice! ₹50 plan lets you connect with 10 companions - perfect for building your network.",
    "50 rupee":
        "Great choice! ₹50 plan lets you connect with 10 companions – perfect for building your network.",
    "50 rupies":
        "Great choice! ₹50 plan lets you connect with 10 companions – perfect for building your network.",
    "50 plan":
        "Great choice! ₹50 plan lets you connect with 10 companions – perfect for building your network.",
    "50 cost":
        "Great choice! ₹50 plan lets you connect with 10 companions – perfect for building your network.",
    "50 ruppee":
        "Great choice! ₹50 plan lets you connect with 10 companions – perfect for building your network.",

    "75":
        "Great choice! ₹75 plan lets you connect with 15 companions – perfect for building your network.",
    "75 rupee":
        "Great choice! ₹75 plan lets you connect with 15 companions – perfect for building your network.",
    "75 rupies":
        "Great choice! ₹75 plan lets you connect with 15 companions – perfect for building your network.",
    "75 plan":
        "Great choice! ₹75 plan lets you connect with 15 companions – perfect for building your network.",
    "75 rupee plan":
        "Great choice! ₹75 plan lets you connect with 15 companions – perfect for building your network.",

    "100":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 rupee":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 rupies":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 rupee plan":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 plan":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 cost":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",
    "100 rupee cost":
        "Great choice! ₹100 plan lets you connect with 20 companions – perfect for building your network.",

    "create a group":
        "In each section, just tap on the Create button, fill in your details, and your group/session will go live instantly!",
    "join a group?":
        "Explore the list of groups, tap on Show More, and click Join to be a part of a session that suits your interests.",
    "join group?":
        "Explore the list of groups, tap on Show More, and click Join to be a part of a session that suits your interests.",

    "chat with companions":
        "Yes! Once you join or create a session, chat options will appear to interact with your selected companions securely.",
    "chat with people":
        "Yes! Once you join or create a session, chat options will appear to interact with your selected companions securely.",
    "chat with person":
        "Yes! Once you join or create a session, chat options will appear to interact with your selected companions securely.",
    "chat with partner":
        "Yes! Once you join or create a session, chat options will appear to interact with your selected companions securely.",

    "fit traveler":
        "Absolutely! Fit Traveler offers a Free Plan to get you started. For more access, you can upgrade anytime.",
    "fit traveler free to use":
        "Absolutely! Fit Traveler offers a Free Plan to get you started. For more access, you can upgrade anytime.",
    "free to use":
        "Absolutely! Fit Traveler offers a Free Plan to get you started. For more access, you can upgrade anytime.",

    "update profile":
        "Tap the profile icon on the top-right corner of the home page to update your details, preferences, and visibility settings.",
    "update my profile":
        "Tap the profile icon on the top-right corner of the home page to update your details, preferences, and visibility settings.",
    "see my profile":
        "Tap the profile icon on the top-right corner of the home page to see your profile.",
    "see profile":
        "Tap the profile icon on the top-right corner of the home page to see your profile.",

    "need help":
        "I'm here to help you with anything – finding companions, creating meetups, upgrading your plan, or just exploring features!",
    "connect":
        "Looking to connect with companions? 🤝 Just tap on the section that matches your interest — Sports, Food, or Travel Companion. Use filters to find your match and click 'Connect' to start chatting!",
  };

  // Activity-specific responses
  static final Map<String, String> _activityResponses = {
    "sport":
        "For sports, you can find companions or create groups for activities like badminton, football, gym, etc.",
    "food":
        "For food, you can find dining companions or create food groups for different cuisines.",
    "travel":
        "For travel, you can find travel buddies or create groups for trips and adventures.",
  };

  static String getResponse(String userMessage) {
    if (userMessage.trim().isEmpty) {
      return "Please type something so I can help you!";
    }

    String userMessageLower = userMessage.toLowerCase();

    // First check for navigation intents
    var intent = detectNavigationIntent(userMessageLower);
    if (intent != null) {
      return intent.response;
    }

    // Then check for activity-specific queries
    for (var entry in _activityResponses.entries) {
      if (userMessageLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Then check predefined keywords (sorted by length)
    List<MapEntry<String, String>> sortedKeywords =
        _predefinedKeywords.entries.toList()
          ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (MapEntry<String, String> entry in sortedKeywords) {
      if (userMessageLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback response with suggestions
    return "I can help you with:\n"
        "- Finding companions (sports, food, travel)\n"
        "- Creating groups\n"
        "- Answering questions about the app\n\n"
        "Try asking:\n"
        "'How do I create a sports group?'\n"
        "'I want to find food companions'\n"
        "'What can you do?'";
  }

  // Enhanced to detect navigation intent type
  static ChatbotNavigationIntent? detectNavigationIntent(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Check for group creation intent
    if (lowerMessage.contains('create') ||
        lowerMessage.contains('make') ||
        lowerMessage.contains('start') ||
        lowerMessage.contains('how to create')) {
      // Only return intent if a specific type is mentioned
      if (lowerMessage.contains('food')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.createGroup,
          companionType: CompanionType.food,
          response: "Taking you to food group creation...",
        );
      } else if (lowerMessage.contains('travel')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.createGroup,
          companionType: CompanionType.travel,
          response: "Taking you to travel group creation...",
        );
      } else if (lowerMessage.contains('sport')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.createGroup,
          companionType: CompanionType.sport,
          response: "Taking you to sports group creation...",
        );
      }
      // No default fallback to sports
    }

    // Check for find companions intent
    if (lowerMessage.contains('find') ||
        lowerMessage.contains('look for') ||
        lowerMessage.contains('search for')) {
      // Only return intent if a specific type is mentioned
      if (lowerMessage.contains('food')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.findCompanions,
          companionType: CompanionType.food,
          response: "Showing you food companions...",
        );
      } else if (lowerMessage.contains('travel')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.findCompanions,
          companionType: CompanionType.travel,
          response: "Showing you travel companions...",
        );
      } else if (lowerMessage.contains('sport')) {
        return ChatbotNavigationIntent(
          type: NavigationIntentType.findCompanions,
          companionType: CompanionType.sport,
          response: "Showing you sports companions...",
        );
      }
      // No default fallback to sports
    }

    return null;
  }

  // Get a random greeting for initial messages
  static String getRandomGreeting() {
    List<String> greetings = [
      "Hello! How can I assist you today?",
      "Hi there! Need any help with sports, food, or travel companions?",
      "Hey! I can help you find companions or create groups. How can I help?",
      "Hello! I'm here to help you connect with others for activities!",
    ];

    return greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];
  }

  // Get suggestions for user
  static List<String> getSuggestions() {
    return [
      "How to create a sports group",
      "Find food companions",
      "Travel buddies near me",
      "What can you do?",
    ];
  }
}

enum NavigationIntentType { createGroup, findCompanions }

class ChatbotNavigationIntent {
  final NavigationIntentType type;
  final CompanionType companionType;
  final String response;

  ChatbotNavigationIntent({
    required this.type,
    required this.companionType,
    required this.response,
  });
}
