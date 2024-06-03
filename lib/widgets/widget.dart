import 'package:flutter/material.dart';
import 'dart:async';

class Todo {
  String title;
  bool isCompleted;

  Todo({
    required this.title,
    this.isCompleted = false,
  });
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _todoController = StreamController<List<Todo>>();
  final List<Todo> _todos = [];

  @override
  void dispose() {
    _todoController.close();
    super.dispose();
  }

  void _addTodo(String title) {
    final todo = Todo(
      title: title,
      isCompleted: false,
    );
    setState(() {
      _todos.add(todo);
    });
    _todoController.sink.add(_todos);
  }

  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
    _todoController.sink.add(_todos);
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _todoController.sink.add(_todos);
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Escribe una nueva tarea.',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addTodo(value);
                  textController.clear();
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: _todoController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tareas disponibles.'));
                }
                final todos = snapshot.data!;
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        todos[index].title,
                        style: TextStyle(
                          decoration: todos[index].isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: todos[index].isCompleted,
                        onChanged: (_) {
                          _toggleTodoStatus(index);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodo(index);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
