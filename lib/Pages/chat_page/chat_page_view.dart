import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/Pages/chat_delete/chat_delete_logic.dart';
import 'package:lumo/core/widgets/responsive_layout.dart';
import 'package:lumo/service/chat_services.dart';
import 'package:lumo/service/ai_service.dart';
import 'package:lumo/service/ai_settings_service.dart';

import '../../service/auth_service.dart';
import '../chat_text/chat_text_view.dart';
import 'chat_page_logic.dart';

class Chat_pageWidget extends StatelessWidget {
  final String reciverEmail;
  final String reciverId;

  Chat_pageWidget({
    super.key,
    required this.reciverEmail,
    required this.reciverId,
  });

  final ChatServices _chatServices = ChatServices();
  final AuthService _authServices = AuthService();
  final ChatDeleteLogic deleteLogic = Get.put(ChatDeleteLogic());
  final Chat_pageLogic chatController = Get.put(Chat_pageLogic());
  final AISettingsService _aiSettings = Get.find<AISettingsService>();

  String get _chatId {
    List<String> ids = [_authServices.getCurrentUser()!.uid, reciverId];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ResponsiveLayout(
        mobile: _buildChatView(),
        tablet: _buildTabletView(),
        desktop: _buildDesktopView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.grey,
      title: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                deleteLogic.isSelectionMode.value
                    ? '${deleteLogic.selectedMessages.length} selected'
                    : _aiSettings.isAIModeEnabled ? 'AI Companion' : reciverEmail,
                style: TextStyle(
                    fontSize: ResponsiveLayout.isMobile(context) ? 16 : 20),
              ),
              if (_aiSettings.isAIModeEnabled && !deleteLogic.isSelectionMode.value)
                Text(
                  'AI Mode Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          )),
      centerTitle: true,
      actions: [_buildAppBarActions(context)],
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return Obx(() => deleteLogic.isSelectionMode.value
        ? _buildSelectionActions(context)
        : const SizedBox());
  }

  Widget _buildSelectionActions(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _selectAll,
            tooltip: 'Select All',
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.select_all),
            label: const Text('Select All'),
            onPressed: _selectAll,
          ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: 'Delete Selected',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: deleteLogic.deselectAll,
          tooltip: 'Cancel',
        ),
      ],
    );
  }

  void _selectAll() {
    if (chatController.messages != null) {
      deleteLogic.selectAll(chatController.messages!.docs);
    }
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        ChatInputWidget(receiverEmail: reciverEmail, receiverId: reciverId),
      ],
    );
  }

  Widget _buildTabletView() {
    return Row(
      children: [
        Expanded(flex: 7, child: _buildChatView()),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildUserInfo()),
      ],
    );
  }

  Widget _buildDesktopView() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildUserList()),
        const VerticalDivider(width: 1),
        Expanded(flex: 5, child: _buildChatView()),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildUserInfo()),
      ],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatServices.getMessages(
          _authServices.getCurrentUser()!.uid, reciverId),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text("Error loading messages"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        chatController.messages = snapshot.data;
        final docs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 8 : 16),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildMessageItem(docs[index], context),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final isCurrentUser =
        data["senderId"] == _authServices.getCurrentUser()!.uid;
    final isAIMessage = AIService.isAIMessage(data["senderId"]);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isSelected = deleteLogic.selectedMessages.contains(doc.id);

    return Obx(() => Container(
          margin: EdgeInsets.symmetric(
              vertical: isMobile ? 4 : 6, horizontal: isMobile ? 4 : 8),
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => deleteLogic.toggleSelection(doc.id),
            onTap: deleteLogic.isSelectionMode.value
                ? () => deleteLogic.toggleSelection(doc.id)
                : null,
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * (isMobile ? 0.8 : 0.6),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 8 : 12,
                horizontal: isMobile ? 12 : 16,
              ),
              decoration: _getMessageDecoration(isCurrentUser, isSelected, isAIMessage),
              child: _buildMessageContent(data, isCurrentUser, isMobile, isAIMessage),
            ),
          ),
        ));
  }

  BoxDecoration _getMessageDecoration(bool isCurrentUser, bool isSelected, bool isAIMessage) {
    Color messageColor;
    if (isSelected) {
      messageColor = Colors.blue.withAlpha(50);
    } else if (isCurrentUser) {
      messageColor = Colors.green;
    } else if (isAIMessage) {
      messageColor = Colors.purple[600]!;
    } else {
      messageColor = Colors.grey[600]!;
    }

    return BoxDecoration(
      color: messageColor,
      borderRadius: BorderRadius.circular(12),
      border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
    );
  }

  Widget _buildMessageContent(
      Map<String, dynamic> data, bool isCurrentUser, bool isMobile, bool isAIMessage) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAIMessage) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'AI',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
        Text(
          data["message"],
          style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white),
        ),
        if (!isMobile) ...[
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(data["timestamp"] as Timestamp),
            style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final isToday = dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return isToday ? timeStr : '${dateTime.day}/${dateTime.month} $timeStr';
  }

  Widget _buildUserInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(reciverId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null)
          return const Center(child: Text('User not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                  radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 16),
              Text(userData['email'] ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('User ID: $reciverId',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('User').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs
            .where((doc) => doc.id != _authServices.getCurrentUser()!.uid)
            .map((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(userData['email'] ?? ''),
            onTap: () {
              // Handle user selection
            },
          );
        }).toList();

        return ListView(padding: const EdgeInsets.all(8), children: users);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final count = deleteLogic.selectedMessages.length;
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Messages'),
        content: Text('Are you sure you want to delete $count message(s)?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await deleteLogic.deleteSelectedMessages(_chatId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
