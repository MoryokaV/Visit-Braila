import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';

class SearchListField extends StatelessWidget {
  final void Function(String) onChanged;
  const SearchListField({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        hintMaxLines: 1,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 8,
        ),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 38,
        ),
        hintText: "Caută",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        hintStyle: Theme.of(context).textTheme.bodyText1,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0),
          child: Icon(
            CupertinoIcons.search,
            size: 20,
            color: kForegroundColor,
          ),
        ),
        fillColor: lightGrey,
      ),
    );
  }
}
