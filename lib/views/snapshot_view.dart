import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magicscreen/widgets/camera_widget.dart';
import '../utils/config.dart';
import '../widgets/steps_widget.dart';

class SnapshotView extends StatefulWidget {
  const SnapshotView({super.key});

  @override
  State<SnapshotView> createState() => _SnapshotViewState();
}

class _SnapshotViewState extends State<SnapshotView> {
  int countDown = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countDown--;
      });

      if (countDown == 0) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // retry
  void onRetry() {
    setState(() {
      countDown = 5;
    });
    _startTimer();
  }

  void onSubmit() {
    Navigator.pushNamed(context, '/styleSelect');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Image(
              fit: BoxFit.cover,
              image: NetworkImage(
                  'https://img1.baidu.com/it/u=3001150338,397170470&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1422'),
            ),
          ),

          StepsWidget(currentStep: 0),

          Positioned(
            top: ss('10vh'),
            left: ss('${(100 - 80) / 2}vw'),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [

                SizedBox(height: ss('5rem')),

                Container(
                  height: ss('80vw'),
                  width: ss('80vw'),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(ss('50vw')),
                    border: Border.all(
                      color: Colors.white,
                      width: ss('1rem'),
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: FaceCameraWidget(),
                ),
                SizedBox(height: ss('2rem')),

                SizedBox(
                  height: ss('12rem'),
                  child: countDown > 0
                      ? Text(
                          countDown.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ss('8rem'),
                              fontWeight: FontWeight.bold,
                              // fontFamily: 'Arial',
                              fontStyle: FontStyle.italic),
                        )
                      : null,
                ),

                // tip text
                Text(
                  '请保持脸都在拍照框中',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ss('3rem'),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          if (countDown <= 0)
            Positioned(
                left: ss('10vw'),
                right: ss('10vw'),
                bottom: ss('5vh'),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: ss('100%'),
                      height: ss('8rem'),
                      child: TextButton(
                          onPressed: onSubmit,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.blue),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(ss('1rem'))))),
                          child: Text('确认',
                              style: TextStyle(
                                  fontSize: ss('3rem'),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),

                    SizedBox(height: ss('2rem')), // 设置间距

                    SizedBox(
                      width: ss('100%'),
                      height: ss('8rem'),
                      child: TextButton(
                          onPressed: onRetry,
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(ss('1rem'))))),
                          child: Text('重新拍照',
                              style: TextStyle(
                                  fontSize: ss('3rem'),
                                  color: Colors.white30,
                                  fontWeight: FontWeight.normal))),
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
