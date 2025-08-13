import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/Pages/my_settings/my_settings_view.dart';

import 'my_drawer_logic.dart';

class My_drawerWidget extends StatelessWidget {
  My_drawerWidget({Key? key}) : super(key: key);

  final My_drawerLogic logic = Get.put(My_drawerLogic());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Icon(
                Icons.message,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    "Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    "Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Get.to(() => My_settingsWidget());
                  },
                ),
              ],
            ),
          ),

          // Logout at bottom
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                logic.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
