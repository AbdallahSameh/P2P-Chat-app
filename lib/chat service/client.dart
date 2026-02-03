import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/data%20models/user.dart';
import 'package:p2p_chat_app/interfaces/chat_type.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';

class Client implements ChatType {
  final int udpPort, tcpPort;
  Socket? socket;
  RawDatagramSocket? rawSocket;
  String? serverIp;
  ChatProvider chatProvider;
  User user = User(username: '', userIp: '');

  Client({
    required this.chatProvider,
    this.udpPort = 2222,
    this.tcpPort = 5050,
  });

  @override
  start() async {
    user = chatProvider.user!;
    user.userIp = await deviceIPs();
    await getHostIp();
  }

  getHostIp() async {
    rawSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    rawSocket!.broadcastEnabled = true;
    final message = utf8.encode('ARE_YOU_CHAT_HOST');
    final broadcastAddress = InternetAddress('255.255.255.255');
    final completer = Completer<String?>();

    rawSocket!.send(message, broadcastAddress, udpPort);
    chatProvider.addSystemNotification('Sent discovery broadcast');

    rawSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = rawSocket!.receive();
        if (dg != null) {
          final message = utf8.decode(dg.data);
          if (message.startsWith('CHAT_SERVER_IP:')) {
            final foundIp = message.split(' ')[1].trim();
            final roomName = message.split(' ')[3].trim();
            if (foundIp == user.userIp) return;
            Room room = Room(roomName: roomName, hostIp: foundIp);
            chatProvider.addSystemNotification('Found Host $foundIp');
            chatProvider.addChatRoom(room);
          }
        }
      }
    });
    Future.delayed(Duration(seconds: 3), () {
      if (rawSocket != null) rawSocket!.close();
      completer.complete();
    });
  }

  connectToHost(serverIp, password, [tcpPort = 5050]) async {
    try {
      socket = await Socket.connect(serverIp, tcpPort);
      chatProvider.addSystemNotification(
        'Connected to host: $serverIp:$tcpPort',
      );
      Message auth = Message(
        type: 'auth',
        senderip: user.userIp,
        senderUsername: user.username,
        content: password,
      );

      socket!.write(jsonEncode(auth.toJson()));

      socket!.listen(
        (data) {
          final message = Message.fromJson(jsonDecode(utf8.decode(data)));

          chatProvider.addMessage(message);
          chatProvider.addSystemNotification('A Message Received');
        },
        onDone: () {
          chatProvider.addSystemNotification('Disonnected from host');
          socket = null;
        },
        onError: (e, stackTrace) {
          chatProvider.addSystemNotification('Error: $e');
          socket = null;
        },
      );
    } catch (e) {
      chatProvider.addSystemNotification("Couldn't connect to Host: $e");
    }
  }

  @override
  void sendMessage(Message message) {
    if (socket == null) {
      chatProvider.addSystemNotification('not Connected');
      return;
    }

    chatProvider.addMessage(message);
    socket!.write(jsonEncode(message.toJson()));
  }

  void disconnect() {
    socket?.destroy();
    socket = null;
    rawSocket!.close();
    rawSocket = null;
  }

  Future<String> deviceIPs() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (var interface in interfaces) {
      if (chatProvider.connectivityType == 0) {
        for (var addr in interface.addresses) {
          return addr.address;
        }
      } else if (chatProvider.connectivityType == 1) {
        if (interface.name.toLowerCase().contains('wi-fi') ||
            interface.name.toLowerCase().contains('wlan')) {
          for (var addr in interface.addresses) {
            return addr.address;
          }
        }
      }
    }
    return 'Not Connected';
  }
}
