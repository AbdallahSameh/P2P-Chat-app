import 'package:p2p_chat_app/data%20models/message.dart';

abstract class ChatType {
  Future<void> start();
  void sendMessage(Message message);
}
