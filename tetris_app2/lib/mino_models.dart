import 'package:flutter/cupertino.dart';
import 'package:tetris_app2/mino_controller.dart';

import 'mino_painter.dart';

/// ミノモデル（落下中ミノ・Nextミノ・Holdミノに使う）
class MinoModel {
  final MinoType minoType;
  final MinoAngleCW minoAngleCW;
  final int xPos; // 左上が原点
  final int yPos; // 左上が原点
  final List<List<MinoType>> minoArrangement; // 配置図

  MinoModel(this.minoType, this.minoAngleCW, this.xPos, this.yPos)
      :this.minoArrangement = minoArrangementList[minoType.index][minoAngleCW.index];

  MinoModel copyWith({
    final MinoType minoType,
    final MinoAngleCW minoAngleCW,
    final int xPos, // 左上が原点
    final int yPos, // 左上が原点
    // List<List<MinoType>> minoArrangement, // 配置図
  }) {
    return MinoModel(
      minoType ?? this.minoType,
      minoAngleCW ?? this.minoAngleCW,
      xPos ?? this.xPos,
      yPos ?? this.yPos,
    );
  }
}



/// 出てくるミノタイプを表すクラス
class MinoRingBuffer {
  final int checkPoint = 7;

  List<MinoModel> minoModelList; // ミノモデルのリスト（リングバッファ）
  int pointer;

  List<MinoType> tmpMinoTypeList; // シャッフル用のミノタイプリスト

  // コンストラクタ
  MinoRingBuffer() {
    pointer = -1;
    minoModelList = List<MinoModel>(14);

    // 7種1巡の法則で7個のミノモデルを生成して、リストに保持
    tmpMinoTypeList = List.generate(7, (i) => MinoType.values[i + 1]);

    tmpMinoTypeList.shuffle();
    for (int i = 0 ; i < 7 ; i++) {
      minoModelList[i] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
    }
  }

