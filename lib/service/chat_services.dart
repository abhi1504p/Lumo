import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import 'ai_service.dart';
import 'ai_settings_service.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AIService _aiService = AIService();
  final AISettingsService _aiSettings = Get.find<AISettingsService>();

  // Track active listeners to prevent duplicates
  final Set<String> _activeListeners = <String>{};

  // Track last processed message timestamps to prevent duplicate responses
  final Map<String, DateTime> _lastProcessedMessage = <String, DateTime>{};

  // ---------------- GET USERS ----------------
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("User").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage(String reciverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      reciverId: reciverId,
      senderEmail: currentUserEmail,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatId = ids.join("_");

    await _firestore
        .collection("Chats_room")
        .doc(chatId)
        .collection("messages")
        .add(newMessage.toMap());

    // 🔹 AI should NOT respond to your own messages
    // AI will respond to incoming messages via the message listener

    // 🔹 Automatically delete old messages (keep only latest 50 for performance)
    await _autoDeleteOldMessages(chatId, limit: 50);
  }

  // ---------------- GET MESSAGES ----------------
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join("_");

    // Set up AI response listener for this specific chat
    setupAIResponseForChat(chatId, userId, otherUserId);

    return _firestore
        .collection("Chats_room")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // ---------------- MANUAL DELETE MESSAGE ----------------
  Future<void> deleteMessage(String userId, String otherUserId, String messageId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatId = ids.join("_");

    await _firestore
        .collection("Chats_room")
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  // ---------------- SETUP AI RESPONSE FOR SPECIFIC CHAT ----------------
  void setupAIResponseForChat(String chatId, String currentUserId, String otherUserId) {
    if (!_aiSettings.isAIModeEnabled || _activeListeners.contains(chatId)) return;

    _activeListeners.add(chatId);

    _firestore
        .collection("Chats_room")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {

      if (snapshot.docs.isEmpty) return;

      final latestMessage = snapshot.docs.first;
      final messageData = latestMessage.data();
      final senderId = messageData['senderId'] as String;
      final message = messageData['message'] as String;
      final timestamp = messageData['timestamp'] as Timestamp;
      final messageTime = timestamp.toDate();

      // Check if we've already processed this message
      final lastProcessed = _lastProcessedMessage[chatId];
      if (lastProcessed != null && !messageTime.isAfter(lastProcessed)) {
        return;
      }

      // Only respond if message is from other user and recent
      final isFromOtherUser = senderId == otherUserId;
      final isNotFromAI = senderId != AIService.aiUserId;
      final isRecent = DateTime.now().difference(messageTime).inSeconds < 10;

      if (_aiSettings.isAIModeEnabled && isFromOtherUser && isNotFromAI && isRecent) {
        _lastProcessedMessage[chatId] = messageTime;
        await _handleAIResponse(chatId, message, currentUserId);
      }
    });
  }

  // ---------------- HANDLE AI RESPONSE ----------------
  Future<void> _handleAIResponse(String chatId, String userMessage, String currentUserId) async {
    try {
      // Get recent conversation history for context
      final conversationHistory = await _getConversationHistory(chatId, limit: 5);

      // Get AI response
      final aiResponse = await _aiService.getAIResponse(
        userMessage,
        conversationHistory: conversationHistory
      );

      // Create AI message
      final aiMessage = Message(
        senderId: AIService.aiUserId,
        reciverId: currentUserId,
        senderEmail: AIService.aiUserEmail,
        message: aiResponse,
        timestamp: Timestamp.now(),
      );

      // Add small delay to make it feel more natural
      await Future.delayed(const Duration(milliseconds: 800));

      // Save AI response to Firestore
      await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .add(aiMessage.toMap());

    } catch (e) {
      // Send fallback message if AI fails
      final fallbackMessage = Message(
        senderId: AIService.aiUserId,
        reciverId: currentUserId,
        senderEmail: AIService.aiUserEmail,
        message: "Sorry, I'm having some technical difficulties. Please try again!",
        timestamp: Timestamp.now(),
      );

      await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .add(fallbackMessage.toMap());
    }
  }

  // ---------------- GET CONVERSATION HISTORY ----------------
  Future<List<Map<String, String>>> _getConversationHistory(String chatId, {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(limit)
          .get();

      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'senderId': data['senderId'] as String,
          'message': data['message'] as String,
        };
      }).toList().reversed.toList();

      return _aiService.formatConversationHistory(messages);
    } catch (e) {
      return [];
    }
  }

  // ---------------- AUTO DELETE OLD MESSAGES ----------------
  Future<void> _autoDeleteOldMessages(String chatId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .get();

      if (snapshot.docs.length > limit) {
        final batch = _firestore.batch();
        final docsToDelete = snapshot.docs.skip(limit);

        for (var doc in docsToDelete) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e) {
      // Silently handle errors to avoid disrupting chat flow
    }
  }

  Future<String> _uploadFile(File file, String chatId) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.path.split('/').last;
    final Reference ref = _storage.ref().child('chat_files/$chatId/$fileName');
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> sendFileMessage(String receiverId, File file, String fileType) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatId = ids.join("_");

    // Upload file to Firebase Storage
    final String fileUrl = await _uploadFile(file, chatId);

    Message newMessage = Message(
      senderId: currentUserId,
      reciverId: receiverId,
      senderEmail: currentUserEmail,
      message: fileUrl,
      timestamp: timestamp,
      type: fileType, // 'image' or 'file'
    );

    await _firestore
        .collection("Chats_room")
        .doc(chatId)
        .collection("messages")
        .add(newMessage.toMap());

    await _autoDeleteOldMessages(chatId, limit: 100);
  }
}






