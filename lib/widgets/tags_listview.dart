import 'package:flutter/material.dart';
import 'package:visit_braila/utils/style.dart';

class TagsListView extends StatelessWidget {
  final List<String> tags;
  final int selectedIndex;
  final Function(int) onTagPressed;
  final double hPadding;

  const TagsListView({
    super.key,
    required this.tags,
    required this.selectedIndex,
    required this.onTagPressed,
    required this.hPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        itemCount: tags.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 10,
          );
        },
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: isSelected ? kBlackColor : lightGrey,
              foregroundColor: isSelected ? Colors.white : kForegroundColor,
              textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isSelected ? Colors.white : kForegroundColor,
                  ),
              shape: const StadiumBorder(),
            ),
            onPressed: () => onTagPressed(index),
            child: Text(
              tags[index],
            ),
          );
        },
      ),
    );
  }
}
