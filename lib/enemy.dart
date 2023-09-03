import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_game_testing/testgame.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:pathfinding/core/grid.dart';
import 'package:pathfinding/finders/astar.dart';

class Enemy extends CircleComponent with HasGameRef<TestGame> {
  Enemy({position, size, paint, radius})
      : super(position: position, paint: paint, radius: radius);

  late var path;
  double fixedDeltaTime = 1 / 60;
  int start = 0;

  double moveSpeed = 5;
  Vector2 velocity = Vector2.zero();
  late Vector2 initialPosition;
  var grid;

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    // print(makeMatrix(750, 420));
    // print(dt.ceil());

    moveEnemy();
    // print(initialPosition);
  }

  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    priority = 1;
    add(CircleHitbox());

    path = calculatepath();
    // final test = makeMatrix(100, 100);
    // game.add(RectangleComponent(
    //     position: position,
    //     size: Vector2.all(radius * 2 + 200),
    //     paint: Paint()..color = Color.fromARGB(66, 3, 255, 57)));
    // for (var element in test) {
    //   // print(element);
    // }

    // test(50, 50);
    // initialPosition = size;

    // List before = makeMatrix(50, 50);
    // print(before.transpose);

    return super.onLoad();
  }

  List makeMatrix(rows, cols) {
    List list = <List<num>>[];

    for (var x = 0; x < rows * 16; x += 16) {
      // print("X: ${x} | Y: ${y} ");
      final column = <num>[];
      int unwalkable = 0;

      for (var y = 0; y < cols * 16; y += 16) {
        for (var element
            in game.componentsAtPoint(Vector2(x.toDouble(), y.toDouble()))) {
          if (element is RectangleComponent) {
            game.add(CircleComponent(
                position: Vector2(x.toDouble(), y.toDouble()),
                radius: 1.5.toDouble(),
                paint: Paint()..color = Color.fromARGB(255, 255, 0, 0)));

            unwalkable = 1;
            break;
          }

          game.add(CircleComponent(
              position: Vector2(x.toDouble(), y.toDouble()),
              radius: 1.5.toDouble(),
              paint: Paint()..color = Color.fromARGB(255, 25, 0, 255)));

          unwalkable = 0;
        }
        column.add(unwalkable);
      }
      // print("${x} : ${column}");
      list.add(column);
    }

    // print("________________________________________");

    list = list.transpose;

    // print(list.length);

    // for (var element in list) {
    //   print(element);
    // }

    return list;
  }

  int matrixDimension = 30;
  calculatepath() {
    grid = Grid(matrixDimension, matrixDimension,
        makeMatrix(matrixDimension, matrixDimension));

    var path =
        AStarFinder().findPath(0, 0, 29, 16, grid);

    // for (var i = 0; i < path.length; i++) {
    //   position = Vector2(path[i][0], path[i][1]);
    // }
    return path;
  }

  void moveEnemy() {
    if (start == path.length) {
      return;
    }

    // print('${start} |  path : ${path[start]}');

    position = Vector2(path[start][0].toDouble()*16, path[start][1].toDouble()*16);
    start++;
  }

  // void _updatePlayerMovement(double dt) {
  //   if (hasJumped && isOnGround) _playerJump(dt);

  //   if (velocity.y > _gravity) isOnGround = false; // optional

  //   velocity.x = moveSpeed;
  //   position.x += velocity.x * dt;
  // }
}
