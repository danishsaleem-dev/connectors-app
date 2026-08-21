import 'package:flutter/material.dart';
import '../widgets/offices_section.dart';

/// Office details moved off Home and behind the Menu — contact information
/// is something you look up, not something that belongs on the screen you
/// land on every time you open the app.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 4, bottom: 32),
          child: OfficesSection(),
        ),
      ),
    );
  }
}
