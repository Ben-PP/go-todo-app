import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './route_scaffold.dart';
import '../application/todo_list.dart' as todo_list_provider;
import '../data/gt_api.dart';
import '../domain/todo_list.dart';
import '../src/get_snack_bar.dart';
import '../src/show_error_snack.dart';
import '../widgets/gt_small_width_container.dart';
import '../widgets/gt_text_field.dart';

class EditListRoute extends ConsumerStatefulWidget {
  const EditListRoute({super.key, required this.todoList});
  final TodoList todoList;

  @override
  ConsumerState<EditListRoute> createState() => _EditListRouteState();
}

class _EditListRouteState extends ConsumerState<EditListRoute> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  var isLoading = false;

  @override
  void initState() {
    final todoList = ref
        .read(todo_list_provider.todoListProvider)
        .value
        ?.firstWhere((list) => list.id == widget.todoList.id);
    titleController.text = todoList!.title;
    descriptionController.text = todoList.description ?? '';
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateList(BuildContext context) async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty) {
      final snackBar = getSnackBar(
        context: context,
        isError: true,
        content: const Text('Title cannot be empty'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ref
          .read(todo_list_provider.todoListProvider.notifier)
          .updateList(
            listId: widget.todoList.id,
            title: title,
            description: description.isEmpty ? null : description,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            context: context,
            content: const Text('List was updated!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } on GtApiException catch (error) {
      if (context.mounted) {
        showErrorSnack(
          context,
          error,
          map: {
            GtApiExceptionType.malformedBody:
                'Something was odd in the request. They say it was malformed.',
            GtApiExceptionType.unauthorized:
                'Hey! This action is not for unauthorized users.',
            GtApiExceptionType.serverError:
                'The server is having a bad day. Please try again later.',
            GtApiExceptionType.unknownResponse:
                'We do not know what the response meant.',
            GtApiExceptionType.hostNotResponding:
                'The server is not responding. Please check your connection.',
          },
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            context: context,
            content: const Text(
              'This error was not handled at all. Fix the thrash...',
            ),
            isError: true,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RouteScaffold(
      implyLeading: true,
      showDrawer: false,
      title: const Text('Edit List'),
      body: GtSmallWidthContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.todoList.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.todoList.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GtTextField(
                      controller: titleController,
                      maxLength: 40,
                      hint: 'List name',
                      label: 'List name',
                      filled: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GtTextField(
                      controller: descriptionController,
                      maxLength: 150,
                      hint: 'List description',
                      label: 'List description',
                      filled: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _updateList(context),
                        child: const Text('Update'),
                      ),
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
