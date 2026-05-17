import 'package:flutter/material.dart';

class SearchScreen extends SearchDelegate {
  List<String> flowers = [
    'الجوري',
    'الياسمين',
    'التوليب',
    'النرجس',
    'اللافندر',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
          showSuggestions(context); // إعادة عرض الاقتراحات بعد المسح
        },
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null); // إغلاق البحث
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // يتم تنفيذ هذا عندما يضغط المستخدم على زر "بحث" من الكيبورد
    List<String> filterList = flowers
        .where((element) => element.contains(query))
        .toList();

    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(filterList[i]),
          onTap: () {
            close(context, filterList[i]); // تغلق البحث وتعيد القيمة المختارة
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestionList = query.isEmpty
        ? flowers
        : flowers.where((element) => element.contains(query)).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(suggestionList[i]),
          onTap: () {
            query = suggestionList[i];
            showResults(context); // عرض النتائج بناءً على الاختيار
          },
        );
      },
    );
  }
}
