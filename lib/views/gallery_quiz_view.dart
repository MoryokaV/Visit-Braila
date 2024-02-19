import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryQuizView extends StatelessWidget {
  final String imageUrl;

  const GalleryQuizView({
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          "Test memorie vizuală",
          style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.adaptive.arrow_back),
        ),
      ),
      body: SafeArea(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
