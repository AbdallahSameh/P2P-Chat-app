import 'package:intl/intl.dart';

class Message {
  String senderip, senderUsername, content;
  String? sendTime;

  Message({
    required this.senderip,
    required this.senderUsername,
    required this.content,
    sendTime,
  }) : sendTime = sendTime ?? DateFormat('hh:mm a').format(DateTime.now());

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      senderip: message['senderip'],
      senderUsername: message['senderUsername'],
      content: message['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderip': senderip,
      'senderUsername': senderUsername,
      'content': content,
    };
  }
}
