import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'articles_details_page.dart';
import 'homepage.dart';
import 'education_category.dart';
import 'profile.dart';
import 'translation_page.dart';
import 'custom_navbar.dart';

class ArticlesPage extends StatefulWidget {
  final bool initialShowSaved;

  const ArticlesPage({super.key, this.initialShowSaved = false});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final CollectionReference articlesRef = FirebaseFirestore.instance.collection('Articles');
  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool sortDescending = true;
  late bool showSavedOnly;
  // ignore: prefer_final_fields
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    showSavedOnly = widget.initialShowSaved;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EducationCategoryScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TranslationScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ArticlesPage()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
        break;
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text("الأحدث أولاً"),
                onTap: () {
                  setState(() {
                    sortDescending = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text("الأقدم أولاً"),
                onTap: () {
                  setState(() {
                    sortDescending = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE7EAF6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF113F67),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(showSavedOnly ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              setState(() {
                showSavedOnly = !showSavedOnly;
              });
            },
          ),
          title: const Text("المقالات", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.trim();
                  });
                },
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "ابحث عن المقال",
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: Color(0xFF38598B)),
                    onPressed: _showSortMenu,
                  ),
                  filled: true,
                  // ignore: deprecated_member_use
                  fillColor: const Color(0xFFA2A8D3).withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: articlesRef.orderBy("ArticleDate", descending: sortDescending).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final subject = data['ArticleSubject'] ?? '';
                    final matchesSearch = subject.toString().contains(RegExp(searchText, caseSensitive: false));
                    final matchesSave = !showSavedOnly || (data['ArticleSave'] == true);
                    return matchesSearch && matchesSave;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text("لا توجد مقالات مطابقة"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final imageUrl = doc['Articleimg'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailsPage(articleData: doc),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: imageUrl != null && imageUrl.toString().isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return buildStaticArticleImage();
                                          },
                                        ),
                                      )
                                    : buildStaticArticleImage(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['ArticleSubject'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF113F67),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatArabicDate((doc['ArticleDate'] as Timestamp).toDate()),
                                      style: const TextStyle(color: Color(0xFF38598B)),
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
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildStaticArticleImage() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF38598B), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/laweh_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String formatArabicDate(DateTime date) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    final formatted = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    String arabicFormatted = formatted;
    for (int i = 0; i < western.length; i++) {
      arabicFormatted = arabicFormatted.replaceAll(western[i], eastern[i]);
    }
    return arabicFormatted;
  }
}