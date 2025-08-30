import 'dart:io';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../service/chat_services.dart';

class ChatInputWidget extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatInputWidget({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final ChatServices _chatServices = ChatServices();
  final TextEditingController _messageController = TextEditingController();
  final RxBool _showEmojiPicker = false.obs;
  final ImagePicker _imagePicker = ImagePicker();
  final RxBool _isUploading = false.obs;

  bool get _hasText => _messageController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await _chatServices.sendMessage(widget.receiverId, message);
    _messageController.clear();
    setState(() {});
  }

  void _toggleEmojiPicker() {
    _showEmojiPicker.toggle();
    if (_showEmojiPicker.value) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onEmojiSelected(Category category, Emoji emoji) {
    _messageController.text += emoji.emoji;
    setState(() {});
  }

  void _onTextFieldTap() {
    if (_showEmojiPicker.value) {
      _showEmojiPicker.value = false;
    }
  }

  Future<bool> _requestPermissions(Permission permission) async {
    try {
      final status = await permission.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Show dialog explaining why we need permission
        final bool shouldOpenSettings = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Permission Required'),
            content: Text('We need ${permission.toString()} permission to handle media files. Please grant permission in settings.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ?? false;

        if (shouldOpenSettings) {
          await openAppSettings();
        }
        return false;
      }
      return status.isGranted;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request permission: $e',
        backgroundColor: Colors.red.withAlpha(50),
      );
      return false;
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      // Request appropriate permission
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.storage;

      if (!await _requestPermissions(permission)) {
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _isUploading.value = true;
        try {
          await _chatServices.sendFileMessage(
            widget.receiverId,
            File(pickedFile.path),
            'image',
          );
        } finally {
          _isUploading.value = false;
        }
      }
    } on PlatformException catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.message}',
        backgroundColor: Colors.red.withAlpha(50),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send image: $e',
        backgroundColor: Colors.red.withAlpha(50),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        _isUploading.value = true;
        await _chatServices.sendFileMessage(
          widget.receiverId,
          File(result.files.single.path!),
          'file',
        );
        _isUploading.value = false;
      }
    } catch (e) {
      _isUploading.value = false;
      Get.snackbar(
        'Error',
        'Failed to send file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(50),
      );
    }
  }

  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Get.back();
                  _pickAndSendImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back();
                  _pickAndSendImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Upload File'),
                onTap: () {
                  Get.back();
                  _pickFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEmojiPicker(),
        Stack(
          children: [
            _buildInputSection(),
            Obx(() => _isUploading.value
                ? Container(
                    color: Colors.black.withAlpha(100),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showEmojiPicker.value ? 250 : 0,
          child: _showEmojiPicker.value
              ? EmojiPicker(
                  onEmojiSelected: (Category? category, Emoji emoji) {
                    if (category != null) {
                      _onEmojiSelected(category, emoji);
                    }
                  },
                  config: Config(
                    checkPlatformCompatibility: true,
                  ),
                )
              : null,
        ));
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 8,
            color: Colors.black.withAlpha(25),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildMessageInput(),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(77),
          ),
        ),
        child: Row(
          children: [
            _buildEmojiButton(),
            _buildTextField(),
            _buildAttachButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiButton() {
    return IconButton(
      icon: Icon(
        _showEmojiPicker.value ? Icons.keyboard : Icons.emoji_emotions_outlined,
      ),
      color: Theme.of(context).hintColor,
      onPressed: _toggleEmojiPicker,
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: TextField(
        controller: _messageController,
        onTap: _onTextFieldTap,
        onChanged: (_) => setState(() {}),
        style: Theme.of(context).textTheme.bodyLarge,
        textAlignVertical: TextAlignVertical.center,
        maxLines: 4,
        minLines: 1,
        decoration: InputDecoration(
          hintText: "Type a message...",
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor.withAlpha(179),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 16,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildAttachButton() {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      color: Theme.of(context).hintColor,
      onPressed: _showAttachmentOptions,
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: _hasText
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        shape: BoxShape.circle,
        boxShadow: _hasText
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withAlpha(77),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: _hasText ? _sendMessage : null,
        icon: Icon(
          Icons.send,
          color: _hasText ? Colors.white : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
