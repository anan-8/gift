import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
<<<<<<< HEAD
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _totalPrice = 0;
  bool _isProcessingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('سلة التسوق', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF8B0000),
          iconTheme: IconThemeData(color: Colors.white),
<<<<<<< HEAD
          centerTitle: true,
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('cart')
                .where('userId', isEqualTo: _auth.currentUser?.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
<<<<<<< HEAD
                return _buildErrorWidget('حدث خطأ في تحميل السلة');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget('جاري تحميل محتويات السلة...');
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return _buildEmptyCartWidget();
=======
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل السلة',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('جاري تحميل محتويات السلة...'),
                    ],
                  ),
                );
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
              }

              _totalPrice = 0;
              snapshot.data?.docs.forEach((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final price = num.tryParse(data['price'].toString()) ?? 0;
<<<<<<< HEAD
                final int quantity =
                    (num.tryParse(data['quantity'].toString()) ?? 1).toInt();
=======
                final quantity = num.tryParse(data['quantity'].toString()) ?? 1;
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                _totalPrice += price * quantity;
              });

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data?.docs[index];
                        final data = doc?.data() as Map<String, dynamic>;
                        return _buildCartItem(doc!.id, data);
                      },
                    ),
                  ),
                  _buildTotalCard(_totalPrice),
                  _buildCheckoutButton(context, snapshot.data!.docs),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B0000),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.threeRotatingDots(
            color: Color(0xFF8B0000),
            size: 50,
          ),
          SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyCartWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'سلة التسوق فارغة',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'أضف منتجات إلى السلة للمتابعة',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCartItem(String docId, Map<String, dynamic> data) {
    final price = num.tryParse(data['price'].toString()) ?? 0;
    final int quantity = (num.tryParse(data['quantity'].toString()) ?? 1)
        .toInt();
    final totalItemPrice = price * quantity;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
=======
  Widget _buildCartItem(String docId, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
<<<<<<< HEAD
            // صورة المنتج
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    data['imageUrl'] != null &&
                        data['imageUrl'].toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: data['imageUrl'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: LoadingAnimationWidget.threeRotatingDots(
                              color: Color(0xFF8B0000),
                              size: 30,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.shopping_bag,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            SizedBox(width: 16),

            // تفاصيل المنتج
=======
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  data['imageUrl'] != null &&
                      data['imageUrl'].toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            SizedBox(width: 16),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'بدون اسم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
<<<<<<< HEAD
                      color: Colors.black87,
=======
                      color: Color(0xFF8B0000),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
<<<<<<< HEAD
                  SizedBox(height: 6),
                  Text(
                    '${price.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B0000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'الإجمالي: ',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        '${totalItemPrice.toStringAsFixed(2)} ريال',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // عداد الكمية
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 18),
                          onPressed: () => _updateQuantity(docId, quantity - 1),
                          color: Colors.grey[700],
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                        ),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '$quantity',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 18),
                          onPressed: () => _updateQuantity(docId, quantity + 1),
                          color: Color(0xFF8B0000),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
=======
                  SizedBox(height: 8),
                  Text(
                    '${data['price']?.toString() ?? '0'} ريال',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8B0000)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 20),
                        onPressed: () =>
                            _updateQuantity(docId, data['quantity'] - 1),
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text('${data['quantity'] ?? 1}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () =>
                            _updateQuantity(docId, data['quantity'] + 1),
                      ),
                    ],
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                  ),
                ],
              ),
            ),
<<<<<<< HEAD

            // زر الحذف
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(docId),
=======
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFromCart(docId),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total) {
<<<<<<< HEAD
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المجموع الكلي',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                '${_totalPrice.toStringAsFixed(2)} ريال',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B0000),
                ),
              ),
            ],
          ),
          Icon(
            Icons.shopping_cart_checkout,
            color: Color(0xFF8B0000),
            size: 30,
          ),
        ],
