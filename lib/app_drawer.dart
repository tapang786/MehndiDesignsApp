import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';
import '../info_screen.dart';
import '../login_screen.dart';
import '../notifications_screen.dart';
import '../my_account_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Column(
        children: [
          // User Profile Top
          // User Profile Top
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE28127), Color(0xFFF2A154)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFFE28127),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pratiksha Singh',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@pratiksha',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(context, Icons.home_outlined, 'Home', () {
                  Navigator.pop(context); // Close drawer
                  // If we are not on HomeScreen, navigate to it
                  // Simple check if we can pop to root, or replace
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                }),
                _buildDrawerItem(
                  context,
                  Icons.person_outline,
                  'My Account',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyAccountScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.category_outlined,
                  'Categories',
                  () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.favorite_outline,
                  'Favorites',
                  () {},
                ),
                // _buildDrawerItem(context, Icons.history, 'History', () {}),
                // _buildDrawerItem(
                //   context,
                //   Icons.notifications_outlined,
                //   'Notifications',
                //   () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const NotificationsScreen(),
                //       ),
                //     );
                //   },
                // ),
                const Divider(height: 32),
                _buildDrawerItem(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Privacy Policy',
                          content:
                              'This is the privacy policy content. We respect your privacy and are committed to protecting your personal data...',
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.description_outlined,
                  'Terms & Conditions',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Terms & Conditions',
                          content:
                              'These are the terms and conditions. By using this app, you agree to comply with and be bound by the following terms...',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  Icons.share_outlined,
                  'Share App',
                  () {},
                ),
                _buildDrawerItem(context, Icons.star_outline, 'Rate Us', () {}),
                _buildDrawerItem(context, Icons.logout, 'Logout', () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }, color: Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE28127).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isActive ? const Color(0xFFE28127) : Colors.black87),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color:
                color ?? (isActive ? const Color(0xFFE28127) : Colors.black87),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
