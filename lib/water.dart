import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';

class Water extends RectangleComponent {
  Water({position}) : super(position: position);

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
      var spring = {}

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

      
  }

  void init()
			{
				for(var i = 0; i < WAVE_COUNT; i++)
				{
					var nw = {};
					nw.x = i*WAVE_FREQ;
					nw.speed = SPEED;
					nw.height = HEIGHT;
					nw.update = function(){
						var x = HEIGHT - this.height;
						this.speed += TENSION * x - this.speed * DAMP;
						this.height += this.speed;
					};
					
					springs[i] = nw;
				}
				
			}
}
