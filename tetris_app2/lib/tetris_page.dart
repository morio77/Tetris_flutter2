import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Consumer<MinoController>(
      builder: (context, minoController, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(gameLevel),
            actions: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => minoController.startGame(),
              ),
              IconButton(
                icon: Icon(Icons.rotate_right),
                onPressed: () => minoController.rotate(MinoAngleCW.Arg90),
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
                        painter: FallingMinoPainter(minoController.minoRingBuffer.getMinoModel()),
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
                    if(details.globalPosition.dx < displaySize.width * 0.5){
                      minoController.rotate(MinoAngleCW.Arg270);
                    }
                    else {
                      minoController.rotate(MinoAngleCW.Arg90);
                    }
                  },
                  // onHorizontalDragUpdate: (details) { /// ドラッグで左右移動
                  //   final double deltaX = details.delta.dx;
                  //   if(deltaX < 0){
                  //     Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag += deltaX;
                  //   }
                  //   else {
                  //     Provider.of<MinoState>(context, listen: false).cumulativeRightDrag += deltaX;
                  //   }
                  //
                  //   if(Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag < -horizontalDragThreshold){
                  //     Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(-1);
                  //     Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag = 0;
                  //   }
                  //
                  //   if(Provider.of<MinoState>(context, listen: false).cumulativeRightDrag > horizontalDragThreshold){
                  //     Provider.of<MinoState>(context, listen: false).moveCurrentMinoHorizon(1);
                  //     Provider.of<MinoState>(context, listen: false).cumulativeRightDrag = 0;
                  //   }
                  //
                  // },
                  // onHorizontalDragEnd: (details) { /// ドラッグ中にが離れたら、累積左右移動距離を0にしておく
                  //   Provider.of<MinoState>(context, listen: false).cumulativeLeftDrag = 0;
                  //   Provider.of<MinoState>(context, listen: false).cumulativeRightDrag = 0;
                  // },
                  // onVerticalDragUpdate: (details) { /// ハードドロップ
                  //   if(details.delta.dy > verticalDragDownThreshold){
                  //     Provider.of<MinoState>(context, listen: false).hardDropFlag = true;
                  //   }
                  // },
                  // onLongPress: () { /// ソフトドロップON
                  //   Provider.of<MinoState>(context, listen: false).timer.cancel();
                  //   Provider.of<MinoState>(context, listen: false).timer = null;
                  //   Provider.of<MinoState>(context, listen: false).startTimer(50);
                  // },
                  // onLongPressEnd: (details) { /// ソフトドロップOFF
                  //   Provider.of<MinoState>(context, listen: false).timer.cancel();
                  //   Provider.of<MinoState>(context, listen: false).timer = null;
                  //   Provider.of<MinoState>(context, listen: false).startTimer(250);
                  // },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}