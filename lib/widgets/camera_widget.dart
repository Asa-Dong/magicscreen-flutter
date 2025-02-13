import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:magicscreen/algorithms/face_detection_cv2.dart';
import 'package:opencv_core/opencv.dart' as cv2;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image/image.dart' as img;
import 'package:magicscreen/algorithms/face_detection_onnx.dart';
import 'package:magicscreen/algorithms/types/detect_box.dart';
import 'package:magicscreen/utils/config.dart' as config;

class FaceCameraWidget extends StatefulWidget {
  @override
  State<FaceCameraWidget> createState() => _FaceCameraWidgetState();
}

class MediaSize {
  int width;
  int height;

  MediaSize(this.width, this.height);
}

class _FaceCameraWidgetState extends State<FaceCameraWidget> {
  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  MediaStreamTrack? _videoTrack;
  FaceDetectionOnnx? _faceDetection1;
  FaceDetectionCv2? _faceDetection2;
  List<MediaDeviceInfo>? _mediaDevicesList;

  Timer? _timer;
  DetectBox? faceBox;
  SendPort? _childPort;


  @override
  void initState() {
    super.initState();

    _initRenderers();

    navigator.mediaDevices.ondevicechange = (event) async {
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      print("devicechange ${_mediaDevicesList}");
    };

    // _faceDetection1 = FaceDetectionOnnx("assets/models/version-RFB-320.onnx");
    // _faceDetection2 =
    //     FaceDetectionCv2("assets/models/face_detection_yunet_2023mar.onnx");
  }

  // @override
  // void deactivate() {
  //   super.deactivate();
  //   _localRenderer.dispose();
  //   navigator.mediaDevices.ondevicechange = null;
  // }

  @override
  void dispose() {
    _localRenderer.dispose();
    _faceDetection1?.dispose();
    _faceDetection2?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  _initRenderers() async {
    await _localRenderer.initialize();

    Future.delayed(Duration(milliseconds: 500), () {
      _initMedia();
    });
  }

  _initMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();

    for (var device in _mediaDevicesList!) {
      print(
          'devicechange kind: ${device.kind}, device: ${device.label}, id: ${device.deviceId}');
    }

    _localStream = stream;
    _localRenderer.srcObject = _localStream;

    _startFaceDetection();
  }

  // _startFaceDetection2() async {
  //   _timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
  //     var face = await _detectFace();
  //     setState(() {
  //       faceBox = face;
  //     });
  //   });
  // }

  _startFaceDetection() async {
    ReceivePort mainReceivePort = ReceivePort();

    late SendPort childPort;
    mainReceivePort.listen((data) async {
      if (data is SendPort) {
        childPort = data;
        _childPort = childPort;

        // send first frame
        (ByteBuffer frame, int width, int height)? params =
            await _captureFrame();
        if (params == null) return;
        var (frame, width, height) = params;
        childPort.send((frame, width, height));
        return;
      }

      if (data == null) {
        setState(() {
          faceBox = null;
        });
      } else {
        final face = DetectBox.fromJson(data);
        setState(() {
          faceBox = _scaleBox(face);
        });
      }

      // next frame
      (ByteBuffer frame, int width, int height)? params = await _captureFrame();
      if (params == null) return;
      var (frame, width, height) = params;
      childPort.send((frame, width, height));
    });

    await Isolate.spawn((SendPort mainPort) {
      var _faceDetection =
          FaceDetectionOnnx("assets/models/version-RFB-320-int8.onnx");

      Future<DetectBox?> _detectFace(
          (ByteBuffer frame, int width, int height) params) async {
        var (frame, width, height) = params;

        var image = img.Image.fromBytes(
            width: width, height: height, bytes: frame, numChannels: 4);

        var beginAt = DateTime.now();
        var faces = _faceDetection.detect(image);
        print(
            "detectFace: ${DateTime.now().difference(beginAt).inMilliseconds}ms");
        if (faces == null) return null;
        var face = faces.first;

        return face;
      }

      final childPort = ReceivePort();
      childPort.listen((data) async {
        var face;
        try {
          face = await _detectFace(data);
        } catch (e) {
          print("error: $e");
          await Future.delayed(Duration(milliseconds: 1000));
        }
        mainPort.send(face?.toJson());
      });

      mainPort.send(childPort.sendPort);
    }, mainReceivePort.sendPort);
  }

