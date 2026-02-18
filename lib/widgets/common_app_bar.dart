import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mehndi_designs/notifications_screen.dart';
import 'package:mehndi_designs/main_screen.dart';
import 'package:mehndi_designs/services/auth_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showDrawerButton;
  final bool showNotification;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackOverride;

  const CommonAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showDrawerButton = true,
    this.showNotification = true,
    this.actions,
    this.leading,
    this.onBackOverride,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenWidth > 600 ? 90 : 70;
    double titleFontSize = screenWidth > 600 ? 24 : 19;

    return AppBar(
      toolbarHeight: appBarHeight,
      backgroundColor: const Color(0xFFE28127),
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading:
          leading ??
          (showLogo
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      final mainScreen = MainScreen.of(context);
                      if (mainScreen != null) {
                        mainScreen.openDrawer();
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                  ),
                )
              : (onBackOverride != null
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: onBackOverride,
                      )
                    : const BackButton(color: Colors.white))),
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/mehndi_design.png',
                    height: screenWidth > 600 ? 50 : 40,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Mehndi Designs',
                    style: GoogleFonts.outfit(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(
              title ?? '',
              style: GoogleFonts.outfit(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      actions: [
        if (showNotification)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
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
                      height: screenWidth > 600 ? 28 : 22,
                      width: screenWidth > 600 ? 28 : 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 20,
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: AuthService.notificationCountNotifier,
                    builder: (context, count, child) {
                      if (count <= 0) return const SizedBox.shrink();
                      return Positioned(
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
                            count.toString(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    // We can't use MediaQuery here easily, so we use a reasonable default
    // or let the AppBar handle it if we could, but preferredSize is used by Scaffold.
    // For simplicity, we can keep it 80 or use 70 as a safer bet for most devices.
    return const Size.fromHeight(70);
  }
}
