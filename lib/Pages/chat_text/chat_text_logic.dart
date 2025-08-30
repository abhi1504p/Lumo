import 'package:get/get.dart';

class Chat_textLogic extends GetxController {
  var showEmojiPicker = false.obs;

  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;
  }

  void hideEmojiPicker() {
    showEmojiPicker.value = false;
  }
}
