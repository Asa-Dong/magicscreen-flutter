# 



## 人脸检测
- tflite + mediapipe  没有跑通，暂时放弃 // https://github.com/google-ai-edge/mediapipe/blob/master/docs/solutions/models.md
- opencv + yunet  跑通 // https://github.com/opencv/opencv_zoo/tree/main/models/face_detection_yunet
- onnx + ultraface  跑通, 速度比opencv稍快  // https://github.com/onnx/models/tree/main/validated/vision/body_analysis/ultraface
  

## 编译tflite
```
## 编译指引
https://www.tensorflow.org/install/source_windows?hl=zh-cn

## python
https://www.python.org/ftp/python/3.6.8/python-3.6.8-amd64.exe

# tensorflow 源码
https://github.com/tensorflow/tensorflow/releases

## bazel
https://github.com/bazelbuild/bazel/releases

## mediapipe 模型下载
https://github.com/google-ai-edge/mediapipe/blob/master/docs/solutions/models.md

## 编译失败了  先从这里下载二进制包
https://github.com/ValYouW/tflite-dist/releases
```