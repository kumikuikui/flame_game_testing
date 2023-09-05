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

enum PlayerState { idle, run, jump, falling, somersault }

class Character2 extends SpriteAnimationGroupComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef<TestGame> {
  Character2({position}) : super(position: position);

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

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

  Vector2 velocity = Vector2.zero();

  double horizontalMovement = 0;
  double moveSpeed = 100;

  double _gravity = 4;

  final double _jumpForce = 270;
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;

  bool canDash = true;
  bool isDashing = false;
  double dashingPower = 500;
  double dashingTime = 0.24;
  int dashingCooldown = 1;

  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

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

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(4, 0, 0);
    runningAnimation = _spriteAnimation(6, 1, 1);
    jumpingAnimation = _spriteAnimation(3, 1, 2);
    fallingAnimation = _spriteAnimation(2, 1, 3);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runningAnimation,
      PlayerState.jump: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(int amount, double start, double end) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('character/adventurer-v1.5-Sheet.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: .15,
          textureSize: Vector2(50, 37),
          texturePosition: Vector2(50 * start, 37 * end)),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.run;

    // check if Falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // Checks if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jump;

    current = playerState;
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
