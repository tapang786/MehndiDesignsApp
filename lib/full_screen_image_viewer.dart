import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/common_app_bar.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';
import 'custom_bottom_navigation_bar.dart';
import 'main_screen.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<DesignModel> designs;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.designs,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final AuthService _authService = AuthService();
  late PageController _pageController;
  late int _currentIndex;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    isFavorite = widget.designs[_currentIndex].isFav;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      isFavorite = widget.designs[_currentIndex].isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final design = widget.designs[_currentIndex];
    final bool originalIsFav = isFavorite;

    print(
      "FullScreenImageViewer: Toggle favorite clicked for design: ${design.id}",
    );

    // 1. Optimistic Update
    setState(() {
      isFavorite = !originalIsFav;
    });

    // 2. API Call
    final result = await _authService.toggleFavorite(design.id);
    print(
      "FullScreenImageViewer: Toggle favorite result status: ${result['status']}",
    );

    if (result['status'] == false) {
      // 3. Rollback
      setState(() {
        isFavorite = originalIsFav;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Action failed")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentIndex < widget.designs.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: CommonAppBar(
        showLogo: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () =>
              Navigator.pop(context, true), // Return true to refresh parent
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Design #${_currentIndex + 1}',
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleFavorite,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.designs.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return Center(
                  child: ZoomableImage(imageUrl: widget.designs[index].image),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: _currentIndex > 0 ? _previousPage : null,
                ),
                const SizedBox(width: 40),
                Text(
                  '${_currentIndex + 1} / ${widget.designs.length}',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 40),
                _buildControlButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: _currentIndex < widget.designs.length - 1
                      ? _nextPage
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0, // It's coming from Home tab usually
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFE28127)
              : Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: const Color(0xFFE28127).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class ZoomableImage extends StatefulWidget {
  final String imageUrl;
  const ZoomableImage({super.key, required this.imageUrl});

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addListener(() {
          _transformationController.value = _animation!.value;
        });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    Matrix4 endMatrix;
    Offset position = _doubleTapDetails != null
        ? _doubleTapDetails!.localPosition
        : Offset.zero;

    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.5)
        ..translate(position.dx / 2.5, position.dy / 2.5);
    }

    _animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurveTween(curve: Curves.easeInOut).animate(_animationController),
        );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: Hero(
        tag: widget.imageUrl,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFFE28127),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
