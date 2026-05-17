import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gift/B2BGifts.dart';
import 'package:gift/Cart_screen.dart';
import 'package:gift/My_Orders_Screen.dart';
import 'package:gift/User_Settings_Screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:gift/home_screen.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  // ✅ إضافة صفحة B2B إلى قائمة الصفحات
  final List<Widget> pages = [
    GiftShopHomeScreen(),
    MyOrdersScreen(),
    CartScreen(),
    B2BGiftsScreen(), // ✅ صفحة B2B (الترتيب الرابع)
    UserSettingsScreen(isLoggedIn: FirebaseAuth.instance.currentUser != null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home, size: 24),
            title: Text("الرئيسية", style: TextStyle(fontSize: 12)),
            selectedColor: Colors.red,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.receipt_long, size: 24),
            title: Text("الطلبات", style: TextStyle(fontSize: 12)),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart, size: 24),
            title: Text("السلة", style: TextStyle(fontSize: 12)),
            selectedColor: Colors.green,
          ),
          // ✅ عنصر B2B الجديد
          SalomonBottomBarItem(
            icon: Icon(Icons.business, size: 24), // أيقونة الشركات
            title: Text("للشركات", style: TextStyle(fontSize: 12)),
            selectedColor: Colors.orange, // لون برتقالي مميز
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.settings, size: 24),
            title: Text("الإعدادات", style: TextStyle(fontSize: 12)),
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
