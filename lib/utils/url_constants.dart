import 'package:url_launcher/url_launcher.dart';

const baseUrl = "http://193.22.95.33:8080";
const apiUrl = "http://193.22.95.33:8080/api";
const obiectivUrl = "https://obiectivbr.ro";
const authorFacebookUrl = "https://www.facebook.com/mario.vlaviano.75";
const authorInstagramUrl = "https://www.instagram.com/mario.vlv";
const authorGithubUrl = "https://github.com/moryokav";

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
