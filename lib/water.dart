import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';

class Water extends RectangleComponent {
  Water({position, size}) : super(position: position, size: size);

  int WAVE_FREQ = 5;
  int WAV_PASS = 6;

  /*VARIABLES TO TWEAK*/
  //spring constant
  double K = 0.05;
  //how fast waves spread 0 - 0.5
  double SPREAD = .2;
  //dampening factor
  double DAMP = .005;
  /*tension of spring*/
  double TENSION = .01;
  /*speed*/
  double SPEED = 0;

  var springs = [];
  var spring = {};

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);

    double WAVE_COUNT = width / WAVE_FREQ + 1;

    //surface of water
    var START_Y = height / 1.75;
    //the depths
    var END_Y = height;

    //start height
    var HEIGHT = END_Y - START_Y;

    canvas.drawPoints(PointMode.lines, [Offset(20, 20), Offset(40, 40)], Paint()..color = Color.fromARGB(255, 0, 42, 84));
  }
}