=======
    return Card(
      margin: EdgeInsets.all(16),
      color: Color(0xFF8B0000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المجموع الكلي:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${total.toStringAsFixed(2)} ريال',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      ),
    );
  }

  Widget _buildCheckoutButton(
    BuildContext context,
    List<QueryDocumentSnapshot> cartItems,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
<<<<<<< HEAD
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B0000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          onPressed: _isProcessingOrder
              ? null
              : () => _navigateToCheckout(context, cartItems),
          child: _isProcessingOrder
              ? LoadingAnimationWidget.threeRotatingDots(
                  color: Colors.white,
                  size: 30,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'تأكيد الطلب والمتابعة للدفع',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
=======
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8B0000),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isProcessingOrder
              ? null
              : () => _confirmOrder(context, cartItems),
          child: _isProcessingOrder
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  'تأكيد الطلب والمتابعة للدفع',
                  style: TextStyle(fontSize: 18, color: Colors.white),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
                ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف هذا المنتج من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromCart(docId);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // ✅ دالة جديدة للتنقل فقط - بدون إنشاء طلب
  Future<void> _navigateToCheckout(
=======
  Future<void> _confirmOrder(
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    BuildContext context,
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
<<<<<<< HEAD
      _showToast('يجب تسجيل الدخول أولاً');
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      return;
    }

    if (cartItems.isEmpty) {
<<<<<<< HEAD
      _showToast('السلة فارغة');
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('السلة فارغة')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      return;
    }

    setState(() => _isProcessingOrder = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw 'لا يوجد اتصال بالإنترنت';
      }

<<<<<<< HEAD
      // تجهيز بيانات الطلب مؤقتاً (بدون حفظ في Firestore)
      final orderData = {
        'userId': user.uid,
        'totalPrice': _totalPrice,
=======
      final orderData = {
        'userId': user.uid,
        'totalPrice': _totalPrice,
        'status': 'جديدة',
        'createdAt': FieldValue.serverTimestamp(),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
        'items': cartItems.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'productId': data['productId'],
            'name': data['name'],
            'price': data['price'],
            'quantity': data['quantity'],
            'imageUrl': data['imageUrl'],
          };
        }).toList(),
      };

<<<<<<< HEAD
      // ✅ التنقل فقط إلى CheckoutScreen - بدون إنشاء طلب في Firestore
=======
      final orderRef = await _firestore.collection('orders').add(orderData);

      final batch = _firestore.batch();
      for (var item in cartItems) {
        batch.delete(item.reference);
      }
      await batch.commit();

>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
<<<<<<< HEAD
            cartItems: cartItems, // تمرير عناصر السلة
=======
            orderId: orderRef.id,
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
            totalAmount: _totalPrice,
            orderData: orderData,
          ),
        ),
      );
    } catch (e) {
<<<<<<< HEAD
      _showToast('حدث خطأ: ${e.toString()}');
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    } finally {
      if (mounted) {
        setState(() => _isProcessingOrder = false);
      }
    }
  }

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeFromCart(docId);
      return;
    }

    try {
      await _firestore.collection('cart').doc(docId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
<<<<<<< HEAD
      _showToast('حدث خطأ أثناء تحديث الكمية');
=======
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحديث الكمية')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    }
  }

  Future<void> _removeFromCart(String docId) async {
    try {
      await _firestore.collection('cart').doc(docId).delete();
<<<<<<< HEAD
      _showToast('تم حذف المنتج من السلة');
    } catch (e) {
      _showToast('حدث خطأ أثناء الحذف من السلة');
=======
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف من السلة')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    }
  }
}

class CheckoutScreen extends StatefulWidget {
<<<<<<< HEAD
  final List<QueryDocumentSnapshot> cartItems; // أضف هذا
=======
  final String orderId;
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
  final double totalAmount;
  final Map<String, dynamic> orderData;

  const CheckoutScreen({
    Key? key,
<<<<<<< HEAD
    required this.cartItems, // أضف هذا
=======
    required this.orderId,
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
    required this.totalAmount,
    required this.orderData,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isGettingLocation = false;
  Position? _currentPosition;
  String _currentAddress = "";
  bool _isSubmitting = false;
<<<<<<< HEAD
  String? _selectedPaymentMethod;

  // إضافة متغيرات لاختيار الدولة
  String _selectedCountry = 'SA'; // القيمة الافتراضية: السعودية
  Map<String, String> countryCodes = {
    'SA': '+966', // السعودية
    'JO': '+962', // الأردن
    'AE': '+971', // الإمارات
    'BH': '+973', // البحرين
    'QA': '+974', // قطر
    'KW': '+965', // الكويت
    'OM': '+968', // عمان
  };

  Map<String, String> countryNames = {
    'SA': 'السعودية',
    'JO': 'الأردن',
    'AE': 'الإمارات العربية المتحدة',
    'BH': 'البحرين',
    'QA': 'قطر',
    'KW': 'الكويت',
    'OM': 'عمان',
  };

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[800] : Color(0xFF8B0000),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
      ),
    );
  }

  // بيانات Telr
  final String _telrStoreId = '34354';
  final String _telrAuthKey = 'GRD4L-Z3cF~xW5jm';
  final bool _isTestMode = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName!;
    }
    if (user != null && user.phoneNumber != null) {
      _phoneController.text = user.phoneNumber!;
    }
  }
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'خدمة الموقع غير مفعلة. يرجى تفعيلها';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'تم رفض إذن الوصول إلى الموقع';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'تم رفض إذن الوصول إلى الموقع بشكل دائم';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

<<<<<<< HEAD
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatAddress(place);

        if (mounted) {
          setState(() {
            _currentPosition = position;
            _currentAddress = address;
            _locationController.text = address;
            _isGettingLocation = false;
          });

          // اكتشاف البلد من الإحداثيات
          await _detectCountryFromCoordinates(place);

          _showToast('تم تحديد موقعك بنجاح');
        }
