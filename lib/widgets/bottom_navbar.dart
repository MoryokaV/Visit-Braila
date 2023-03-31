import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/views/about_view.dart';
import 'package:visit_braila/views/all_events_view.dart';
import 'package:visit_braila/views/home_view.dart';
import 'package:visit_braila/views/wishlist_view.dart';
import 'package:visit_braila/widgets/notifications_button.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({Key? key}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int pageIndex = 0;

  List<Widget> pages = [
    HomeView(),
    const WishlistView(),
    const AllEventsView(),
    const AboutView(),
  ];

  AppBar? getAppBar(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return null;
      case 1:
        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          elevation: 4,
          title: Text(
            "Favorite",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
          ),
          bottom: const TabBar(
            labelColor: kPrimaryColor,
            indicatorWeight: 2.5,
            isScrollable: true,
            tabs: [
              Tab(
                text: "Obiective",
              ),
              Tab(
                text: "Tururi",
              ),
              Tab(
                text: "Gastronomie",
              ),
              Tab(
                text: "Cazări",
              ),
            ],
          ),
        );
      case 2:
        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          elevation: 0,
          title: Text(
            "Evenimente",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
          ),
          actions: const [
            NotificationsButton(),
          ],
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: pages[pageIndex],
        appBar: getAppBar(context),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          selectedFontSize: 14,
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
              label: "Explorează",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              label: "Favorite",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bell),
              label: "Evenimente",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.info_circle),
              label: "Despre",
            ),
          ],
          onTap: (newIndex) => setState(() => pageIndex = newIndex),
        ),
      ),
    );
  }
}
