import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'main_screen.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/design_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _sliderImages = [
    'https://backhandmehndidesigns.in/wp-content/uploads/2025/04/Stylish-back-hand-mehndi-design.png',
    'https://www.thesparklingwedding.com/wp-content/uploads/2024/09/cover_02.jpg',
    'https://www.triund-trek.com/uploads/blog/mehndi-hands-girl.jpg',
  ];

  final List<Map<String, String>> _categories = [
    {
      'name': 'Arabic',
      'image':
          'https://blog.shaadivyah.com/wp-content/uploads/2024/12/Mandala-at-the-centre.png',
    },
    {
      'name': 'Bridal',
      'image':
          'https://image.wedmegood.com/resized-nw/700X/wp-content/uploads/2019/03/rose2.jpg',
    },
    {
      'name': 'Simple',
      'image':
          'https://cdn0.weddingwire.in/article/6495/original/1280/jpeg/125946-henna-designs-aj-mehandi-creation.jpeg',
    },
    {
      'name': 'Indian',
      'image':
          'https://static.wixstatic.com/media/f969bb_dea3dded6bb449f29569f6becbadcff7~mv2.png',
    },
    {
      'name': 'Moroccan',
      'image':
          'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/Leafy-Square-Moroccan-Mehndi-Design.jpg',
    },
  ];

  final List<String> _latestDesigns = [
    'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/henna-design-mixed-opt1200w-1024x696.jpg',
    'https://img.freepik.com/free-photo/beautiful-mehndi-tattoo-woman-hand_23-2148080083.jpg',
    'https://i.pinimg.com/736x/2e/81/d4/2e81d4cb2453936a93508c2b949c290b.jpg',
    'https://piyushbridalmehendi.in/wp-content/uploads/2024/06/Leafy-Square-Moroccan-Mehndi-Design.jpg',
    'https://img.freepik.com/premium-photo/woman-with-henna-her-hand_1001890-1697.jpg',
    'https://www.shaadidukaan.com/vogue/wp-content/uploads/2025/03/lotus-mehndi-design-2.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: const CommonAppBar(showLogo: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTopSlider(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildLatestDesignsSection(),
            const SizedBox(height: 24),
          ],
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
      items: _sliderImages.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
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
          child: Text(
            'Categories',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
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
                            image: NetworkImage(_categories[index]['image']!),
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
                        _categories[index]['name']!,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
          itemCount: _latestDesigns.length,
          itemBuilder: (context, index) {
            return DesignCard(
              imageUrl: _latestDesigns[index],
              index: index,
              allImages: _latestDesigns,
            );
          },
        ),
      ],
    );
  }
}
