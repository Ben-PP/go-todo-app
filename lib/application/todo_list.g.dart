// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoList)
final todoListProvider = TodoListProvider._();

final class TodoListProvider
    extends $AsyncNotifierProvider<TodoList, List<todo_list_domain.TodoList>> {
  TodoListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoListHash();

  @$internal
  @override
  TodoList create() => TodoList();
}

String _$todoListHash() => r'af7280c3c552a1937af84f87b8bf5040919eec61';

abstract class _$TodoList
    extends $AsyncNotifier<List<todo_list_domain.TodoList>> {
  FutureOr<List<todo_list_domain.TodoList>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<todo_list_domain.TodoList>>,
              List<todo_list_domain.TodoList>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<todo_list_domain.TodoList>>,
                List<todo_list_domain.TodoList>
              >,
              AsyncValue<List<todo_list_domain.TodoList>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
