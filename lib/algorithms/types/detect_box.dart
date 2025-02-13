import 'dart:ui';

class DetectBox {
  double score;

  int x1, y1, x2, y2;

  int get width => x2 - x1;

  int get height => y2 - y1;

  int originWidth;
  int originHeight;

  DetectBox(this.score, this.x1, this.y1, this.x2, this.y2, this.originWidth,
      this.originHeight);

  Rect toRect() {
    return Rect.fromLTWH(x1.toDouble(), y1.toDouble(), x2.toDouble() - x1, y2.toDouble() - y1);
  }

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "x1": x1,
      "y1": y1,
      "x2": x2,
      "y2": y2,
      "originWidth": originWidth,
      "originHeight": originHeight,
    };
  }

  static DetectBox fromJson(Map<String, dynamic> json) {
    return DetectBox(
      json["score"],
      json["x1"],
      json["y1"],
      json["x2"],
      json["y2"],
      json["originWidth"],
      json["originHeight"],
    );
  }
}
