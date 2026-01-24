import 'package:flutter/material.dart';
import 'package:p2p_chat_app/chat%20service/client.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/ui/chat_screen.dart';
import 'package:p2p_chat_app/ui/shared/custom_text_form_field.dart';

class PasswordDialogue extends StatefulWidget {
  final List<Room> rooms;
  final int choice;
  final Client client;
  const PasswordDialogue({
    super.key,
    required this.rooms,
    required this.choice,
    required this.client,
  });

  @override
  State<PasswordDialogue> createState() => _PasswordDialogueState();
}

class _PasswordDialogueState extends State<PasswordDialogue> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController controller;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: controller,
                labelText: 'Room Password',
                hintText: 'Enter a password',
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.client.connectToHost(
                      widget.rooms[widget.choice].hostIp,
                      controller.text,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatScreen(choice: 2, client: widget.client),
                      ),
                    );
                  }
                },
                child: Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
