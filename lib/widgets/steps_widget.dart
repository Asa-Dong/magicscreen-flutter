import 'package:flutter/material.dart';
import '../utils/config.dart';

class StepsWidget extends StatelessWidget {
  final int currentStep;

  StepsWidget({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: ss('5vh'),
      left: ss('5vw'),
      right: ss('5vw'),
      child: Container(
        width: ss('100vw'),
        decoration: BoxDecoration(
          color: Colors.orange[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStep('拍照', 0),
            _buildStep('选择风格', 1),
            _buildStep('照片生成', 2),
            _buildStep('购买打印', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, int index) {
    bool isActive = currentStep == index;
    return Container(
      padding: EdgeInsets.only(
          top: ss('1rem'),
          bottom: ss('1rem'),
          left: ss('3rem'),
          right: ss('3rem')),
      decoration: currentStep == index
          ? BoxDecoration(
              color: Colors.orange[500],
              borderRadius: BorderRadius.circular(ss('2rem')),
            )
          : null,
      child: Text(
        title,
        style: TextStyle(
          fontSize: ss('1.8rem'),
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}
