import 'package:flutter/material.dart';
import 'package:p2p_chat_app/chat%20service/client.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';
import 'package:p2p_chat_app/ui/dialogues/password_dialogue.dart';
import 'package:p2p_chat_app/ui/shared/colourful_button.dart';
import 'package:provider/provider.dart';

class HostChooser extends StatefulWidget {
  const HostChooser({super.key});

  @override
  State<HostChooser> createState() => _HostChooserState();
}

class _HostChooserState extends State<HostChooser> {
  late final ChatProvider chatProvider;
  int choice = -1;
  late final Client client;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    client = Client(chatProvider: chatProvider);
    client.start();
    chatProvider.deleteRooms();
  }

  @override
  Widget build(BuildContext context) {
    List<Room> rooms = context.watch<ChatProvider>().chatRooms;

    return Scaffold(
      backgroundColor: Color(0xff1a1a24),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff1a1a24),
        elevation: 8,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () async {
              await client.getHostIp();
              setState(() {});
            },
            icon: Icon(Icons.replay),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            top: 24,
            right: 24,
            bottom: 16,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, index) => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xff242333),
                      borderRadius: BorderRadius.circular(12),
                      border: BoxBorder.all(
                        width: 2,
                        color: choice == index
                            ? Colors.indigo
                            : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(4, 5),
                          blurRadius: 4,
                          color: Color(0xFF242333).withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 14,
                      ),
                      title: Center(
                        child: Text(
                          rooms[index].roomName,
                          style: Theme.of(
                            context,
                          ).primaryTextTheme.bodyMedium?.copyWith(fontSize: 18),
                        ),
                      ),
                      onTap: () => setState(() {
                        choice = index;
                      }),
                    ),
                  ),
                  separatorBuilder: (_, index) {
                    return SizedBox(height: 20);
                  },
                  itemCount: rooms.length,
                ),
              ),
              ColourfulButton(
                onPressed: () async {
                  if (choice == -1) {
                    return;
                  }
                  if (choice >= rooms.length) {
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (dialogContext) => PasswordDialogue(
                      rooms: rooms,
                      choice: choice,
                      client: client,
                    ),
                  );
                },
                text: 'Enter chat room',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
