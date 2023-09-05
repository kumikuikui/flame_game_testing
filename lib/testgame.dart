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

  final world = World();
  late final CameraComponent cameraComponent;
  late TiledComponent tileMap;
  // late Character character;
  late Character2 character;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    tileMap = await TiledComponent.load(
      'testlevel2.tmx',
      Vector2.all(32),
    );

    // final skillsArtboard = await loadArtboard(
    //     RiveFile.asset('assets/images/character/walkman.riv'));

    // final controller = StateMachineController.fromArtboard(
    //   skillsArtboard,
    //   "State Machine 2",
    // );

    // skillsArtboard.addController(controller!);

    // character = Character(artboard: skillsArtboard);

    character = Character2();

    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);
    add(tileMap);

    _spawningObjects();
    cameraComponent.follow(character);

    debugMode = true;

    return super.onLoad();
  }

  late final origin = Vector2(200, 200);

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

  double get resetPosition => -canvasSize.y;

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

  Paint paint = Paint()..color = Color.fromARGB(255, 0, 140, 255);
  Paint paint1 = Paint()..color = Color.fromARGB(255, 238, 255, 0);
  Paint pointerColor = Paint()..color = Color.fromARGB(255, 255, 94, 0);

  Vector2? pointerCoor;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (pointerCoor != null) {
      final pointerPosition = pointerCoor!.toOffset();
      canvas.drawLine(
        character.positionOfAnchor(Anchor.center).toOffset(),
        pointerPosition,
        pointerColor,
      );
    }

    if (topRay != null && topRay!.isActive) {
      if (!(topRay?.hitbox?.hitboxParent is CollisionBlock)) {
        final originOffset =
            character.positionOfAnchor(Anchor.topCenter).toOffset();
        final intersectionPoint = topRay!.intersectionPoint!.toOffset();
        canvas.drawLine(
          originOffset,
          intersectionPoint,
          paint1,
        );
      }
      final originOffset =
          character.positionOfAnchor(Anchor.topCenter).toOffset();
      final intersectionPoint = topRay!.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
      // canvas.drawCircle(originOffset, 10, paint);
    }

    if (bottomRay != null && bottomRay!.isActive) {
      if (!(bottomRay?.hitbox?.hitboxParent is CollisionBlock)) {
        final originOffset =
            character.positionOfAnchor(Anchor.bottomCenter).toOffset();
        final intersectionPoint = bottomRay!.intersectionPoint!.toOffset();
        canvas.drawLine(
          originOffset,
          intersectionPoint,
          paint1,
        );
      }
      final originOffset =
          character.positionOfAnchor(Anchor.bottomCenter).toOffset();
      final intersectionPoint = bottomRay!.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );

      // canvas.drawCircle(originOffset, 10, paint);
    }

    if (leftRay != null && leftRay!.isActive) {
      if (!(leftRay?.hitbox?.hitboxParent is CollisionBlock)) {
        final originOffset =
            character.positionOfAnchor(Anchor.centerLeft).toOffset();
        final intersectionPoint = leftRay!.intersectionPoint!.toOffset();
        canvas.drawLine(
          originOffset,
          intersectionPoint,
          paint1,
        );
      }
      final originOffset =
          character.positionOfAnchor(Anchor.centerLeft).toOffset();
      final intersectionPoint = leftRay!.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
      // canvas.drawCircle(originOffset, 10, paint);
    }

    if (rightRay != null && rightRay!.isActive) {
      if (!(rightRay?.hitbox?.hitboxParent is CollisionBlock)) {
        final originOffset =
            character.positionOfAnchor(Anchor.centerRight).toOffset();
        final intersectionPoint = rightRay!.intersectionPoint!.toOffset();
        canvas.drawLine(
          originOffset,
          intersectionPoint,
          paint1,
        );
      }
      final originOffset =
          character.positionOfAnchor(Anchor.centerRight).toOffset();
      final intersectionPoint = rightRay!.intersectionPoint!.toOffset();
      canvas.drawLine(
        originOffset,
        intersectionPoint,
        paint,
      );
      // canvas.drawCircle(originOffset, 10, paint);
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    // print(info.eventPosition.game);aa
    pointerCoor = info.eventPosition.game;
  }

  List<CollisionBlock> collisionBlocks = [];

  void _spawningObjects() async {
    final spawnPointsLayer = tileMap.tileMap.getLayer<ObjectGroup>('spawn');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Spawnpoints':
            character.position = Vector2(spawnPoint.x, spawnPoint.y);
            character.scale.x = 1;
            add(character);
            break;
          case 'Collision':
            final block = CollisionBlock(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            block.add(RectangleHitbox(collisionType: CollisionType.passive));
            collisionBlocks.add(block);
            add(block);
            break;
          case 'enemy':
            // final enemy = Enemy(
            //     position: Vector2(0, 0),
            //     radius: 5.toDouble(),
            //     paint: Paint()..color = Color.fromARGB(255, 255, 174, 0));
            // add(enemy);
            break;
          default:
        }
      }
    }
    character.collisionBlocks = collisionBlocks;
  }
}
