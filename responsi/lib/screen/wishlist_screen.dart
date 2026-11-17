import 'package:flutter/material.dart';
import '../model/product.dart';
import '../service/database_service.dart';
import 'detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final String username;

  const WishlistScreen({super.key, required this.username});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistProducts = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    setState(() {
      _wishlistProducts = DatabaseService.getWishlist(widget.username);
    });
  }

  void _removeItem(int productId) {
    DatabaseService.removeWishlist(widget.username, productId);
    _loadWishlist();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil dihapus dari wishlist'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Saya'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _wishlistProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Wishlist Anda Masih Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan produk favorit Anda melalui halaman detail.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _wishlistProducts.length,
              itemBuilder: (context, index) {
                final product = _wishlistProducts[index];
                final image = product.images.isNotEmpty
                    ? product.images[0]
                    : product.thumbnail;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus dari Wishlist',
                      onPressed: () => _removeItem(product.id),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            productId: product.id,
                            username: widget.username,
                            initialProduct: product,
                          ),
                        ),
                      );
                      _loadWishlist();
                    },
                  ),
                );
              },
            ),
    );
  }
}
