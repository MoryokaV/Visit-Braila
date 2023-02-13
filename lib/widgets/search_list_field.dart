import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';

class SearchListField extends StatefulWidget {
  final void Function(String) onChanged;
  const SearchListField({
    super.key,
    required this.onChanged,
  });

  @override
  State<SearchListField> createState() => _SearchListFieldState();
}

class _SearchListFieldState extends State<SearchListField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightGrey,
        isDense: true,
        hintMaxLines: 1,
        contentPadding: EdgeInsets.zero,
        prefixIconConstraints: const BoxConstraints(
          minHeight: 38,
        ),
        suffixIconConstraints: const BoxConstraints(
          maxHeight: 38,
        ),
        hintText: "Caută",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        hintStyle: Theme.of(context).textTheme.bodyLarge,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0),
          child: Icon(
            CupertinoIcons.search,
            size: 20,
            color: kForegroundColor,
          ),
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                splashRadius: 1,
                onPressed: () {
                  _controller.clear();
                  widget.onChanged("");
                },
                icon: const Icon(
                  Icons.clear_rounded,
                  color: kForegroundColor,
                ),
              )
            : null,
      ),
    );
  }
}
