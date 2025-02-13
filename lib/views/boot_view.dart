import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    // Navigator.pushNamed(context, '/snapshot');
  }

  @override
  void initState() {
    super.initState();

    _startTasks();

    /* final task = config.Task(
      name: '获取数据',
      func: () async {},
    );
    task.status = "doing";
    task.progressText = "正在获取数据...";
    setState(() {
      tasks.add(task);
      currentTask = task;
    });*/
  }

  void onRetry() async {
    await _retryCurrentTask();

    if (currentTask == null || currentTask!.status == config.Task.statusDone) {
      // continue
      await _startTasks();
    }
  }

  _retryCurrentTask() async {
    var task = currentTask!;
    setState(() {
      task.status = config.Task.statusDoing;
    });
    await task.execute((text) {
      setState(() {
        task.progressText = text;
      });
    });
    setState(() {});
  }

  _startTasks() async {
    setState(() {
      loading = true;
    });

    final taskList = config.tasks;
    for (int i = 0; i < taskList.length; i++) {
      if (tasks.contains(taskList[i])) {
        continue;
      }

      tasks.add(taskList[i]);
      currentTask = tasks[i];

      setState(() {});

      await currentTask!.execute((text) {
        setState(() {
          currentTask!.progressText = text;
          tasks[tasks.indexOf(currentTask!)] = currentTask!;
        });
      });

      if (currentTask!.status == config.Task.statusError) {
        break;
      }
    }

    setState(() {
      loading = false;
      onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    var dateFormat = DateFormat("HH:mm:ss");

    return Scaffold(
      body: DefaultTextStyle(
        style: TextStyle(
          fontSize: config.ss('1.5rem'),
          // fontFamily: '微软雅黑',
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: config.ss("4rem")),
              color: Color(0xFF300a24),
              child: ListView.builder(
                padding: EdgeInsets.all(config.ss("2rem")),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Row(
                    spacing: 10,
                    children: [
                      Text(
                        "[${dateFormat.format(task.beginAt!)}]",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                      Text(
                        task.name,
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                      if (task.status == config.Task.statusDoing &&
                          task.progressText != null)
                        Text("[${task.progressText}]"),
                      if (task.status == config.Task.statusDoing)
                        SizedBox(
                          width: config.ss('1.5rem'),
                          height: config.ss('1.5rem'),
                          child: CircularProgressIndicator(
                            strokeAlign: BorderSide.strokeAlignInside,
                            strokeWidth: config.ss("0.2rem"),
                            color: Colors.amber,
                          ),
                        ),
                      if (task.status != config.Task.statusDoing)
                        Text(
                          "[${task.status == config.Task.statusDone ? 'ok' : task.status}]",
                          style: TextStyle(
                            color: task.status == config.Task.statusError
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      if (task.status == config.Task.statusDone)
                        Text("${task.usedTime!}ms",
                            style: TextStyle(color: Colors.white54))
                    ],
                  );
                },
              ),
            ),
            Positioned(
                top: config.ss("2rem"),
                left: config.ss("2rem"),
                right: 0,
                child: Text("大屏启动开始", style: TextStyle(color: Colors.white))),
            Positioned(
                bottom: config.ss("2rem"),
                left: config.ss("2rem"),
                right: 0,
                child: Text("©北京天翔睿翼科技有限公司",
                    style: TextStyle(
                        color: Colors.white, fontSize: config.ss("1rem")))),
            Positioned(
              bottom: config.ss('20vh'),
              left: 0,
              right: 0,
              child: Column(
                children: currentTask?.status == config.Task.statusError
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
            if (loading)
              Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              )),
          ],
        ),
      ),
    );
  }
}
