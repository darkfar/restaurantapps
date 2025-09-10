// lib/ui/widgets/description_widget.dart
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class DescriptionWidget extends StatelessWidget {
  final String description;
  final int trimLines;
  final TextStyle? style;

  const DescriptionWidget({
    super.key,
    required this.description,
    this.trimLines = 4,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      description,
      trimLines: trimLines,
      colorClickableText: Theme.of(context).primaryColor,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' Baca selengkapnya',
      trimExpandedText: ' Tutup',
      style: style ?? const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
      moreStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
      lessStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}