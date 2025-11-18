import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/interfaces/chat_type.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';

class Client implements ChatType {
  final int udpPort, tcpPort;
  Socket? socket;
  String? serverIp;
  ChatProvider chatProvider;
  String deviceIp = '';
  String? roomName;

  Client({
    required this.chatProvider,
    this.udpPort = 2222,
    this.tcpPort = 5050,
  });

  @override
  start() async {
    deviceIp = await DeviceIPs();
    serverIp = await _getHostIp();
    if (serverIp == null) {
      chatProvider.addSystemNotification('no Host found');
      return;
    }

    // to do
    // the room name is stored in the variable make _connectToHost global and start returns the room name to the room_chooser.dart
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
            final foundIp = message.split(' ')[1].trim();
            roomName = message.split(' ')[3].trim();
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
    socket!.write(message.content);
  }

  void disconnect() {
    socket?.destroy();
    socket = null;
  }

  Future<String> DeviceIPs() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (var interface in interfaces) {
      print('Interface: ${interface.name}');
      for (var addr in interface.addresses) {
        print('  IP Address: ${addr.address}');
        return addr.address;
      }
    }
    return 'Not Connected';
  }
}
