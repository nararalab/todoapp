import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/todo_model.dart';
import 'todo_list.dart';

class ActiveTodoCountState extends Equatable {
  final int activeTodoCount;
  const ActiveTodoCountState({
    required this.activeTodoCount,
  });

  factory ActiveTodoCountState.initial() {
    return const ActiveTodoCountState(activeTodoCount: 0);
  }

  @override
  List<Object> get props => [activeTodoCount];

  ActiveTodoCountState copyWith({
    int? activeTodoCount,
  }) {
    return ActiveTodoCountState(
      activeTodoCount: activeTodoCount ?? this.activeTodoCount,
    );
  }

  @override
  String toString() =>
      'ActiveTodoCountState(activeTodoCount: $activeTodoCount)';
}

class ActiveTodoCount extends StateNotifier<ActiveTodoCountState>
    with LocatorMixin {
  ActiveTodoCount() : super(ActiveTodoCountState.initial());

  @override
  void update(Locator watch) {
    final List<Todo> todos = watch<TodoListState>().todos;
    state = state.copyWith(
      activeTodoCount:
          todos.where((Todo todo) => !todo.completed).toList().length,
    );
    super.update(watch);
  }
}