=======
      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _locationController.text = address;
          _isGettingLocation = false;
        });
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGettingLocation = false);
<<<<<<< HEAD
        _showToast('خطأ في الموقع: $e');
=======
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الموقع: $e')));
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      }
    }
  }

<<<<<<< HEAD
  // دالة لاكتشاف البلد من الإحداثيات
  Future<void> _detectCountryFromCoordinates(Placemark place) async {
    try {
      final country = place.country;
      if (country == 'Saudi Arabia' || country == 'السعودية') {
        setState(() => _selectedCountry = 'SA');
      } else if (country == 'Jordan' || country == 'الأردن') {
        setState(() => _selectedCountry = 'JO');
      } else if (country == 'United Arab Emirates' ||
          country == 'الإمارات العربية المتحدة') {
        setState(() => _selectedCountry = 'AE');
      } else if (country == 'Bahrain' || country == 'البحرين') {
        setState(() => _selectedCountry = 'BH');
      } else if (country == 'Qatar' || country == 'قطر') {
        setState(() => _selectedCountry = 'QA');
      } else if (country == 'Kuwait' || country == 'الكويت') {
        setState(() => _selectedCountry = 'KW');
      } else if (country == 'Oman' || country == 'عمان') {
        setState(() => _selectedCountry = 'OM');
      }
    } catch (e) {
      print('Error detecting country: $e');
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street?.isNotEmpty ?? false) addressParts.add(place.street!);
    if (place.subLocality?.isNotEmpty ?? false)
      addressParts.add(place.subLocality!);
    if (place.locality?.isNotEmpty ?? false) addressParts.add(place.locality!);
    if (place.administrativeArea?.isNotEmpty ?? false)
      addressParts.add(place.administrativeArea!);

    if (addressParts.isEmpty && (place.country?.isNotEmpty ?? false)) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  // دالة للحصول على التلميح المناسب لرقم الهاتف
  String _getPhoneHint() {
    switch (_selectedCountry) {
      case 'SA':
        return '5xxxxxxxx'; // السعودية
      case 'JO':
        return '7xxxxxxxx'; // الأردن
      case 'AE':
        return '5xxxxxxxx'; // الإمارات
      case 'BH':
        return '3xxxxxxxx'; // البحرين
      case 'QA':
        return '3xxxxxxxx'; // قطر
      case 'KW':
        return '5xxxxxxxx'; // الكويت
      case 'OM':
        return '9xxxxxxxx'; // عمان
      default:
        return 'أدخل رقم الهاتف';
    }
  }

  // دالة للتحقق من صحة رقم الهاتف حسب البلد
  String? _validatePhoneNumber(String digits, String countryCode) {
    if (digits.isEmpty) return 'الرجاء إدخال رقم الهاتف';

    switch (countryCode) {
      case 'SA': // السعودية
        if (digits.length != 9 || !digits.startsWith('5')) {
          return 'رقم الهاتف السعودي يجب أن يبدأ بـ 5 ويتكون من 9 أرقام';
        }
        break;

      case 'JO': // الأردن
        if (digits.length != 9 ||
            !(digits.startsWith('7') || digits.startsWith('9'))) {
          return 'رقم الهاتف الأردني يجب أن يبدأ بـ 7 أو 9 ويتكون من 9 أرقام';
        }
        break;

      case 'AE': // الإمارات
        if (digits.length != 9 || !digits.startsWith('5')) {
          return 'رقم الهاتف الإماراتي يجب أن يبدأ بـ 5 ويتكون من 9 أرقام';
        }
        break;

      case 'BH': // البحرين
        if (digits.length != 8 || !digits.startsWith('3')) {
          return 'رقم الهاتف البحريني يجب أن يبدأ بـ 3 ويتكون من 8 أرقام';
        }
        break;

      case 'QA': // قطر
        if (digits.length != 8 || !digits.startsWith('3')) {
          return 'رقم الهاتف القطري يجب أن يبدأ بـ 3 ويتكون من 8 أرقام';
        }
        break;

      case 'KW': // الكويت
        if (digits.length != 8 || !digits.startsWith('5')) {
          return 'رقم الهاتف الكويتي يجب أن يبدأ بـ 5 ويتكون من 8 أرقام';
        }
        break;

      case 'OM': // عمان
        if (digits.length != 8 || !digits.startsWith('9')) {
          return 'رقم الهاتف العماني يجب أن يبدأ بـ 9 ويتكون من 8 أرقام';
        }
        break;
    }

    return null;
  }

  // دالة للتحقق من تطابق العنوان مع البلد
  bool _isAddressMatchingCountry(String address, String countryCode) {
    final lowerAddress = address.toLowerCase();

    switch (countryCode) {
      case 'JO':
        return lowerAddress.contains('الأردن') ||
            lowerAddress.contains('jordan') ||
            lowerAddress.contains('عمان');
      case 'SA':
        return lowerAddress.contains('السعودية') ||
            lowerAddress.contains('saudi') ||
            lowerAddress.contains('الرياض') ||
            lowerAddress.contains('جدة') ||
            lowerAddress.contains('الدمام');
      case 'AE':
        return lowerAddress.contains('الإمارات') ||
            lowerAddress.contains('emirates') ||
            lowerAddress.contains('دبي') ||
            lowerAddress.contains('أبوظبي');
      case 'BH':
        return lowerAddress.contains('البحرين') ||
            lowerAddress.contains('bahrain');
      case 'QA':
        return lowerAddress.contains('قطر') ||
            lowerAddress.contains('qatar') ||
            lowerAddress.contains('الدوحة');
      case 'KW':
        return lowerAddress.contains('الكويت') ||
            lowerAddress.contains('kuwait');
      case 'OM':
        return lowerAddress.contains('عمان') ||
            lowerAddress.contains('oman') ||
            lowerAddress.contains('مسقط');
      default:
        return true;
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إتمام الدفع', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF8B0000),
          iconTheme: IconThemeData(color: Colors.white),
<<<<<<< HEAD
          centerTitle: true,
=======
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                // ملخص الطلب
                _buildOrderSummary(),
                SizedBox(height: 24),

                // معلومات العميل
                _buildCustomerInfo(),
                SizedBox(height: 24),

                // طرق الدفع
                _buildPaymentMethods(),
                SizedBox(height: 32),

                // زر التأكيد
                _buildConfirmButton(),
=======
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الطلب: ${widget.orderId}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'المبلغ الإجمالي: ${widget.totalAmount.toStringAsFixed(2)} ريال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  'معلومات العميل:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (value.length < 10) {
                      return 'يجب أن يحتوي رقم الهاتف على 10 أرقام على الأقل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'العنوان / الموقع',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: _isGettingLocation
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال العنوان';
                    }
                    return null;
                  },
                ),
                if (_currentPosition != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'الإحداثيات: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
                SizedBox(height: 32),

                Text(
                  'اختر طريقة الدفع:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildPaymentMethod(
                  context,
                  'الدفع عند الاستلام',
                  Icons.money,
                  () => _completeOrder(context, 'الدفع عند الاستلام'),
                ),
                _buildPaymentMethod(
                  context,
                  'بطاقة ائتمان',
                  Icons.credit_card,
                  () => _completeOrder(context, 'بطاقة ائتمان'),
                ),
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
              ],
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildOrderSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B0000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'طلب جديد',
                    style: TextStyle(
                      color: Color(0xFF8B0000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ الإجمالي',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  '${widget.totalAmount.toStringAsFixed(2)} ريال',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'عدد المنتجات: ${widget.orderData['items']?.length ?? 0}',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
=======
  Widget _buildPaymentMethod(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    if (title == 'بطاقة ائتمان') return SizedBox(); // إخفاء خيار بطاقة ائتمان
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF8B0000)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (_formKey.currentState!.validate()) {
            onPressed();
          }
        },
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: Color(0xFF8B0000)),
            SizedBox(width: 8),
            Text(
              'معلومات العميل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),

        // حقل الاسم الكامل
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'الاسم الكامل',
            hintText: 'أدخل اسمك الكامل',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.person),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الاسم';
            }
            if (value.length < 3) {
              return 'الاسم يجب أن يكون 3 أحرف على الأقل';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // اختيار البلد
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[400]!),
            color: Colors.grey[50],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'البلد',
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              items: countryCodes.keys.map((String code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(
                        '${countryNames[code]} (${countryCodes[code]})',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء اختيار البلد';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFF8B0000)),
              isExpanded: true,
            ),
          ),
        ),
        SizedBox(height: 16),

        // تلميح التأكد من تطابق البلد
        if (_selectedCountry.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF8B0000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF8B0000).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF8B0000), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تأكد من تطابق البلد مع العنوان لضمان وصول الطلب',
                    style: TextStyle(color: Color(0xFF8B0000), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // حقل رقم الهاتف
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: _getPhoneHint(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.phone),
            prefixText: '${countryCodes[_selectedCountry]} ',
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم الهاتف';
            }
            String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            return _validatePhoneNumber(digits, _selectedCountry);
          },
        ),
        SizedBox(height: 16),

        // حقل العنوان
        TextFormField(
          controller: _locationController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'العنوان التفصيلي',
            hintText: 'الشارع، الحي، المدينة',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.location_on),
            suffixIcon: IconButton(
              icon: _isGettingLocation
                  ? LoadingAnimationWidget.threeRotatingDots(
                      color: Color(0xFF8B0000),
                      size: 20,
                    )
                  : Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال العنوان';
            }
            if (value.length < 10) {
              return 'الرجاء إدخال عنوان مفصل';
            }
            return null;
          },
        ),
        if (_currentPosition != null) ...[
          SizedBox(height: 8),
          Text(
            'الإحداثيات: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payment_outlined, color: Color(0xFF8B0000)),
            SizedBox(width: 8),
            Text(
              'طريقة الدفع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildPaymentOption(
          title: 'الدفع عند الاستلام',
          icon: Icons.money,
          description: 'ادفع نقداً عند استلام الطلب',
          value: 'cash',
        ),
        SizedBox(height: 12),
        _buildPaymentOption(
          title: 'بطاقة ائتمان / مدى',
          icon: Icons.credit_card,
          description: 'دفع آمن عبر بوابة Telr',
          value: 'card',
        ),
        SizedBox(height: 12),
        if (_isTestMode)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String description,
    required String value,
  }) {
    bool isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF8B0000).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF8B0000) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF8B0000) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Color(0xFF8B0000) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Color(0xFF8B0000)),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: _isSubmitting ? null : _processOrder,
        child: _isSubmitting
            ? LoadingAnimationWidget.threeRotatingDots(
                color: Colors.white,
                size: 30,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'تأكيد الطلب',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ✅ دالة معالجة الطلب - هنا يتم إنشاء الطلب في Firestore مع حساب العمولة
  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      showMessage('الرجاء ملء جميع الحقول المطلوبة', isError: true);
      return;
    }

    if (_selectedPaymentMethod == null) {
      _showToast('الرجاء اختيار طريقة الدفع');
      return;
    }

    // التحقق من تطابق البلد مع العنوان
    final address = _locationController.text.trim();
    final countryName = countryNames[_selectedCountry];

    if (!_isAddressMatchingCountry(address, _selectedCountry)) {
      showMessage(
        'العنوان المدخل لا يتطابق مع البلد المختار ($countryName). '
        'يرجى التأكد من صحة العنوان أو اختيار البلد المناسب.',
        isError: true,
      );
      return;
    }
