import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // أضف هذا
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      // الحصول على المستخدم الحالي
      User? user = _auth.currentUser;
      if (user == null) {
        return []; // إذا لم يكن المستخدم مسجل الدخول
      }

      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid) // تصفية حسب المستخدم الحالي
          .orderBy('createdAt', descending: true)
          .limit(5) // جلب آخر 5 طلبات فقط
          .get();

      List<Map<String, dynamic>> orders = [];

      for (var doc in ordersSnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        // حساب إجمالي السعر وعدد المنتجات
        double total = 0;
        int itemsCount = 0;

        if (orderData['items'] != null && orderData['items'] is List) {
          itemsCount = (orderData['items'] as List).length;
          for (var item in orderData['items']) {
            total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
          }
        }

        // تحويل التاريخ إلى تنسيق مقروء
        String formattedDate = 'غير معروف';
        if (orderData['createdAt'] != null) {
          Timestamp timestamp = orderData['createdAt'] as Timestamp;
          DateTime date = timestamp.toDate();
          formattedDate = DateFormat('d MMMM y', 'ar').format(date);
        }

        // تحديد حالة الطلب الفعلية
        String status = orderData['status'] ?? 'قيد التنفيذ';
        IconData statusIcon = _getStatusIcon(status);
        Color statusColor = _getStatusColor(status);

        orders.add({
          'id': doc.id,
          'date': formattedDate,
          'total': total,
          'items': itemsCount,
          'status': status,
          'icon': statusIcon,
          'color': statusColor,
          'orderData': orderData, // حفظ بيانات الطلب الكاملة للتفاصيل
        });
      }

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'جديدة':
        return Icons.access_time;
      case 'قيد التجهيز':
        return Icons.inventory;
      case 'قيد التوصيل':
        return Icons.delivery_dining;
      case 'مكتملة':
        return Icons.check_circle;
      case 'ملغية':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديدة':
        return Colors.orange;
      case 'قيد التجهيز':
        return Colors.blue;
      case 'قيد التوصيل':
        return Colors.blueAccent;
      case 'مكتملة':
        return Colors.green;
      case 'ملغية':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'طلباتي الأخيرة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B0000),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFF8B0000).withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF8B0000)),
                const SizedBox(width: 8),
                Text(
                  'يمكنك تتبع حالة طلبك هنا',
                  style: TextStyle(
                    color: Color(0xFF8B0000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في تحميل الطلبات'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد طلبات حتى الآن',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _ordersFuture = _fetchOrders();
                    });
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order['id'].substring(0, 6)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(order['icon'], size: 16, color: order['color']),
                      const SizedBox(width: 6),
                      Text(
                        order['status'],
                        style: TextStyle(
                          color: order['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, 'التاريخ', order['date']),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.shopping_bag,
              'عدد المنتجات',
              '${order['items']} منتجات',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.payments,
              'المبلغ الإجمالي',
              '${order['total'].toStringAsFixed(2)} د.ع',
              isTotal: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF8B0000)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _showOrderDetails(context, order['orderData']);
                },
                child: const Text(
                  'عرض تفاصيل الطلب',
                  style: TextStyle(
                    color: Color(0xFF8B0000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(),

              // معلومات حالة الطلب
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    orderData['status'] ?? '',
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(orderData['status'] ?? ''),
                      color: _getStatusColor(orderData['status'] ?? ''),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالة الطلب',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            orderData['status'] ?? 'غير معروف',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getStatusColor(orderData['status'] ?? ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // معلومات الطلب الأساسية
              if (orderData['createdAt'] != null)
                _buildDetailRow(
                  Icons.calendar_today,
                  'تاريخ الطلب',
                  DateFormat(
                    'd MMMM y - h:mm a',
                    'ar',
                  ).format((orderData['createdAt'] as Timestamp).toDate()),
                ),

              if (orderData['deliveredAt'] != null)
                _buildDetailRow(
                  Icons.check_circle,
                  'تاريخ التوصيل',
                  DateFormat(
                    'd MMMM y - h:mm a',
                    'ar',
                  ).format((orderData['deliveredAt'] as Timestamp).toDate()),
                ),

              SizedBox(height: 16),
              Text(
                'المنتجات:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),

              if (orderData['items'] != null && orderData['items'] is List)
                ...(orderData['items'] as List).map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (item['imageUrl'] != null)
                          Image.network(
                            item['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'منتج غير معروف',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${item['price']?.toStringAsFixed(2) ?? '0'} د.ع × ${item['quantity'] ?? '1'}',
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)} د.ع',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${orderData['items']?.fold(0.0, (sum, item) => sum + (item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)} د.ع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8B0000)),
          const SizedBox(width: 12),
          Text('$title: ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isTotal ? const Color(0xFF8B0000) : Colors.black,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
