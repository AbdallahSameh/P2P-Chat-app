import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';

class Client {
  final int udpPort, tcpPort;
  Socket? socket;
  String? serverIp;
  ChatProvider chatProvider;

  Client({
    required this.chatProvider,
    this.udpPort = 2222,
    this.tcpPort = 5050,
  });

  start() async {
    serverIp = await _getHostIp();
    if (serverIp == null) {
      chatProvider.addSystemNotification('no Host found');
      return;
    }

    _connectToHost(serverIp, tcpPort);
  }

  _getHostIp() async {
    final rawSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    rawSocket.broadcastEnabled = true;
    final message = utf8.encode('ARE_YOU_CHAT_HOST');
    final broadcastAddress = InternetAddress('255.255.255.255');
    final completer = Completer<String?>();

    rawSocket.send(message, broadcastAddress, udpPort);
    chatProvider.addSystemNotification('Sent discovery broadcast');

    rawSocket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = rawSocket.receive();
        if (dg != null) {
          final message = utf8.decode(dg.data);
          if (message.startsWith('CHAT_SERVER_IP:')) {
            final foundIp = message.split(' ').last.trim();
            completer.complete(foundIp);
            rawSocket.close();
          }
        }
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete(null);
        rawSocket.close();
      }
    });

    return completer.future;
  }

  _connectToHost(serverIp, tcpPort) async {
    try {
      socket = await Socket.connect(serverIp, tcpPort);
      chatProvider.addSystemNotification(
        'Connected to host: $serverIp:$tcpPort',
      );

      socket!.listen(
        (data) {
          final message = Message(
            sender: socket!.remoteAddress.address,
            content: utf8.decode(data),
          );

          chatProvider.addMessage(message);
          chatProvider.addSystemNotification('A Message Received');
        },
        onDone: () {
          chatProvider.addSystemNotification('Disonnected from host');
          socket = null;
        },
        onError: (e) {
          chatProvider.addSystemNotification('Error: $e');
          socket = null;
        },
      );
    } catch (e) {
      chatProvider.addSystemNotification("Couldn't connect to Host: $e");
    }
  }

  void sendMessage(message) {
    if (socket == null) {
      chatProvider.addSystemNotification('not Connected');
      return;
    }

    socket!.write(message);
  }

  void disconnect() {
    socket?.destroy();
    socket = null;
  }
}