=======
  Future<void> _completeOrder(
    BuildContext context,
    String paymentMethod,
  ) async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b

    setState(() => _isSubmitting = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw 'لا يوجد اتصال بالإنترنت';
      }

<<<<<<< HEAD
      // ✅ حساب العمولة (24%)
      const double platformFeePercentage = 0.24; // 24%
      final double platformFee = widget.totalAmount * platformFeePercentage;
      final double storeNetAmount = widget.totalAmount - platformFee;

      // في _processOrder، عند تجهيز items
      final List<Map<String, dynamic>> processedItems = [];

      if (widget.orderData['items'] != null) {
        for (var item in widget.orderData['items']) {
          final double itemPrice = (item['price'] ?? 0).toDouble();
          final int quantity = item['quantity'] ?? 1;

          // ✅ جلب معلومات إضافية من المنتج (قد تحتاج لجلبها من Firestore)
          String storeName = item['storeName'] ?? 'متجر غير معروف';
          String storeNumber = item['storeNumber'] ?? 'رقم غير متوفر';
          String storeId = item['storeId'] ?? 'store_unknown';

          // إذا لم تكن موجودة في item، حاول جلبها من Firestore
          if (storeName == 'متجر غير معروف' && item['productId'] != null) {
            try {
              final productDoc = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(item['productId'])
                  .get();

              if (productDoc.exists) {
                final productData = productDoc.data() as Map<String, dynamic>;
                storeName = productData['storeName'] ?? storeName;
                storeNumber = productData['storeNumber'] ?? storeNumber;
                storeId = productData['storeId'] ?? storeId;
              }
            } catch (e) {
              print('❌ خطأ في جلب معلومات المتجر: $e');
            }
          }

          processedItems.add({
            ...item,
            'storeName': storeName, // ✅ إضافة اسم المتجر
            'storeNumber': storeNumber, // ✅ إضافة رقم الهاتف
            'storeId': storeId, // ✅ إضافة معرف المتجر
            'itemPlatformFee': itemPrice * platformFeePercentage,
            'itemNetPrice': itemPrice * (1 - platformFeePercentage),
            'itemTotalNet': itemPrice * quantity * (1 - platformFeePercentage),
          });
        }
      }

      // ✅ إنشاء الطلب في Firestore مع الحقول المالية الجديدة
      final orderData = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'totalPrice': widget.totalAmount, // السعر الذي يدفعه العميل (100%)
        'platformFee': platformFee, // عمولة المنصة (24%)
        'storeNetAmount': storeNetAmount, // صافي المتجر (76%)
        'platformFeePercentage': platformFeePercentage, // نسبة العمولة
        'status': _selectedPaymentMethod == 'cash' ? 'جديدة' : 'بانتظار الدفع',
        'createdAt': FieldValue.serverTimestamp(),
        'customerInfo': {
          'name': _nameController.text.trim(),
          'phone': _formatPhoneNumber(_phoneController.text),
          'country': _selectedCountry,
          'countryName': countryName,
          'address': address,
=======
      Map<String, dynamic> updatedData = {
        ...widget.orderData,
        'customerInfo': {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _locationController.text,
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
          'coordinates': _currentPosition != null
              ? {
                  'latitude': _currentPosition!.latitude,
                  'longitude': _currentPosition!.longitude,
                }
              : null,
        },
<<<<<<< HEAD
        'paymentMethod': _selectedPaymentMethod == 'cash'
            ? 'الدفع عند الاستلام'
            : 'بطاقة ائتمان',
        'items': processedItems, // استخدام العناصر المعدلة مع تفاصيل العمولة
        'financialSummary': {
          'totalPaidByCustomer': widget.totalAmount,
          'platformCommission': platformFee,
          'storeEarnings': storeNetAmount,
          'commissionRate': '24%',
        },
      };

      // حفظ الطلب في Firestore والحصول على ID
      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData);

      // ✅ تحديث مخزون المنتجات (تقليل الكمية)
      final batch = FirebaseFirestore.instance.batch();

      for (var item in widget.orderData['items']) {
        final productId = item['productId'];
        final quantity = item['quantity'] ?? 1;

        if (productId != null) {
          final productRef = FirebaseFirestore.instance
              .collection('products')
              .doc(productId);

          batch.update(productRef, {
            'stock': FieldValue.increment(-quantity), // تقليل المخزون
            'totalSold': FieldValue.increment(quantity), // زيادة عدد المبيعات
          });
        }
      }

      // ✅ تفريغ السلة بعد إنشاء الطلب
      for (var item in widget.cartItems) {
        batch.delete(item.reference);
      }

      await batch.commit();

      if (_selectedPaymentMethod == 'cash') {
        _showToast('تم تأكيد الطلب بنجاح');
        await Future.delayed(Duration(seconds: 1));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // معالجة الدفع الإلكتروني باستخدام orderRef.id
        await _processTelrPayment(orderRef.id);
      }
    } catch (e) {
      _showToast('حدث خطأ: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '${countryCodes[_selectedCountry]}$digits';
  }

  // ========== دوال Telr ==========

  Future<String?> _createTelrMobileSession(String orderId) async {
    try {
      print('=== Mobile API Request ===');

      final params = {
        'ivp_method': 'create',
        'ivp_store': _telrStoreId,
        'ivp_authkey': _telrAuthKey,
        'ivp_cart': orderId,
        'ivp_test': _isTestMode ? '1' : '0',
        'ivp_amount': (widget.totalAmount * 100).toStringAsFixed(0),
        'ivp_currency': 'SAR',
        'ivp_desc': 'طلب رقم $orderId',
        'ivp_mobile': '1',
        'mobile_app': '1',
        'app_scheme': 'giftapp',

        // معلومات العميل
        'bill_fname': _nameController.text.split(' ').first,
        'bill_lname': _nameController.text.split(' ').last,
        'bill_email': 'customer${_phoneController.text}@temp.com',
        'bill_mobile': _formatPhoneNumber(_phoneController.text),
        'bill_addr1': _locationController.text,
        'bill_city': 'Riyadh',
        'bill_country': 'SA',
        'bill_zip': '12345',

        // روابط العودة
        'return_auth': 'giftapp://payment/success',
        'return_decl': 'giftapp://payment/declined',
        'return_can': 'giftapp://payment/cancelled',
      };

      final response = await http
          .post(
            Uri.parse('https://secure.telr.com/gateway/mobile.xml'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/xml',
            },
            body: params,
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final xmlString = response.body;

        final urlMatch = RegExp(r'<url>([^<]+)</url>').firstMatch(xmlString);
        if (urlMatch != null && urlMatch.group(1)!.isNotEmpty) {
          return urlMatch.group(1)!;
        }

        final refMatch = RegExp(r'<ref>([^<]+)</ref>').firstMatch(xmlString);
        if (refMatch != null && refMatch.group(1)!.isNotEmpty) {
          final ref = refMatch.group(1)!;
          return 'https://secure.telr.com/gateway/mobile_pay.php?ref=$ref';
        }

        throw 'لا يمكن العثور على رابط الدفع في استجابة Mobile API';
      } else {
        throw 'Mobile API returned status: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Mobile API Error: $e');
      rethrow;
    }
  }

  Future<String?> _createTelrStandardSession(String orderId) async {
    try {
      print('=== Standard API Request ===');

      final params = {
        'ivp_method': 'create',
        'ivp_store': _telrStoreId,
        'ivp_authkey': _telrAuthKey,
        'ivp_test': _isTestMode ? '1' : '0',
        'ivp_cart': orderId,
        'ivp_amount': (widget.totalAmount * 100).toStringAsFixed(0),
        'ivp_currency': 'SAR',
        'ivp_desc': 'طلب رقم $orderId',
        'ivp_trantype': 'sale',
        'ivp_framed': '1',
        'ivp_mobile': '1',

        // معلومات العميل
        'bill_fname': _nameController.text.split(' ').first,
        'bill_lname': _nameController.text.split(' ').last,
        'bill_email': 'customer${_phoneController.text}@temp.com',
        'bill_mobile': _formatPhoneNumber(_phoneController.text),
        'bill_addr1': _locationController.text,
        'bill_city': 'Riyadh',
        'bill_country': 'SA',
        'bill_zip': '12345',

        // روابط العودة
        'return_auth': 'https://example.com/success',
        'return_decl': 'https://example.com/declined',
        'return_can': 'https://example.com/cancelled',
      };

      final response = await http
          .post(
            Uri.parse('https://secure.telr.com/gateway/order.json'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: params,
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['order'] != null &&
            responseData['order']['url'] != null) {
          return responseData['order']['url'] as String;
        }

        if (responseData['error'] != null) {
          final errorMsg =
              responseData['error']['message'] ??
              responseData['error'].toString();
          throw 'Telr Standard API Error: $errorMsg';
        }

        throw 'لا يمكن العثور على رابط الدفع في استجابة Standard API';
      } else {
        throw 'Standard API returned status: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Standard API Error: $e');
      rethrow;
    }
  }

  // ✅ دالة رئيسية للدفع مع المحاولات المتعددة
  Future<void> _processTelrPayment(String orderId) async {
    setState(() => _isSubmitting = true);

    try {
      String? paymentUrl;
      String usedMethod = '';

      // حاول أولاً Mobile API
      try {
        print('🔄 محاولة Mobile API أولاً...');
        paymentUrl = await _createTelrMobileSession(orderId);
        usedMethod = 'Mobile API';
      } catch (mobileError) {
        print('❌ Mobile API فشل: $mobileError');

        // حاول Standard API كبديل
        try {
          print('🔄 محاولة Standard API كبديل...');
          paymentUrl = await _createTelrStandardSession(orderId);
          usedMethod = 'Standard API';
        } catch (standardError) {
          print('❌ Standard API فشل: $standardError');
          throw 'فشل كلا الطريقتين';
        }
      }

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        print('✅ تم إنشاء رابط الدفع باستخدام: $usedMethod');

        // فتح شاشة الدفع
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelrPaymentScreen(
              paymentUrl: paymentUrl!,
              orderId: orderId,
              totalAmount: widget.totalAmount,
              storeId: _telrStoreId,
              authKey: _telrAuthKey,
              isTestMode: _isTestMode,
            ),
          ),
        );

        // التحقق من حالة الطلب بعد العودة
        await _checkOrderStatus(orderId);
      } else {
        throw 'فشل في إنشاء رابط الدفع';
      }
    } catch (e) {
      print('❌ عملية الدفع فشلت: $e');
      showMessage('فشل في إنشاء جلسة الدفع', isError: true);

      // عرض خيار الدفع عند الاستلام كبديل
      await _showCashPaymentOption();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ✅ دالة للتحقق من حالة الطلب
  Future<void> _checkOrderStatus(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        final data = orderDoc.data() as Map<String, dynamic>;
        final status = data['status'];

        if (status == 'مدفوعة' || status == 'مكتمل') {
          showMessage('تم الدفع بنجاح');
        } else if (status == 'فشل الدفع') {
          showMessage('فشل عملية الدفع', isError: true);
        }
      }
    } catch (e) {
      print('Error checking order status: $e');
    }
  }

  // ✅ دالة للدفع عند الاستلام كبديل
  Future<void> _showCashPaymentOption() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('الدفع الإلكتروني غير متاح', style: TextStyle(fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('عذراً، خدمة الدفع الإلكتروني غير متاحة حالياً.'),
            SizedBox(height: 10),
            Text('هل ترغب في الاستمرار مع الدفع عند الاستلام؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B0000)),
            child: Text(
              'موافق على الدفع عند الاستلام',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // لا حاجة لتحديث الطلب هنا لأنه تم إنشاؤه مسبقاً في _processOrder
        showMessage('تم تحويل طلبك للدفع عند الاستلام');
        await Future.delayed(Duration(seconds: 2));
        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        _showToast('حدث خطأ في تحديث الطلب: $e');
      }
    }
  }
}

class TelrPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderId;
  final double totalAmount;
  final String storeId;
  final String authKey;
  final bool isTestMode;

  const TelrPaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.orderId,
    required this.totalAmount,
    required this.storeId,
    required this.authKey,
    required this.isTestMode,
  }) : super(key: key);

  @override
  _TelrPaymentScreenState createState() => _TelrPaymentScreenState();
}

class _TelrPaymentScreenState extends State<TelrPaymentScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    print('💰 Telr Payment Screen Initialized');
    print('📦 Order ID: ${widget.orderId}');
    print('💰 Amount: ${widget.totalAmount} SAR');
    print('🔗 Payment URL: ${widget.paymentUrl}');
    print('🧪 Test Mode: ${widget.isTestMode}');
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[800] : Color(0xFF8B0000),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
      ),
    );
  }

  Future<void> _updateOrderStatus(bool success, String? transactionId) async {
    try {
      final Map<String, Object> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (success) {
        updateData['status'] = 'مدفوعة';
        updateData['paymentStatus'] = 'مكتمل';
        updateData['paidAt'] = FieldValue.serverTimestamp();
        if (transactionId != null) {
          updateData['transactionId'] = transactionId;
        }

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .update(updateData);

        showMessage('تم الدفع بنجاح');
        print('✅ Payment successful for order: ${widget.orderId}');
      } else {
        updateData['status'] = 'فشل الدفع';
        updateData['paymentStatus'] = 'فاشل';

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .update(updateData);

        showMessage('فشل عملية الدفع', isError: true);
        print('❌ Payment failed for order: ${widget.orderId}');
      }
    } catch (e) {
      print('Error updating order status: $e');
      showMessage('حدث خطأ في تحديث حالة الطلب', isError: true);
    }
  }

  void _handlePaymentResponse(String url) {
    print('🔄 Processing URL: $url');

    if (url.contains('/success') ||
        url.contains('authorised') ||
        url.contains('approved') ||
        url.contains('payment/success')) {
      final uri = Uri.parse(url);
      final transactionId =
          uri.queryParameters['tran_ref'] ??
          uri.queryParameters['transaction_id'] ??
          uri.queryParameters['ref'] ??
          'TELR_${DateTime.now().millisecondsSinceEpoch}';

      print('✅ Payment successful! Transaction ID: $transactionId');

      setState(() => _paymentCompleted = true);
      _updateOrderStatus(true, transactionId);

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    } else if (url.contains('/declined') ||
        url.contains('declined') ||
        url.contains('/cancelled') ||
        url.contains('cancelled') ||
        url.contains('payment/declined') ||
        url.contains('payment/cancelled')) {
      print('❌ Payment failed or cancelled');
      _updateOrderStatus(false, null);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('فشل الدفع'),
          content: Text('لم تكتمل عملية الدفع. الرجاء المحاولة مرة أخرى.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('حسناً', style: TextStyle(color: Color(0xFF8B0000))),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الدفع الإلكتروني',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF8B0000),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (_paymentCompleted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 60,
                        color: Color(0xFF8B0000),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'دفع آمن عبر بوابة Telr',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'رقم الطلب: ${widget.orderId}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'المبلغ: ${widget.totalAmount.toStringAsFixed(2)} ريال',
                        style: TextStyle(
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.isTestMode) ...[
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'وضع الاختبار - استخدم بطاقات الاختبار',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.paymentUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      allowsInlineMediaPlayback: true,
                      mediaPlaybackRequiresUserGesture: false,
                      useShouldOverrideUrlLoading: true,
                      useOnLoadResource: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      print('🌐 WebView created');
                    },
                    onLoadStart: (controller, url) {
                      setState(() => _isLoading = true);
                      print('📥 Loading started: $url');
                    },
                    onLoadStop: (controller, url) {
                      setState(() => _isLoading = false);
                      print('✅ Loaded: $url');
                      _handlePaymentResponse(url.toString());
                    },
                    onLoadError: (controller, url, code, message) {
                      setState(() => _isLoading = false);
                      print('❌ Load error: $message (Code: $code)');
                      showMessage('خطأ في تحميل صفحة الدفع', isError: true);
                    },
                    onProgressChanged: (controller, progress) {
                      print('📊 Progress: $progress%');
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print('📝 Console: ${consoleMessage.message}');
                    },
                  ),
                ),
              ],
            ),

            if (_isLoading)
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.threeRotatingDots(
                        color: Color(0xFF8B0000),
                        size: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل صفحة الدفع...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: widget.isTestMode
            ? Container(
                padding: EdgeInsets.all(12),
                color: Colors.orange[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'بطاقات الاختبار:',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '4111 1111 1111 1111 | تاريخ انتهاء: أي تاريخ مستقبلي | CVV: أي 3 أرقام',
                      style: TextStyle(color: Colors.orange[700], fontSize: 11),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ TelrPaymentScreen disposed');
    super.dispose();
  }
=======
        'paymentMethod': paymentMethod,
        'status': 'جديدة',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // إذا كانت طريقة الدفع "الدفع عند الاستلام" نضيف بيانات المنتجات
      if (paymentMethod == 'الدفع عند الاستلام') {
        final List<Map<String, dynamic>> enrichedItems = [];

        for (var item in widget.orderData['items']) {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(item['productId'])
              .get();

          final productData = productDoc.data();

          if (productData != null) {
            enrichedItems.add({
              ...item,
              'createdAt': productData['createdAt'],
              'description': productData['description'],
              'imageUrl': productData['imageUrl'],
              'latitude': productData['latitude'],
              'longitude': productData['longitude'],
              'storeId': productData['storeId'],
              'storeName': productData['storeName'],
              'storeNumber': productData['storeNumber'],
            });
          } else {
            enrichedItems.add(item);
          }
        }

        updatedData['items'] = enrichedItems;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .set(updatedData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تأكيد الطلب بنجاح'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
>>>>>>> f7a77c2230bd076a0b7d696c96738da0fb2cfe7b
}
