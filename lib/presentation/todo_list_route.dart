import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todo_list.dart';
import '../presentation/route_scaffold.dart';
import '../presentation/todo_view.dart';

class TodoListRoute extends ConsumerWidget {
  const TodoListRoute(
      {super.key, required this.todoListId, required this.actions});
  final String todoListId;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoLists = ref.watch(todoListProvider).value!.where(
          (list) => list.id == todoListId,
        );

    return RouteScaffold(
      implyLeading: true,
      showDrawer: false,
      appBarActions: actions,
      body: todoLists.isNotEmpty
          ? TodoView(
              todoList: todoLists.first,
              afterDelete: () => Navigator.of(context).pop(),
            )
          : const Center(),
    );
  }
}
