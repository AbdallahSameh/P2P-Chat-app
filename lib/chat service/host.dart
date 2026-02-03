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
  RawDatagramSocket? udpSocket;
  ServerSocket? tcpSocket;
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
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);

    udpSocket!.listen((event) async {
      if (event == RawSocketEvent.read) {
        final dg = udpSocket!.receive();
        if (dg != null) {
          if (utf8.decode(dg.data) == 'ARE_YOU_CHAT_HOST') {
            final serverIp = user.userIp;
            chatProvider.addSystemNotification(
              'Discovery request from: ${dg.address.address}',
            );

            udpSocket!.send(
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
    tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, tcpIpPort);

    tcpSocket!.listen((client) {
      String? clientUsername;
      client.listen(
        (data) {
          print('error is here: ${jsonDecode(utf8.decode(data))}');
          final message = Message.fromJson(jsonDecode(utf8.decode(data)));
          if (message.type == 'auth') {
            if (message.content != room!.password) {
              chatProvider.addSystemNotification('Invalid Password');

              client.close();
              return;
            } else {
              clients.add(client);
              clientUsername = message.senderUsername;
              chatProvider.addSystemNotification('$clientUsername Connected');
              shareNotifications('$clientUsername Connected');
              return;
            }
          }

          _handleMessage(client, message);
        },
        onDone: () => _removeClient(client, clientUsername!),
        onError: (error, stackTrace) => _removeClient(client, clientUsername!),
      );
    });
  }

  _handleMessage(Socket client, data) {
    final message = data;
    chatProvider.addMessage(message);
    chatProvider.addSystemNotification('A Message Received');
  }

  _removeClient(Socket client, String clientUsername) {
    chatProvider.addSystemNotification('$clientUsername Disconnected');
    shareNotifications('$clientUsername Disconnected');
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

  void shareNotifications(String notification) {
    sendMessage(
      Message(
        type: 'notification',
        senderip: user.userIp,
        senderUsername: user.username,
        content: notification,
      ),
    );
  }

  stop() async {
    udpSocket?.close();
    udpSocket = null;
    for (final client in List<Socket>.from(clients)) {
      try {
        await client.close();
      } catch (_) {}
    }
    clients.clear();
    tcpSocket?.close();
    tcpSocket = null;
  }
}
