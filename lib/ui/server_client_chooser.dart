import 'package:flutter/material.dart';
import 'package:p2p_chat_app/ui/dialogues/choice.dialogue.dart';
import 'package:p2p_chat_app/ui/shared/colourful_button.dart';

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
      backgroundColor: Color(0xff1a1a24),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              spacing: 50,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      choice = 1;
                    });
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Color(0xff242333),
                      borderRadius: BorderRadius.circular(20),
                      border: BoxBorder.all(
                        width: 2,
                        color: choice == 1 ? Colors.indigo : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(4, 5),
                          blurRadius: 4,
                          color: Color(0xFF242333).withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Host",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      choice = 2;
                    });
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Color(0xff242333),
                      borderRadius: BorderRadius.circular(20),
                      border: BoxBorder.all(
                        width: 2,
                        color: choice == 2 ? Colors.indigo : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(4, 5),
                          blurRadius: 4,
                          color: Color(0xFF242333).withOpacity(0.5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Join",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                ColourfulButton(
                  text: 'Enter',
                  onPressed: () {
                    if (choice == null) {
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (_) => ChoiceDialogue(choice: choice!),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
