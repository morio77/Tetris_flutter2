import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            ],
          ),
        );
      },
    );
  }
}