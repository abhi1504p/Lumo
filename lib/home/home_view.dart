import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_logic.dart';

class HomeWidget extends StatelessWidget {
  HomeWidget({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: logic.logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text("Welcome to Home"),
      ),
    );
  }
}
