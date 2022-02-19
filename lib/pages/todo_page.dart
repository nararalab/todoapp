import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                const TodoHeader(),
                CreateTodo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text(
        'TODO',
        style: TextStyle(fontSize: 40.0),
      ),
      Text(
        '${context.watch<ActiveTodoCount>().state.activeTodoCount} items left',
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.redAccent,
        ),
      ),
    ]);
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final newTodoController = TextEditingController();

  @override
  void dispose() {
    newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: newTodoController,
        decoration: const InputDecoration(labelText: '할일?'),
        onSubmitted: (String? todoDesc) {
          if (todoDesc != null && todoDesc.trim().isNotEmpty) {
            context.read<TodoList>().addTodo(todoDesc);
            newTodoController.clear();
          }
        });
  }
}
