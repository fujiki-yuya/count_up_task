import 'package:flutter/material.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  final List<String> _taskList = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    //　未入力であればリスト追加できず、追加済みのテキストと同じテキストは追加できない
    if (_taskController.text.isNotEmpty &&
        !_taskList.contains(_taskController.text)) {
      setState(() {
        _taskList.add(_taskController.text);
        _taskController.clear();
      });
    } else if (_taskList.contains(_taskController.text)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('エラー'),
              content: const Text('このタスクはすでに追加されています。'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                )
              ],
            );
          });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _taskList.removeAt(index);
    });
  }

  //　テキストを押すと編集できる
  void _editTask(int index) {
    String selectTask = _taskList[index];
    TextEditingController editController =
        TextEditingController(text: selectTask);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('編集'),
          content: TextField(
            controller: editController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 同じタスク名が存在しない場合にのみ、タスクを更新
                if (!_taskList.contains(editController.text)) {
                  setState(() {
                    selectTask = editController.text;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('このタスクはすでに追加されています'),
                    ),
                  );
                }
              },
              child: const Text('保存'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDoアプリ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'タスクを入力してください',
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: _addTask,
                  child: const Text('追加'),
                ),
              ],
            ),
          ),

          // ToDoリストを表示する
          Expanded(
            child: ListView.builder(
              itemCount: _taskList.length,
              itemBuilder: (context, index) {
                String task = _taskList[index];
                return ListTile(
                  title: Text(task),
                  onTap: () => _editTask(index),
                  trailing: IconButton(
                    icon: const Text('削除'),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
