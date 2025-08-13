import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todo_list.dart';
import '../data/gt_api.dart';
import '../domain/todo.dart';
import '../src/get_snack_bar.dart';
import '../src/show_error_snack.dart';
import '../widgets/gt_card.dart';
import './add_todo_card_button.dart';

class TodoCard extends ConsumerStatefulWidget {
  const TodoCard({
    super.key,
    required this.todo,
    this.childTodos,
  });
  final Todo todo;
  final List<Todo>? childTodos;

  @override
  ConsumerState<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends ConsumerState<TodoCard> {
  late var isOpen = false;
  var isDeleting = false;
  var isLoadingDelete = false;
  var isLoadingToggle = false;

  Future<void> _toggleTodo(BuildContext context) async {
    setState(() {
      isLoadingToggle = true;
    });
    try {
      await ref.read(todoListProvider.notifier).updateTodo(
            listId: widget.todo.listId,
            todoId: widget.todo.id,
            isCompleted: !widget.todo.isCompleted,
          );
    } on GtApiException catch (error) {
      if (context.mounted) {
        showErrorSnack(context, error, map: {
          GtApiExceptionType.malformedBody:
              'Your todo update request is malformed.',
          GtApiExceptionType.forbidden:
              'You are not allowed to edit this todo.',
          GtApiExceptionType.unauthorized: 'You are not authorized...',
          GtApiExceptionType.unknown: 'Failed to edit todo.',
        });
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            context: context,
            content: const Text('Something went wrong.'),
            isError: true,
          ),
        );
      }
    } finally {
      setState(() {
        isLoadingToggle = false;
      });
    }
  }

  Future<void> _deleteTodo(BuildContext context) async {
    bool yes = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Todo'),
            content: const Text(
              'Are you sure you want to delete this todo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        });
    if (!yes) {
      setState(() {
        isDeleting = false;
      });
      return;
    }
    setState(() {
      isLoadingDelete = true;
    });

    try {
      await ref.read(todoListProvider.notifier).deleteTodo(
            widget.todo.listId,
            widget.todo.id,
          );
    } on GtApiException catch (error) {
      if (context.mounted) {
        showErrorSnack(context, error, map: {
          GtApiExceptionType.forbidden:
              'You are not allowed to delete todo for this list.',
          GtApiExceptionType.unauthorized: 'You are not authorized...',
          GtApiExceptionType.unknown: 'Failed to delete todo.',
        });
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            context: context,
            content: const Text('Something went wrong.'),
            isError: true,
          ),
        );
      }
    } finally {
      setState(() {
        isLoadingDelete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpandable =
        widget.childTodos != null && widget.childTodos!.isNotEmpty;
    final completeBefore = widget.todo.completeBefore;

    return TapRegion(
      onTapOutside: (_) => setState(() => isOpen = false),
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TapRegion(
              onTapOutside: (_) => setState(() => isDeleting = false),
              child: GtCard(
                isStriked: widget.todo.isCompleted && !isDeleting,
                onSecondaryTap: () => setState(() => isDeleting = !isDeleting),
                onLongPress: () => setState(() => isDeleting = !isDeleting),
                toptitle: completeBefore != null
                    ? 'Due: ${completeBefore.year}-${completeBefore.month}-${completeBefore.day}'
                    : null,
                title: widget.todo.title,
                subtitle: widget.todo.description,
                isSelected: isDeleting,
                onTap: isExpandable
                    ? () => setState(() {
                          isOpen = !isOpen;
                          isDeleting = false;
                        })
                    : null,
                trailing: isDeleting
                    ? IconButton(
                        onPressed: () async {
                          _deleteTodo(context);
                        },
                        icon: isLoadingDelete
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.delete_forever),
                        color: Theme.of(context).colorScheme.error,
                      )
                    : Row(
                        children: [
                          if (widget.childTodos != null)
                            Text(
                              '${widget.childTodos!.where((t) => t.isCompleted).length}/${widget.childTodos!.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: widget.childTodos!.length ==
                                            widget.childTodos!
                                                .where((t) => t.isCompleted)
                                                .length
                                        ? Colors.green.shade600
                                        : null,
                                  ),
                            ),
                          if (isLoadingToggle)
                            const CircularProgressIndicator(),
                          if (!isLoadingToggle)
                            IconButton(
                              onPressed: () async {
                                _toggleTodo(context);
                              },
                              icon: Icon(
                                widget.todo.isCompleted
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank,
                                color: widget.todo.isCompleted
                                    ? Colors.green.shade600
                                    : null,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            if (isOpen)
              IntrinsicHeight(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 16, 80),
                      child: VerticalDivider(
                        width: 16,
                        thickness: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ...widget.childTodos
                                  ?.map(
                                    (todo) => TodoCard(todo: todo),
                                  )
                                  .toList() ??
                              [],
                          AddTodoCardButton(
                            title: 'Add Child Todo',
                            listId: widget.todo.listId,
                            parentId: widget.todo.id,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
