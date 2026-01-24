import 'package:flutter/material.dart';
import 'package:p2p_chat_app/chat%20service/client.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';
import 'package:p2p_chat_app/ui/dialogues/password_dialogue.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    List<Room> rooms = context.watch<ChatProvider>().chatRooms;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await client.getHostIp();
              setState(() {}); // now rooms list updates correctly
            },
            icon: Icon(Icons.replay),
          ),
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, index) => Container(
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: choice == index
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      title: Text(rooms[index].roomName),
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
              ElevatedButton(
                onPressed: () async {
                  if (choice == -1) {
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
                child: Text('Enter chat room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
