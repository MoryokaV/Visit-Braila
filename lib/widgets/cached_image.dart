import 'package:flutter/material.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedApiImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double? cacheWidth;
  final double? cacheHeight;
  final BoxFit? fit;
  final String? blurhash;

  const CachedApiImage({
    super.key,
    required this.imageUrl,
    this.cacheWidth,
    this.cacheHeight,
    this.width,
    this.height,
    this.fit,
    this.blurhash,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      memCacheWidth: cacheWidth == null ? null : (cacheWidth! * Responsive.pixelRatio).round(),
      memCacheHeight: cacheHeight == null ? null : (cacheHeight! * Responsive.pixelRatio).round(),
      fit: fit ?? BoxFit.cover,
      placeholder: blurhash == null
          ? null
          : (_, __) {
              return SizedBox.expand(
                child: Image(
                  image: BlurHashImage(
                    blurhash!,
                  ),
                  fit: fit ?? BoxFit.cover,
                ),
              );
            },
    );
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
