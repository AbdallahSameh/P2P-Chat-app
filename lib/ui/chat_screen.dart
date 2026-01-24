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
  final Client? client;
  const ChatScreen({super.key, required this.choice, this.client});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatType chatType;
  late final ChatProvider chatProvider;
  late final TextEditingController typingFieldController;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    if (widget.choice == 1) {
      final host = Host(chatProvider: chatProvider);
      chatType = host;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await chatType.start();
      });
    } else {
      chatType = widget.client!;
    }

    typingFieldController = TextEditingController();
  }

  @override
  void dispose() {
    typingFieldController.dispose();
    super.dispose();
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
                    leading: Text(
                      messages[messages.length - 1 - index].senderUsername,
                    ),
                    title: Text(messages[messages.length - 1 - index].content),
                    trailing: Text(
                      messages[messages.length - 1 - index].sendTime ?? '0',
                    ),
                  );
                  // return ChatBubble();
                },
                separatorBuilder: (_, index) => SizedBox(height: 10),
                itemCount: messages.length,
              ),
            ),
          ),
          // the chat utils

          // test
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: typingFieldController,
                      decoration: InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (typingFieldController.text == '' ||
                          typingFieldController.text.isEmpty) {
                        return;
                      }
                      for (var notification
                          in chatProvider.systemNotifications) {
                        print('Notification: $notification');
                      }
                      chatType.sendMessage(
                        Message(
                          senderip: chatProvider.user!.userIp,
                          senderUsername: chatProvider.user!.username,
                          content: typingFieldController.text,
                        ),
                      );

                      typingFieldController.text = '';
                    },
                    child: Text('Send Message'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
