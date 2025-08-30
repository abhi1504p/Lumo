import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String reciverId;
  final String message;
  final Timestamp timestamp;
  final String? type; // 'text', 'image', or 'file'
  final String? fileName; // For file attachments

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.reciverId,
    required this.message,
    required this.timestamp,
    this.type = 'text',
    this.fileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'reciverId': reciverId,
      'message': message,
      'timestamp': timestamp,
      'type': type,
      'fileName': fileName,
    };
  }
}
