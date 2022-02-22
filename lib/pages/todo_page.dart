import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_model.dart';
import '../providers/providers.dart';
import '../utils/debounce.dart';

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
                const CreateTodo(),
                const SizedBox(height: 20.0),
                SearchAndFilterTodo(),
                const ShowTodos(),
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
        '${context.watch<ActiveTodoCountState>().activeTodoCount} items left',
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

class SearchAndFilterTodo extends StatelessWidget {
  SearchAndFilterTodo({Key? key}) : super(key: key);
  final debounce = Debounce(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '검색',
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (String? newSearchTerm) {
            if (newSearchTerm != null) {
              debounce.run(() {
                context.read<TodoSearch>().setSearchTerm(newSearchTerm);
              });
            }
          },
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            filterButton(context, Filter.all),
            filterButton(context, Filter.active),
            filterButton(context, Filter.completed),
          ],
        ),
      ],
    );
  }

  Widget filterButton(BuildContext context, Filter filter) {
    return TextButton(
      onPressed: () {
        context.read<TodoFilter>().changeFilter(filter);
      },
      child: Text(
        filter == Filter.all
            ? 'All'
            : filter == Filter.active
                ? 'Active'
                : 'completed',
        style: TextStyle(
          fontSize: 18.0,
          color: textColor(context, filter),
        ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    final currentFilter = context.watch<TodoFilterState>().filter;
    return currentFilter == filter ? Colors.blue : Colors.grey;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodosState>().filteredTodos;

    Widget showBackground(int direction) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        color: Colors.red,
        alignment:
            direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          size: 30.0,
          color: Colors.white,
        ),
      );
    }

    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: todos.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(color: Colors.grey);
      },
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: ValueKey(todos[index].id),
          background: showBackground(0),
          secondaryBackground: showBackground(1),
          onDismissed: (_) {
            context.read<TodoList>().removeTodo(todos[index]);
          },
          confirmDismiss: (_) {
            return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('경고'),
                    content: const Text('삭제할까요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('아니요'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('네'),
                      ),
                    ],
                  );
                });
          },
          child: TodoItem(todo: todos[index]),
        );
      },
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;

  const TodoItem({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            bool _error = false;
            textEditingController.text = widget.todo.desc;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text('수정'),
                  content: TextField(
                    controller: textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      errorText: _error ? '널' : null,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _error =
                              textEditingController.text.isEmpty ? true : false;
                          if (!_error) {
                            context.read<TodoList>().editTodo(
                                  widget.todo.id,
                                  textEditingController.text,
                                );
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: const Text('수정'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      leading: Checkbox(
        value: widget.todo.completed,
        onChanged: (bool? checked) {
          context.read<TodoList>().toggleTodo(widget.todo.id);
        },
      ),
      title: Text(widget.todo.desc),
    );
  }
}
