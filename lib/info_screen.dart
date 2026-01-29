import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mehndi_designs/widgets/common_app_bar.dart';
import 'package:mehndi_designs/custom_bottom_navigation_bar.dart';
import 'package:mehndi_designs/main_screen.dart';
import 'package:mehndi_designs/app_drawer.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: title,
        showNotification: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0, // Default to Home tab
        onDestinationSelected: (index) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: index),
            ),
            (route) => false,
          );
        },
      ),
    );
  }
}
