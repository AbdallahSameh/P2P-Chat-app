import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/data%20models/user.dart';

abstract class ChatType {
  User user = User(username: '', userIp: 'Not Connected');
  Future<void> start();
  void sendMessage(Message message);
}
