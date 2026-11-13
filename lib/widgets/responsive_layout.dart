import 'package:flutter/material.dart';

/// Reusable Widget 1: ResponsiveLayout & ResponsiveCollectionView
/// Mengelola 2 kondisi layar utama:
/// - Compact (< 600px, layar smartphone portrait)
/// - Wide / Expanded (>= 600px, tablet, foldables, desktop/web, atau landscape)
class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget wide;
  static const double breakpoint = 600.0;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    required this.wide,
  });

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < breakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= breakpoint;

  static int getGridColumns(double width) {
    if (width >= 1100) return 4;
    if (width >= 840) return 3;
    if (width >= breakpoint) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return wide;
        }
        return compact;
      },
    );
  }
}

/// Widget yang otomatis mengubah tampilan dari ListView (saat layar Compact)
/// menjadi GridView multi-kolom (saat layar Wide / Expanded).
class ResponsiveCollectionView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index, bool isWide)
      itemBuilder;
  final EdgeInsetsGeometry padding;
  final double mainAxisExtent;

  const ResponsiveCollectionView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.mainAxisExtent = 250,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= ResponsiveLayout.breakpoint;

        if (!isWide) {
          return ListView.separated(
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => itemBuilder(context, index, false),
          );
        }

        final columns = ResponsiveLayout.getGridColumns(width);
        return GridView.builder(
          padding: padding,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (context, index) => itemBuilder(context, index, true),
        );
      },
    );
  }
}
