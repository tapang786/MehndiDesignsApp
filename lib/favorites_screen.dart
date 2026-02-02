import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/design_card.dart';
import 'main_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final AuthService _authService = AuthService();
  List<DesignModel> _favoriteDesigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _authService.getFavorites();
      setState(() {
        _favoriteDesigns = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print("Error in FavoritesScreen: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(DesignModel design) async {
    print("FavoritesScreen: Toggle favorite clicked for design: ${design.id}");
    // Optimistic UI update: remove from list immediately
    setState(() {
      _favoriteDesigns.removeWhere((item) => item.id == design.id);
    });

    final result = await _authService.toggleFavorite(design.id);
    print(
      "FavoritesScreen: Toggle favorite result status: ${result['status']}",
    );
    if (result['status'] == false) {
      print(
        "FavoritesScreen: Failed to toggle favorite, reverting. Error: ${result['message']}",
      );
      // Revert if API failed
      _fetchFavorites();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      print(
        "FavoritesScreen: Successfully toggled favorite for design: ${design.id}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: const CommonAppBar(title: 'Favorites'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            )
          : _favoriteDesigns.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchFavorites,
              color: const Color(0xFFE28127),
              child: _buildFavoritesGrid(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE28127).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: const Color(0xFFE28127).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Explore our stunning Mehndi designs and save your favorites here!',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to Categories or Home
              final mainScreenState = MainScreen.of(context);
              if (mainScreenState != null) {
                mainScreenState.setSelectedIndex(0);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE28127),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Start Exploring',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    final List<String> imageUrls = _favoriteDesigns
        .map((d) => d.image)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount = screenWidth > 600 ? 3 : 2;
        if (screenWidth > 900) crossAxisCount = 4;

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _favoriteDesigns.length,
          itemBuilder: (context, index) {
            final design = _favoriteDesigns[index];
            return DesignCard(
              imageUrl: design.image,
              title: design.title,
              index: index,
              allImages: imageUrls,
              allDesigns: _favoriteDesigns,
              isFavorite: true,
              onFavoriteToggle: () => _toggleFavorite(design),
            );
          },
        );
      },
    );
  }
}
