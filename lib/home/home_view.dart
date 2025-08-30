import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Pages/chat_page/chat_page_view.dart';
import '../Pages/my_drawer/my_drawer_view.dart';
import '../Pages/my_settings/settings_view.dart';
import '../Pages/user__tile/user__tile_view.dart';
import '../service/auth_service.dart';
import '../service/chat_services.dart';
import '../core/widgets/responsive_layout.dart';
import 'home_logic.dart';

class HomeWidget extends StatelessWidget {
  HomeWidget({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final _chatServices = ChatServices();
  final _authServices = AuthService();


  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              size: isSmallScreen ? 24 : 28,
            ),
            onPressed: () => Get.to(() => SettingsView()),
            tooltip: 'Settings',
          ),
        ],
      ),
      drawer: My_drawerWidget(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading users"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    final currentUser = _authServices.getCurrentUser();
    if (userData["email"] != currentUser?.email) {
      return User_TileWidget(
        text: userData["email"],
        userId: userData["uid"],
        onTap: () {
          Get.to(() => Chat_pageWidget(
                reciverEmail: userData["email"],
                reciverId: userData["uid"],
              ));
        },
        canDelete: currentUser?.email == "admin@admin.com", // Only admin can delete users
      );
    } else {
      return Container();
    }
  }
}
