import 'package:flutter/material.dart';

class ResponsiveAuthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveAuthContainer({
    super.key,
    required this.child,
    this.maxWidth = 500.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
