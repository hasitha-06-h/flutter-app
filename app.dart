import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MagazineCoverApp());
}

class MagazineCoverApp extends StatefulWidget {
  @override
  State<MagazineCoverApp> createState() => _MagazineCoverAppState();
}

class _MagazineCoverAppState extends State<MagazineCoverApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = !isDarkMode);
    prefs.setBool('darkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine Covers',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor:
            isDarkMode ? Colors.grey[900] : Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      home: MagazineHomePage(
        toggleTheme: _toggleTheme,
        isDarkMode: isDarkMode,
      ),
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
  bool isFavorite;

  Magazine({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.issue,
    required this.content,
    required this.facts,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'imageUrl': imageUrl,
        'issue': issue,
        'content': content,
        'facts': facts,
        'isFavorite': isFavorite,
      };

  static Magazine fromJson(Map<String, dynamic> json) => Magazine(
        title: json['title'],
        category: json['category'],
        imageUrl: json['imageUrl'],
        issue: json['issue'],
        content: json['content'],
        facts: json['facts'],
        isFavorite: json['isFavorite'],
      );
}

class MagazineHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MagazineHomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _MagazineHomePageState createState() => _MagazineHomePageState();
}

class _MagazineHomePageState extends State<MagazineHomePage> {
  late List<Magazine> magazines;
  String selectedCategory = 'All';
  String searchQuery = '';
  bool showFavoritesOnly = false;

  final List<String> categories = [
    'All',
    'Technology',
    'Travel',
    'Fashion',
    'Food',
    'Health'
  ];

  @override
  void initState() {
    super.initState();
    magazines = _defaultMagazines();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getString('favorites');
    if (favData != null) {
      final favTitles = List<String>.from(jsonDecode(favData));
      setState(() {
        for (var mag in magazines) {
          mag.isFavorite = favTitles.contains(mag.title);
        }
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favTitles =
        magazines.where((m) => m.isFavorite).map((m) => m.title).toList();
    prefs.setString('favorites', jsonEncode(favTitles));
  }

  List<Magazine> get filteredMagazines {
    List<Magazine> filtered = magazines;
    if (selectedCategory != 'All') {
      filtered =
          filtered.where((mag) => mag.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((mag) =>
              mag.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (showFavoritesOnly) {
      filtered = filtered.where((m) => m.isFavorite).toList();
    }
    return filtered;
  }

  void toggleFavorite(Magazine mag) {
    setState(() {
      mag.isFavorite = !mag.isFavorite;
    });
    _saveFavorites();
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Content updated successfully!")),
    );
  }

  void openMagazineDetail(Magazine mag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MagazineDetailPage(mag: mag),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
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
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() {
              showFavoritesOnly = !showFavoritesOnly;
            }),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search magazines...',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
            // Categories
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final selected = cat == selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                    selectedColor: Colors.indigo,
                    backgroundColor: Colors.indigo.shade100,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.indigo.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            // Grid View
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: GridView.builder(
                  key: ValueKey(filteredMagazines.length),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.64,
                  ),
                  itemCount: filteredMagazines.length,
                  itemBuilder: (context, index) {
                    final mag = filteredMagazines[index];
                    return AnimatedScale(
                      scale: 1,
                      duration:
                          Duration(milliseconds: 400 + (index * 70) % 300),
                      curve: Curves.easeOutBack,
                      child: InkWell(
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
                                Hero(
                                  tag: mag.title,
                                  child: Image.network(
                                    mag.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey.shade300,
                                      child: Icon(Icons.broken_image,
                                          size: 50, color: Colors.grey),
                                    ),
                                  ),
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
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      mag.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: mag.isFavorite
                                          ? Colors.redAccent
                                          : Colors.white,
                                    ),
                                    onPressed: () => toggleFavorite(mag),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mag.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Magazine> _defaultMagazines() {
    return [
      Magazine(
        title: 'Tech Innovators',
        category: 'Technology',
        imageUrl:
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=60',
        issue: 'Nov 2025',
        content:
            'This issue explores the latest breakthroughs in AI, robotics, and quantum computing.',
        facts:
            '• Published since 2010.\n• Exclusive interviews with tech leaders.\n• Cover photo shot in 2025.',
      ),
      Magazine(
        title: 'Travel Explorer',
        category: 'Travel',
        imageUrl:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=800&q=60',
        issue: 'Winter 2025',
        content:
            'A journey through the world’s most breathtaking destinations and festivals.',
        facts:
            '• Featured over 100 countries.\n• Special eco-tourism edition.\n• Shot in the Swiss Alps.',
      ),
      Magazine(
        title: 'Fashion Forward',
        category: 'Fashion',
        imageUrl:
            'https://images.unsplash.com/photo-1488376732949-d985c0bda506?auto=format&fit=crop&w=800&q=60',
        issue: 'Fall 2025',
        content:
            'Latest trends from global runways and inspiring street fashion.',
        facts:
            '• A trendsetter since 2005.\n• Includes exclusive designer insights.\n• Paris cover photo.',
      ),
      Magazine(
        title: 'Foodies Guide',
        category: 'Food',
        imageUrl:
            'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=60',
        issue: 'Oct 2025',
        content:
            'Explore global cuisines, top chefs, and delicious recipes for every home.',
        facts:
            '• Over 500 recipes published.\n• Focus on vegan cuisine.\n• Photo from Italy.',
      ),
      Magazine(
        title: 'Health Matters',
        category: 'Health',
        imageUrl:
            'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=800&q=60',
        issue: 'Sept 2025',
        content:
            'Covers wellness, fitness, nutrition, and mental health for modern lifestyles.',
        facts:
            '• Trusted source since 2008.\n• Expert mental health advice.\n• Photo from Bali retreat.',
      ),
    ];
  }
}

class MagazineDetailPage extends StatelessWidget {
  final Magazine mag;

  const MagazineDetailPage({Key? key, required this.mag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(mag.title),
              background: Hero(
                tag: mag.title,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(mag.imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issue: ${mag.issue}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Category: ${mag.category}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 16),
                  Text(mag.content,
                      style: TextStyle(fontSize: 16, height: 1.5)),
                  SizedBox(height: 24),
                  Text('Interesting Facts',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(mag.facts, style: TextStyle(fontSize: 16, height: 1.4)),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text('Share This Magazine'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Sharing ${mag.title}...'),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