  Future<(ByteBuffer, int, int)?> _captureFrame() async {
    if (_localStream == null) return null;
    if (_videoTrack == null) {
      _videoTrack = _localStream!
          .getVideoTracks()
          .firstWhere((track) => track.kind == 'video');
    }

    var beginAt = DateTime.now();
    final frame = await _videoTrack!.captureFrame();
    print(
        "captureFrame: ${DateTime.now().difference(beginAt).inMilliseconds}ms");

    var width = _videoTrack!.getSettings()['width'] as int;
    var height = _videoTrack!.getSettings()['height'] as int;
    return (frame, width, height);
  }

  // scale face box to screen
  DetectBox _scaleBox(DetectBox face) {
    var containerWidth = config.screenSize.width;
    var scale = containerWidth / face.originWidth;

    face.x1 = (face.x1 * scale).round();
    face.y1 = (face.y1 * scale).round();
    face.x2 = (face.x2 * scale).round();
    face.y2 = (face.y2 * scale).round();

    // flip
    face.x1 = (config.screenSize.width - face.x1).round();
    face.x2 = (config.screenSize.width - face.x2).round();

    return face;
  }

  Future<DetectBox?> _detectFace1(
      ByteBuffer frame, int width, int height) async {
    var image = img.Image.fromBytes(
        width: width, height: height, bytes: frame, numChannels: 4);

    var beginAt = DateTime.now();
    var faces = _faceDetection1?.detect(image);
    print("detectFace: ${DateTime.now().difference(beginAt).inMilliseconds}ms");
    if (faces == null) return null;
    return _scaleBox(faces.first);
  }

  Future<DetectBox?> _detectFace2(ByteBuffer? frame) async {
    if (frame == null) return null;

    // cover frame to mat
    var mat = cv2.Mat.fromList(_localRenderer.videoHeight,
        _localRenderer.videoWidth, cv2.MatType.CV_8UC4, frame.asUint8List());
    var image = cv2.cvtColor(mat, cv2.COLOR_RGBA2BGR);

    // 保存图像
    // cv2.imwrite('output_image.png', image);

    var beginAt = DateTime.now();
    var faces = _faceDetection2?.detect(image);
    print("detectFace: ${DateTime.now().difference(beginAt).inMilliseconds}ms");
    if (faces == null) return null;
    return _scaleBox(faces.first);
  }

  void _onDetect() async {
    var params = await _captureFrame();
    if (params == null) return;

    _childPort?.send(params);

/*    var face = await _detectFace1(params.$1, params.$2, params.$3);
    if (face == null) {
      return;
    }

    print("faceBox: ${face.toJson()}");
    setState(() {
      faceBox = face;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: config.ss('100vw'),
          height: _localRenderer.videoHeight > 0
              ? config.ss('100vw') *
              _localRenderer.videoHeight /
              _localRenderer.videoWidth
              : config.ss('100vw'),
          child: Stack(
            children: [
              RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              ),
              faceBox != null
                  ? CustomPaint(
                      painter: FaceBoxPainter(
                          [faceBox!.toRect()]),
                      // size: Size(faceBox!.originWidth.toDouble(), faceBox!.originHeight.toDouble()),
                     )
                  : Container(),
              Center(
                  child: FilledButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text("Start Face Detection"),
                onPressed: () {
                  _onDetect();
                },
              )),
            ],
          ),
        )
      ],
    );
  }
}

class FaceBoxPainter extends CustomPainter {
  final List<Rect> faceRects;

  FaceBoxPainter(this.faceRects);

  @override
  void paint(Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    for (final rect in faceRects) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
