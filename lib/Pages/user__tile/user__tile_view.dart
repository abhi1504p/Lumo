import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../service/auth_service.dart';
import 'user__tile_logic.dart';

class User_TileWidget extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final String? userId;
  final bool canDelete;

  User_TileWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.userId,
    this.canDelete = true,
  });

  final User_TileLogic logic = Get.put(User_TileLogic());
  final AuthService _authService = AuthService();

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete $text?'),
            const SizedBox(height: 8),
            const Text('This will:'),
            const Text('• Delete all their messages'),
            const Text('• Remove them from all chat rooms'),
            const Text('• Delete their account', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Get.back();
                await _authService.deleteUserByEmail(text);
                Get.snackbar(
                  'Success',
                  'User deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withAlpha(50),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withAlpha(50),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveLayout.isMobile(context);
    final double verticalMargin = isSmallScreen ? 5 : 8;
    final double horizontalMargin = isSmallScreen ? 25 : 32;
    final double padding = isSmallScreen ? 16 : 20;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin,
        horizontal: horizontalMargin,
      ),
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmallScreen ? 20 : 24,
            child: Icon(Icons.person, size: isSmallScreen ? 24 : 28),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isSmallScreen && userId != null)
                  Text(
                    'ID: $userId',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: isSmallScreen ? 24 : 28,
                color: Colors.red[400],
              ),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          IconButton(
            icon: Icon(
              Icons.chat,
              size: isSmallScreen ? 24 : 28,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
