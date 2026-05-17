import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class B2BGiftsScreen extends StatefulWidget {
  const B2BGiftsScreen({super.key});

  @override
  _B2BGiftsScreenState createState() => _B2BGiftsScreenState();
}

class _B2BGiftsScreenState extends State<B2BGiftsScreen> {
  final Color darkRed = Color(0xFF8B0000);
  final Color white = Colors.white;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // متغيرات B2B
  int _minQuantity = 10; // الحد الأدنى للطلب
  Map<String, int> _bulkQuantities = {}; // الكميات المختارة

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
            : Text('طلبات الشركات - B2B', style: TextStyle(color: white)),
        backgroundColor: darkRed,
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
        actions: [
          // زر البحث
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

          // زر تعديل الحد الأدنى
          IconButton(
            icon: Icon(Icons.numbers),
            onPressed: _showMinQuantityDialog,
          ),

          // زر السلة (مع عداد الكميات)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _navigateToBulkCart,
              ),
              if (_bulkQuantities.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '${_bulkQuantities.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner B2B
          _buildB2BBanner(),
          Expanded(child: _buildB2BProductsList()),
        ],
      ),
    );
  }

  // ✅ Banner علوي خاص بــ B2B
  Widget _buildB2BBanner() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkRed, darkRed.withOpacity(0.7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛒 طلبات الشركات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'الحد الأدنى للطلب: $_minQuantity قطعة',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.business_center, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  // ✅ حقل البحث
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ابحث عن هدايا للشركات...',
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

  // ✅ مربع حوار تعديل الحد الأدنى
  Future<void> _showMinQuantityDialog() async {
    int? result = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempQuantity = _minQuantity;
        return AlertDialog(
          title: Text('الحد الأدنى للطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('حدد الحد الأدنى لعدد القطع'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: darkRed),
                    onPressed: () {
                      if (tempQuantity > 5) {
                        tempQuantity -= 5;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkRed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$tempQuantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: darkRed),
                    onPressed: () {
                      tempQuantity += 5;
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempQuantity),
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _minQuantity = result;
      });
    }
  }

  // ✅ قائمة منتجات B2B
  Widget _buildB2BProductsList() {
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
                // اسم المتجر مع معلومات المتجر
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${storeProducts.length} منتج',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // شبكة المنتجات
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: storeProducts.length,
                  itemBuilder: (context, index) {
                    var product = storeProducts[index];
                    var data = product.data() as Map<String, dynamic>;
                    String productId = product.id;

                    // الكمية المختارة لهذا المنتج
                    int selectedQuantity = _bulkQuantities[productId] ?? 0;

                    return B2BProductCard(
                      productId: productId,
                      productName: data['name'] ?? 'بدون اسم',
                      productPrice:
                          double.tryParse(data['price'].toString()) ?? 0,
                      storeName: data['storeName'] ?? 'متجر الهدايا',
                      storeNumber: data['storeNumber'] ?? '',
                      description: data['description'] ?? 'لا يوجد وصف',
                      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
                      imageUrl: data['imageUrl'],
                      darkRed: darkRed,
                      white: white,
                      minQuantity: _minQuantity,
                      selectedQuantity: selectedQuantity,
                      onQuantityChanged: (newQuantity) {
                        setState(() {
                          if (newQuantity > 0) {
                            _bulkQuantities[productId] = newQuantity;
                          } else {
                            _bulkQuantities.remove(productId);
                          }
                        });
                      },
                      onViewDetails: () =>
                          _showB2BProductDetails(context, data, product.id),
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

  // ✅ عرض تفاصيل المنتج لـ B2B
  void _showB2BProductDetails(
    BuildContext context,
    Map<String, dynamic> product,
    String productId,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final createdAt = product['createdAt']?.toDate() ?? DateTime.now();
    double price = double.tryParse(product['price'].toString()) ?? 0;

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

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('السعر:'),
                        Text(
                          '$price ريال',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkRed,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الحد الأدنى للطلب: $_minQuantity قطعة',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBulkQuantitySelector(context, product, productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkRed),
            child: Text('طلب الكمية'),
          ),
        ],
      ),
    );
  }

  // ✅ منتقي الكمية للشركات
  void _showBulkQuantitySelector(
    BuildContext context,
    Map<String, dynamic> product,
    String productId,
  ) {
    int quantity = _bulkQuantities[productId] ?? _minQuantity;
    double price = double.tryParse(product['price'].toString()) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تحديد الكمية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkRed,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (product['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: product['imageUrl']!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    product['name'] ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // اختيار الكمية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: darkRed,
                          size: 30,
                        ),
                        onPressed: () {
                          if (quantity > _minQuantity) {
                            setSheetState(() => quantity -= 5);
                          }
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: darkRed),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: darkRed, size: 30),
                        onPressed: () {
                          setSheetState(() => quantity += 5);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // تفاصيل السعر
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('السعر للقطعة:'),
                            Text(
                              '$price ريال',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإجمالي:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(price * quantity).toStringAsFixed(2)} ريال',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // الأزرار
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('إلغاء'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _bulkQuantities[productId] = quantity;
                            });
                            Navigator.pop(context);
                            _showToast('تمت إضافة المنتج');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkRed,
                          ),
                          child: Text('إضافة للطلبات'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ سلة B2B
  void _navigateToBulkCart() {
    if (_bulkQuantities.isEmpty) {
      _showToast('لم يتم اختيار أي منتجات بعد');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BulkCartScreen(
          bulkQuantities: _bulkQuantities,
          minQuantity: _minQuantity,
          darkRed: darkRed,
        ),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          _bulkQuantities.clear();
        });
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkRed,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ✅ كارت منتج B2B
class B2BProductCard extends StatelessWidget {
  final String productId;
  final String productName;
  final double productPrice;
  final String storeName;
  final String storeNumber;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;
  final Color darkRed;
  final Color white;
  final int minQuantity;
  final int selectedQuantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onViewDetails;

  const B2BProductCard({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.storeName,
    required this.storeNumber,
    required this.description,
    required this.createdAt,
    this.imageUrl,
    required this.darkRed,
    required this.white,
    required this.minQuantity,
    required this.selectedQuantity,
    required this.onQuantityChanged,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selectedQuantity > 0
            ? BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onViewDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة المنتج
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.card_giftcard,
                                  color: darkRed,
                                  size: 40,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.broken_image, color: darkRed),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.card_giftcard, color: darkRed),
                            ),
                          ),
                  ),
                  // شعار B2B
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'B2B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // مؤشر الكمية المختارة
                  if (selectedQuantity > 0)
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$selectedQuantity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // معلومات المنتج
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    storeName,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // عرض السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('السعر:', style: TextStyle(fontSize: 10)),
                      Text(
                        '$productPrice ريال',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'الحد الأدنى: $minQuantity قطعة',
                    style: TextStyle(fontSize: 9, color: Colors.grey),
                  ),

                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // زر إنقاص
                      if (selectedQuantity > 0)
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: darkRed,
                            size: 20,
                          ),
                          onPressed: () {
                            int newQuantity = selectedQuantity - minQuantity;
                            onQuantityChanged(
                              newQuantity > 0 ? newQuantity : 0,
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      SizedBox(width: 8),
                      // زر إضافة
                      IconButton(
                        icon: Icon(
                          selectedQuantity > 0 ? Icons.edit : Icons.add_circle,
                          color: darkRed,
                          size: 20,
                        ),
                        onPressed: () {
                          int newQuantity = selectedQuantity + minQuantity;
                          onQuantityChanged(newQuantity);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
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

// ✅ شاشة سلة B2B مع إدخال رقم العميل
class BulkCartScreen extends StatefulWidget {
  final Map<String, int> bulkQuantities;
  final int minQuantity;
  final Color darkRed;

  const BulkCartScreen({
    required this.bulkQuantities,
    required this.minQuantity,
    required this.darkRed,
    super.key,
  });

  @override
  _BulkCartScreenState createState() => _BulkCartScreenState();
}

class _BulkCartScreenState extends State<BulkCartScreen> {
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الشركات', style: TextStyle(color: Colors.white)),
        backgroundColor: widget.darkRed,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where(
              FieldPath.documentId,
              whereIn: widget.bulkQuantities.keys.toList(),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: widget.darkRed),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('لا توجد منتجات في الطلب'));
          }

          double totalPrice = 0;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // نموذج معلومات العميل
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات العميل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.darkRed,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          labelText: 'اسم العميل',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person, color: widget.darkRed),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم العميل';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.phone, color: widget.darkRed),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          if (value.length < 10) {
                            return 'رقم الهاتف غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      int quantity = widget.bulkQuantities[doc.id] ?? 0;
                      double price =
                          double.tryParse(data['price'].toString()) ?? 0;
                      totalPrice += price * quantity;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: data['imageUrl'] != null
                              ? CachedNetworkImage(
                                  imageUrl: data['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.card_giftcard,
                                    color: widget.darkRed,
                                  ),
                                ),
                          title: Text(data['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الكمية: $quantity قطعة'),
                              Text('السعر: $price ريال للقطعة'),
                              Text('المتجر: ${data['storeName'] ?? ''}'),
                            ],
                          ),
                          trailing: Text(
                            '${(price * quantity).toStringAsFixed(2)} ريال',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.darkRed,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ملخص الطلب
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي الطلب:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} ريال',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.darkRed,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _submitBulkOrder(context, snapshot.data!.docs);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.darkRed,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'إرسال طلب الشركة',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitBulkOrder(
    BuildContext context,
    List<DocumentSnapshot> products,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
        return;
      }

      // تجميع المنتجات حسب المتجر
      Map<String, List<Map<String, dynamic>>> productsByStore = {};

      for (var doc in products) {
        var data = doc.data() as Map<String, dynamic>;
        String storeName = data['storeName'] ?? 'متجر غير معروف';
        String storeNumber = data['storeNumber'] ?? '';

        double price = double.tryParse(data['price'].toString()) ?? 0;
        int quantity = widget.bulkQuantities[doc.id] ?? 0;

        if (quantity > 0) {
          if (!productsByStore.containsKey(storeName)) {
            productsByStore[storeName] = [];
          }
          productsByStore[storeName]!.add({
            'productId': doc.id,
            'name': data['name'],
            'price': price,
            'quantity': quantity,
            'imageUrl': data['imageUrl'],
            'storeNumber': storeNumber,
          });
        }
      }

      // إنشاء طلب منفصل لكل متجر
      List<String> createdOrderIds = [];

      for (var entry in productsByStore.entries) {
        String storeName = entry.key;
        List<Map<String, dynamic>> storeItems = entry.value;

        // حساب إجمالي هذا المتجر
        double storeTotal = 0;
        for (var item in storeItems) {
          storeTotal += (item['price'] * item['quantity']);
        }

        // إنشاء طلب في مجموعة orders
        DocumentReference orderRef = await FirebaseFirestore.instance
            .collection('orders')
            .add({
              'userId': user.uid,
              'customerName': _customerNameController.text.trim(),
              'customerPhone': _customerPhoneController.text.trim(),
              'storeName': storeName,
              'storeNumber': storeItems.first['storeNumber'],
              'totalPrice': storeTotal,
              'status': 'جديد',
              'orderType': 'B2B',
              'createdAt': FieldValue.serverTimestamp(),
              'items': storeItems
                  .map(
                    (item) => {
                      'productId': item['productId'],
                      'name': item['name'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                      'imageUrl': item['imageUrl'],
                    },
                  )
                  .toList(),
              'minQuantity': widget.minQuantity,
            });

        createdOrderIds.add(orderRef.id);
      }

      // تتبع الحدث

      // عرض رسالة نجاح والعودة
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('✅ تم إرسال الطلبات'),
          content: Text(
            'تم إنشاء ${createdOrderIds.length} طلب للمتاجر المختلفة\n'
            'سيتم التواصل معكم قريباً لتأكيد الطلبات',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: Text('موافق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }
}
