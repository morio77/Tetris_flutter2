import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris_app2/main.dart';
import 'package:tetris_app2/mino_models.dart';

import 'mino_controller.dart';
import 'mino_painter.dart';

class TetrisPlayPage extends StatelessWidget {
  final int fallSpeed;
  final String gameLevel;
  TetrisPlayPage(this.fallSpeed, this.gameLevel);

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MinoController>(
      create: (_) => MinoController(fallSpeed),
      child: TetrisPlayPageRender(gameLevel),
    );
  }
}


class TetrisPlayPageRender extends StatelessWidget {
  final String gameLevel;
  TetrisPlayPageRender(this.gameLevel);

  @override
  Widget build(BuildContext context) {
    final Size displaySize = MediaQuery.of(context).size;
    final double playWindowHeight = displaySize.height * 0.6;
    final double playWindowWidth = playWindowHeight * 0.5;
    final double opacity = 0.1;
    final double horizontalDragThreshold= 15;
    final double verticalDragDownThreshold= 3;
    final double nextHoldWindowHeight = displaySize.height * 0.1;
    final double nextHoldWindowWidth = nextHoldWindowHeight;

    return Consumer<MinoController>(
      builder: (context, minoController, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TetrisHomePage())),
            ),
            title: Text(gameLevel),
            actions: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => minoController.startGame(),
              ),
              IconButton(
                icon: Icon(Icons.rotate_right),
                onPressed: () => minoController.rotate(MinoAngleCW.arg90),
              )
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 枠線を描画
                        painter: BoaderPainter(),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// フィックスしたミノを描画
                        painter: FixedMinoPainter(minoController.fixedMinoArrangement),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 落下中のミノを描画
                        painter: minoController.minoRingBuffer.pointer == -1 ? null : FallingMinoPainter(minoController.minoRingBuffer.getMinoModel()),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 落下予測位置を描画
                        painter: minoController.minoRingBuffer.pointer == -1 ? null : FallPositionPainter(minoController.getFallMinoModel()),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: displaySize.height,
                width: displaySize.width,
                child: GestureDetector(
                  onTapUp: (details) { /// タップで回転させる
                    if (details.globalPosition.dx < displaySize.width * 0.5) {
                      minoController.rotate(MinoAngleCW.arg270);
                    }
                    else {
                      minoController.rotate(MinoAngleCW.arg90);
                    }
                  },
                  onHorizontalDragUpdate: (details) { /// ドラッグで左右移動
                    final double deltaX = details.delta.dx;
                    if (deltaX < 0) {
                      minoController.cumulativeLeftDrag += deltaX;
                    }
                    else {
                      minoController.cumulativeRightDrag += deltaX;
                    }

                    if (minoController.cumulativeLeftDrag < -horizontalDragThreshold) {
                      minoController.moveHorizontal(-1);
                      minoController.cumulativeLeftDrag = 0;
                    }

                    if (minoController.cumulativeRightDrag > horizontalDragThreshold) {
                      minoController.moveHorizontal(1);
                      minoController.cumulativeRightDrag = 0;
                    }

                  },
                  onHorizontalDragEnd: (details) { /// ドラッグ中にが離れたら、累積左右移動距離を0にしておく
                    minoController.cumulativeLeftDrag = 0;
                    minoController.cumulativeRightDrag = 0;
                  },
                  onVerticalDragUpdate: (details) { /// ハードドロップ ＆ Hold機能
                    if (details.delta.dy > verticalDragDownThreshold && minoController.isPossibleHardDrop) { // ハードドロップ
                      minoController.doHardDrop();
                    }
                    else if (details.delta.dy < 0) { // Hold機能
                      minoController.changeHoldMinoAndFallingMino();
                    }
                  },
                  onVerticalDragEnd: (details) {
                    minoController.isPossibleHardDrop = true;
                  },
                  onLongPress: () { /// ソフトドロップON
                    minoController.OnSoftDropMode();
                  },
                  onLongPressEnd: (details) { /// ソフトドロップOFF
                    minoController.OffSoftDropMode();
                  },
                ),
              ),
              Stack( /// NEXT,HOLD枠
                children: [
                  Positioned(
                    left: 10.0,
                    top: 20.0,
                    child: GestureDetector(
                      onTap: () => minoController.changeHoldMinoAndFallingMino(),
                      child: Container(
                        height: nextHoldWindowHeight,
                        width: nextHoldWindowWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: CustomPaint( /// Holdミノを描画
                          painter: minoController.holdMino != null ? NextOrHoldMinoPainter(minoController.holdMino) : null
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 20.0,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next1ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModel(1)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 20 + nextHoldWindowHeight + 20,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next2ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModel(2)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 20.0 +nextHoldWindowHeight + 20 + nextHoldWindowHeight + 20,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next3ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModel(3)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}