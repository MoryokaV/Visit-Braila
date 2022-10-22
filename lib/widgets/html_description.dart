import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/url_constants.dart';

class HtmlDescription extends StatefulWidget {
  final String data;

  const HtmlDescription({
    super.key,
    required this.data,
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
    ),
    'a': Style(
      color: kPrimaryColor,
    ),
    'body': Style(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      textAlign: TextAlign.justify,
      whiteSpace: WhiteSpace.NORMAL,
    ),
    'h1': Style(
      fontSize: FontSize.xLarge,
    ),
    'h2': Style(
      fontSize: FontSize.larger,
    ),
    'h3': Style(
      fontSize: FontSize.large,
    ),
    'p': Style(
      margin: const EdgeInsets.only(bottom: 6),
      fontSize: FontSize.medium,
    ),
  };

  RegExp htmlTagsRegExp = RegExp(
    r"<[^>]*>",
    multiLine: true,
    caseSensitive: true,
  );

  @override
  void initState() {
    super.initState();

    final int lines = widget.data.split("<p").length - 1;
    final int chars = widget.data.replaceAll(htmlTagsRegExp, '').length;

    if (lines > 15 || chars > 400) {
      longDescription = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return longDescription
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
                child: SizedBox(
                  height: readMore ? null : 200,
                  child: Stack(
                    children: [
                      SelectableHtml(
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                        data: widget.data,
                        onLinkTap: (url, context, attributes, element) =>
                            openBrowserURL(url!),
                        style: descriptionStyle,
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
                                colors: [
                                  kBackgroundColor.withAlpha(100),
                                  kBackgroundColor.withAlpha(255),
                                ],
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
                      style: Theme.of(context).textTheme.button!.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      readMore
                          ? FeatherIcons.chevronUp
                          : FeatherIcons.chevronDown,
                      color: kBlackColor,
                      size: 20,
                    )
                  ],
                ),
              ),
            ],
          )
        : SelectableHtml(
            scrollPhysics: const NeverScrollableScrollPhysics(),
            data: widget.data,
            onLinkTap: (url, context, attributes, element) =>
                openBrowserURL(url!),
            style: descriptionStyle,
          );
  }
}
