import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user__tile_logic.dart';

class User_TileWidget extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  User_TileWidget({super.key, required this.text, required this.onTap});

  final User_TileLogic logic = Get.put(User_TileLogic());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: EdgeInsets.all(20),
        child: Row(children: [Icon(Icons.person), Text(text)]),
      ),
    );
  }
}
