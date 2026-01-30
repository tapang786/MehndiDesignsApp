import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/design_card.dart';

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
    // Optimistic UI update: remove from list immediately
    setState(() {
      _favoriteDesigns.removeWhere((item) => item.id == design.id);
    });

    final result = await _authService.toggleFavorite(design.id);
    if (result['status'] == false) {
      // Revert if API failed
      _fetchFavorites();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
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
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start liking designs to see them here!',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    final List<String> imageUrls = _favoriteDesigns
        .map((d) => d.image)
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _favoriteDesigns.length,
      itemBuilder: (context, index) {
        final design = _favoriteDesigns[index];
        return DesignCard(
          imageUrl: design.image,
          index: index,
          allImages: imageUrls,
          isFavorite: true,
          onFavoriteToggle: () => _toggleFavorite(design),
        );
      },
    );
  }
}
