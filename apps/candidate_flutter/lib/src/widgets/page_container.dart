import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.all(48.0),
          decoration: BoxDecoration(
            color: AppColors.containerBackground,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
