# AI Chatbot Integration for Lumo Chat App

This document explains the AI chatbot integration that transforms your WhatsApp-like chat application into a hybrid platform supporting both human-to-human messaging and AI companion chat.

## 🚀 Features

- **Toggle-based AI Mode**: Simple switch in settings to enable/disable AI companion
- **Seamless Integration**: AI responses are stored in Firestore like regular messages
- **Visual Indicators**: AI messages have distinct styling and indicators
- **Context-Aware**: AI maintains conversation context for natural interactions
- **Fallback Handling**: Graceful error handling with fallback responses
- **Real-time Updates**: AI responses appear in real-time like human messages

## 📁 Files Added/Modified

### New Files Created:
1. **`lib/service/ai_service.dart`** - Core AI service for LLaMA-3 API integration
2. **`lib/service/ai_settings_service.dart`** - Manages AI toggle state and settings

### Modified Files:
1. **`lib/service/chat_services.dart`** - Enhanced to handle AI responses
2. **`lib/Pages/my_settings/my_settings_view.dart`** - Added AI toggle switch
3. **`lib/Pages/chat_page/chat_page_view.dart`** - AI message styling and indicators
4. **`lib/env/env.dart`** - Added LLaMA API configuration
5. **`lib/main.dart`** - Initialize AI settings service
6. **`pubspec.yaml`** - Added HTTP dependency
7. **`a.env`** - Added LLaMA API key configuration

## 🔧 Setup Instructions

### 1. API Key Configuration

Add your LLaMA-3 API key to the `a.env` file:

```env
# Replace YOUR_LLAMA_API_KEY with your actual API key
LLAMA_API_KEY=your_actual_api_key_here
LLAMA_API_URL=https://api.groq.com/openai/v1/chat/completions
```

**Supported API Providers:**
- **Groq** (Recommended): `https://api.groq.com/openai/v1/chat/completions`
- **OpenAI**: `https://api.openai.com/v1/chat/completions`
- **Together AI**: `https://api.together.xyz/v1/chat/completions`
- **Perplexity**: `https://api.perplexity.ai/chat/completions`

### 2. Get Your API Key

#### For Groq (Recommended - Free tier available):
1. Visit [https://console.groq.com](https://console.groq.com)
2. Sign up for a free account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key to your `a.env` file

#### For OpenAI:
1. Visit [https://platform.openai.com](https://platform.openai.com)
2. Sign up and add billing information
3. Go to API Keys section
4. Create a new secret key
5. Copy the key to your `a.env` file

### 3. Install Dependencies

Run the following command in your project root:

```bash
flutter pub get
```

## 🎯 How It Works

### AI Mode Toggle
1. Open **Settings** in the app
2. Find the **"AI Companion"** toggle switch
3. Turn it **ON** to enable AI mode
4. Turn it **OFF** to return to normal human chat mode

### When AI Mode is Enabled:
1. User sends a message → Stored in Firestore
2. AI service automatically triggered
3. Recent conversation history sent to LLaMA-3 API
4. AI response received and stored in Firestore
5. AI message appears in chat with special styling

### Visual Indicators:
- **App Bar**: Shows "AI Companion" and "AI Mode Active" when enabled
- **AI Messages**: Purple background with robot icon and "AI Assistant" label
- **Settings**: Clear toggle with description

## 🔧 Technical Details

### AI Service Features:
- **Context Awareness**: Sends last 10 messages for context
- **Error Handling**: Fallback responses when API fails
- **Rate Limiting**: Handles API rate limits gracefully
- **Customizable**: Easy to modify AI personality and behavior

### Message Flow:
```
User Message → Firestore → AI Service → LLaMA API → AI Response → Firestore → UI Update
```

### AI Message Structure:
- **Sender ID**: `AI_BOT`
- **Sender Email**: `ai@lumo.app`
- **Special Styling**: Purple background, robot icon
- **Context**: Maintains conversation history

## 🎨 Customization

### Modify AI Personality:
Edit the system prompt in `lib/service/ai_service.dart`:

```dart
messages.add({
  'role': 'system',
  'content': 'Your custom AI personality prompt here...'
});
```

### Change AI Styling:
Modify colors and styling in `lib/Pages/chat_page/chat_page_view.dart`:

```dart
// AI message color
messageColor = Colors.purple[600]!; // Change this color
```

### Adjust Context Length:
Change the number of messages sent for context:

```dart
// In chat_services.dart
final conversationHistory = await _getConversationHistory(chatId, limit: 20); // Increase limit
```

## 🚨 Important Notes

1. **API Costs**: Be aware of API usage costs, especially with OpenAI
2. **Rate Limits**: APIs have rate limits - the app handles this gracefully
3. **Internet Required**: AI features require internet connection
4. **Privacy**: Messages are sent to third-party AI services
5. **Fallback**: App continues working even if AI service fails

## 🔍 Troubleshooting

### AI Not Responding:
1. Check API key in `a.env` file
2. Verify internet connection
3. Check API provider status
4. Look for error messages in console

### Toggle Not Working:
1. Ensure AI settings service is initialized in `main.dart`
2. Check if toggle state is being saved to SharedPreferences

### Styling Issues:
1. Verify AI message detection logic
2. Check if `AIService.isAIMessage()` is working correctly

## 📱 Usage Examples

### Normal Mode:
- User A sends: "Hello!"
- User B receives and can reply
- Standard human-to-human chat

### AI Mode:
- User sends: "Hello!"
- AI responds: "Hello! How can I help you today?"
- User sends: "Tell me a joke"
- AI responds: "Why don't scientists trust atoms? Because they make up everything!"

## 🔄 Future Enhancements

Potential improvements you can add:
1. **Multiple AI Models**: Support for different AI personalities
2. **Voice Integration**: Text-to-speech for AI responses
3. **Image Analysis**: AI that can analyze shared images
4. **Smart Suggestions**: AI-powered message suggestions
5. **Conversation Summaries**: AI-generated chat summaries

## 📞 Support

If you encounter any issues:
1. Check the console for error messages
2. Verify API key configuration
3. Test with a simple message first
4. Ensure all dependencies are installed correctly

The AI integration is designed to be robust and user-friendly, providing a seamless experience whether chatting with humans or AI companions!
