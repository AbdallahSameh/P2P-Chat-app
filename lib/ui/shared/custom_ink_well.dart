import 'package:flutter/material.dart';
import 'package:p2p_chat_app/provider/chat_provider.dart';
import 'package:provider/provider.dart';

class CustomInkWell extends StatelessWidget {
  final int index;
  final double height;
  final String text;

  const CustomInkWell({
    super.key,
    required this.index,
    required this.height,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    int choice = context.watch<ChatProvider>().connectivityType;
    return InkWell(
      onTap: () => context.read<ChatProvider>().addConnectivityType(index),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Color(0xff242333),
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(
            color: choice == index ? Colors.indigo : Colors.transparent,
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
            text,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
