import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todo_list.dart';
import '../data/gt_api.dart';
import '../domain/todo_list.dart' as todo_list_domain;
import '../globals.dart';
import '../presentation/todo_list_card.dart';
import '../presentation/todo_list_route.dart';
import '../presentation/todo_view.dart';
import '../src/create_gt_route.dart';
import '../src/get_snack_bar.dart';
import '../widgets/gt_card_button.dart';
import '../widgets/gt_fading_scroll_view.dart';
import '../widgets/gt_loading_button.dart';
import '../widgets/gt_loading_page.dart';
import './create_list_route.dart';
import './create_todo_route.dart';

class TodoListsView extends ConsumerStatefulWidget {
  const TodoListsView({super.key, this.actions});
  final List<Widget>? actions;

  @override
  ConsumerState<TodoListsView> createState() => _TodoListsViewState();
}

class _TodoListsViewState extends ConsumerState<TodoListsView> {
  var isRefreshing = false;
  String? selectedListId;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<todo_list_domain.TodoList>> todoLists =
        ref.watch(todoListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width > ScreenSize.large.value;
    Widget content = const GtLoadingPage();

    List<Widget> getListActions(String todoListId) {
      return [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(createGtRoute(
              context,
              CreateTodoRoute(listId: todoListId),
              emergeVertically: true,
            ));
          },
          icon: const Icon(Icons.add),
        ),
        MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert));
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                // Handle edit action
              },
              child: const Text('Edit'),
            ),
            // Delete action
            MenuItemButton(
              onPressed: () async {
                bool success = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete List'),
                          content: const Text(
                              'Are you sure you want to delete this list?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(todoListProvider.notifier)
                                      .deleteList(todoListId);
                                  if (context.mounted) {
                                    final snackBar = getSnackBar(
                                      context: context,
                                      content: const Text('List deleted.'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.of(context).pop(true);
                                  }
                                } on GtApiException catch (_) {
                                  if (context.mounted) {
                                    final snackBar = getSnackBar(
                                      context: context,
                                      content:
                                          const Text('Failed to delete list'),
                                      isError: true,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
                if (success && isDesktop) {
                  selectedListId = null; // Reset selected list on delete
                } else if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ];
    }

    if (isRefreshing || todoLists.isRefreshing || todoLists is AsyncLoading) {
      return content;
    }

    switch (todoLists) {
      case AsyncLoading():
        content = const GtLoadingPage();
        break;
      case AsyncData(:final value):
        if (isDesktop) {
          setState(() {
            selectedListId ??= value.isNotEmpty ? value.first.id : null;
          });
        }
        content = Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width > ScreenSize.large.value
                ? ScreenSize.large.value.toDouble()
                : double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 4,
                  child: GtFadingScrollView(
                    actions: isDesktop ? widget.actions : null,
                    title: isDesktop ? 'Todo Lists' : null,
                    subtitle: isDesktop ? 'Select a list to view' : null,
                    children: [
                      ...value.map((list) => TodoListCard(
                            list: list,
                            onTap: () {
                              if (isDesktop) {
                                setState(() {
                                  selectedListId = list.id;
                                });
                              } else {
                                Navigator.of(context).push(createGtRoute(
                                  context,
                                  TodoListRoute(
                                    todoListId: list.id,
                                    actions: getListActions(list.id),
                                  ),
                                  emergeVertically: true,
                                ));
                              }
                            },
                            isSelected: selectedListId == list.id && isDesktop,
                          )),
                      GtCardButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add New List',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Icon(
                              Icons.add,
                              size: 32,
                              color: colorScheme.onSurface,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(createGtRoute(
                            context,
                            const CreateListRoute(),
                            emergeVertically: true,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                if (isDesktop)
                  VerticalDivider(
                    width: 16,
                    thickness: 2,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                if (isDesktop)
                  Flexible(
                    flex: 8,
                    child: value.isNotEmpty
                        ? TodoView(
                            actions: selectedListId != null
                                ? getListActions(selectedListId ?? '')
                                : null,
                            todoList: value.firstWhere((l) {
                              if (selectedListId != null) {
                                return l.id == selectedListId;
                              }
                              return l.todos.isNotEmpty;
                            }),
                            afterDelete: () {
                              setState(() {
                                selectedListId = null;
                              });
                            },
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'No todo lists available.',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        );
        break;
      case AsyncError():
        content = SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Error loading todo lists.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              GtLoadingButton(
                  text: 'Try Again',
                  onPressed: () {
                    var _ = ref.refresh(todoListProvider);
                  }),
            ],
          ),
        );
        break;
    }
    return content;
  }
}
