import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/banner_ad_widget.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';
import 'widgets/design_card.dart';
import 'login_screen.dart';

class AllDesignsScreen extends StatefulWidget {
  const AllDesignsScreen({super.key});

  @override
  State<AllDesignsScreen> createState() => _AllDesignsScreenState();
}

class _AllDesignsScreenState extends State<AllDesignsScreen> {
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  
  List<DesignModel> _designs = [];
  bool _isLoading = true;
  bool _isLoadMoreLoading = false;
  bool _hasMoreDesigns = true;
  int _nextPage = 2;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInitialDesigns();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialDesigns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _nextPage = 2;
      _hasMoreDesigns = true;
      _isLoadMoreLoading = false;
    });

    try {
      final result = await _authService.getDesignsListPaginated(page: 1);
      setState(() {
        _designs = result?['designs'] ?? [];
        _hasMoreDesigns = result?['hasNext'] ?? false;
        _isLoading = false;
        if (_designs.isEmpty) {
          _errorMessage = "No designs found.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load designs. Please try again.";
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreDesigns();
    }
  }

  Future<void> _loadMoreDesigns() async {
    if (_isLoadMoreLoading || !_hasMoreDesigns) return;

    setState(() {
      _isLoadMoreLoading = true;
    });

    print("AllDesignsScreen: Loading more designs page $_nextPage");

    final result = await _authService.getDesignsListPaginated(
      page: _nextPage,
    );

    if (result != null) {
      final List<DesignModel> newDesigns = result['designs'];
      final bool hasNext = result['hasNext'];

      setState(() {
        if (newDesigns.isNotEmpty) {
          _designs.addAll(newDesigns);
          _nextPage++;
        }
        _hasMoreDesigns = hasNext;
        _isLoadMoreLoading = false;
      });
    } else {
      setState(() {
        _isLoadMoreLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load more designs.")),
        );
      }
    }
  }

  Future<void> _toggleFavorite(DesignModel design) async {
    final token = await _authService.getToken();
    if (token == null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    print("AllDesignsScreen: Toggle favorite clicked for design: ${design.id}");

    final bool originalIsFav = design.isFav;

    // 1. Optimistic Update (Immediate UI response)
    setState(() {
      final index = _designs.indexWhere((e) => e.id == design.id);
      if (index != -1) {
        _designs[index] = DesignModel(
          id: design.id,
          title: design.title,
          slug: design.slug,
          image: design.image,
          isFav: !originalIsFav,
        );
      }
    });

    // 2. API Call
    final result = await _authService.toggleFavorite(design.id);
    print("AllDesignsScreen: Toggle favorite result status: ${result['status']}");

    if (result['status'] == false) {
      // 3. Rollback on failure
      setState(() {
        final index = _designs.indexWhere((e) => e.id == design.id);
        if (index != -1) {
          _designs[index] = design; // Revert to original instance
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Failed to update favorite"),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: const CommonAppBar(title: 'All Designs'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _fetchInitialDesigns,
                  color: const Color(0xFFE28127),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double screenWidth = constraints.maxWidth;
                            int crossAxisCount = screenWidth > 600 ? 3 : 2;
                            if (screenWidth > 900) crossAxisCount = 4;

                            return GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: _designs.length,
                              itemBuilder: (context, index) {
                                final design = _designs[index];
                                return DesignCard(
                                  imageUrl: design.image,
                                  title: design.title,
                                  index: index,
                                  allImages: _designs.map((e) => e.image).toList(),
                                  allDesigns: _designs,
                                  isFavorite: design.isFav,
                                  onFavoriteToggle: () => _toggleFavorite(design),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      if (_isLoadMoreLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFFE28127)),
                          ),
                        ),
                      const BannerAdWidget(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!, style: GoogleFonts.outfit(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchInitialDesigns,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE28127),
            ),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
