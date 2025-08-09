import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
              }

              _totalPrice = 0;
              snapshot.data?.docs.forEach((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final price = num.tryParse(data['price'].toString()) ?? 0;
                final quantity = num.tryParse(data['quantity'].toString()) ?? 1;
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

  Widget _buildCartItem(String docId, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'بدون اسم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFromCart(docId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total) {
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
                ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder(
    BuildContext context,
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('السلة فارغة')));
      return;
    }

    setState(() => _isProcessingOrder = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw 'لا يوجد اتصال بالإنترنت';
      }

      final orderData = {
        'userId': user.uid,
        'totalPrice': _totalPrice,
        'status': 'جديدة',
        'createdAt': FieldValue.serverTimestamp(),
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

      final orderRef = await _firestore.collection('orders').add(orderData);

      final batch = _firestore.batch();
      for (var item in cartItems) {
        batch.delete(item.reference);
      }
      await batch.commit();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            orderId: orderRef.id,
            totalAmount: _totalPrice,
            orderData: orderData,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحديث الكمية')));
    }
  }

  Future<void> _removeFromCart(String docId) async {
    try {
      await _firestore.collection('cart').doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف من السلة')));
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final Map<String, dynamic> orderData;

  const CheckoutScreen({
    Key? key,
    required this.orderId,
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الموقع: $e')));
      }
    }
  }

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
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      ),
    );
  }

  Future<void> _completeOrder(
    BuildContext context,
    String paymentMethod,
  ) async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw 'لا يوجد اتصال بالإنترنت';
      }

      Map<String, dynamic> updatedData = {
        ...widget.orderData,
        'customerInfo': {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _locationController.text,
          'coordinates': _currentPosition != null
              ? {
                  'latitude': _currentPosition!.latitude,
                  'longitude': _currentPosition!.longitude,
                }
              : null,
        },
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
}
