import 'package:flutter/material.dart';

class CustomStickyHeader extends StatelessWidget {
  final Widget stickyContent;
  final Widget content;
  final bool isEmpty;
  final Color color;
  final double headerHeight;
  final List<Widget> items;

  const CustomStickyHeader({
    super.key,
    required this.stickyContent,
    required this.content,
    required this.isEmpty,
    required this.color,
    required this.headerHeight,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return content;
    } else {
      return CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: headerHeight,
              maxHeight: headerHeight,
              stickyContent: stickyContent,
              color: color,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return items[index];
              },
              childCount: items.length,
            ),
          ),
        ],
      );
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget stickyContent;
  final Color color;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.stickyContent,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 18.0),
              child: stickyContent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        stickyContent != oldDelegate.stickyContent;
  }
}
