import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magicscreen/widgets/StepsWidget.dart';
import '../utils/config.dart';

class StyleSelectView extends StatefulWidget {
  const StyleSelectView({super.key});

  @override
  State<StyleSelectView> createState() => _StyleSelectViewState();
}

class _StyleSelectViewState extends State<StyleSelectView> {
  int countDown = 5;
  late List<dynamic> styles;
  late Map<int, bool> selected;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _startTimer();

    styles = globalState.styles;
    selected = {};
    for (int i = 0; i < styles.length; i++) {
      selected[i] = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  void onNext() {
    Navigator.pushNamed(context, '/imageGenerator');
  }

  Widget _buildItem(int index) {
    return GestureDetector(
        onTap: () {
          /*   ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('点击了图片 $index'),
                        ),
                      );*/
          setState(() {
            selected[index] = !selected[index]!;
          });
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(ss('0.3rem')), // 图片间距
              decoration: BoxDecoration(
                border: Border.all(
                  width: ss('0.3rem'),
                  color: Colors.black,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(ss('1rem')),
                image: DecorationImage(
                  image: NetworkImage(styles[index]['picAddress']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: ss('1rem'),
              right: ss('1rem'),
              child: Checkbox(
                // tristate: true,
                value: selected[index],
                onChanged: (bool? value) {},
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StepsWidget(currentStep: 1),

          Positioned(
            left: ss('10vw'),
            right: ss('10vw'),
            top: ss('10.5vh'),
            child:  Center( child: Text('选择照片风格进行生成', style: TextStyle(fontSize: ss('2rem'),color: Colors.black54,  fontWeight: FontWeight.bold))),
          ),

          Positioned(
            left: ss('5vw'),
            right: ss('5vw'),
            top: ss('15vh'),
            height: ss('80vh'),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: ss('5vw'), // 5% 间距
                mainAxisSpacing: ss('5vw'), // 5% 间距
                childAspectRatio: 3 / 4, // 设置宽高比为 4:3
              ),
              itemCount: styles.length, // 假设有30张照片
              itemBuilder: (context, index) {
                return _buildItem(index);
              },
            ),
          ),



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
                      onPressed: onNext,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.orange),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ss('1rem'))))),
                      child: Text('确认',
                          style: TextStyle(
                              fontSize: ss('3rem'),
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
