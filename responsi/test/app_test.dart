import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/model/product.dart';
import 'package:responsi/service/database_service.dart';

void main() {
  group('Model & Security Tests', () {
    test('Password Hashing dengan SHA-256', () {
      final hash1 = DatabaseService.hashPassword('password123');
      final hash2 = DatabaseService.hashPassword('password123');
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64));
    });

    test('Product.fromJson parsing schema dummyjson', () {
      final json = {
        'id': 1,
        'title': 'Essence Mascara',
        'description': 'Mascara lash princess',
        'category': 'beauty',
        'price': 9.99,
        'discountPercentage': 7.17,
        'rating': 4.94,
        'stock': 5,
        'brand': 'Essence',
        'thumbnail': 'https://example.com/thumb.png',
        'images': ['https://example.com/1.png'],
        'tags': ['beauty']
      };

      final p = Product.fromJson(json);
      expect(p.id, equals(1));
      expect(p.title, equals('Essence Mascara'));
      expect(p.price, equals(9.99));
    });
  });
}
