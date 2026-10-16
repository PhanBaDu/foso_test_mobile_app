import 'package:flutter/material.dart';

/// The shell positions this above the IME without moving its tabbar.
class KeyboardDismissButton extends StatelessWidget {
  const KeyboardDismissButton({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF0F1F2),
    elevation: 4,
    shadowColor: const Color(0x22000000),
    shape: const CircleBorder(side: BorderSide(color: Colors.white)),
    child: IconButton(
      tooltip: 'Đóng bàn phím',
      color: const Color(0xFF1A1A1A),
      constraints: const BoxConstraints.tightFor(width: 52, height: 52),
      iconSize: 20,
      icon: const Icon(Icons.keyboard_hide_rounded),
      onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
    ),
  );
}
