import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mino_controller.dart';

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
    return Consumer<MinoController>(
      builder: (_, minoController, __) {
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
          body: Center(
            child: Text("ここらへんでテトリス"),
          ),
        );
      },
    );
  }
}