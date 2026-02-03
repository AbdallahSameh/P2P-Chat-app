import 'package:intl/intl.dart';

class Message {
  String type, senderip, senderUsername, content;
  String? sendTime;

  Message({
    required this.type,
    required this.senderip,
    required this.senderUsername,
    required this.content,
    sendTime,
  }) : sendTime = sendTime ?? DateFormat('hh:mm a').format(DateTime.now());

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      type: message['type'],
      senderip: message['senderip'],
      senderUsername: message['senderUsername'],
      content: message['content'],
      sendTime: message['sendTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'senderip': senderip,
      'senderUsername': senderUsername,
      'content': content,
      'sendTime': sendTime,
    };
  }
}
