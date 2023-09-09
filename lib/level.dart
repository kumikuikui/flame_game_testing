import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_game_testing/block.dart';
import 'package:flame_game_testing/character2.dart';
import 'package:flame_game_testing/testgame.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<TestGame> {
  final String levelName;
  final Character2 character;
  Level({required this.levelName, required this.character});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  Future<void>? onLoad() async {
    // TODO: implement onLoad
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    _spawningObjects();

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

    topRay = game.collisionDetection.raycast(top);
    bottomRay = game.collisionDetection.raycast(bottom);
    leftRay = game.collisionDetection.raycast(left);
    rightRay = game.collisionDetection.raycast(right);
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

      // canvas.drawLine(
      //   character.positionOfAnchor(Anchor.center).toOffset(),
      //   pointerPosition,
      //   pointerColor,
      // );

      canvas.drawPoints(
          PointMode.lines,
          [
            character.positionOfAnchor(Anchor.center).toOffset(),
            pointerPosition
          ],
          paint);
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
    }
  }

  void _spawningObjects() async {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('spawn');

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
