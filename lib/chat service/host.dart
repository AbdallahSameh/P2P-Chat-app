import 'dart:convert';
import 'dart:io';

import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';

class Host {
  ChatProvider chatProvider;
  int udpPort;
  int tcpPort;
  List<Socket> clients = [];
  Socket? _selfSocket;

  Host({required this.chatProvider, this.udpPort = 2222, this.tcpPort = 5050});

  Future<void> start() async {
    _udpResponder(udpPort);
    await _startTcpServer(tcpPort);
    await _selfConnect();
  }

  Future<void> _udpResponder(udpPort) async {
    final rawSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
    );

    rawSocket.listen((event) async {
      if (event == RawSocketEvent.read) {
        final dg = rawSocket.receive();
        if (dg != null) {
          final message = utf8.decode(dg.data);
          if (message == 'ARE_YOU_CHAT_HOST') {
            final serverIp = await _getLocalIp();
            chatProvider.addSystemNotification(
              'Discovery request from: ${dg.address.address}',
            );

            rawSocket.send(
              utf8.encode('CHAT_SERVER_IP: $serverIp'),
              dg.address,
              dg.port,
            );
          }
        }
      }
    });
  }

  Future<void> _startTcpServer(tcpIpPort) async {
    ServerSocket server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      tcpIpPort,
    );

    server.listen((client) {
      clients.add(client);
      chatProvider.addSystemNotification(
        'Client connected: ${client.remoteAddress.address}',
      );

      client.listen(
        (data) {
          _handleMessage(client, data);
        },
        onDone: () => _removeClient(client),
        onError: () => _removeClient(client),
      );
    });
  }

  _handleMessage(Socket client, data) {
    final message = Message(
      sender: client.remoteAddress.address,
      content: utf8.decode(data),
    );
    chatProvider.addMessage(message);
    chatProvider.addSystemNotification('A Message Received');
    _broadcast(message, client);
  }

  _removeClient(Socket client) {
    chatProvider.addSystemNotification(
      'Client disconnected: ${client.remoteAddress.address}',
    );
    clients.remove(client);
  }

  _broadcast(message, sender) {
    for (var client in clients) {
      if (client != sender) {
        client.write(message);
      }
    }
  }

  _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        return addr.address;
      }
    }
    return null;
  }

  _selfConnect() async {
    final ip = await _getLocalIp();
    _selfSocket = await Socket.connect(ip, tcpPort);

    if (_selfSocket == null) {
      chatProvider.addSystemNotification('Failed to connect the host');
      return;
    }

    _selfSocket!.listen((data) {
      final message = Message(
        sender: _selfSocket!.remoteAddress.address,
        content: utf8.decode(data),
      );
      chatProvider.addMessage(message);
      chatProvider.addSystemNotification('A Message Received');
    });
  }

  void sendMessage(message) {
    if (_selfSocket == null) return;
    _selfSocket!.write(message);
  }
}
