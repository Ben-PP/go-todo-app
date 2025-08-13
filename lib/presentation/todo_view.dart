import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/todo.dart';
import '../domain/todo_list.dart' as todo_list_domain;
import '../widgets/gt_fading_scroll_view.dart';
import './add_todo_card_button.dart';
import './todo_card.dart';

class TodoView extends ConsumerWidget {
  const TodoView({
    super.key,
    required this.todoList,
    required this.afterDelete,
    this.actions,
  });
  final todo_list_domain.TodoList todoList;
  final VoidCallback afterDelete;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentTodos = <Todo>[];
    final childTodos = <Todo>[];

    for (Todo todo in todoList.todos) {
      if (todo.parentId == null) {
        parentTodos.add(todo);
      } else {
        childTodos.add(todo);
      }
    }

    return SizedBox(
      width: double.infinity,
      child: GtFadingScrollView(
        title: todoList.title,
        subtitle: todoList.description,
        actions: actions,
        children: [
          ...parentTodos.map((todo) {
            final childs =
                childTodos.where((t) => t.parentId == todo.id).toList();
            return TodoCard(
              todo: todo,
              childTodos: childs.isNotEmpty ? childs : null,
            );
          }),
          AddTodoCardButton(listId: todoList.id),
        ],
      ),
    );
  }
}
