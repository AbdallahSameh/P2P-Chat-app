class Message {
  String senderip, senderUsername, content;
  late String sendTime;

  Message({
    required this.senderip,
    required this.senderUsername,
    required this.content,
    sendTime = DateTime.now,
  });
}
