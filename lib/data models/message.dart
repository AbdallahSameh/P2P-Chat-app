class Message {
  String sender, content;
  late String sentTime;

  Message({
    required this.sender,
    required this.content,
    sentTime = DateTime.now,
  });
}
