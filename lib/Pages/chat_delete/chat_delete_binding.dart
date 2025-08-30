import 'package:get/get.dart';
import 'chat_delete_logic.dart';

class ChatDeleteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatDeleteLogic>(() => ChatDeleteLogic());
  }
}
