import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_text.dart';
import 'chat_page_logic.dart';

class Chat_pageWidget extends StatelessWidget {
  final String  reciverEmail;
  Chat_pageWidget({super.key, required this.reciverEmail});

  final Chat_pageLogic logic = Get.put(Chat_pageLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reciverEmail,),
      ),
    );
  }
}
