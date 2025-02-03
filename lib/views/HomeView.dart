import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

import '../utils/config.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  void onNext() {
    Navigator.pushNamed(context, '/snapshot');
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
          Positioned(
            left: ss('10vw'),
            right: ss('10vw'),
            top: ss('20rem'),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: ss('80vw'),
                  height: ss('60vh'),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ss('1rem')),
                      border: Border.all(
                        color: Colors.white,
                        width: ss('1rem'),
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: HomeSwiperWidget(),
                  ),
                ),

                SizedBox(height: ss('4rem')),

                SizedBox(
                  width: ss('80vw'),
                  height: ss('8rem'),
                  child: TextButton.icon(
                      onPressed: onNext,
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red[300]),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ss('1rem'))))),
                      icon: Icon(Icons.camera_alt, size: ss('3rem'), color: Colors.white),
                      label: Text('开始拍照',
                          style: TextStyle(
                              fontSize: ss('3rem'),
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                )
              ],
            ),
          ),

          /*Positioned(
              left: ss('10vw'),
              right: ss('10vw'),
              top: ss('20rem'),
              bottom: ss('20rem'),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ss('1rem')),
                  border: Border.all(
                    color: Colors.white,
                    width: ss('2rem'),
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: HomeSwiperWidget(),
              )),

          Positioned(
            left: ss('10vw'),
            right: ss('10vw'),
            bottom: ss('10vh'),
            child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/snapshot');
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ss('3rem'))))),
                child: Text('开始按钮',
                    style: TextStyle(
                        fontSize: ss('3rem'),
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
          ), //Positioned*/
        ],
      ),
    );
  }
}

class HomeSwiperWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return Container(
            alignment: Alignment.center,
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.blue[100 * (index + 1)],
            child: Text('Item $index'));
      },
      itemCount: 3,
      loop: true,
      autoplay: true,
    );
  }
}
