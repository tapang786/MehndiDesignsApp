import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_drawer.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE28127),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: const AppDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          content,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.grey[800],
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
