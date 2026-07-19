
import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const PageContainer({super.key, required this.child, this.maxWidth = 1200, this.padding = const EdgeInsets.all(32)});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24),
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 12))
            ]
          ),
          child: child,
        ),
      ),
    );
  }
}
