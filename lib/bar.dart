import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Color.fromARGB(255, 172, 170, 170),
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/dashboard.png',
            width: 25,
            height: 25,
            color: currentIndex == 0 ? Colors.green : Colors.grey,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/delivery.webp',
            width: 25,
            height: 25,
            color: currentIndex == 1 ? Colors.green : Colors.grey,
          ),
          label: 'Orders',
        ),
      ],
    );
  }
}
