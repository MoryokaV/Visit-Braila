import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const baseUrl = "https://visit.bjbraila.ro";
const apiUrl = "https://visit.bjbraila.ro/api";
const obiectivUrl = "https://obiectivbr.ro";
const authorFacebookUrl = "https://www.facebook.com/mario.vlaviano.75";
const authorInstagramUrl = "https://www.instagram.com/mario.vlv";
const authorGithubUrl = "https://github.com/moryokav";

Future<void> trustServer() async {
  ByteData data = await PlatformAssetBundle().load('assets/certs/isrgrootx1.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
}

void openBrowserURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw "Could not launch $url";
  }
}

void openTel(String phone) async {
  Uri url = Uri.parse("tel:$phone");

  if (await canLaunchUrl(url)) {
    launchUrl(url);
  }
}

void openEmail(String email) async {
  Uri url = Uri.parse("mailto:$email");

  try {
    await launchUrl(url);
  } catch (_) {
    return;
  }
}
