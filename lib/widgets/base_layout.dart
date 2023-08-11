import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/profile/presentation/profile_screen.dart';
import 'package:spendbuddy/shared/controllers/success_snackbar.controller.dart';
import 'package:spendbuddy/shared/providers/snackbar_provider.dart';
import 'package:spendbuddy/widgets/gw_drawer.dart';

class BaseLayout extends ConsumerStatefulWidget {
  final Widget body;
  final String? title;
  final bool isScrollable;
  final bool layoutAuth;
  final MainAxisAlignment mainAxisAlignment;

  const BaseLayout({
    Key? key,
    required this.body,
    this.title,
    this.isScrollable = false,
    this.layoutAuth = false,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  ConsumerState<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends ConsumerState<BaseLayout> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final goRouter = ref.read(routerControllerProvider);

    String photoURL = authState.maybeWhen(
      data: (user) => user?.photoURL ?? '',
      orElse: () => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Flavius App'),
        actions: [
          if (widget.title == null)
            IconButton(
              icon: Icon(Icons
                  .arrow_forward), // You can choose a more appropriate icon if needed.
              onPressed: () => goRouter.go(
                  '/dashboard'), // Replace with your dashboard route location.
            ),
          if (photoURL.isNotEmpty)
            GestureDetector(
              onTap: () => goRouter.go(
                  '/profile'), // Replace with the correct profile route if different.
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 15, // Adjust the size as per your need
                  backgroundImage: NetworkImage(photoURL),
                ),
              ),
            ),
        ],
      ),
      drawer: widget.title != null ? const GWDrawer() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle your "+" button logic here
        },
        child: Icon(Icons.add),
      ),
      body: Builder(builder: (context) {
        final snackbarController =
            ref.watch(snackbarProvider); // Updated provider
        final currentMessage = snackbarController.currentMessage;
        if (currentMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Color backgroundColor;
            if (currentMessage.type == SnackbarMessageType.success) {
              backgroundColor = Theme.of(context).colorScheme.tertiary;
            } else {
              backgroundColor = Theme.of(context).colorScheme.error;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(currentMessage.message),
                backgroundColor: backgroundColor,
              ),
            );
            snackbarController.hideMessage();
          });
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.isScrollable
              ? widget.layoutAuth
                  ? LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints viewportConstraints,
                      ) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: widget.mainAxisAlignment,
                                children: <Widget>[
                                  widget.body,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : widget.body
              : widget.body,
        );
      }),
    );
  }
}
