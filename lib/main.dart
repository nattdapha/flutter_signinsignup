import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/signin_screen.dart';
import 'package:flutter_application_1/screen/signup_screen.dart';
import 'package:flutter_application_1/screen/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
        ),
        initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SigninScreen(),
        '/signup': (context) => const SignupScreen(),
        '/todo': (context) => const TodoScreen(),
      },
        home: const SigninScreen() //TodoApp(),
        );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _noteController = TextEditingController();
  }

  void addTodoHandle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task Title",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task Details",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('tasks').add({
                  'completed': false,
                  'name': _nameController.text,
                  'note': _noteController.text,
                });
                _nameController.clear();
                _noteController.clear();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  void editTodoHandle(String id, String currentName, String currentNote, bool currentStatus) {
    _nameController.text = currentName;
    _noteController.text = currentNote;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task Title",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task Details",
                ),
              ),
              CheckboxListTile(
                title: const Text("Completed"),
                value: currentStatus,
                onChanged: (value) {
                  setState(() {
                    currentStatus = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('tasks').doc(id).update({
                  'name': _nameController.text,
                  'note': _noteController.text,
                  'completed': currentStatus,
                });
                _nameController.clear();
                _noteController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void deleteTodoHandle(String id) {
    FirebaseFirestore.instance.collection('tasks').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var task = snapshot.data!.docs[index];
              var taskName = task['name'];
              var taskNote = task['note'];
              var isCompleted = task['completed'];

              return ListTile(
                title: Text(
                  taskName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                subtitle: Text(taskNote),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        editTodoHandle(task.id, taskName, taskNote, isCompleted);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteTodoHandle(task.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
                    'completed': !isCompleted,
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodoHandle(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
