import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xfff1f3f5);
const Color kBlackColor = Color(0xff343a40);
const Color kForegroundColor = Color(0xff495057);
const Color kPrimaryColor = Color(0xff228be6);
const Color kSecondaryColor = Color(0xffff5a5f);
const Color kDimmedForegroundColor = Color(0xffadb5bd);
const Color kDateTimeForegroundColor = Color(0xff92a1b0);
const Color kHotelStarColor = Color(0xfffcba03);
Color kDisabledIconColor = Colors.grey[500]!;
Color lightGrey = Colors.grey[300]!;

List<Color> fadeEffect = [
  kBackgroundColor.withAlpha(0),
  kBackgroundColor.withAlpha(255),
];

const BoxShadow shadowSm = BoxShadow(
  color: Colors.black12,
  offset: Offset(0, 1),
  blurRadius: 3.5,
  spreadRadius: 3,
);

const BoxShadow bottomShadowMd = BoxShadow(
  color: Colors.black38,
  offset: Offset(0, 6),
  blurRadius: 8,
  spreadRadius: 0,
);

const BoxShadow globalShadow = BoxShadow(
  color: Colors.black12,
  offset: Offset(0, 0),
  spreadRadius: 1,
  blurRadius: 3,
);

const BoxShadow topShadow = BoxShadow(
  color: Colors.black12,
  offset: Offset(0, -1.5),
  blurRadius: 4,
  spreadRadius: 0.5,
);

const List<BoxShadow> topOnlyShadows = [
  BoxShadow(
    color: Colors.black38,
    offset: Offset(0, -2),
    blurRadius: 5,
  ),
  BoxShadow(
    color: Colors.white,
    offset: Offset(0, 2),
    spreadRadius: 2,
  ),
];

const List<BoxShadow> shadowLg = [
  BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  ),
  BoxShadow(
    color: Colors.black12,
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -4,
  ),
];

const BoxShadow tinyShadow = BoxShadow(
  color: Colors.black12,
  offset: Offset(0, 0.5),
  blurRadius: 2,
);

const String labelFont = "Inter";
const String bodyFont = "Merriweather";

class TopLeftTriangleClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    path.moveTo(0, h);
    path.lineTo(w, h);
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BottomRightTriangleClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    path.lineTo(0, h);
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}