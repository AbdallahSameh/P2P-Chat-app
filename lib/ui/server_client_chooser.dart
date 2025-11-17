import 'package:flutter/material.dart';
import 'package:p2p_chat_app/ui/chat_screen.dart';

class ServerClientChooser extends StatefulWidget {
  const ServerClientChooser({super.key});

  @override
  State<ServerClientChooser> createState() => _ServerClientChooserState();
}

class _ServerClientChooserState extends State<ServerClientChooser> {
  int? choice;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    choice = 1;
                  });
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      color: choice == 1
                          ? Colors.blueAccent
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(child: Text("Host")),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    choice = 2;
                  });
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      color: choice == 2
                          ? Colors.blueAccent
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(child: Text("Join")),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (choice == null) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(choice: choice!),
                    ),
                  );
                },
                child: Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
