import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';
import 'full_screen_image_viewer.dart';

class CategoriesScreen extends StatefulWidget {
  final int? initialCategoryIndex;
  const CategoriesScreen({super.key, this.initialCategoryIndex});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedMainCategoryIndex = -1;
  int _selectedSubCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryIndex != null) {
      _selectedMainCategoryIndex = widget.initialCategoryIndex!;
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Arabic',
      'image':
          'https://blog.shaadivyah.com/wp-content/uploads/2024/12/Mandala-at-the-centre.png',
      'subCategories': [
        {
          'name': 'Front Hand',
          'image':
              'https://blog.shaadivyah.com/wp-content/uploads/2024/12/Mandala-at-the-centre.png',
          'designs': [
            'https://blog.shaadivyah.com/wp-content/uploads/2024/12/Mandala-at-the-centre.png',
            'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/henna-design-mixed-opt1200w-1024x696.jpg',
          ],
        },
        {
          'name': 'Back Hand',
          'image':
              'https://img.freepik.com/free-photo/beautiful-mehndi-tattoo-woman-hand_23-2148080083.jpg',
          'designs': [
            'https://img.freepik.com/free-photo/beautiful-mehndi-tattoo-woman-hand_23-2148080083.jpg',
            'https://i.pinimg.com/736x/2e/81/d4/2e81d4cb2453936a93508c2b949c290b.jpg',
          ],
        },
        {
          'name': 'Finger',
          'image':
              'https://i.pinimg.com/736x/2e/81/d4/2e81d4cb2453936a93508c2b949c290b.jpg',
          'designs': [
            'https://i.pinimg.com/736x/2e/81/d4/2e81d4cb2453936a93508c2b949c290b.jpg',
          ],
        },
      ],
    },
    {
      'name': 'Bridal',
      'image':
          'https://image.wedmegood.com/resized-nw/700X/wp-content/uploads/2019/03/rose2.jpg',
      'subCategories': [
        {
          'name': 'Heavy Bridal',
          'image':
              'https://image.wedmegood.com/resized-nw/700X/wp-content/uploads/2019/03/rose2.jpg',
          'designs': [
            'https://image.wedmegood.com/resized-nw/700X/wp-content/uploads/2019/03/rose2.jpg',
            'https://www.thesparklingwedding.com/wp-content/uploads/2024/09/cover_02.jpg',
          ],
        },
        {
          'name': 'Simple Bridal',
          'image':
              'https://www.triund-trek.com/uploads/blog/mehndi-hands-girl.jpg',
          'designs': [
            'https://www.triund-trek.com/uploads/blog/mehndi-hands-girl.jpg',
          ],
        },
      ],
    },
    {
      'name': 'Simple',
      'image':
          'https://cdn0.weddingwire.in/article/6495/original/1280/jpeg/125946-henna-designs-aj-mehandi-creation.jpeg',
      'subCategories': [
        {
          'name': 'Minimalist',
          'image':
              'https://cdn0.weddingwire.in/article/6495/original/1280/jpeg/125946-henna-designs-aj-mehandi-creation.jpeg',
          'designs': [
            'https://cdn0.weddingwire.in/article/6495/original/1280/jpeg/125946-henna-designs-aj-mehandi-creation.jpeg',
            'https://img.freepik.com/premium-photo/woman-with-henna-her-hand_1001890-1697.jpg',
          ],
        },
      ],
    },
    {
      'name': 'Indian',
      'image':
          'https://static.wixstatic.com/media/f969bb_dea3dded6bb449f29569f6becbadcff7~mv2.png',
      'subCategories': [
        {
          'name': 'Traditional',
          'image':
              'https://static.wixstatic.com/media/f969bb_dea3dded6bb449f29569f6becbadcff7~mv2.png',
          'designs': [
            'https://static.wixstatic.com/media/f969bb_dea3dded6bb449f29569f6becbadcff7~mv2.png',
            'https://www.shaadidukaan.com/vogue/wp-content/uploads/2025/03/lotus-mehndi-design-2.webp',
          ],
        },
      ],
    },
    {
      'name': 'Moroccan',
      'image':
          'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/Leafy-Square-Moroccan-Mehndi-Design.jpg',
      'subCategories': [
        {
          'name': 'Geometric',
          'image':
              'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/Leafy-Square-Moroccan-Mehndi-Design.jpg',
          'designs': [
            'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/Leafy-Square-Moroccan-Mehndi-Design.jpg',
          ],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDetailsView = _selectedMainCategoryIndex != -1;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isDetailsView ? Icons.arrow_back_ios_new : Icons.menu,
            color: Colors.black87,
            size: isDetailsView ? 24 : 30,
          ),
          onPressed: () {
            if (isDetailsView) {
              setState(() {
                _selectedMainCategoryIndex = -1;
                _selectedSubCategoryIndex = 0;
              });
            } else {
              MainScreen.of(context)?.openDrawer();
            }
          },
        ),
        title: Text(
          isDetailsView
              ? _categories[_selectedMainCategoryIndex]['name']
              : 'Categories',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE28127),
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: isDetailsView
            ? _buildSubCategoryView()
            : _buildMainCategoryGrid(),
      ),
    );
  }

  Widget _buildMainCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMainCategoryIndex = index;
              _selectedSubCategoryIndex = 0;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE28127),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_categories[index]['image']),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _categories[index]['name'],
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_categories[index]['subCategories'].length} Sub-categories',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryView() {
    return Column(
      key: ValueKey(_selectedMainCategoryIndex),
      children: [
        const SizedBox(height: 10),
        _buildSubCategorySlider(),
        const SizedBox(height: 10),
        Expanded(child: _buildDesignsGrid()),
      ],
    );
  }

  Widget _buildSubCategorySlider() {
    final subCats =
        _categories[_selectedMainCategoryIndex]['subCategories'] as List;
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subCats.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedSubCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubCategoryIndex = index;
              });
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE28127)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          subCats[index]['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subCats[index]['name'],
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFE28127)
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesignsGrid() {
    final List<dynamic> subCats =
        _categories[_selectedMainCategoryIndex]['subCategories'];
    final List<String> currentDesigns = List<String>.from(
      subCats[_selectedSubCategoryIndex]['designs'],
    );

    return GridView.builder(
      key: ValueKey(
        '${_selectedMainCategoryIndex}_${_selectedSubCategoryIndex}',
      ),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: currentDesigns.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageViewer(
                  images: currentDesigns,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      currentDesigns[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Design #${index + 1}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
