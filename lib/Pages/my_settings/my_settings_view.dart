import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_bar.dart';
import 'my_settings_logic.dart';

class My_settingsWidget extends StatelessWidget {
  My_settingsWidget({Key? key}) : super(key: key);

  final My_settingsLogic logic = Get.put(My_settingsLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings',onBack: (){
        Get.back();
      },)
    );
  }
}
