import 'package:flutter/material.dart';
import 'package:libirary_app/screen/register_page.dart';

void main(List<String> args) {
  runApp(Libirary());
}

class Libirary extends StatelessWidget {
  const Libirary({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterPage(),
    );
  }
}
