import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xfff1f3f5);
const Color kBlackColor = Color(0xff343a40);
const Color kForegroundColor = Color(0xff495057);
const Color kPrimaryColor = Color(0xff228be6);
const Color kSecondaryColor = Color(0xffff5a5f);
const Color kDimmedForegroundColor = Color(0xffadb5bd);
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

const String labelFont = "Inter";
const String bodyFont = "Merriweather";