  /// ミノモデルを返す
  MinoModel getMinoModel([int forwardCountFromPointer = 0]) {
    return minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];
  }

  /// 指定された方向へミノを移動させる
  /// <return>true:移動できた, false:移動できなかった</return>
  bool moveIfCan(int moveXPos, int moveYPos, List<List<MinoType>> fixedMinoArrangement, [int forwardCountFromPointer = 0]) {
    // 移動したものを適用してみてダメなら戻す。OKならそのまま。
    MinoModel minoModel = minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];
    MinoModel _moveMinoModel = minoModel.copyWith(xPos: minoModel.xPos + moveXPos, yPos: minoModel.yPos + moveYPos);

    // 衝突チェック
    if (hasCollision(_moveMinoModel, fixedMinoArrangement)) {
      return false;
    }
    else {
      minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length] = _moveMinoModel;
      return true;
    }
  }

  /// 指定された角度だけミノを回転させる
  /// <return>true:回転できた, false:回転できなかった</return>
  bool rotateIfCan(MinoAngleCW minoAngleCW, List<List<MinoType>> fixedMinoArrangement, [int forwardCountFromPointer = 0]) {
    // 回転したものを適用してみてダメなら戻す。OKならそのまま。
    MinoModel minoModel = minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];

    List<MinoModel> minoModelListWithSRS = _getMinoModelListWithSRS(minoModel, minoAngleCW);

    for (MinoModel rotateMinoModel in minoModelListWithSRS) {
      if (!hasCollision(rotateMinoModel, fixedMinoArrangement)) {
        minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length] = rotateMinoModel;
        return true;
      }
    }

    return false;
  }

  List<MinoModel> _getMinoModelListWithSRS(MinoModel minoModel, MinoAngleCW minoAngleCW) {

    MinoAngleCW _afterRotationAngleCW = MinoAngleCW.values[(minoModel.minoAngleCW.index + minoAngleCW.index) % 4];
    MinoModel _rotationMinoModel = minoModel.copyWith(minoAngleCW: _afterRotationAngleCW);

    var minoModelListWithSRS = List<MinoModel>();
    minoModelListWithSRS.add(_rotationMinoModel);

    if (minoModel.minoType == MinoType.O) {
      // 何もしない
    }
    else if (minoModel.minoType == MinoType.I) {

    }
    else {

    }

    return minoModelListWithSRS;

  }

  /// 指定されたミノが適用できるかどうかを返す
  /// <return>true:適用できる, false:適用できない
  bool hasCollision(MinoModel _minoModel, List<List<MinoType>> fixedMinoArrangement) {
    // // 下端チェック
    // int adjustY = _minoModel.minoArrangement.indexWhere((line) => line.every((minoType) => minoType == MinoType.MinoType_None) , 1);
    // if (_minoModel.yPos + adjustY > verticalSeparationCount) return true;
    //
    // // 左端チェック
    // if (_minoModel.xPos < 0) return true;
    //
    // // 右端チェック
    // int addXPos = 0;
    // _minoModel.minoArrangement.forEach((line) {
    //   int x = 0;
    //   line.forEach((minoType) {
    //     x++;
    //     if (minoType != MinoType.MinoType_None) {
    //       if (addXPos < x) addXPos = x;
    //     }
    //   });
    // });
    // if (_minoModel.xPos + addXPos > horizontalSeparationCount) return true;

    // fixedミノチェック（これですべてのチェックになっているばず）
    int y = _minoModel.yPos;
    for (final line in _minoModel.minoArrangement) {
      int x = _minoModel.xPos;
      for (final minoType in line) {
        if (minoType != MinoType.none) {
          try {
            // debugPrint(y.toString());
            // debugPrint(x.toString());
            if (fixedMinoArrangement[y][x] != MinoType.none) {
              return true;
            }
          }
          catch (e) {
            debugPrint(e.toString());
            return true;
          }
        }
        x++;
      }
      y++;
    }

    // ここまで来たら適用しても問題なし
    return false;
  }

  /// ポインタを進める
  void forwardPointer() {
    pointer++;

    // 7種のミノが1巡したら、次の7種のミノを生成して詰める
    if ((pointer % checkPoint) == 0) {
      tmpMinoTypeList.shuffle();

      for (int i = 0 ; i < 7 ; i++) {
        minoModelList[(pointer + i + 7) % minoModelList.length] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
      }
    }
  }
}

enum MinoType {
  none, // 0
  I,    // 1
  O,    // 2
  S,    // 3
  Z,    // 4
  J,    // 5
  L,    // 6
  T,    // 7
}

extension MinoTypeExt on MinoType {
  int get index {
    switch (this) {
      case MinoType.none:
        return 0;
        break;
      case MinoType.I:
        return 1;
        break;
      case MinoType.O:
        return 2;
        break;
      case MinoType.S:
        return 3;
        break;
      case MinoType.Z:
        return 4;
        break;
      case MinoType.J:
        return 5;
        break;
      case MinoType.L:
        return 6;
        break;
      case MinoType.T:
        return 7;
        break;
      default:
        return 0;
    }
  }
}

enum MinoAngleCW {
  arg0,
  arg90,
  arg180,
  arg270,
}


extension MinoAngleCWExt on MinoAngleCW {
  int get index {
    switch (this) {
      case MinoAngleCW.arg0:
        return 0;
        break;
      case MinoAngleCW.arg90:
        return 1;
        break;
      case MinoAngleCW.arg180:
        return 2;
        break;
      case MinoAngleCW.arg270:
        return 3;
        break;
      default:
        return 0;
    }
  }
}


const List<List<List<List<MinoType>>>> minoArrangementList = [
  [], // 0番目なので何もなし
  [ /// Iミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.I, MinoType.I, MinoType.I, MinoType.I],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.I, MinoType.I, MinoType.I, MinoType.I],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Oミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Sミノ
    [ // 0度
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.S, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.S, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Zミノ
    [ // 0度
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Jミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.J, MinoType.none],
      [MinoType.J, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.J, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.J, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.J, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Lミノ
    [ // 0度
      [MinoType.L, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Tミノ
    [ // 0度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
];