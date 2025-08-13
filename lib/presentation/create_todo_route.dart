import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todo_list.dart';
import '../data/gt_api.dart';
import '../src/get_snack_bar.dart';
import '../src/show_error_snack.dart';
import '../widgets/gt_loading_button.dart';
import '../widgets/gt_small_width_container.dart';
import '../widgets/gt_text_field.dart';
import './route_scaffold.dart';

class CreateTodoRoute extends ConsumerStatefulWidget {
  const CreateTodoRoute({super.key, required this.listId, this.parentId});
  final String listId;
  final String? parentId;

  @override
  ConsumerState<CreateTodoRoute> createState() => _CreateTodoRouteState();
}

class _CreateTodoRouteState extends ConsumerState<CreateTodoRoute> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate;
  var isLoading = false;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  void addTodo(BuildContext context) async {
    var title = titleController.text.trim();
    String? description = descriptionController.text.trim().isNotEmpty
        ? descriptionController.text.trim()
        : null;
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar(
          context: context,
          content: const Text('Title cannot be empty'),
          isError: true,
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(todoListProvider.notifier).createTodo(
            listId: widget.listId,
            title: title,
            description: description,
            completeBefore: selectedDate,
            parentId: widget.parentId,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            context: context,
            content: const Text('Todo created successfully'),
          ),
        );
        Navigator.of(context).pop();
      }
    } on GtApiException catch (error) {
      if (context.mounted) {
        showErrorSnack(context, error, map: {
          GtApiExceptionType.malformedBody: 'Your todo request is malformed.',
          GtApiExceptionType.forbidden:
              'You are not allowed to create todo for this list.',
          GtApiExceptionType.unauthorized: 'You are not authorized...',
          GtApiExceptionType.unknown: 'Failed to create todo.',
        });
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
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
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RouteScaffold(
      implyLeading: true,
      showDrawer: false,
      title: const Text('New TODO'),
      body: GtSmallWidthContainer(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Create a new TODO item',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Form(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GtTextField(
                      controller: titleController,
                      filled: true,
                      label: 'Title',
                      hint: 'Title of the TODO',
                      maxLength: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GtTextField(
                      controller: descriptionController,
                      filled: true,
                      label: 'Description',
                      hint: 'Description of the TODO',
                      maxLength: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Text('Due date:', style: textTheme.labelLarge),
                        const SizedBox(width: 20),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                              : 'Not set',
                          style: textTheme.labelLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            var date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => setState(() => selectedDate = null),
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            child: GtLoadingButton(
                                text: 'Cancel',
                                onPressed: () => Navigator.of(context).pop()),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            child: GtLoadingButton(
                                isLoading: isLoading,
                                text: 'Add Todo',
                                onPressed: () => addTodo(context)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
