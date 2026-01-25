import 'package:flutter/material.dart';
import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/data%20models/user.dart';

class ChatProvider extends ChangeNotifier {
  User? user;
  int connectivityType = -1;
  List<Message> _messages = [];
  List<String> _systemNotifications = [];
  List<Room> chatRooms = [];

  List<Message> get messages => _messages;
  List<String> get systemNotifications => _systemNotifications;

  void addUser(User user) {
    this.user = user;
    notifyListeners();
  }

  void addMessage(message) {
    _messages.add(message);
    notifyListeners();
  }

  void addSystemNotification(notification) {
    _systemNotifications.add(notification);
    notifyListeners();
  }

  void addChatRoom(Room room) {
    chatRooms.add(room);
    notifyListeners();
  }

  void addConnectivityType(int choice) {
    connectivityType = choice;
    notifyListeners();
  }

  void deleteMessages() {
    _messages = [];
  }
}
