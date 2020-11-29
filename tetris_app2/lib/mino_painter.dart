import 'package:flutter/material.dart';

import 'package:tetris_app2/mino_models.dart';
import 'mino_models.dart';

const int verticalSeparationCount = 20; // 縦のマス数
const int horizontalSeparationCount = 10; // 横のマス数

/// フィックスしたミノを描画
class FixedMinoPainter extends CustomPainter {

  List<List<MinoType>> minoArrangement;
  FixedMinoPainter(this.minoArrangement);

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / verticalSeparationCount; /// 1マスの縦
    double side = size.width / horizontalSeparationCount;    /// 1マスの横
    var paint = Paint();
    double yPos = 0;
    double xPos = 0;

    minoArrangement.forEach((lineList) { /// 1行分でループ
      xPos = 0;
      lineList.forEach((minoType) { /// 1マス分を描画
        paint.color = MinoColor.getMinoColor(minoType);

        if(minoType != MinoType.MinoType_None){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , side, vertical), paint); /// 1マス分描画
        }
        xPos += side; /// 描画位置を右に1マスずらす
      });
      yPos += vertical; /// 描画位置を下に1マスずらす
    });

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 落下中のミノを描画
class FallingMinoPainter extends CustomPainter {

  MinoModel minoModel;
  FallingMinoPainter(this.minoModel);

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / verticalSeparationCount; /// 1マスの縦
    double side = size.width / horizontalSeparationCount;    /// 1マスの横
    var paint = Paint();
    double yPos = minoModel.yPos * vertical;
    double xPos;

    minoModel.minoArrangement.forEach((lineList) { /// 1行分でループ
      xPos = minoModel.xPos * side;
      lineList.forEach((minoType) { /// 1マス分を描画
        paint.color = MinoColor.getMinoColor(minoType);

        if(minoType != MinoType.MinoType_None){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , side, vertical), paint); /// 1マス分描画
        }
        xPos += side; /// 描画位置を右に1マスずらす
      });
      yPos += vertical; /// 描画位置を下に1マスずらす
    });

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// NEXT,HOLDミノを描画
class NextOrHoldMinoPainter extends CustomPainter {

  MinoModel minoModel;
  NextOrHoldMinoPainter(this.minoModel);

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / minoModel.minoArrangement.length; /// 1マスの縦
    double side = size.width / minoModel.minoArrangement.length;    /// 1マスの横
    var paint = Paint();
    double yPos = 0;
    double xPos;

    minoModel.minoArrangement.forEach((lineList) { /// 1行分でループ
      xPos = 0;
      lineList.forEach((minoType) { /// 1マス分を描画
        paint.color = MinoColor.getMinoColor(minoType);

        if(minoType != MinoType.MinoType_None){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , side, vertical), paint); /// 1マス分描画
        }
        xPos += side; /// 描画位置を右に1マスずらす
      });
      yPos += vertical; /// 描画位置を下に1マスずらす
    });

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}



/// 枠線を描画
class BoaderPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    double vertical = size.height / verticalSeparationCount; /// 1マスの縦
    double side = size.width / horizontalSeparationCount;      /// 1マスの横

    // 横線
    for(double y = 0; y < size.height ; y += vertical){
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint());
    }

    // 縦線
    for(double x = 0; x < size.width ; x += side){
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint());
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MinoColor {
  static List<MaterialAccentColor> minoColorListBasedOnMinoType = [
    Colors.lightBlueAccent, // 使われない想定
    Colors.lightBlueAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  static MaterialAccentColor getMinoColor(MinoType minoType) {
    return minoColorListBasedOnMinoType[minoType.index];
  }
}

