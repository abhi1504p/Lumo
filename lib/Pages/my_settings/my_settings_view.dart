import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_bar.dart';
import '../../theme/theme_mode.dart';
import '../../service/ai_settings_service.dart';
import 'my_settings_logic.dart';

class My_settingsWidget extends StatelessWidget {
  My_settingsWidget({Key? key}) : super(key: key);

  final logic = Get.put(ThemeController());
  final aiSettings = Get.put(AISettingsService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Dark Mode Setting
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Dark Mode"),
                  CupertinoSwitch(
                    value: logic.isDarkMode,
                    onChanged: (value) {
                      logic.toggleTheme();
                    },
                  )
                ],
              ),
            ),

            // AI Companion Setting
            Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI Companion",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Chat with AI friend instead of humans",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: aiSettings.isAIModeEnabled,
                        onChanged: (value) {
                          aiSettings.toggleAIMode();
                        },
                      )
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
