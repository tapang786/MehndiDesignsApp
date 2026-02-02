import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/common_app_bar.dart';
import 'services/auth_service.dart';
import 'models/dashboard_model.dart';
import 'widgets/design_card.dart';

class CategoriesScreen extends StatefulWidget {
  final int? initialCategoryIndex;
  const CategoriesScreen({super.key, this.initialCategoryIndex});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final AuthService _authService = AuthService();
  List<CategoryModel> _apiCategories = [];
  CategoryModel? _selectedCategory;
  List<SubCategoryModel> _subCategories = [];
  SubCategoryModel? _selectedSubCategory;
  List<DesignModel> _designs = [];
  bool _isLoading = true;
  bool _isSubLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final categories = await _authService.getCategoriesList();
      setState(() {
        _apiCategories = categories;
        _isLoading = false;
        if (categories.isEmpty) {
          _errorMessage = "No categories found.";
        }
      });

      // If initialCategoryIndex is provided, auto-select it
      if (widget.initialCategoryIndex != null &&
          widget.initialCategoryIndex! < categories.length) {
        _onCategoryTap(categories[widget.initialCategoryIndex!]);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load categories. Please try again.";
      });
    }
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    setState(() {
      _selectedCategory = category;
      _subCategories = [];
      _selectedSubCategory = null;
      _designs = [];
      _isSubLoading = true;
    });

    try {
      final subs = await _authService.getSubCategoriesList(category.id);
      setState(() {
        _subCategories = subs;
        if (subs.isNotEmpty) {
          _selectedSubCategory = subs.first;
          _fetchDesigns();
        } else {
          _isSubLoading = false;
        }
      });
    } catch (e) {
      setState(() => _isSubLoading = false);
    }
  }

  Future<void> _fetchDesigns() async {
    if (_selectedSubCategory == null) return;

    setState(() => _isSubLoading = true);
    try {
      final designs = await _authService.getDesignsList(
        subCategoryId: _selectedSubCategory!.id,
      );
      setState(() {
        _designs = designs;
        _isSubLoading = false;
      });
    } catch (e) {
      setState(() => _isSubLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedCategory == null,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedCategory != null) {
          setState(() {
            _selectedCategory = null;
            _subCategories = [];
            _selectedSubCategory = null;
            _designs = [];
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: CommonAppBar(
          title: _selectedCategory?.name ?? 'Categories',
          onBackOverride: _selectedCategory != null
              ? () {
                  setState(() {
                    _selectedCategory = null;
                    _subCategories = [];
                    _selectedSubCategory = null;
                    _designs = [];
                  });
                }
              : null,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE28127)),
              )
            : _errorMessage != null
            ? _buildErrorWidget()
            : _selectedCategory == null
            ? _buildMainCategoryGrid()
            : _buildSubCategoryView(),
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
            onPressed: _fetchCategories,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE28127),
            ),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryView() {
    return Column(
      children: [
        // Sub-categories SlideView (Horizontal List)
        if (_subCategories.isNotEmpty)
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _subCategories.length,
              itemBuilder: (context, index) {
                final sub = _subCategories[index];
                final isSelected = _selectedSubCategory?.id == sub.id;
                double itemWidth =
                    (MediaQuery.of(context).size.width - 24) / 4.2;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubCategory = sub;
                      _designs = [];
                    });
                    _fetchDesigns();
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
                              color: isSelected
                                  ? const Color(0xFFE28127)
                                  : Colors.grey[200]!,
                              width: 2.5,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(sub.image),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFFE28127).withOpacity(0.2)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sub.name,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFE28127)
                                : Colors.black87,
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

        // Designs Grid
        Expanded(
          child: _isSubLoading && _designs.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE28127)),
                )
              : _designs.isEmpty
              ? Center(
                  child: Text(
                    "No designs found in this sub-category.",
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _designs.length,
                  itemBuilder: (context, index) {
                    final design = _designs[index];
                    return DesignCard(
                      imageUrl: design.image,
                      title: design.title,
                      index: index,
                      allImages: _designs.map((e) => e.image).toList(),
                      isFavorite: design.isFav,
                      onFavoriteToggle: () => _toggleFavorite(design),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(DesignModel design) async {
    print("CategoriesScreen: Toggle favorite clicked for design: ${design.id}");
    final result = await _authService.toggleFavorite(design.id);
    print(
      "CategoriesScreen: Toggle favorite result status: ${result['status']}",
    );
    if (result['status'] == true) {
      setState(() {
        // Find and update the design in the list
        final index = _designs.indexWhere((e) => e.id == design.id);
        if (index != -1) {
          final updatedDesign = DesignModel(
            id: design.id,
            title: design.title,
            slug: design.slug,
            image: design.image,
            isFav: !design.isFav,
          );
          _designs[index] = updatedDesign;
          print(
            "CategoriesScreen: Design ${design.id} isFav updated to: ${!design.isFav}",
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
        "CategoriesScreen: Failed to toggle favorite for design ${design.id}: ${result['message']}",
      );
    }
  }

  Widget _buildMainCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: _apiCategories.length,
      itemBuilder: (context, index) {
        final category = _apiCategories[index];
        return GestureDetector(
          onTap: () => _onCategoryTap(category),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFE28127).withOpacity(0.06),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE28127),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE28127).withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(category.image),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
