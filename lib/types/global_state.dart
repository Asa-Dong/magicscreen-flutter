import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:magicscreen/utils/api.dart';
import 'package:yaml/yaml.dart' as yaml;

class GlobalState {
  late String screenNum;
  late String apiBaseUrl;
  late String cacheDir;

  late List<dynamic> styles;

  GlobalState();

  Future<void> loadConfig() async {
    var file = File('config/config.yaml');
    var config = yaml.loadYaml(file.readAsStringSync());

    screenNum = config['screenNum'];
    apiBaseUrl = config['apiBaseUrl'];
    cacheDir = config['cacheDir'];
  }

  Future<void> fetchStyle() async {
    await API.post<Map<String, dynamic>>("/mpScreen/getStyleContentByScreenId",
        {"screenNumber": screenNum, "stylePicContent": []}).then((res) {
      if (res.data == null) {
        throw ApiException("获取风格列表失败");
      }
      styles = res.data!['info']!;
    });
  }

  Future<void> downloadStylePic(Function(String msg) callback) async {
    final List<String> imgUrls = [];
    for (var item in styles) {
      for (var basePicContent in item['basePicContentList']) {
        imgUrls.add(basePicContent['basePicAddress']);
      }
    }

    // download
    final dir = Directory("$cacheDir/styles");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final len = imgUrls.length;
    for (int i = 0; i < len; i++) {
      final url = imgUrls[i];
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final fileName = url.split('/').last.split('?').first;

      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes);

      callback("${i + 1}/$len");

      await Future.delayed(Duration(seconds: 3));
    }
  }
}
