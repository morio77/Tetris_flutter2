import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mino_controller.dart';

class TetrisPlayPage extends StatelessWidget {
  final int fallSpeed;
  final String difficulty;
  TetrisPlayPage(this.fallSpeed, this.difficulty);

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MinoController>(
      create: (_) => MinoController(fallSpeed),
      child: TetrisPlayPageRender(difficulty),
    );
  }
}


class TetrisPlayPageRender extends StatelessWidget {
  final String difficulty;
  TetrisPlayPageRender(this.difficulty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(difficulty),
      ),
      body: Center(
        child: Text("ここらへんでテトリス"),
      ),
    );
  }
}