import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../service/auth_service.dart';

class SettingsView extends StatelessWidget {
  final AuthService _authService = AuthService();

  SettingsView({Key? key}) : super(key: key);

  void _showDeleteAccountConfirmation(BuildContext context) {
    final bool isSmallScreen = ResponsiveLayout.isMobile(context);

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This will:',
              style: TextStyle(fontSize: 14),
            ),
            Text('• Delete all your messages', style: TextStyle(fontSize: 14)),
            Text('• Remove you from all chat rooms', style: TextStyle(fontSize: 14)),
            Text('• Delete your account', style: TextStyle(fontSize: 14)),
            Text('This action cannot be undone.',
                style: TextStyle(fontSize: 14, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                Get.back(); // Close the confirmation dialog
                Get.rawSnackbar(
                  message: 'Deleting account...',
                  isDismissible: false,
                  duration: const Duration(seconds: 30),
                  backgroundColor: Colors.blue.withAlpha(30),
                  showProgressIndicator: true,
                  progressIndicatorBackgroundColor: Colors.blue.withAlpha(100),
                );

                await _authService.deleteUserAccount();

                Get.closeAllSnackbars();
                Get.offAllNamed('/login');
              } catch (e) {
                Get.closeAllSnackbars();
                _showErrorSnackbar(e.toString());
              }
            },
            child: Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withAlpha(25),
      colorText: Colors.red,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveLayout.isMobile(context);
    final currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, currentUser),
        tablet: _buildTabletLayout(context, currentUser),
        desktop: _buildDesktopLayout(context, currentUser),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountSection(context, user),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, user) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildMobileLayout(context, user),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, user) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildAccountSection(context, user),
            ),
            const VerticalDivider(),
            const Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Add other settings here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, user) {
    final bool isSmallScreen = ResponsiveLayout.isMobile(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(isSmallScreen ? 0 : 16),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                user?.email ?? 'No email',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              subtitle: const Text('Email address'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              subtitle: const Text('Permanently delete your account and all data'),
              onTap: () => _showDeleteAccountConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}
