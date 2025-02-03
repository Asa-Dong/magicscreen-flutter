import 'package:flutter/material.dart';
import 'package:magicscreen/types/global_state.dart';

const double designWidth = 750;
const double baseRem = 10;
late Size screenSize;

//
late String apiBaseUrl;
const String apiCodeSuccess = '100';

//
GlobalState globalState = GlobalState();

List<Task> tasks = [
  Task(
      name: "读取配置文件",
      func: (ProgressCallback callback) async {
        await globalState.loadConfig();
        apiBaseUrl = globalState.apiBaseUrl;
      }),
  Task(
      name: "拉取样式配置",
      func: (ProgressCallback callback) async {
        await globalState.fetchStyle();
      }),
  Task(
      name: "下载风格图片",
      func: (ProgressCallback progressCallback) async {
        await globalState.downloadStylePic(progressCallback);
      }),
];

typedef ProgressCallback = void Function(String text);

class Task {
  final String name;
  final Function func;
  late String status;

  String? errorText;
  String? progressText;

  Task({required this.name, required this.func}) {
    status = "doing";
  }

  Future<void> execute(ProgressCallback progressCallback) async {
    status = "doing";
    try {
      await func(progressCallback);
      status = "success";
    } catch (e) {
      errorText = e.toString();
      status = "error";
    }
  }

}

double ss(String value) {
  if (value.endsWith('rem')) {
    return baseRem * double.parse(value.replaceFirst('rem', ''));
  }
  if (value.endsWith('vh')) {
    return double.parse(value.replaceFirst('vh', '')) / 100 * screenSize.height;
  }
  if (value.endsWith('vw')) {
    return double.parse(value.replaceFirst('vw', '')) / 100 * screenSize.width;
  }
  if (value.endsWith('%')) {
    return double.parse(value.replaceFirst('%', '')) / 100 * screenSize.width;
  }
  return double.parse(value);
}
