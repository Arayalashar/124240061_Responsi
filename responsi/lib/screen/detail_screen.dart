import 'package:flutter/material.dart';
import '../model/product.dart';
import '../service/api_service.dart';
import '../service/database_service.dart';

class DetailScreen extends StatefulWidget {
  final int productId;
  final String username;
  final Product? initialProduct;

  const DetailScreen({
    super.key,
    required this.productId,
    required this.username,
    this.initialProduct,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isWishlist = false;

  @override
  void initState() {
    super.initState();
    _isWishlist = DatabaseService.isWishlist(widget.username, widget.productId);

    if (widget.initialProduct != null) {
      _product = widget.initialProduct;
      _isLoading = false;
    }
    _fetchDetail();
  }

  void _fetchDetail() async {
    try {
      final data = await ApiService.getSingleProduct(widget.productId);
      if (mounted) {
        setState(() {
          _product = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _product == null) {
        setState(() {
          _errorMessage = 'Gagal memuat detail produk.';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleWishlist() {
    if (_product == null) return;

    setState(() {
      if (_isWishlist) {
        DatabaseService.removeWishlist(widget.username, _product!.id);
        _isWishlist = false;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil dihapus dari wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        DatabaseService.addWishlist(widget.username, _product!);
        _isWishlist = true;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil ditambahkan ke wishlist'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_product != null)
            IconButton(
              icon: Icon(
                _isWishlist ? Icons.favorite : Icons.favorite_border,
                color: _isWishlist ? Colors.red : Colors.white,
              ),
              onPressed: _toggleWishlist,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_errorMessage.isNotEmpty && _product == null) {
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
              onPressed: _fetchDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final p = _product!;
    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: images.length > 1
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Image.network(
                      images[0],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(p.category),
                backgroundColor: Colors.orange[50],
              ),
              const SizedBox(width: 8),
              Text(
                'Brand: ${p.brand}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  if (p.discountPercentage > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        'Diskon ${p.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(
                    ' ${p.rating}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Informasi Stok: ${p.stock} unit tersedia',
            style: TextStyle(
              color: p.stock > 0 ? Colors.black87 : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 24),
          const Text(
            'Deskripsi:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.description,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isWishlist ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _toggleWishlist,
              icon: Icon(_isWishlist ? Icons.favorite : Icons.favorite_border),
              label: Text(
                _isWishlist
                    ? 'Hapus dari Wishlist'
                    : 'Tambahkan ke Wishlist',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
