import 'package:flutter/material.dart';
import '../model/product.dart';
import '../service/api_service.dart';
import '../service/database_service.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';

class ProductScreen extends StatefulWidget {
  final String username;

  const ProductScreen({super.key, required this.username});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts();
  }

  void _fetchCategories() async {
    try {
      final list = await ApiService.getCategories();
      setState(() {
        _categories = list;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Product> result;
      if (_selectedCategory == 'Semua') {
        result = await ApiService.getProducts();
      } else {
        result = await ApiService.getProductsByCategory(_selectedCategory);
      }
      setState(() {
        _products = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat produk. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  void _logout() {
    DatabaseService.clearSession();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: Text('Halo, ${widget.username}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WishlistScreen(username: widget.username),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_categories.isNotEmpty)
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Semua'),
                      selected: _selectedCategory == 'Semua',
                      selectedColor: Colors.orange[200],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = 'Semua';
                          });
                          _fetchProducts();
                        }
                      },
                    ),
                  ),
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: Colors.orange[200],
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : 'Semua';
                          });
                          _fetchProducts();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          Expanded(
            child: _buildProductContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: _fetchProducts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk pada kategori ini.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        final image = product.images.isNotEmpty
            ? product.images[0]
            : product.thumbnail;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  productId: product.id,
                  username: widget.username,
                  initialProduct: product,
                ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Image.network(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
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
