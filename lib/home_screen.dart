import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GiftShopHomeScreen extends StatefulWidget {
  @override
  _GiftShopHomeScreenState createState() => _GiftShopHomeScreenState();
}

class _GiftShopHomeScreenState extends State<GiftShopHomeScreen> {
  final Color darkRed = Color(0xFF8B0000);
  final Color white = Colors.white;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text('متجر الهدايا', style: TextStyle(color: white)),
        backgroundColor: darkRed,
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ],
      ),
      body: _buildProductsList(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ابحث عن هدايا...',
        hintStyle: TextStyle(color: white.withOpacity(0.7)),
        border: InputBorder.none,
        suffixIcon: Icon(Icons.search, color: white),
      ),
      style: TextStyle(color: white),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('products')
          .orderBy('storeName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ في جلب البيانات'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: darkRed));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('لا توجد منتجات متاحة حالياً'));
        }

        // تصفية المنتجات حسب نص البحث
        final filteredProducts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          final storeName = data['storeName']?.toString().toLowerCase() ?? '';
          final description =
              data['description']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery) ||
              storeName.contains(_searchQuery) ||
              description.contains(_searchQuery);
        }).toList();

        if (filteredProducts.isEmpty) {
          return Center(child: Text('لا توجد نتائج مطابقة للبحث'));
        }

        // تجميع المنتجات حسب المتجر
        Map<String, List<DocumentSnapshot>> productsByStore = {};
        for (var product in filteredProducts) {
          final storeName =
              (product.data() as Map<String, dynamic>)['storeName'] ??
              'متجر غير معروف';
          if (!productsByStore.containsKey(storeName)) {
            productsByStore[storeName] = [];
          }
          productsByStore[storeName]!.add(product);
        }

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: productsByStore.length,
          itemBuilder: (context, index) {
            final storeName = productsByStore.keys.elementAt(index);
            final storeProducts = productsByStore[storeName]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkRed,
                    ),
                  ),
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: storeProducts.length,
                  itemBuilder: (context, index) {
                    var product = storeProducts[index];
                    var data = product.data() as Map<String, dynamic>;

                    return ProductCard(
                      productId: product.id,
                      productName: data['name'] ?? 'بدون اسم',
                      productPrice: data['price']?.toString() ?? '0',
                      storeName: data['storeName'] ?? 'متجر الهدايا',
                      description: data['description'] ?? 'لا يوجد وصف',
                      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
                      imageUrl: data['imageUrl'],
                      darkRed: darkRed,
                      white: white,
                      onAddToCart: () => _addToCart(data, product.id),
                      onViewDetails: () => _showProductDetails(context, data),
                    );
                  },
                ),
                Divider(height: 20, thickness: 1, color: Colors.grey[300]),
              ],
            );
          },
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final createdAt = product['createdAt']?.toDate() ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name'] ?? 'تفاصيل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product['imageUrl'] != null)
                CachedNetworkImage(
                  imageUrl: product['imageUrl'],
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.card_giftcard, color: darkRed, size: 50),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: darkRed, size: 50),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                'السعر: ${product['price']?.toString() ?? '0'}ريال',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'المتجر: ${product['storeName'] ?? 'غير معروف'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'رقم المتجر: ${product['storeNumber'] ?? 'غير متوفر'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'تاريخ الإضافة: ${dateFormat.format(createdAt)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('الوصف:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(product['description'] ?? 'لا يوجد وصف'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: TextStyle(color: darkRed)),
          ),
          TextButton(
            onPressed: () {
              _addToCart(product, '');
              Navigator.pop(context);
            },
            child: Text('إضافة إلى السلة', style: TextStyle(color: darkRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(
    Map<String, dynamic> product,
    String productId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
        return;
      }

      final querySnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: user.uid)
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'quantity': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('cart').add({
          'userId': user.uid,
          'productId': productId,
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة ${product['name']} إلى السلة'),
          backgroundColor: darkRed,
        ),
      );
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الإضافة إلى السلة: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final String productName;
  final String productPrice;
  final String storeName;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;
  final Color darkRed;
  final Color white;
  final VoidCallback onAddToCart;
  final VoidCallback onViewDetails;

  const ProductCard({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.storeName,
    required this.description,
    required this.createdAt,
    this.imageUrl,
    required this.darkRed,
    required this.white,
    required this.onAddToCart,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onViewDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.card_giftcard,
                            color: darkRed,
                            size: 50,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            color: darkRed,
                            size: 50,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.card_giftcard,
                          color: darkRed,
                          size: 50,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    storeName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$productPriceريال',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkRed,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: darkRed,
                              size: 18,
                            ),
                            onPressed: onViewDetails,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: darkRed,
                              size: 18,
                            ),
                            onPressed: onAddToCart,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
