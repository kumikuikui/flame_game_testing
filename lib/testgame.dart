import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_game_testing/block.dart';
import 'package:flame_game_testing/character2.dart';
import 'package:flame_game_testing/enemy.dart';
import 'package:flame_game_testing/level.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'character.dart';

class TestGame extends FlameGame
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        MouseMovementDetector {
  TestGame();

  late final CameraComponent cameraComponent;
  late Level world;
  Character2 character = Character2();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    world = Level(
      character: character,
      levelName: 'testlevel2',
    );

    // tileMap.anchor = Anchor.center;

    // final skillsArtboard = await loadArtboard(
    //     RiveFile.asset('assets/images/character/walkman.riv'));

    // final controller = StateMachineController.fromArtboard(
    //   skillsArtboard,
    //   "State Machine 2",
    // );

    // skillsArtboard.addController(controller!);

    // character = Character(artboard: skillsArtboard);

    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.center;

    // debugMode = true;

    addAll([cameraComponent, world]);

    cameraComponent.follow(character, snap: true);

    cameraComponent.viewfinder.zoom = 1.5;

    return super.onLoad();
  }


  @override
  void onMouseMove(PointerHoverInfo info) {
    // print(info.eventPosition.game);
    world.pointerCoor = info.eventPosition.game;
  }
}
