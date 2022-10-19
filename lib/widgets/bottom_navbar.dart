import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/views/home_view.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int pageIndex = 0;

  List<Widget> pages = [
    Home(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        selectedFontSize: 12,
        unselectedLabelStyle: const TextStyle(fontFamily: labelFont),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: labelFont,
        ),
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info),
            label: "Info",
          ),
        ],
        onTap: (newIndex) => setState(() => pageIndex = newIndex),
      ),
    );
  }
}
