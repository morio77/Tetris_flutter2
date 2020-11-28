import 'package:flutter/cupertino.dart';
import 'package:tetris_app2/mino_controller.dart';

import 'mino_painter.dart';

/// ミノモデル（落下中ミノ・Nextミノ・Holdミノに使う）
class MinoModel {
  MinoType minoType;
  MinoAngleCW minoAngleCW;
  int xPos; // 左上が原点
  int yPos; // 左上が原点
  List<List<MinoType>> minoArrangement; // 配置図

  MinoModel(minoType, minoAngleCW, xPos, yPos) {
    this.minoType = minoType;
    this.minoAngleCW = minoAngleCW;
    this.xPos = xPos;
    this.yPos = yPos;

    this.minoArrangement = minoArrangementList[this.minoType.index][this.minoAngleCW.index];
  }
}

/// 出てくるミノタイプを表すクラス
class MinoRingBuffer {

  final int checkPoint1 = 0;
  final int checkPoint2 = 7;

  List<MinoModel> minoModelList; // ミノモデルのリスト（リングバッファ）
  int pointer;

  List<MinoType> tmpMinoTypeList; // シャッフル用のミノタイプリスト

  // コンストラクタ
  MinoRingBuffer() {
    pointer = 13;
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
    MinoModel _tmpMinoModel = MinoModel(minoModel.minoType, minoModel.minoAngleCW, minoModel.xPos, minoModel.yPos);

    _tmpMinoModel.xPos += moveXPos;
    _tmpMinoModel.yPos += moveYPos;

    // 衝突チェック
    if (_isCollideMino(_tmpMinoModel, fixedMinoArrangement)) {
      return false;
    }
    else {
      minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length] = _tmpMinoModel;
      return true;
    }
  }

  /// 指定された角度だけミノを回転させる
  /// <return>true:回転できた, false:回転できなかった</return>
  bool rotateIfCan(MinoAngleCW minoAngleCW, List<List<MinoType>> fixedMinoArrangement, [int forwardCountFromPointer = 0]) {
    return true;
  }

  /// 指定されたミノが適用できるかどうかを返す
  /// <return>true:適用できる, false:適用できない
  bool _isCollideMino(MinoModel _minoModel, List<List<MinoType>> fixedMinoArrangement) {
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
        if (minoType != MinoType.MinoType_None) {
          try {
            if (fixedMinoArrangement[y][x] != MinoType.MinoType_None) {
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
    // ポインタを1つすすめる
    if (pointer == minoModelList.length) {
      pointer = 0;
    }
    else {
      pointer++;
    }

    // 7種のミノが1巡したら、次の7種のミノを生成して詰める
    if (pointer == checkPoint1 || pointer == checkPoint2) {
      tmpMinoTypeList.shuffle();

      for (int i = 0 ; i < 7 ; i++) {
        minoModelList[(pointer + i + 7) % minoModelList.length] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
      }
    }
  }
}

enum MinoType {
  MinoType_None, // 0
  MinoType_I,    // 1
  MinoType_O,    // 2
  MinoType_S,    // 3
  MinoType_Z,    // 4
  MinoType_J,    // 5
  MinoType_L,    // 6
  MinoType_T,    // 7
}

extension MinoTypeExt on MinoType {
  int get index {
    switch (this) {
      case MinoType.MinoType_None:
        return 0;
        break;
      case MinoType.MinoType_I:
        return 1;
        break;
      case MinoType.MinoType_O:
        return 2;
        break;
      case MinoType.MinoType_S:
        return 3;
        break;
      case MinoType.MinoType_Z:
        return 4;
        break;
      case MinoType.MinoType_J:
        return 5;
        break;
      case MinoType.MinoType_L:
        return 6;
        break;
      case MinoType.MinoType_T:
        return 7;
        break;
      default:
        return 0;
    }
  }
}

enum MinoAngleCW {
  Arg0,
  Arg90,
  Arg180,
  Arg270,
}


extension MinoAngleCWExt on MinoAngleCW {
  int get index {
    switch (this) {
      case MinoAngleCW.Arg0:
        return 0;
        break;
      case MinoAngleCW.Arg90:
        return 1;
        break;
      case MinoAngleCW.Arg180:
        return 2;
        break;
      case MinoAngleCW.Arg270:
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
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_I, MinoType.MinoType_I, MinoType.MinoType_I, MinoType.MinoType_I],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_I, MinoType.MinoType_I, MinoType.MinoType_I, MinoType.MinoType_I],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_I, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Oミノ
    [ // 0度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_O, MinoType.MinoType_O, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Sミノ
    [ // 0度
      [MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None],
      [MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None],
      [MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_S, MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_S, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Zミノ
    [ // 0度
      [MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_None, MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_Z, MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_Z, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Jミノ
    [ // 0度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_None],
      [MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_None],
      [MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_J, MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_J, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Lミノ
    [ // 0度
      [MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_L, MinoType.MinoType_L, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
  [ /// Tミノ
    [ // 0度
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 90度
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 180度
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
    [ // 270度
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_T, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_T, MinoType.MinoType_None, MinoType.MinoType_None],
      [MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None, MinoType.MinoType_None],
    ],
  ],
];