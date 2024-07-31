import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double containerWidth;

        if (maxWidth >= 600) {
          containerWidth = maxWidth * 0.45;
        } else {
          containerWidth = maxWidth * 0.8;
        }

        return SizedBox(width: containerWidth, child: child);
      },
    );
  }
}

class ResponsiveBox extends StatelessWidget {
  final Widget child;
  const ResponsiveBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double containerWidth;

        if (maxWidth >= 600) {
          containerWidth = maxWidth * 0.65;
        } else {
          containerWidth = maxWidth * 0.95;
        }
        return SizedBox(width: containerWidth, child: child);
      },
    );
  }
}

class ResponsiveCourse extends StatelessWidget {
  final Widget child;
  const ResponsiveCourse({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = constraints.maxHeight;
        double maxWidth = constraints.maxWidth;

        double containerHeight;

        if (maxWidth >= 600) {
          containerHeight = maxHeight * 0.5; // Tablet height
        } else {
          containerHeight = maxHeight * 0.8; // Mobile height
        }
        return SizedBox(height: containerHeight, child: child);
      },
    );
  }
}
