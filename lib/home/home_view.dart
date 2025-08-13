import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Pages/chat_page/chat_page_view.dart';
import '../Pages/my_drawer/my_drawer_view.dart';
import '../Pages/user__tile/user__tile_view.dart';
import '../service/auth_service.dart';
import '../service/chat_services.dart';
import 'home_logic.dart';

class HomeWidget extends StatelessWidget {
  HomeWidget({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final _chatServies = ChatServices();
  final _authServies = AuthService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Home'),
        centerTitle: true,
      ),
      drawer: My_drawerWidget(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServies.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error)");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..");
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if(userData["email"]!= _authServies.getCurrentUser()?.email){
      return User_TileWidget(
        text: userData["email"],
        onTap: () {
          Get.to(() => Chat_pageWidget(reciverEmail: userData["email"]));
        },
      );
    }
    else{
      return Container();
    }
  }
}
