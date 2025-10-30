import 'package:flutter/material.dart';
import 'package:tugas4/API/api_service.dart';
import 'package:tugas4/models/meal_model.dart';

void main() {
  runApp(const ArtikelApp());
}

class ArtikelApp extends StatelessWidget {
  const ArtikelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Artikel",
      home: ArtikelScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  late Future<List<Meal>> _articlesFuture;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _articlesFuture = ApiService().fetchMeals();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTopButton) {
        setState(() => _showBackToTopButton = true);
      } else if (_scrollController.offset <= 300 && _showBackToTopButton) {
        setState(() => _showBackToTopButton = false);
      }
    });
  }

  Future<void> _refreshArticles() async {
    // Pastikan Future selesai dijalankan sebelum setState
    final newData = await ApiService().fetchMeals();
    setState(() {
      _articlesFuture = Future.value(newData);
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel Saya"), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: FutureBuilder<List<Meal>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tambahkan controller agar bisa di-pull
              return ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final articles = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          if (article.linkGambar != null &&
                              article.linkGambar!.isNotEmpty)
                            Image.network(
                              article.linkGambar!,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                );
                              },
                            )
                          else
                            const SizedBox(
                              height: 100,
                              child:
                                  Center(child: Text("Gambar tidak tersedia")),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            article.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Tidak Ada Berita Terkini')),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
