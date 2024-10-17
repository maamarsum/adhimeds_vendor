import 'dart:convert';

import 'package:adhimedsvendor/bar.dart';
import 'package:adhimedsvendor/login.dart';
import 'package:adhimedsvendor/mydelivery2.dart';
import 'package:adhimedsvendor/neworder.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences _prefs;
  String _userName = '';
  String _userEmail = '';
  String avatar = '';
  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchOrders();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = _prefs.getString('userName') ?? '';
      _userEmail = _prefs.getString('userEmail') ?? '';
      avatar = _prefs.getString('avatar') ?? '';
    });
  }

  void _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Text(
            "Are you sure you want to LogOut?",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "CANCEL",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _performLogout(context);
              },
              child: Text(
                "LOGOUT",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  Future<void> fetchOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    final response = await http.post(
      Uri.parse('https://baba.qa/adhimeds/api/v2/vendororderlist'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'System-Key':
            '\$2y\$10\$BO45zUbQshM6XXFcnVSlKuhPqqDTIu15JOAVlkxS/o6K8c32w6wPa',
      },
      body: jsonEncode({'vendorid': userId}),
    );

    if (response.statusCode == 200) {
      print('Success');
      print(response.body);
      final data = jsonDecode(response.body);
      final List<dynamic> allOrders = data['data'];
      setState(() {
        orders = allOrders.where((order) => order['status'] == '1').toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void updateOrderStatus(String orderId, String status) async {
    print('Updating order status for Order ID: $orderId, Status: $status');
    try {
      final response = await http.post(
        Uri.parse('https://baba.qa/adhimeds/api/v2/orderstatuschange'),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'System-Key':
              '\$2y\$10\$BO45zUbQshM6XXFcnVSlKuhPqqDTIu15JOAVlkxS/o6K8c32w6wPa',
        },
        body: jsonEncode({
          'orderid': orderId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);

        Fluttertoast.showToast(
          msg: status == "2" ? "Order accepted" : "Order cancelled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        fetchOrders();
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
              title: Text(
                'Dashboard',
                style: TextStyle(color: Colors.black),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              backgroundColor: Colors.white),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.6),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(80),
                          )),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.green,
                              backgroundImage: NetworkImage(avatar)),
                          SizedBox(
                            width: 25,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 65,
                              ),
                              Text(
                                _userName,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                              Text(
                                _userEmail,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          Image.asset(
                            'images/dashboard.png',
                            height: 30,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          Text(
                            'Dashboard',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          Image.asset(
                            'images/completed.webp',
                            height: 20,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          Text(
                            'Orders',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyDelivery2()));
                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          Image.asset(
                            'images/logout.webp',
                            height: 20,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          Text(
                            'LogOut',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        _logOut(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.green.withOpacity(0.3)),
                                  height: 130,
                                  width: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: Image.asset(
                                              'images/truck.webp',
                                              color: Colors.green),
                                        ),
                                        Text(
                                          'Completed Delivery',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.pink.withOpacity(0.2),
                                  ),
                                  height: 130,
                                  width: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: Image.asset(
                                            'images/time.webp',
                                            color: Colors.pink,
                                          ),
                                        ),
                                        Text(
                                          'Pending Delivery',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.orange.withOpacity(0.2),
                                  ),
                                  height: 130,
                                  width: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 60,
                                          width: 60,
                                          child: Image.asset(
                                            'images/truck.webp',
                                            color: Colors.orange,
                                          ),
                                        ),
                                        Text(
                                          'Total Collected',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  height: 130,
                                  width: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        child: Image.asset(
                                          'images/mo.webp',
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        'Earnings',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '0',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'New Orders',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          orders.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(60.0),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/no.png',
                                        height: 50,
                                      ),
                                      Text(
                                        'No new orders available',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: orders
                                      .map((order) => OrderCard(
                                            order: order,
                                            onUpdateStatus: updateOrderStatus,
                                          ))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 0,
            onTap: (int index) {
              if (index == 1) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyDelivery2()));
              } else if (index == 2) {}
            },
          )),
    );
  }
}
