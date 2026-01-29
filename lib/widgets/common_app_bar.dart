import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mehndi_designs/notifications_screen.dart';
import 'package:mehndi_designs/main_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showDrawerButton;
  final bool showNotification;
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showDrawerButton = true,
    this.showNotification = true,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: const Color(0xFFE28127),
      elevation: 0,
      leading:
          leading ??
          (showDrawerButton
              ? IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () {
                    final mainScreen = MainScreen.of(context);
                    if (mainScreen != null) {
                      mainScreen.openDrawer();
                    } else {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                )
              : null),
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    // color: Colors.white,
                    // shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/mehndi_design.png',
                    height: 50,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mehndi Designs',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              title ?? '',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (actions != null) ...actions!,
        if (showNotification)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: Lottie.network(
                      'https://lottie.host/43f60632-6e9f-444a-9b8c-5507ad987f65/Cg2g8s73C1.json',
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '1',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
