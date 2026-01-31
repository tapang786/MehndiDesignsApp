import 'package:flutter/material.dart';
import 'custom_bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'categories_screen.dart';
import 'my_account_screen.dart';
import 'app_drawer.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int? initialCategoryIndex;
  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialCategoryIndex,
  });

  static MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _selectedIndex;

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      CategoriesScreen(initialCategoryIndex: widget.initialCategoryIndex),
      const FavoritesScreen(),
      const MyAccountScreen(),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        extendBody: false,
        body: screens[_selectedIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
