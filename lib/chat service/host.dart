import 'dart:convert';
import 'dart:io';
import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/data%20models/user.dart';
import 'package:p2p_chat_app/interfaces/chat_type.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';

class Host implements ChatType {
  ChatProvider chatProvider;
  int udpPort;
  int tcpPort;
  List<Socket> clients = [];
  Room? room;
  User user = User(username: '', userIp: 'Not Connected');

  Host({required this.chatProvider, this.udpPort = 2222, this.tcpPort = 5050});

  @override
  Future<void> start() async {
    user = chatProvider.user!;
    room = chatProvider.chatRooms[0];
    user.userIp = await _getLocalIp();
    _udpResponder(udpPort);
    await _startTcpServer(tcpPort);
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
          if (utf8.decode(dg.data) == 'ARE_YOU_CHAT_HOST') {
            final serverIp = user.userIp;
            chatProvider.addSystemNotification(
              'Discovery request from: ${dg.address.address}',
            );

            rawSocket.send(
              utf8.encode(
                'CHAT_SERVER_IP: $serverIp ROOM_NAME: ${room!.roomName}',
              ),
              dg.address,
              dg.port,
            );
            chatProvider.addSystemNotification(
              'RoomInfo: CHAT_SERVER_IP: $serverIp ROOM_NAME: ${room!.roomName} was sent to ${dg.address.address}',
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
      bool authenticated = false;

      clients.add(client);

      chatProvider.addSystemNotification(
        'Client connected: ${client.remoteAddress.address}',
      );

      client.listen(
        (data) {
          final message = Message.fromJson(jsonDecode(utf8.decode(data)));
          if (!authenticated) {
            if (message.content != room!.password) {
              chatProvider.addSystemNotification('Invalid Password');

              client.close();
              return;
            }
            authenticated = true;
            return;
          }

          _handleMessage(client, message);
        },
        onDone: () => _removeClient(client),
        onError: (error, stackTrace) => _removeClient(client),
      );
    });
  }

  _handleMessage(Socket client, data) {
    final message = data;
    chatProvider.addMessage(message);
    chatProvider.addSystemNotification('A Message Received');
  }

  _removeClient(Socket client) {
    chatProvider.addSystemNotification(
      'Client disconnected: ${client.remoteAddress.address}',
    );
    clients.remove(client);
  }

  _broadcast(Message message) {
    for (var client in clients) {
      client.write(jsonEncode(message.toJson()));
    }
  }

  _getLocalIp() async {
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

  @override
  void sendMessage(Message message) {
    chatProvider.addMessage(message);
    _broadcast(message);
  }
}
