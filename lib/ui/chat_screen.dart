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
  Host? host;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    if (widget.choice == 1) {
      host = Host(chatProvider: chatProvider);
      chatType = host!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await chatType.start();
      });
    } else {
      chatType = widget.client!;
    }

    chatProvider.deleteMessages();
    typingFieldController = TextEditingController();
  }

  @override
  void dispose() async {
    typingFieldController.dispose();
    if (host != null) {
      host!.stop();
      chatProvider.deleteRooms();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          context
              .watch<ChatProvider>()
              .chatRooms[context.watch<ChatProvider>().currentRoom]
              .roomName,
          style: Theme.of(
            context,
          ).primaryTextTheme.bodyMedium?.copyWith(fontSize: 24),
        ),
        backgroundColor: Color(0xff1a1a24),
        elevation: 8,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        toolbarHeight: 100,
      ),
      backgroundColor: Color(0xff1a1a24),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView.separated(
                  reverse: true,
                  itemBuilder: (_, index) {
                    // return ListTile(
                    //   leading: Text(
                    //     messages[messages.length - 1 - index].senderUsername,
                    //   ),
                    //   title: Text(
                    //     messages[messages.length - 1 - index].content,
                    //   ),
                    //   trailing: Text(
                    //     messages[messages.length - 1 - index].sendTime ?? '0',
                    //   ),
                    // );
                    return ChatBubble(
                      message: messages[messages.length - 1 - index],
                      isMe:
                          messages[messages.length - 1 - index].senderip ==
                              context.watch<ChatProvider>().user!.userIp
                          ? true
                          : false,
                    );
                  },
                  separatorBuilder: (_, index) => SizedBox(height: 10),
                  itemCount: messages.length,
                ),
              ),
            ),

            // chat utils
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: TextFormField(
                        minLines: 1,
                        maxLines: 4,
                        controller: typingFieldController,
                        cursorColor: Colors.indigo,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.indigo,
                              width: 1.5,
                            ),
                          ),
                          hint: Text(
                            'Message',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: typingFieldController.text.isEmpty
                            ? Colors.indigo.withOpacity(0.4)
                            : Colors.indigo,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          if (typingFieldController.text.trim().isEmpty) {
                            return;
                          }
                          for (var notification
                              in chatProvider.systemNotifications) {
                            print('Notification: $notification');
                          }
                          chatType.sendMessage(
                            Message(
                              type: 'message',
                              senderip: chatProvider.user!.userIp,
                              senderUsername: chatProvider.user!.username,
                              content: typingFieldController.text,
                            ),
                          );

                          typingFieldController.text = '';
                        },
                        child: Icon(
                          Icons.send_rounded,
                          color: typingFieldController.text.isEmpty
                              ? Colors.white24
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
