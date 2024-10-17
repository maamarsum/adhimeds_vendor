import 'package:adhimedsvendor/activeorder.dart';
import 'package:adhimedsvendor/bar.dart';
import 'package:adhimedsvendor/home.dart';
import 'package:adhimedsvendor/neworder.dart';
import 'package:flutter/material.dart';

class MyDelivery2 extends StatefulWidget {
  const MyDelivery2({Key? key}) : super(key: key);

  @override
  State<MyDelivery2> createState() => _MyDelivery2State();
}

class _MyDelivery2State extends State<MyDelivery2> {
  int selectedIndex = 0;

  void selectIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget getBody() {
    switch (selectedIndex) {
      case 0:
        return NewOrdersBody();
      case 1:
        return ActiveOrdersBody();

      default:
        return NewOrdersBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Orders'),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                children: [
                  buildTab(0, 'New Order'),
                  SizedBox(width: 15),
                  buildTab(1, 'Active'),
                ],
              ),
            ),
            Expanded(
              child: getBody(),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 1,
          onTap: (int index) {
            if (index == 0) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }
          },
        ));
  }

  Widget buildTab(int index, String title) {
    return GestureDetector(
      onTap: () {
        selectIndex(index);
      },
      child: Container(
        height: 50,
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selectedIndex == index ? Colors.orange : Colors.white,
          border:
              selectedIndex != index ? Border.all(color: Colors.grey) : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedIndex == index ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
