Blast some confetti all over the screen and celebrate user achievements!  

## Demo
[WEB Demo](https://funwithflutter.github.io/confetti/#/)

A video walkthrough is available [here](https://www.youtube.com/watch?v=jvhw3cfj2rk).


## Getting Started  
  
To use this plugin, add `confetti` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). 
  
See the example to get started quickly.

To begin you need to instantiate a `ConfettiController` variable and pass in a `Duration` argument. The `ConfettiController` can be instantiated in the `initState` method and disposed in the `dispose` method.

In the `build` method return a `ConfettiWidget`. The only attribute that is required is the `ConfettiController`.

Other attributes that can be set are:
* `blastDirectionality` -> an enum value to state if the particles shoot in random directions or a specific direction. `BlastDirectionality.explosive` will shoot in random directions and don't require a `blastDirection` to be set. `BlastDirectionality.directional` requires a `blastDirection` to specify the direction of the confetti.
* `blastDirection` -> a radial value to determine the direction of the particle emission. The default is set to `PI` (180 degrees). A value of `PI` will emit to the left of the canvas/screen.
* `emissionFrequency` -> should be a value between 0 and 1. The higher the value the higher the likelihood that particles will be emitted on a single frame. Default is set to `0.02` (2% chance)
* `numberOfParticles` -> the number of particles to be emitted per emission. Default is set to `10`
* `shouldLoop` -> determines if the emission will reset after the duration is completed, which will result in continues particles being emitted, and the animation looping
* `maxBlastForce` -> will determine the maximum blast force applied to a particle within it's first 5 frames of life. The default `maxBlastForce` is set to `20`
* `minBlastForce` -> will determine the minimum blast force applied to a particle within it's first 5 frames of life. The default `minBlastForce` is set to `5`
* `displayTarget` -> if `true` a crosshair will be displayed to show the location of the particle emitter
* `colors` -> a list of colors can be provided to manually set the confetti colors. If omitted then random colors will be used. A single color, for example `[Colors.blue]`, or multiple colors `[Colors.blue, Colors.red, Colors.green]` can be provided as an argument in the `ConfettiWidget
* `minimumSize` -> a `Size` controlling the minimum possible size of the confetti. To be used in conjuction with `maximumSize`. For example, setting a `minimumSize` equal to `Size(10,10)` will ensure that the confetti will never be smaller than the specified size. Must be positive and smaller than the `maximumSize`. Can not be null.
* `maximumSize` -> a `Size` controlling the maximum possible size of the confetti. To be used in conjuction with `minimumSize`. For example, setting a `maximumSize` equal to `Size(100,100)` will create confetti with a size somewhere between the minimum and maximum size of (100, 100) [widht, height]. Must be positive and bigger than the `minimumSize`, Can not be null.
* `gravity` -> change the speed at which the confetti falls. A value between 0 and 1. The higher the value the faster it will fall. Default is set to `0.1`
* `particleDrag` -> configure the drag force to apply to the confetti. A value between 0 and 1. A value of 1 will be no drag at all, while 0.1, for example, will be a lot of drag. Default is set to `0.05`
* `canvas` -> set the size of the area where the confetti will be shown, by default this is set to full screen size.

Enjoy the confetti.

*NOTE:* Don't be greedy with the number of particles. The more particles that are on screen the more calculations need to be performed. Performance improvements have been made, however this is still ongoing work. Too many particles will result in performance issues. Use wisely and carefully.
