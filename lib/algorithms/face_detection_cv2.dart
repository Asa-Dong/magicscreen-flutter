import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:magicscreen/algorithms/types/face_detect_box.dart';
import 'package:opencv_core/opencv.dart' as cv2;

// cv2 + yunet model
// https://github.com/opencv/opencv_zoo/tree/main/models/face_detection_yunet
class FaceDetectionCv2 {
  late cv2.FaceDetectorYN _faceDetector;

  // assets/models/face_detection_yunet_2023mar.onnx
  FaceDetectionCv2(String modelPath) {
    _loadModel(modelPath);
  }

  Future<void> _loadModel(String modelPath) async {
    final rawAssetFile = File(modelPath);
    final bytes = rawAssetFile.readAsBytesSync();
    _faceDetector = cv2.FaceDetectorYN.fromBuffer(
      "onnx",
      bytes,
      Uint8List(0),
      (320, 320),
      // backendId: cv.DNN_BACKEND_VKCOM,
      // targetId: cv.DNN_TARGET_VULKAN,
      topK: 2,
      scoreThreshold: 0.5,
      nmsThreshold: 0.3,
    );
  }

  cv2.Mat resizeAndPadding(cv2.Mat origImage) {
    var image = cv2.cvtColor(origImage, cv2.COLOR_BGR2RGB);

    var h = image.height;
    var w = image.width;

    var targetW = 320;
    var targetH = 240;

    // 计算缩放比例
    var scaleRatio = min(targetW / w, targetH / h);

    // # 计算缩放后的尺寸
    var newWidth = (w * scaleRatio).ceil();
    var newHeight = (h * scaleRatio).ceil();

    // # 等比缩放图像
    var resizedImage = cv2.resize(image, (newWidth, newHeight));

    // # 计算填充的尺寸
    var deltaW = targetW - newWidth;
    var deltaH = targetH - newHeight;
    var bottom = (deltaH / 2).ceil();
    var top = deltaH - bottom;
    var left = (deltaW / 2).ceil();
    var right = deltaW - left;

    // # 添加填充
    resizedImage = cv2.copyMakeBorder(
        resizedImage, top, bottom, left, right, cv2.BORDER_CONSTANT);

    return resizedImage;
  }

  List<DetectBox>? detectFaces(String imagePath) {
    var img = cv2.imread(imagePath, flags: cv2.IMREAD_COLOR);
    _faceDetector.setInputSize((img.width, img.height));
    final faces = _faceDetector.detect(img);
    if (faces.isEmpty) {
      return null;
    }

    return List.generate(faces.rows, (i) {
      final x = faces.at<double>(i, 0).toInt();
      final y = faces.at<double>(i, 1).toInt();
      final width = faces.at<double>(i, 2).toInt();
      final height = faces.at<double>(i, 3).toInt();
      // final correctedWidth = (x + width) > img.width ? img.width - x : width;
      // final correctedHeight =
      //     (y + height) > img.height ? img.height - y : height;

      final score = faces.at<double>(i, 14);
      return DetectBox(
        score,
        x,
        y,
        x + width,
        y + height,
      );
    });
  }
}
