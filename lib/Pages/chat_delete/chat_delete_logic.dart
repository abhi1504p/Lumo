import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatDeleteLogic extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Selection state
  final RxList<String> selectedMessages = <String>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxBool isProcessing = false.obs;

  // Get chat room ID
  String getChatId(String userId, String otherUserId) {
    final List<String> ids = [userId, otherUserId];
    ids.sort();
    return ids.join("_");
  }

  // Select all messages
  void selectAll(List<QueryDocumentSnapshot> messages) {
    selectedMessages.clear();
    selectedMessages.addAll(messages.map((doc) => doc.id));
    isSelectionMode.value = true;
  }

  // Deselect all messages
  void deselectAll() {
    selectedMessages.clear();
    isSelectionMode.value = false;
  }

  // Toggle single message selection
  void toggleSelection(String messageId) {
    if (selectedMessages.contains(messageId)) {
      selectedMessages.remove(messageId);
      if (selectedMessages.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedMessages.add(messageId);
      isSelectionMode.value = true;
    }
  }

  // Delete single message
  Future<void> deleteMessage(String userId, String otherUserId, String messageId) async {
    try {
      isProcessing.value = true;
      final chatId = getChatId(userId, otherUserId);
      await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .doc(messageId)
          .delete();
    } finally {
      isProcessing.value = false;
    }
  }

  // Delete multiple messages
  Future<void> deleteSelectedMessages(String chatId) async {
    if (selectedMessages.isEmpty) return;

    try {
      isProcessing.value = true;
      final batch = _firestore.batch();

      for (String messageId in selectedMessages) {
        final docRef = _firestore
            .collection("Chats_room")
            .doc(chatId)
            .collection("messages")
            .doc(messageId);
        batch.delete(docRef);
      }

      await batch.commit();
      deselectAll();
    } finally {
      isProcessing.value = false;
    }
  }

  // Delete old messages (automatic cleanup)
  Future<void> deleteOldMessages(String chatId) async {
    try {
      isProcessing.value = true;
      final DateTime twentyDaysAgo = DateTime.now().subtract(const Duration(days: 20));

      final QuerySnapshot oldMessages = await _firestore
          .collection("Chats_room")
          .doc(chatId)
          .collection("messages")
          .where("timestamp", isLessThan: Timestamp.fromDate(twentyDaysAgo))
          .get();

      if (oldMessages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in oldMessages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } finally {
      isProcessing.value = false;
    }
  }
}
