import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/todo_model.dart';

class TodoListState extends Equatable {
  final List<Todo> todos;
  const TodoListState({
    required this.todos,
  });

  factory TodoListState.initial() {
    return TodoListState(todos: [
      Todo(id: '1', desc: '할일1'),
      Todo(id: '2', desc: '할일2'),
      Todo(id: '3', desc: '할일3'),
    ]);
  }

  @override
  String toString() => 'TodoListState(todos: $todos)';

  @override
  List<Object> get props => [todos];

  TodoListState copyWith({
    List<Todo>? todos,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
    );
  }
}

class TodoList extends StateNotifier<TodoListState> {
  TodoList() : super(TodoListState.initial());

  void addTodo(String todoDesc) {
    final newTodo = Todo(desc: todoDesc);
    final newTodos = [...state.todos, newTodo];

    state = state.copyWith(todos: newTodos);
    //디버깅
    print(state);
  }

  void editTodo(String id, String todoDesc) {
    final newTodos = state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(
          id: id,
          desc: todoDesc,
          completed: todo.completed,
        );
      }
      return todo;
    }).toList();

    state = state.copyWith(todos: newTodos);
  }

  void toggleTodo(String id) {
    final newTodos = state.todos.map((Todo todo) {
      if (todo.id == id) {
        return Todo(
          id: id,
          desc: todo.desc,
          completed: !todo.completed,
        );
      }
      return todo;
    }).toList();

    state = state.copyWith(todos: newTodos);
  }

  void removeTodo(Todo todo) {
    final newTodos = state.todos.where((Todo t) => t.id != todo.id).toList();

    state = state.copyWith(todos: newTodos);
  }
}
