import 'package:flutter/material.dart';
import 'package:magicscreen/algorithms/entity/face_detect_box.dart';
import 'package:magicscreen/algorithms/face_detection_cv2.dart';
import 'package:magicscreen/algorithms/face_detection_onnx.dart';

class FaceDetection extends StatefulWidget {
  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  late FaceDetectionOnnx _faceDetection;
  late FaceDetectionCv2 _faceDetectionCv2;

  @override
  void initState() {
    super.initState();

    _faceDetection = FaceDetectionOnnx("assets/models/version-RFB-320.onnx");
    _faceDetectionCv2 =
        FaceDetectionCv2("assets/models/face_detection_yunet_2023mar.onnx");


  }

  void detectFace() async {
    var beginAt2 = DateTime.now();
    for (int i = 0; i < 20; i++) {
      await _faceDetection.detectFaceFile('assets/images/face-2.png');
    }
    print('_faceDetection: ${DateTime.now().difference(beginAt2).inMilliseconds} ms');

    var beginAt = DateTime.now();
    for (int i = 0; i < 20; i++) {
      List<DetectBox>? boxes =
      _faceDetectionCv2.detectFaces('assets/images/face-2.png');
    }
    print('_faceDetectionCv2: ${DateTime.now().difference(beginAt).inMilliseconds} ms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Detection')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => detectFace(),
          child: Text('Detect Face'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(home: FaceDetection()));
}
