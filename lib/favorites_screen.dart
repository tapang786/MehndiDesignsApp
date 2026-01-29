import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/design_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Dummy data for favorites
  final List<String> _favoriteDesigns = [
    'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/henna-design-mixed-opt1200w-1024x696.jpg',
    'https://img.freepik.com/free-photo/beautiful-mehndi-tattoo-woman-hand_23-2148080083.jpg',
    'https://i.pinimg.com/736x/2e/81/d4/2e81d4cb2453936a93508c2b949c290b.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: const CommonAppBar(title: 'Favorites'),
      body: _favoriteDesigns.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesGrid(),
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
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _favoriteDesigns.length,
      itemBuilder: (context, index) {
        return DesignCard(
          imageUrl: _favoriteDesigns[index],
          index: index,
          allImages: _favoriteDesigns,
          isFavorite: true,
          onFavoriteToggle: () {
            setState(() {
              _favoriteDesigns.removeAt(index);
            });
          },
        );
      },
    );
  }
}
