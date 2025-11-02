import 'package:flutter/material.dart';
import 'package:p2p_chat_app/data%20models/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];
  List<String> _systemNotifications = [];

  List<Message> get messages => _messages;
  List<String> get systemNotifications => _systemNotifications;

  void addMessage(message) {
    _messages.add(message);
    notifyListeners();
  }

  void addSystemNotification(notification) {
    _systemNotifications.add(notification);
    notifyListeners();
  }
}
