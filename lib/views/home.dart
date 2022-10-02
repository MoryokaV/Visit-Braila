import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:visit_braila/constants.dart';
import 'package:visit_braila/responsive.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: Responsive.safePaddingTop,
                color: Colors.black,
              ),
              Stack(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset("assets/images/braila_night.jpg"),
                      Positioned(
                        bottom: 0,
                        child: FractionalTranslation(
                          translation: const Offset(0, 0.5),
                          child: Container(
                            width: Responsive.screenWidth / 1.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white,
                              boxShadow: const [shadowSm],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.search,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Unde vrei să mergi?",
                                      style: TextStyle(
                                        color: kDimmedForegroundColor,
                                        fontFamily: "Merriweather",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 24),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Brăila",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: " - un oraș istoric de pe malul Dunării",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Merriweather",
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 38,
                  left: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                        right: 16,
                      ),
                      child: Text(
                        "Inspirație pentru următoarea ta călătorie",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        height: Responsive.safeBlockVertical * 35,
                        child: ListView.separated(
                          itemCount: 4,
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              width: 10,
                            );
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              width: Responsive.safeBlockHorizontal * 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: const [shadowSm],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        boxShadow: [shadowSm],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          "assets/images/braila_night.jpg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 6),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: const [
                                            Flexible(
                                              child: Text(
                                                "Teatrul Maria Filotti",
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: null,
                                              constraints: BoxConstraints(),
                                              icon: Icon(
                                                CupertinoIcons.heart,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FeatherIcons.mapPin,
                                              size: 18,
                                              color: kDisabledIconColor,
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            const Text(
                                              "2km depărtare",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                        right: 16,
                      ),
                      child: Text(
                        "Descoperă locuri și oameni",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                        right: 12,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              "assets/images/republicii.jpg",
                              height: Responsive.safeBlockVertical * 30,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Fă o plimbare",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    primary: Colors.white,
                                    onPrimary: Colors.black,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  child: const Text("Tururi"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                        right: 12,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              "assets/images/biserica_greceasca.jpg",
                              height: Responsive.safeBlockVertical * 30,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Explorează noi culturi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    primary: Colors.white,
                                    onPrimary: Colors.black,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  child: const Text("Atracții"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
