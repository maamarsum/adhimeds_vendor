import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ActiveOrdersBody extends StatefulWidget {
  @override
  State<ActiveOrdersBody> createState() => _ActiveOrdersBodyState();
}

class _ActiveOrdersBodyState extends State<ActiveOrdersBody> {
   List<dynamic> orders = [];
    bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

 Future<void> fetchOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    final response = await http.post(
      Uri.parse('https://baba.qa/adhimeds/api/v2/vendororderlist'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'System-Key': '\$2y\$10\$BO45zUbQshM6XXFcnVSlKuhPqqDTIu15JOAVlkxS/o6K8c32w6wPa',
      },
      body: jsonEncode({'vendorid': userId}),
    );

    if (response.statusCode == 200) {
      print('Success');
      print(response.body);
      final data = jsonDecode(response.body);
      final List<dynamic> allOrders = data['data'];
   setState(() {
    orders = allOrders.where((order) => ['2', '3', '4', '5'].contains(order['status'])).toList();
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
          'System-Key': '\$2y\$10\$BO45zUbQshM6XXFcnVSlKuhPqqDTIu15JOAVlkxS/o6K8c32w6wPa',
        },
        body: jsonEncode({
          'orderid': orderId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
      
        Fluttertoast.showToast(
         msg: "Delivery Status Updated Succesfully!"
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
  if (isLoading) {
    return Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2));
  }

  if (errorMessage.isNotEmpty) {
    return Center(child: Text(errorMessage));
  }

  if (orders.isEmpty) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('images/no.png',height: 50,),
        Text("No Active orders available.",style: TextStyle(fontSize: 13),),
      ],
    ));
  }
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: orders.map((order) => OrderCard(order: order, onUpdateStatus: updateOrderStatus)).toList(),
        ),
      ),
    );
  }
}

 class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
 
  final Function(String, String) onUpdateStatus;
  OrderCard({required this.order, required this.onUpdateStatus});

  void _handleAccept() {
    onUpdateStatus(order['id'].toString(), "2");
  }

 void _handleReject(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Delivery Status',style: TextStyle(fontSize: 20,color: Colors.green),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onUpdateStatus(order['id'].toString(), "3"); 
              },
              child: Text('Picked up', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onUpdateStatus(order['id'].toString(), "4"); 
              },
              child: Text('On the way', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onUpdateStatus(order['id'].toString(), "5");
              },
              child: Text('Delivered', style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onUpdateStatus(order['id'].toString(), "6"); 
              },
              child: Text('Cancelled', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
      Color statusColor = Colors.white; 
  switch (order['status']) {
    case '2':
      statusColor = Colors.blue;
      break;
    case '3':
      statusColor = Colors.orange; 
      break;
    case '4':
      statusColor = Colors.yellow; 
      break;
    case '5':
      statusColor = Colors.green; 
      break;
    case '6':
      statusColor = Colors.red; 
      break;
    default:
      statusColor = Colors.white; 
  }
    return GestureDetector(
      onTap: () {
        showDialog(
          
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Order Details'),
              content: SingleChildScrollView(
                child: Container(
                  height: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Code', style: TextStyle(fontSize: 13)),
                          Text(order['code'], style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: TextStyle(fontSize: 13)),
                              Text(
                                order['date'].toString(),
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                    
                        ],
                      ),
                      SizedBox(height: 10),
                         Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Status', style: TextStyle(fontSize: 13)),
                              Row(
                                children: [
                                  Text(order['delivery_status'], style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                               SizedBox(height: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment', style: TextStyle(fontSize: 13)),
                              Text(order['payment_type'], style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shipment', style: TextStyle(fontSize: 13)),
                              Row(
                                children: [
                                  Text(order['shipping_type'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                   if (order['shipping_address'] is Map<String, dynamic>) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Address", style: TextStyle(fontSize: 13)),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text("Name:- "),
                                Text(order['shipping_address']['name'] ?? '', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          
                      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Address:- "),
    Expanded(
      child: Text(
        (order['shipping_address']['address'] ?? '').replaceAll(',', '\n'),
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    ),
  ],
),


                            Row(
                              children: [
                                Text("City:- "),
                                Text(order['shipping_address']['city'] ?? '', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Country:- "),
                                Text(order['shipping_address']['country'] ?? '', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Phone:- "),
                                Text(order['shipping_address']['phone'] ?? '', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Postal Code:- "),
                                Text(order['shipping_address']['postal_code'] ?? '', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        Text("No shipping address provided.", style: TextStyle(color: Colors.grey)),
                      ],
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text('Total Amount', style: TextStyle(fontSize: 13)),
                          Spacer(),
                          Text(order['grand_total'].toString(), style: TextStyle(color: Colors.orange, fontSize: 26)),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          height: 190,
          width: 328,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 0.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Order Code', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(width: 40),
                        Text(order['code'], style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Date', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(width: 40),
                        Text(order['date'].toString(), style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.money_rounded, color: Colors.grey, size: 20),
                    SizedBox(width: 10),
                    Text('Payment Status', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        Text(order['payment_status'], style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 5),
                        Icon(Icons.check_circle, color: order['payment_status'] == 'paid' ? Colors.green : Colors.red),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                    SizedBox(width: 10),
                    Text('Total Amount', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 25),
                    Text(order['grand_total'].toString(), style: TextStyle(color: Colors.orange)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Center(
                      child: Text('Delivery Status', style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 50),
                    InkWell(
               
                      child: Container(
                        height: 43,
                        width: 140,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(order['delivery_status'], style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
