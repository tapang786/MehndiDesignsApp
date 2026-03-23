import 'package:flutter/material.dart';
import 'custom_bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'categories_screen.dart';
import 'my_account_screen.dart';
import 'app_drawer.dart';
import 'services/auth_service.dart';
import 'widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

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

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final authService = AuthService();
      final updateData = await authService.checkAppUpdate();

      if (updateData != null && updateData['status'] == true) {
        final data = updateData['data'];

        final String latestVersion =
            (Platform.isAndroid
                ? data['app_version_android']
                : data['app_version_ios']) ??
            "";

        final bool isForceUpdate =
            data['force_update'] == true ||
            data['force_update'].toString() == "1";

        final String updateUrl =
            (Platform.isAndroid ? data['app_link'] : data['ios_app_link']) ??
            "";

        if (latestVersion.isNotEmpty) {
          final packageInfo = await PackageInfo.fromPlatform();
          final currentFullVersion =
              "${packageInfo.version}+${packageInfo.buildNumber}";

          if (_isVersionGreater(latestVersion, currentFullVersion)) {
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: !isForceUpdate,
                builder: (context) => UpdateDialog(
                  appVersion: latestVersion,
                  isForceUpdate: isForceUpdate,
                  updateUrl: updateUrl,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print("Error checking for update in UI: $e");
    }
  }

  bool _isVersionGreater(String latest, String current) {
    try {
      // Split version and build number if present
      String latestVersion = latest.split('+')[0];
      int latestBuild = latest.contains('+')
          ? int.tryParse(latest.split('+')[1]) ?? 0
          : 0;

      String currentVersion = current.split('+')[0];
      int currentBuild = current.contains('+')
          ? int.tryParse(current.split('+')[1]) ?? 0
          : 0;

      List<int> latestParts = latestVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      List<int> currentParts = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      // Compare major.minor.patch
      for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      // If version parts are equal, compare version string length
      if (latestParts.length != currentParts.length) {
        return latestParts.length > currentParts.length;
      }

      // Finally, compare build numbers
      return latestBuild > currentBuild;
    } catch (e) {
      print("Error comparing versions: $e");
      return false;
    }
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
