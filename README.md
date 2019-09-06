Blast some confetti all over the screen and celebrate user achievements!  

## Demo
<img height="480px" src="https://media.giphy.com/media/ZA4gWAVlhx18f3fhMY/giphy.gif">

A video walkthrough is available [here](https://www.youtube.com/watch?v=jvhw3cfj2rk).


## Getting Started  
  
To use this plugin, add `confetti` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). 
  
See the example to get started quickly.

To begin you need to instantiate a `ConfettiController` variable and pass in a `Duration` argument. The `ConfettiController` can be instantiated in the `initState` method and disposed in the `dispose` method.

In the `build` method return a `ConfettiWidget`. The only attribute that is required is the `ConfettiController`.

Other attributes that can be set are:
* `blastDirection` -> a radial value to determine the direction of the particle emission. The default is set to `PI` (180 degrees). A value of `PI` will emit to the left of the canvas/screen.
* `emissionFrequency` -> should be a value between 0 and 1. The higher the value the higher the likelihood that particles will be emitted on a single frame. Default is set to `0.02` (2% chance)
* `numberOfParticles` -> the number of particles to be emitted per emission. Default is set to `10`
* `shouldLoop` -> determines if the emission will reset after the duration is completed, which will result in continues particles being emitted, and the animation looping
* `maxBlastForce` -> will determine the maximum blast force applied to a particle within it's first 5 frames of life. The default `maxBlastForce` is set to `20`
* `minBlastForce` -> will determine the minimum blast force applied to a particle within it's first 5 frames of life. The default `minBlastForce` is set to `5`
* `displayTarget` -> if `true` a crosshair will be displayed to show the location of the particle emitter

Enjoy the confetti.

*NOTE:* Don't be greedy with the number of particles. Too many will result in performance issues. Future versions might be more performant. Use wisely and carefully.
