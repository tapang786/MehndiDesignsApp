import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'all_designs_screen.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/native_ad_widget.dart';
import 'widgets/design_card.dart';
import 'widgets/banner_ad_widget.dart';
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
  int _currentBannerIndex = 0;

  // Pagination & Load More States
  final ScrollController _scrollController = ScrollController();
  bool _isLoadMoreLoading = false;
  bool _hasMoreDesigns = true;
  int _nextPage = 2;

  @override
  void initState() {
    super.initState();
    _loadCachedDataAndFetchFresh();
    _scrollController.addListener(_onScroll);
    _authService.updateFcmToken(); // Update FCM token on home page load
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedDataAndFetchFresh() async {
    // 1. Load cached dashboard data first (instantly updates UI)
    final cachedData = await _authService.getCachedDashboardData();
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _dashboardData = cachedData;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    }

    // 2. Fetch fresh data from API in background
    try {
      final freshData = await _authService.getDashboardData();
      if (freshData != null) {
        if (mounted) {
          setState(() {
            _dashboardData = freshData;
            _isLoading = false;
            _errorMessage = null;
            // Reset pagination state
            _nextPage = 2;
            _hasMoreDesigns = true;
            _isLoadMoreLoading = false;
          });
        }
      } else {
        // If fetch failed but we have no cached data, show error screen.
        if (_dashboardData == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage =
                  "Failed to load dashboard data. Please try again.";
            });
          }
        }
      }
    } catch (e) {
      if (_dashboardData == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load dashboard data. Please try again.";
          });
        }
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    // Direct pull-to-refresh
    try {
      final freshData = await _authService.getDashboardData();
      if (freshData != null) {
        setState(() {
          _dashboardData = freshData;
          _isLoading = false;
          _errorMessage = null;
          _nextPage = 2;
          _hasMoreDesigns = true;
          _isLoadMoreLoading = false;
        });
      } else {
        if (_dashboardData == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load dashboard data. Please try again.";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to refresh. Showing offline data."),
            ),
          );
        }
      }
    } catch (e) {
      if (_dashboardData == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load dashboard data. Please try again.";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error refreshing. Showing offline data."),
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreDesigns();
    }
  }

  Future<void> _loadMoreDesigns() async {
    if (_isLoadMoreLoading || !_hasMoreDesigns || _dashboardData == null)
      return;

    setState(() {
      _isLoadMoreLoading = true;
    });

    print("HomeScreen: Loading more designs page $_nextPage");

    final result = await _authService.getDesignsListPaginated(page: _nextPage);

    if (result != null) {
      final List<DesignModel> newDesigns = result['designs'];
      final bool hasNext = result['hasNext'];

      setState(() {
        if (newDesigns.isNotEmpty) {
          _dashboardData!.designs.addAll(newDesigns);
          _nextPage++;
        }
        _hasMoreDesigns = hasNext;
        _isLoadMoreLoading = false;
      });

      // Update cache
      await _authService.saveDashboardToCache(_dashboardData!);
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
                controller: _scrollController,
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
                    const NativeAdWidget(),
                    const SizedBox(height: 24),
                    if (_dashboardData?.designs != null &&
                        _dashboardData!.designs.isNotEmpty)
                      _buildLatestDesignsSection(),
                    const SizedBox(height: 16),
                    const BannerAdWidget(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 2.2 / 1,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items: _dashboardData!.banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                        // Subtle overlay for better visual depth
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _dashboardData!.banners.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentBannerIndex == entry.key ? 20.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentBannerIndex == entry.key
                    ? const Color(0xFFE28127)
                    : const Color(0xFFE28127).withOpacity(0.2),
              ),
            );
          }).toList(),
        ),
      ],
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
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE28127),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Categories',
                    style: GoogleFonts.outfit(
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 24
                          : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
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
        // const SizedBox(height: 5),
        SizedBox(
          height: MediaQuery.of(context).size.width > 600 ? 150 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _dashboardData!.categories.length,
            itemBuilder: (context, index) {
              final category = _dashboardData!.categories[index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  double itemWidth = screenWidth > 600 ? 140 : 100;
                  double circleSize = screenWidth > 600 ? 100 : 80;

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
                    child: Container(
                      width: itemWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE28127).withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: category.image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.category,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              category.name,
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth > 600 ? 16 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE28127),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Latest Designs',
                    style: GoogleFonts.outfit(
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 24
                          : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllDesignsScreen(),
                    ),
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
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            int crossAxisCount = screenWidth > 600 ? 3 : 2;
            if (screenWidth > 900) crossAxisCount = 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _dashboardData!.designs.length,
              itemBuilder: (context, index) {
                final design = _dashboardData!.designs[index];
                return DesignCard(
                  imageUrl: design.image,
                  title: design.title,
                  index: index,
                  allImages: _dashboardData!.designs
                      .map((e) => e.image)
                      .toList(),
                  allDesigns: _dashboardData!.designs,
                  isFavorite: design.isFav,
                  onFavoriteToggle: () => _toggleFavorite(design),
                );
              },
            );
          },
        ),
        if (_isLoadMoreLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFE28127)),
            ),
          ),
      ],
    );
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

    print("HomeScreen: Toggle favorite clicked for design: ${design.id}");

    final bool originalIsFav = design.isFav;

    // 1. Optimistic Update (Immediate UI response)
    setState(() {
      final index = _dashboardData!.designs.indexWhere(
        (e) => e.id == design.id,
      );
      if (index != -1) {
        _dashboardData!.designs[index] = DesignModel(
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
    print("HomeScreen: Toggle favorite result status: ${result['status']}");

    if (result['status'] == false) {
      // 3. Rollback on failure
      setState(() {
        final index = _dashboardData!.designs.indexWhere(
          (e) => e.id == design.id,
        );
        if (index != -1) {
          _dashboardData!.designs[index] =
              design; // Revert to original instance
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
      // Persist the updated state to dashboard cache
      await _authService.saveDashboardToCache(_dashboardData!);

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
}
