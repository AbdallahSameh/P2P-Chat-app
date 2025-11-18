import 'package:flutter/material.dart';
import 'package:p2p_chat_app/chat%20service/client.dart';
import 'package:p2p_chat_app/chat%20service/host.dart';
import 'package:p2p_chat_app/data%20models/message.dart';
import 'package:p2p_chat_app/interfaces/chat_type.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';
import 'package:p2p_chat_app/ui/shared/chat_bubble.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int choice;
  final String? roomName;
  const ChatScreen({super.key, required this.choice, this.roomName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatType chatType;
  late final ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    if (widget.choice == 1) {
      final host = Host(chatProvider: chatProvider, roomName: widget.roomName!);
      chatType = host;
    } else {
      final client = Client(chatProvider: chatProvider);
      chatType = client;
    }

    chatType.start();
  }

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      body: Column(
        children: [
          // the chat container
          Expanded(
            child: Container(
              child: ListView.separated(
                reverse: true,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(messages[messages.length - 1 - index].content),
                  );
                  // return ChatBubble();
                },
                separatorBuilder: (_, index) => SizedBox(height: 10),
                itemCount: messages.length,
              ),
            ),
          ),
          // the chat utils
          // Container(child: Row()),

          // test
          Center(
            child: ElevatedButton(
              onPressed: () {
                for (var notification
                    in context.read<ChatProvider>().systemNotifications) {
                  print('Notification: $notification');
                }
                chatType.sendMessage(
                  Message(
                    sender: chatType.deviceIp,
                    content: 'Hello ${chatType.deviceIp}',
                  ),
                );
              },
              child: Text('Send Message'),
            ),
          ),
        ],
      ),
    );
  }
}
