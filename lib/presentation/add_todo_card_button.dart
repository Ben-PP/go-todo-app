import 'package:flutter/material.dart';

import '../src/create_gt_route.dart';
import '../widgets/gt_card_button.dart';
import './create_todo_route.dart';

class AddTodoCardButton extends StatelessWidget {
  const AddTodoCardButton({
    super.key,
    required this.listId,
    this.parentId,
    this.title,
  });

  final String listId;
  final String? parentId;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return GtCardButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title ?? 'Add New Todo',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Icon(
            Icons.add,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(createGtRoute(
          context,
          CreateTodoRoute(
            listId: listId,
            parentId: parentId,
          ),
          emergeVertically: true,
        ));
      },
    );
  }
}
