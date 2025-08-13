import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/authentication_provider.dart';
import '../application/todo_list.dart';
import '../globals.dart';
import '../src/create_gt_route.dart';
import '../widgets/gt_loading_page.dart';
import './auth_view/login_view.dart';
import './auth_view/retry_refresh_view.dart';
import './create_list_route.dart';
import './route_scaffold.dart';
import './todo_lists_view.dart';

class HomeRoute extends ConsumerWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width > ScreenSize.large.value;
    final addListButton = IconButton(
      onPressed: () {
        Navigator.of(context).push(
          createGtRoute(
            context,
            const CreateListRoute(),
            emergeVertically: true,
          ),
        );
      },
      icon: const Icon(Icons.add),
    );
    var authState = ref.watch(authenticationProvider);
    var hasAuthError = authState == AuthState.error;

    if (hasAuthError) {
      return const RetryRefreshRoute();
    } else if (authState == AuthState.pending) {
      return const RouteScaffold(body: GtLoadingPage());
    }

    return RouteScaffold(
      appBarActions: [
        if (authState == AuthState.authenticated)
          IconButton(
              onPressed: () {
                ref.invalidate(todoListProvider);
              },
              icon: const Icon(Icons.refresh)),
        if (authState == AuthState.authenticated && !isDesktop) addListButton,
      ],
      body: authState != AuthState.unauthenticated
          ? TodoListsView(
              actions:
                  authState == AuthState.authenticated ? [addListButton] : null,
            )
          : const LoginView(),
    );
  }
}
