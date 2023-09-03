import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame_game_testing/block.dart';
import 'package:flame_game_testing/testgame.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:vector_math/vector_math_64.dart';

enum CharacterState {
  idle,
  walking,
}

class Character extends RiveComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef<TestGame> {
  Character({required artboard, position})
      : super(artboard: artboard, position: position);

  double speed = 0;
  double maxSpeed = 150;
  double maxAcceleration = 52;
  double maxDecceleration = 52;
  double maxTurnSpeed = 80;
  late double maxAirAcceleration;
  late double maxAirDeceleration;
  double maxAirTurnSpeed = 80;

  late double directionX;
  late Vector2 desiredVelocity;
  late Vector2 velocityTest;
  late double maxSpeedChange;
  double acceleration = .8;
  late double deceleration;
  late double turnSpeed;

  late SMIInput<bool>? isWalking;
  late SMIInput<bool>? isJumping;
  late SMIInput<bool>? isFalling;
  final Vector2 fromAbove = Vector2(0, -1);
  double horizontalMovement = 0;
  double moveSpeed = 100;
  double _gravity = 4;
  final double _jumpForce = 270;
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  Vector2 velocity = Vector2.zero();

  bool canDash = true;
  bool isDashing = false;
  double dashingPower = 500;
  double dashingTime = 0.24;
  int dashingCooldown = 1;

  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 2",
    );
    artboard.addController(controller!);
    isWalking = controller.findInput<bool>('isWalking');
    isJumping = controller.findInput<bool>('isJumping');
    isFalling = controller.findInput<bool>('isFalling');

    add(RectangleHitbox(collisionType: CollisionType.active, isSolid: true));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    // move(dt);
    _updatePlayerState();

    _checkHorizontalCollisions();

    _applyGravity(dt);
    _checkVerticalCollisions();
    _Dash(dt);

    if (horizontalMovement == 0) {
      stop();
    }

    super.update(dt);
  }

  Paint paint = Paint()..color = Color.fromARGB(255, 0, 140, 255);
  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      if (intersectionPoints.length == 2) {}
    }

    super.onCollision(intersectionPoints, other);
  }

  bool checkCollision(player, block) {
    final playerX = player.position.x;
    final playerY = player.position.y;
    final playerWidth = width;
    final playerHeight = height;

    final blockX = block.x;
    final blockY = block.y;
    final blockWidth = block.width;
    final blockHeight = block.height;

    final fixedX = player.scale.x < 0 ? playerX - playerWidth : playerX;
    final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

    // print((fixedX < blockX + blockWidth && fixedX + playerWidth > blockX));

    return (fixedY < blockY + blockHeight &&
        fixedY + playerHeight > blockY &&
        fixedX < blockX + blockWidth &&
        fixedX + playerWidth > blockX);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + width;
            break;
          }
        }
      }
    }
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - height;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height;
          }
        }
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    if (keysPressed.contains(LogicalKeyboardKey.shiftLeft) && canDash) {
      // _Dash();
      isDashing = true;
    }
    // print(canDash);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    if (isDashing) {
      return;
    }

    if (hasJumped && isOnGround) _playerJump(dt);

    if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void move(double dt) {
    if (isDashing) {
      return;
    }

    if (hasJumped && isOnGround) _playerJump(dt);

    if (velocity.y > _gravity) isOnGround = false; // optional

    speed += acceleration * dt;

    if (speed > maxSpeed) {
      speed = maxSpeed;
    }

    velocity.x = horizontalMovement * speed;
    position.x += velocity.x * dt;
  }

  void stop() {
    // Decelerate to stop
    if (speed > 0) {
      speed -= 1 * 2;
      if (speed < 0) {
        speed = 0;
      }
    } else if (speed < 0) {
      speed += 1 * 2;
      if (speed > 0) {
        speed = 0;
      }
    }
  }

  void _Dash(double dt) {
    if (isDashing) {
      canDash = false;
      // isDashing = true;

      // final oriGravity = _gravity;
      // _gravity = 0;
      final dashDistance = (scale.x.sign * dashingPower) * dt;
      position.x += dashDistance;

      dashingTime -= dt;
      if (dashingTime < 0) {
        // _gravity = oriGravity;
        isDashing = false;
        dashingTime = 0.24;

        Future.delayed(Duration(seconds: dashingCooldown), () {
          // print("Cooldown Complete");
          canDash = true;
        });
      }
    }
  }

  void _updatePlayerState() {
    if (isWalking == null || isJumping == null || isFalling == null) {
      return;
    }

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) {
      isWalking!.value = true;
      isJumping!.value = false;
      isFalling!.value = false;
    } else {
      isWalking!.value = false;
    }

    // check if Falling set to falling
    if (velocity.y > 0 && !isOnGround) {
      isWalking!.value = false;
      isJumping!.value = false;
      isFalling!.value = true;
    } else {
      isFalling!.value = false;
    }

    // Checks if jumping, set to jumping
    if (velocity.y < 0 && !isOnGround) {
      isWalking!.value = false;
      isJumping!.value = true;
      isFalling!.value = false;
    } else {
      isJumping!.value = false;
    }

    // print('isWalking : ${isWalking!.value} ---- isJumping : ${isJumping!.value} ---  isFalling : ${isFalling!.value} ');
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerJump(double dt) {
    if (isDashing) {
      return;
    }

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
}
