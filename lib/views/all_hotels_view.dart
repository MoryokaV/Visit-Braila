import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class AllHotelsView extends StatefulWidget {
  const AllHotelsView({super.key});

  @override
  State<AllHotelsView> createState() => _AllHotelsViewState();
}

class _AllHotelsViewState extends State<AllHotelsView> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Odihnă și ",
              ),
              TextSpan(
                text: "Comfort",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.adaptive.arrow_back,
            color: kForegroundColor,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading ? const LoadingSpinner() : CustomScrollView(),
      ),
    );
  }
}
