import './todo.dart';

class TodoList {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Todo> todos;

  TodoList({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.todos = const [],
  });

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      todos: (json['todos'] as List<dynamic>?)
              ?.map((todo) => Todo.fromJson(todo as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  TodoList copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Todo>? todos,
  }) {
    return TodoList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      todos: todos ?? this.todos,
    );
  }
}
