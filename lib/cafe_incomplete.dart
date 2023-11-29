import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var firestore = FirebaseFirestore.instance;
var orderCollectionName = 'cafe_order';

class CafeInComplete extends StatefulWidget {
  const CafeInComplete({super.key});

  @override
  State<CafeInComplete> createState() => _CafeInCompleteState();
}

class _CafeInCompleteState extends State<CafeInComplete> {
  bool init = true;
  List<dynamic> orderDataList = [];
  dynamic body = const Text('액션 빔');

  Future<void> getOrders() async {
    firestore.collection(orderCollectionName).snapshots().listen((event) {
      // docChanges = 새로 생긴 데이터만.
      // docs = 전체 데이터.
      setState(() {
        if (init) {
          // 처음 데이터 전체 불러오기
          orderDataList = event.docs;
          init = false; // 다음부턴 새로운 데이터만.
        } else {
          // 새로운 데이터만.
          orderDataList.insertAll(
              0, event.docChanges); // [신규, 신규, 신규, aa, ss, dd]
          print('${orderDataList.length} count');
        }
      });
    });
  }

  void showOrderList() {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: orderDataList.isEmpty
            ? const Text('없')
            : body = ListView.separated(
                itemBuilder: (context, index) {
                  var order = orderDataList[index];
                  return ListTile(
                    leading: Text('${order['orderNumber']}'),
                    title: Text('${order['orderName']}'),
                  );
                },
                separatorBuilder: (c, i) => const Divider(),
                itemCount: orderDataList.length));
  }
}
