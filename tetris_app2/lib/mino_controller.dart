import 'dart:async';

import 'package:flutter/material.dart';

import 'mino_models.dart';

import 'dart:math' as math;

const int lowerLimitOfFallSpeed = 100; // 落下速度の下限
final random = math.Random();

class MinoController extends ChangeNotifier{
  int currentFallSpeed;
  MinoController(this.currentFallSpeed);

  final sw = Stopwatch();

  // タップ中における左右累積移動距離（ミノの左右moveが発生・指が離れたら0にリセット）
  double cumulativeLeftDrag = 0;
  double cumulativeRightDrag = 0;

  bool isFixed = true; // 落下中のミノがフィックスしたか
  bool isGameOver = false; // ゲームオーバーになったかどうか。
  MinoRingBuffer minoRingBuffer = MinoRingBuffer(); // 7種1巡の法則が適用された、出現するミノをリングバッファとして保持
  MinoModel holdMino;
  bool doneUsedHoldFunction = false; // Hold機能は1つのミノに対して一回まで
  bool isPossibleHardDrop = true; // ハードドロップを1度使用したら、指が離れるまではfalseにしておく
  int millSecondIn1Loop = 0;
  bool doneHardDropIn1Loop = false;
  int memoryCurrentFallSpeed;

  /// 落下して位置が決まったすべてのミノ（フィックスしたミノ）
  List<List<MinoType>> fixedMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => MinoType.values[0]));
  // ↓こんな感じなのができる
  // [
  //   [0,0,0,0,0,0,0,0,0,0,], // 0 ではなく、本当はenumで表している
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  // ];


  @override
  void dispose() {
    super.dispose();

    sw.stop();
  }

  /// ゲームスタート
  void startGame() {
    // メインループへ
    mainLoop();
  }

  /// ゲームオーバー
  void gameOver() {
    debugPrint("ゲームオーバー");
    // stopTimer();
  }

  // /// タイマーON
  // void startTimer() {
  //   if (timer != null) {
  //     timer.cancel();
  //   }
  //   timer = Timer.periodic(Duration(milliseconds: currentFallSpeed), mainLoop);
  // }
  
  // /// タイマーオフ
  // void stopTimer() {
  //   if (timer != null) {
  //     timer.cancel();
  //     timer = null;
  //   }
  // }



  /// =============
  /// メインのループ
  /// =============
  /// ①ミノを生成する
  /// ②1マス落下処理
  Future<void> mainLoop() async {
    sw.start();

    while (!isGameOver) {
      millSecondIn1Loop = sw.elapsedMilliseconds;

      if (millSecondIn1Loop > currentFallSpeed || doneHardDropIn1Loop) {
        if (isFixed) {
          _generateFallingMino();
        }
        else {
          _subRoutine();
        }

        millSecondIn1Loop = 0;
        sw.reset();
        doneHardDropIn1Loop = false;
      }
      await Future.delayed(Duration(milliseconds: 20));
    }

    gameOver();
  }



  /// 前処理
  void _generateFallingMino() {

    // 落下中のミノがなければ、落下中のミノを生成する（ポインタを1つ進める）
    minoRingBuffer.forwardPointer();

    // Hold機能使用済みフラグをリセットする
    doneUsedHoldFunction = false;

    // 衝突判定
    if (minoRingBuffer.hasCollision(minoRingBuffer.getMinoModel(), fixedMinoArrangement)) {
      debugPrint("衝突");
      isGameOver = true;
    }

    // フィックスフラグを解除
    isFixed = false;

    notifyListeners();
  }

  /// 1段落とす
  Future<void> _subRoutine() async {
    int deferralCount = 0; // 0.5秒の猶予を使える回数

    // 1段落下させられるなら、1段落下させて、
    // 落下できなかったら、フィックス判定（ToDo:0.5秒の猶予処理に移る）
    if (!minoRingBuffer.moveIfCan(0, 1, fixedMinoArrangement)) {
      isFixed = true;
    }

    // // 0.5秒の猶予（15回まで使える）
    // if (isFixed && deferralCount < 15) {
    //
    //   // ToDo:ここでタイマーの時間を0.5に変えてなんとかできないか
    //
    //   if (!_isCollideBottom()) {
    //     isFixed = false;
    //     deferralCount++;
    //   }
    // }

    notifyListeners();

    if (isFixed) {
      _postProcessing();
    }

  }

  /// 後処理
  void _postProcessing() {
    // カレントミノをフィックスさせる
    MinoModel minoModel = minoRingBuffer.getMinoModel();
    int y = minoModel.yPos;
    minoModel.minoArrangement.forEach((side) {
      int x = minoModel.xPos;
      side.forEach((minoType) {
        if (minoType != MinoType.none) fixedMinoArrangement[y][x] = minoType;
        x++;
      });
      y++;
    });

    isFixed = true;
    isPossibleHardDrop = false;

    // 消せる行があったら、消す
    _deleteLineIfCan();

    notifyListeners();

    // 落下速度を速める
    _changeFallSpeed();
  }

  void _changeFallSpeed() {
    if (currentFallSpeed > lowerLimitOfFallSpeed){
      currentFallSpeed--;
    }

    if (memoryCurrentFallSpeed > lowerLimitOfFallSpeed) {
      memoryCurrentFallSpeed--;
    }
  }

  void _deleteLineIfCan() {
    var deleteLineIndexs = List<int>();

    // 削除する行番号を取得
    for (int index = 0 ; index < 20 ; index++) {
      if (fixedMinoArrangement[index].every((minoType) => minoType != MinoType.none)) {
        deleteLineIndexs.add(index);
      }
    }

    // 削除実行
    deleteLineIndexs.forEach((index) {
      fixedMinoArrangement.removeAt(index);
      fixedMinoArrangement.insert(0, List.generate(10, (index) => MinoType.values[0]));
    });

  }

  /// 回転
  void rotate(MinoAngleCW minoAngleCW) {
    minoRingBuffer.rotateIfCan(minoAngleCW, fixedMinoArrangement);
    notifyListeners();
  }

  /// 左右移動
  void moveHorizontal(int moveXPos) {
    minoRingBuffer.moveIfCan(moveXPos, 0, fixedMinoArrangement);
    notifyListeners();
  }

  /// 落下予測位置を取得する
  MinoModel getFallMinoModel() {
    var _fallMinoModel = minoRingBuffer.getMinoModel().copyWith();
    var _oneStepDownMinoModel = _fallMinoModel.copyWith(yPos: _fallMinoModel.yPos + 1);

    while (!minoRingBuffer.hasCollision(_oneStepDownMinoModel, fixedMinoArrangement)) {
      _fallMinoModel = _oneStepDownMinoModel.copyWith();
      _oneStepDownMinoModel = _oneStepDownMinoModel.copyWith(yPos: _oneStepDownMinoModel.yPos + 1);
    }

    return _fallMinoModel;
  }

  /// ハードドロップ
  void doHardDrop() {
    var fallMinoModel = getFallMinoModel();
    minoRingBuffer.changeFallingMinoModel(fallMinoModel);
    _postProcessing();

    // 時間を待たずに、ループの先頭に戻る
    doneHardDropIn1Loop = true;

    notifyListeners();
  }

  /// ソフトドロップON
  void OnSoftDropMode() {
    memoryCurrentFallSpeed = currentFallSpeed;
    currentFallSpeed = 100;
  }

  /// ソフトドロップOFF
  void OffSoftDropMode() {
    currentFallSpeed = memoryCurrentFallSpeed;
  }

  /// Hold機能
  void changeHoldMinoAndFallingMino() {
    if (doneUsedHoldFunction || minoRingBuffer.pointer == -1) return;

    if (holdMino == null) {
      holdMino = minoRingBuffer.getMinoModel();
      minoRingBuffer.forwardPointer();
    }
    else {
      MinoModel _willFallingMinoModel = MinoModel(holdMino.minoType, holdMino.minoAngleCW, 4, 0);
      holdMino = minoRingBuffer.getMinoModel();
      minoRingBuffer.changeFallingMinoModel(_willFallingMinoModel);
    }
    doneUsedHoldFunction = true;
    notifyListeners();
  }
}