import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';

class CollisionBlock extends RectangleComponent {
  bool isPlatform;
  CollisionBlock({
    position,
    size,
    this.isPlatform = false,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Color.fromARGB(114, 43, 44, 45)
        );

}
