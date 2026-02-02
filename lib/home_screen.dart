import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'main_screen.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/design_card.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final data = await _authService.getDashboardData();
    setState(() {
      _dashboardData = data;
      _isLoading = false;
      if (data == null) {
        _errorMessage = "Failed to load dashboard data. Please try again.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: const CommonAppBar(showLogo: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.outfit(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDashboardData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE28127),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              color: const Color(0xFFE28127),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (_dashboardData?.banners != null &&
                        _dashboardData!.banners.isNotEmpty)
                      _buildTopSlider(),
                    const SizedBox(height: 24),
                    if (_dashboardData?.categories != null &&
                        _dashboardData!.categories.isNotEmpty)
                      _buildCategorySection(),
                    const SizedBox(height: 24),
                    if (_dashboardData?.designs != null &&
                        _dashboardData!.designs.isNotEmpty)
                      _buildLatestDesignsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.85,
      ),
      items: _dashboardData!.banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(banner.image),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE28127),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _dashboardData!.categories.length,
            itemBuilder: (context, index) {
              final category = _dashboardData!.categories[index];
              double itemWidth = (MediaQuery.of(context).size.width - 24) / 4.2;
              return GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(
                        initialIndex: 1,
                        initialCategoryIndex: index,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE28127),
                            width: 2.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(category.image),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLatestDesignsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Designs',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE28127),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _dashboardData!.designs.length,
          itemBuilder: (context, index) {
            final design = _dashboardData!.designs[index];
            return DesignCard(
              imageUrl: design.image,
              title: design.title,
              index: index,
              allImages: _dashboardData!.designs.map((e) => e.image).toList(),
              isFavorite: design.isFav,
              onFavoriteToggle: () => _toggleFavorite(design),
            );
          },
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(DesignModel design) async {
    print("HomeScreen: Toggle favorite clicked for design: ${design.id}");
    final result = await _authService.toggleFavorite(design.id);
    print("HomeScreen: Toggle favorite result status: ${result['status']}");
    if (result['status'] == true) {
      setState(() {
        final index = _dashboardData!.designs.indexWhere(
          (e) => e.id == design.id,
        );
        if (index != -1) {
          final updatedDesign = DesignModel(
            id: design.id,
            title: design.title,
            slug: design.slug,
            image: design.image,
            isFav: !design.isFav,
          );
          _dashboardData!.designs[index] = updatedDesign;
          print(
            "HomeScreen: Design ${design.id} isFav updated to: ${!design.isFav}",
          );
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      print(
        "HomeScreen: Failed to toggle favorite for design ${design.id}: ${result['message']}",
      );
    }
  }
}
