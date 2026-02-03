import 'package:flutter/material.dart';
import 'package:p2p_chat_app/data%20models/room.dart';
import 'package:p2p_chat_app/data%20models/user.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';
import 'package:p2p_chat_app/ui/chat_screen.dart';
import 'package:p2p_chat_app/ui/room_chooser.dart';
import 'package:p2p_chat_app/ui/shared/colourful_button.dart';
import 'package:p2p_chat_app/ui/shared/custom_ink_well.dart';
import 'package:p2p_chat_app/ui/shared/custom_text_form_field.dart';
import 'package:provider/provider.dart';

class ChoiceDialogue extends StatefulWidget {
  final int choice;
  const ChoiceDialogue({super.key, required this.choice});

  @override
  State<ChoiceDialogue> createState() => _ChoiceDialogueState();
}

class _ChoiceDialogueState extends State<ChoiceDialogue> {
  late final GlobalKey<FormState> formKey;
  late TextEditingController controller1, controller2, controller3;
  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
    context.read<ChatProvider>().deleteUser();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Color(0xff1a1a24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 30,
            children: [
              Text(
                'Create Chat Room',
                style: Theme.of(context).primaryTextTheme.bodyMedium,
              ),
              Form(
                key: formKey,
                child: Column(
                  spacing: 14,
                  children: [
                    CustomTextFormField(
                      controller: controller1,
                      labelText: 'Username',
                      hintText: 'Enter Username',
                    ),
                    if (widget.choice == 1) ...[
                      CustomTextFormField(
                        controller: controller2,
                        labelText: 'Room name',
                        hintText: 'Enter Room name',
                      ),
                      CustomTextFormField(
                        controller: controller3,
                        labelText: 'Password',
                        hintText: 'Enter Password',
                      ),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomInkWell(
                              height: 50,
                              index: 0,
                              text: 'Hotspot',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomInkWell(
                              height: 50,
                              index: 1,
                              text: 'Wifi',
                            ),
                          ),
                        ),
                      ],
                    ),

                    ColourfulButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<ChatProvider>().addUser(
                            User(username: controller1.text, userIp: ''),
                          );

                          Navigator.pop(context);
                          if (widget.choice == 1) {
                            Room room = Room(
                              roomName: controller2.text,
                              hostIp: '',
                            );
                            room.password = controller3.text;
                            context.read<ChatProvider>().addChatRoom(room);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatScreen(choice: widget.choice),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HostChooser()),
                            );
                          }
                        }
                      },
                      text: 'Enter',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
