import 'package:flame/game.dart';
import 'package:flame_game_testing/testgame.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameWidget<TestGame>.controlled(
      gameFactory: TestGame.new,
    ),);
}

