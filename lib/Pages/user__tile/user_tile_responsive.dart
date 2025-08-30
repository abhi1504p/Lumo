import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTileResponsive extends StatelessWidget {
  final String email;
  final String uid;
  final Function()? onTap;
  final bool isCurrentUser;

  const UserTileResponsive({
    Key? key,
    required this.email,
    required this.uid,
    this.onTap,
    this.isCurrentUser = false,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $email?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteUser();
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser() async {
    try {
      // Delete user's chats
      await _deleteUserChats();
      // Delete user document
      await FirebaseFirestore.instance.collection('User').doc(uid).delete();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _deleteUserChats() async {
    // Get all chat rooms where user is involved
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Chats_room')
        .where('participants', arrayContains: uid)
        .get();

    // Delete each chat room
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 4 : 8,
        horizontal: isSmallScreen ? 8 : 16,
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue.withAlpha(30) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 20 : 24,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: isSmallScreen ? 24 : 28,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isSmallScreen)
                        Text(
                          'User ID: $uid',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isCurrentUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.message,
                          size: isSmallScreen ? 20 : 24,
                          color: Colors.blue,
                        ),
                        onPressed: onTap,
                        tooltip: 'Send Message',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: isSmallScreen ? 20 : 24,
                          color: Colors.red,
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
