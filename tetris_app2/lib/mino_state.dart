/// 出てくるミノタイプを表すクラス
class MinoRingBuffer{

  final int checkPoint1 = 0;
  final int checkPoint2 = 7;

  List<int> minoTypeList; // ミノタイプのリスト（リングバッファ）
  // List<int> minoTypeArgCW; // ミノ角度のリスト（リングバッファ）
  int pointer;

  List<int> tmpMinoTypeList; // シャッフル用のミノタイプリスト

  MinoRingBuffer() { /// コンストラクタ
    pointer = 13;
    minoTypeList = List<int>(14);

    // 7種1巡の法則で7個のミノを生成して、リストに保持
    tmpMinoTypeList = List.generate(7, (i) => i + 1);

    //
    tmpMinoTypeList.shuffle();
    tmpMinoTypeList.forEach((minoType) {
      minoTypeList.add(minoType);
    });
  }

  // カレントミノを返して、ポインタを1つ進める
  int getCurrentMinoTypeAndForwardPointer() {

    final int currentMinoType =  minoTypeList[pointer];

    // ポインタを1つすすめる
    if (pointer == minoTypeList.length) {
      pointer = 0;
    }
    else {
      pointer++;
    }

    // 7種のミノが1巡したら、次の7種のミノを生成して詰める
    if (pointer == checkPoint1 || pointer == checkPoint2) {
      tmpMinoTypeList.shuffle();
      for (int i = 0 ; i < 7 ; i++) {
        minoTypeList[(pointer + i + 7) % minoTypeList.length] = tmpMinoTypeList[i];
      }
    }

    return currentMinoType;
  }
}