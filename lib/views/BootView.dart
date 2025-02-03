import 'package:flutter/material.dart';

import '../utils/config.dart' as config;

class BootView extends StatefulWidget {
  const BootView({super.key});

  @override
  State<BootView> createState() => _BootViewState();
}

class _BootViewState extends State<BootView> {
  bool loading = false;
  List<config.Task> tasks = [];
  config.Task? currentTask;

  void onNext() {
    Navigator.pushNamed(context, '/styleSelect');
  }

  @override
  void initState() {
    super.initState();

    // _startTasks();

    final task = config.Task(
      name: '获取数据',
      func: () async {},
    );
    task.status = "doing";
    task.progressText = "正在获取数据...";
    setState(() {
      tasks.add(task);
      currentTask = task;
    });
  }

  void onRetry() async {
    _retryCurrentTask();

    // continue
    // _startTasks();
  }

  void _retryCurrentTask() async {
    if (currentTask == null) {
      return;
    }
    setState(() {
      currentTask!.status = "doing";
    });
    await currentTask!.execute((text) {
      setState(() {
        currentTask!.progressText = text;
        tasks[tasks.indexOf(currentTask!)] = currentTask!;
      });
    });
    setState(() {
      tasks[tasks.indexOf(currentTask!)] = currentTask!;
    });
  }

  void _startTasks() async {
    setState(() {
      loading = true;
    });

    final taskList = config.tasks;
    for (int i = 0; i < taskList.length; i++) {
      if (tasks.contains(taskList[i])) {
        continue;
      }

      setState(() {
        tasks.add(taskList[i]);
        currentTask = tasks[i];
      });

      await currentTask!.execute((text) {
        setState(() {
          currentTask!.progressText = text;
          tasks[tasks.indexOf(currentTask!)] = currentTask!;

          print(currentTask!.progressText);
        });
      });

      setState(() {
        tasks[i] = currentTask!;
      });
      if (currentTask!.status == "error") {
        break;
      }
    }

    // setState(() {
    //   loading = false;
    //   onNext();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color(0xFF300a24),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Row(
                  spacing: 20,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: config.ss('1.5rem'),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: config.ss('1.5rem'),
                        color: Colors.white,
                      ),
                    ),
                    if (task.status == "doing" && task.progressText != null)
                      Text(
                        "[${task.progressText}]",
                        style: TextStyle(
                          fontSize: config.ss('1.5rem'),
                          color: Colors.white,
                        ),
                      ),
                    if (task.status == "doing")
                      SizedBox(
                        width: config.ss('1rem'),
                        height: config.ss('1rem'),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    if (task.status != "doing")
                      Text(
                        "[${task.status}]",
                        style: TextStyle(
                          fontSize: config.ss('1.5rem'),
                          color: task.status == "error"
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: config.ss('20vh'),
            left: 0,
            right: 0,
            child: Column(
              children: currentTask?.status == "error"
                  ? [
                      Text(currentTask?.errorText ?? '错误',
                          style: TextStyle(color: Colors.red)),
                      SizedBox(
                        height: config.ss('5rem'),
                        width: config.ss('20rem'),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.refresh),
                          label: Text('重试'),
                          onPressed: onRetry,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          // if (loading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
