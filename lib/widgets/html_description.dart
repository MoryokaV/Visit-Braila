import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/url_constants.dart';

class HtmlDescription extends StatefulWidget {
  final String data;
  final bool shrink;

  const HtmlDescription({
    super.key,
    required this.data,
    required this.shrink,
  });

  @override
  State<HtmlDescription> createState() => _HtmlDescriptionState();
}

class _HtmlDescriptionState extends State<HtmlDescription> {
  bool readMore = false;
  bool longDescription = false;

  Map<String, Style> descriptionStyle = {
    '#': Style(
      color: kForegroundColor,
      fontFamily: bodyFont,
      letterSpacing: 0.25,
    ),
    'a': Style(
      color: kPrimaryColor,
    ),
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      textAlign: TextAlign.start,
      whiteSpace: WhiteSpace.normal,
    ),
    'h1': Style(
      margin: Margins.only(bottom: 6),
      fontSize: FontSize(20.0),
    ),
    'h2': Style(
      fontSize: FontSize(17.0),
    ),
    'h3': Style(
      margin: Margins.symmetric(vertical: 6),
      fontSize: FontSize(15.5),
    ),
    'p': Style(
      fontSize: FontSize.medium,
    ),
    'p:last-child': Style(
      margin: Margins.zero,
    ),
    'br': Style(
      display: Display.none,
    )
  };

  bool isEmptyDescription() {
    return widget.data == "<p><br></p>" || widget.data.isEmpty;
  }

  void analyzeHtml() {
    var doc = HtmlParser.parseHTML(widget.data);
    // var body = doc.body!;
    var body = doc;

    if (body.children.length > 12 || body.text.length > 400) {
      longDescription = true;
    }
  }

  @override
  void initState() {
    super.initState();

    analyzeHtml();
  }

  @override
  Widget build(BuildContext context) {
    return isEmptyDescription()
        ? const Text("Nu există descriere")
        : widget.shrink && longDescription
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      height: readMore ? null : 200,
                      child: Stack(
                        children: [
                          SelectionArea(
                            child: Html(
                              // scrollPhysics: const NeverScrollableScrollPhysics(),
                              data: widget.data,
                              onLinkTap: (url, attributes, element) => openBrowserURL(url!),
                              style: descriptionStyle,
                            ),
                          ),
                          if (!readMore)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                height: 30,
                                width: Responsive.screenWidth,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: fadeEffect,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() => readMore = !readMore);
                    },
                    child: Row(
                      children: [
                        Text(
                          readMore ? "Citește mai puțin" : "Citește mai mult",
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset(
                          readMore ? "assets/icons/chevron-up.svg" : "assets/icons/chevron-down.svg",
                          colorFilter: const ColorFilter.mode(kBlackColor, BlendMode.srcIn),
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : SelectionArea(
                child: Html(
                  // scrollPhysics: const NeverScrollableScrollPhysics(),
                  data: widget.data,
                  onLinkTap: (url, attributes, element) => openBrowserURL(url!),
                  style: descriptionStyle,
                ),
              );
  }
}
