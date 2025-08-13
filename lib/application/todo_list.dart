import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/gt_api.dart';
import '../domain/todo_list.dart' as todo_list_domain;

part 'todo_list.g.dart';

@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<todo_list_domain.TodoList>> build() async {
    await Future.delayed(const Duration(milliseconds: 200));
    var todoLists = await GtApi().getLists();
    return todoLists;
  }

  Future<void> createList({
    required String title,
    String? description,
  }) async {
    final newList = await GtApi().createList(
      title: title,
      description: description,
    );
    state = AsyncData([...state.value ?? [], newList]);
  }

  Future<void> deleteList(String listId) async {
    await GtApi().deleteList(listId);
    state = AsyncData(
      (state.value ?? []).where((list) => list.id != listId).toList(),
    );
  }

  Future<void> createTodo({
    required String listId,
    required String title,
    String? description,
    DateTime? completeBefore,
    String? parentId,
  }) async {
    final newTodo = await GtApi().createTodo(
      listId: listId,
      title: title,
      description: description,
      completeBefore: completeBefore,
      parentId: parentId,
    );
    final updatedLists = state.value?.map((list) {
      if (list.id == listId) {
        return list.copyWith(todos: [...list.todos, newTodo]);
      }
      return list;
    }).toList();
    state = AsyncData(updatedLists ?? []);
  }

  Future<void> updateTodo({
    required String listId,
    required String todoId,
    String? title,
    String? description,
    DateTime? completeBefore,
    bool? isCompleted,
  }) async {
    final updatedTodo = await GtApi().updateTodo(
      listId: listId,
      todoId: todoId,
      title: title,
      description: description,
      completeBefore: completeBefore,
      isCompleted: isCompleted,
    );
    final updatedLists = state.value?.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          todos: list.todos.map((todo) {
            return todo.id == todoId ? updatedTodo : todo;
          }).toList(),
        );
      }
      return list;
    }).toList();
    state = AsyncData(updatedLists ?? []);
  }

  Future<void> deleteTodo(String listId, String todoId) async {
    await GtApi().deleteTodo(listId: listId, todoId: todoId);
    final updatedLists = state.value?.map((list) {
      if (list.id == listId) {
        return list.copyWith(
          todos: list.todos.where((todo) => todo.id != todoId).toList(),
        );
      }
      return list;
    }).toList();
    state = AsyncData(updatedLists ?? []);
  }
}
