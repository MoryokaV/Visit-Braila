import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// const baseUrl = "https://visit.bjbraila.ro";
// const apiUrl = "https://visit.bjbraila.ro/api";

const baseUrl = "http://localhost:3000";
const apiUrl = "http://localhost:3000/api";

const privacyPolicyUrl = "https://visit.bjbraila.ro/privacy";
const obiectivUrl = "https://obiectivbr.ro";
const authorFacebookUrl = "https://www.facebook.com/mario.vlaviano.75";
const authorInstagramUrl = "https://www.instagram.com/mario.vlv";
const authorLinkedInUrl = "https://www.linkedin.com/in/mario-alexandru-vlaviano-6b3798289/";
const brTranporIOSUrl = "https://apps.apple.com/ro/app/braila-transport-public/id1471991385";
const brTranportAndroidUrl = "https://play.google.com/store/apps/details?id=com.modeshift.braila";
const brBoatUrl = "https://stplcapbraila.ro/new/index.php/plimbari-pe-dunare/";

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
