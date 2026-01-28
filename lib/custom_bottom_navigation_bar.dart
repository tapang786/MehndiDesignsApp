import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFE28127).withOpacity(0.15),
            indicatorShape: const CircleBorder(),
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: Color(0xFFE28127));
              }
              return const IconThemeData(color: Colors.grey);
            }),
          ),
          child: NavigationBar(
            height: 80,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.home_outlined),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.home),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.category_outlined),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.category),
                ),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.favorite_border),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.favorite),
                ),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.person_outline),
                ),
                selectedIcon: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.person),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
