import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../chat_delete/chat_delete_logic.dart';

class Chat_pageLogic extends GetxController {
  QuerySnapshot? messages;
  final ChatDeleteLogic deleteLogic = Get.find<ChatDeleteLogic>();

  // Message selection state
  final RxBool showEmojiPicker = false.obs;
  final RxBool isLoading = false.obs;

  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;
  }

  void hideEmojiPicker() {
    showEmojiPicker.value = false;
  }

  // Message management methods
  void selectAllMessages() {
    if (messages != null) {
      deleteLogic.selectAll(messages!.docs);
    }
  }

  void clearMessageSelection() {
    deleteLogic.deselectAll();
  }

  bool isMessageSelected(String messageId) {
    return deleteLogic.selectedMessages.contains(messageId);
  }

  void toggleMessageSelection(String messageId) {
    deleteLogic.toggleSelection(messageId);
  }

  Future<void> deleteSelectedMessages(String chatId) async {
    try {
      isLoading.value = true;
      await deleteLogic.deleteSelectedMessages(chatId);
    } finally {
      isLoading.value = false;
    }
  }
}
