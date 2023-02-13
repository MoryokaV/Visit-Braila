import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/responsive.dart';

class CachedApiImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? cacheWidth;
  final double? cacheHeight;
  final BoxFit? fit;
  final bool blur;

  const CachedApiImage(
      {super.key,
      required this.imageUrl,
      this.cacheWidth,
      this.cacheHeight,
      this.width,
      this.height,
      this.fit,
      required this.blur});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      memCacheWidth: cacheWidth == null ? null : (cacheWidth! * Responsive.pixelRatio).round(),
      memCacheHeight: cacheHeight == null ? null : (cacheHeight! * Responsive.pixelRatio).round(),
      fadeOutDuration: const Duration(milliseconds: 600),
      fadeInDuration: const Duration(milliseconds: 250),
      fit: fit ?? BoxFit.cover,
    );
    // return OctoImage(
    //   image: CachedNetworkImageProvider(
    //     imageUrl,
    //   ),
    //   width: width,
    //   height: height,
    //   placeholderBuilder: !blur
    //       ? null
    //       : OctoPlaceholder.blurHash(
    //           "LdGS.Ue7JDsl?^rWR.adEns*sRWX",
    //           fit: fit ?? BoxFit.cover,
    //         ),
    //   fit: fit ?? BoxFit.cover,
    //   memCacheWidth: cacheWidth == null ? null : (cacheWidth! * Responsive.pixelRatio).round(),
    //   memCacheHeight: cacheHeight == null ? null : (cacheHeight! * Responsive.pixelRatio).round(),
    //   fadeOutDuration: const Duration(milliseconds: 600),
    //   fadeInDuration: const Duration(milliseconds: 250),
    // );
  }
}

class CachedAssetImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? cacheWidth;
  final double? cacheHeight;

  const CachedAssetImage(
    this.imageUrl, {
    super.key,
    this.cacheWidth,
    this.cacheHeight,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      cacheWidth: cacheWidth == null ? null : (cacheWidth! * Responsive.pixelRatio).round(),
      cacheHeight: cacheHeight == null ? null : (cacheHeight! * Responsive.pixelRatio).round(),
      fit: BoxFit.cover,
    );
  }
}
