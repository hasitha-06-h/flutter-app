import 'package:flutter/material.dart';

void main() {
  runApp(MagazineCoverApp());
}

class MagazineCoverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine Covers',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: MagazineHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Magazine {
  final String title;
  final String category;
  final String imageUrl;
  final String issue;
  final String content;
  final String facts;

  Magazine({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.issue,
    required this.content,
    required this.facts,
  });
}

class MagazineHomePage extends StatefulWidget {
  @override
  _MagazineHomePageState createState() => _MagazineHomePageState();
}

class _MagazineHomePageState extends State<MagazineHomePage> {
  final List<Magazine> magazines = [
    Magazine(
      title: 'Tech Innovators',
      category: 'Technology',
      imageUrl:
          'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=60',
      issue: 'Nov 2025',
      content:
          'This issue explores the latest breakthroughs in AI, robotics, and quantum computing. Discover how these technologies are shaping the future of work and society.',
      facts:
          '• Did you know? Tech Innovators was first published in 2010.\n• This issue features interviews with leading experts in technology.\n• The cover photo was taken in 2025.',
    ),
    Magazine(
      title: 'Travel Explorer',
      category: 'Travel',
      imageUrl:
          'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=800&q=60',
      issue: 'Winter 2025',
      content:
          'Join us on a journey through the world’s most breathtaking winter destinations. From cozy mountain cabins to vibrant city festivals, this issue has it all.',
      facts:
          '• Did you know? Travel Explorer has featured over 100 countries.\n• This issue includes a special section on eco-tourism.\n• The cover photo was taken in the Swiss Alps.',
    ),
    Magazine(
      title: 'Fashion Forward',
      category: 'Fashion',
      imageUrl:
          'https://images.unsplash.com/photo-1488376732949-d985c0bda506?auto=format&fit=crop&w=800&q=60', // Reliable fashion cover
      issue: 'Fall 2025',
      content:
          'Explore the latest trends in fashion this season. From runway highlights to street style, get inspired by the world’s top designers.',
      facts:
          '• Did you know? Fashion Forward has been a trendsetter since 2005.\n• This issue features exclusive interviews with top designers.\n• The cover photo was taken in Paris.',
    ),
    Magazine(
      title: 'Foodies Guide',
      category: 'Food',
      imageUrl:
          'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=60',
      issue: 'Oct 2025',
      content:
          'Dive into the world of gourmet cuisine. This issue features recipes from around the globe, restaurant reviews, and tips for home cooks.',
      facts:
          '• Did you know? Foodies Guide has published over 500 recipes.\n• This issue includes a special section on vegan cuisine.\n• The cover photo was taken in Italy.',
    ),
    Magazine(
      title: 'Health Matters',
      category: 'Health',
      imageUrl:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=800&q=60',
      issue: 'Sept 2025',
      content:
          'Stay informed about the latest health trends, wellness tips, and medical breakthroughs. This issue covers nutrition, fitness, and mental health.',
      facts:
          '• Did you know? Health Matters has been a trusted source since 2008.\n• This issue features expert advice on mental health.\n• The cover photo was taken in a wellness retreat.',
    ),
  ];

  String selectedCategory = 'All';

  List<String> categories = ['All', 'Technology', 'Travel', 'Fashion', 'Food', 'Health'];

  List<Magazine> get filteredMagazines {
    if (selectedCategory == 'All') return magazines;
    return magazines.where((mag) => mag.category == selectedCategory).toList();
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void openMagazineDetail(Magazine mag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(mag.title),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      mag.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Issue: ${mag.issue}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Category: ${mag.category}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  Text(
                    mag.content,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Interesting Facts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    mag.facts,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazine Covers'),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => selectCategory(cat),
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.indigo.shade100,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.indigo.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 20,
                childAspectRatio: 0.64,
              ),
              itemCount: filteredMagazines.length,
              itemBuilder: (context, index) {
                final mag = filteredMagazines[index];
                return InkWell(
                  onTap: () => openMagazineDetail(mag),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: Offset(0, 6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            mag.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                                stops: [0.5, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mag.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  mag.issue,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 3,
                                        color: Colors.black54,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
