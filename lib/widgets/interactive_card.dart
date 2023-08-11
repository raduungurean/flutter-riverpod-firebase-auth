import 'package:flutter/material.dart';

class InteractiveCard extends StatelessWidget {
  final Widget child;

  const InteractiveCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing the color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.0, // Reduced the elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                child,
              ],
            ),
          ),
          // Menu icon on top right corner
          Positioned(
            top: 8.0,
            right: 8.0,
            child: PopupMenuButton<int>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.edit,
                        color: colorScheme.primary,
                        size: 18.0, // Reduced icon size
                      ),
                      SizedBox(width: 8.0),
                      Text('Edit',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14.0, // Reduced font size
                          )),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete,
                        color: colorScheme.error,
                        size: 18.0, // Reduced icon size
                      ),
                      SizedBox(width: 8.0),
                      Text('Delete',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14.0, // Reduced font size
                          )),
                    ],
                  ),
                ),
                // ... Add more items if desired
              ],
              onSelected: (value) {
                if (value == 1) {
                  // Edit logic here
                } else if (value == 2) {
                  // Delete logic here
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
