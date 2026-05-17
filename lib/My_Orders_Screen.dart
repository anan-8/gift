import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  // ===================== جلب الطلبات =====================
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> orders = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        double total = 0;
        int itemsCount = 0;

        if (data['items'] is List) {
          for (final item in data['items']) {
            final price = (item['price'] ?? 0).toDouble();
            final quantity = item['quantity'] ?? 1;
            total += price * quantity;
            itemsCount++;
          }
        }

        String date = 'غير معروف';
        if (data['createdAt'] is Timestamp) {
          date = DateFormat(
            'd MMMM y',
            'ar',
          ).format((data['createdAt'] as Timestamp).toDate());
        }

        final status = data['status'] ?? 'قيد التنفيذ';

        orders.add({
          'id': doc.id,
          'date': date,
          'total': total,
          'items': itemsCount,
          'status': status,
          'icon': _getStatusIcon(status),
          'color': _getStatusColor(status),
          'orderData': {...data, 'id': doc.id},
        });
      }

      return orders;
    } catch (e) {
      debugPrint('Fetch orders error: $e');
      return [];
    }
  }

  // ===================== إلغاء الطلب =====================
  Future<void> _cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'ملغية',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  // ===================== الواجهة =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'طلباتي الأخيرة',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  // ===================== كرت الطلب =====================
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final canCancel =
        order['status'] == 'جديدة' || order['status'] == 'قيد التجهيز';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
                Row(
                  children: [
                    Icon(order['icon'], color: order['color'], size: 18),
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
              ],
            ),
            const SizedBox(height: 8),
            Text('التاريخ: ${order['date']}'),
            Text('عدد المنتجات: ${order['items']}'),
            Text(
              'الإجمالي: ${order['total'].toStringAsFixed(2)} ريال',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showOrderDetails(context, order['orderData']),
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _cancelOrder(order['id']),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== تفاصيل الطلب =====================
  void _showOrderDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'حالة الطلب: ${data['status']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (data['items'] is List)
                ...(data['items'] as List).map<Widget>((item) {
                  return ListTile(
                    title: Text(item['name'] ?? ''),
                    trailing: Text(
                      '${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)} ريال',
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ===================== أدوات مساعدة =====================
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'مكتملة':
        return Icons.check_circle;
      case 'ملغية':
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتملة':
        return Colors.green;
      case 'ملغية':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
