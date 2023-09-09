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

    debugMode = true;

    addAll([cameraComponent, world]);

    cameraComponent.follow(character, snap: true);

    cameraComponent.viewfinder.zoom = 1.5;

    return super.onLoad();
  }

  final TopDirection = Vector2(0, -1);
  final BottomDirection = Vector2(0, 1);
  final LeftDirection = Vector2(-1, 0);
  final RightDirection = Vector2(1, 0);

  List<RaycastResult<ShapeHitbox>>? results;
  RaycastResult<ShapeHitbox>? topRay;
  RaycastResult<ShapeHitbox>? bottomRay;
  RaycastResult<ShapeHitbox>? leftRay;
  RaycastResult<ShapeHitbox>? rightRay;

  List<ShapeHitbox>? test;

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    final top = Ray2(
      origin: character.positionOfAnchor(Anchor.topCenter),
      direction: TopDirection,
    );
    final bottom = Ray2(
      origin: character.positionOfAnchor(Anchor.bottomCenter),
      direction: BottomDirection,
    );
    final left = Ray2(
      origin: character.positionOfAnchor(Anchor.centerLeft),
      direction: LeftDirection,
    );
    final right = Ray2(
      origin: character.positionOfAnchor(Anchor.centerRight),
      direction: RightDirection,
    );

    if (character.scale.x < 0) {
      left.setWith(
          origin: character.positionOfAnchor(Anchor.centerLeft),
          direction: RightDirection);
      right.setWith(
          origin: character.positionOfAnchor(Anchor.centerRight),
          direction: LeftDirection);
    }

    topRay = collisionDetection.raycast(top);
    bottomRay = collisionDetection.raycast(bottom);
    leftRay = collisionDetection.raycast(left);
    rightRay = collisionDetection.raycast(right);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    // print(info.eventPosition.game);
    world.pointerCoor = info.eventPosition.game;
  }
}
