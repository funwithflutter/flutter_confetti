## Upcomming
⛔️ Breaking!
- Added the concept of delta time, to allow for better simulation when the refresh rate is 120 (or more than 60). There should be no noticable change on a 60fps screen, however, there may be variance if Flutter drops frames. No changes needed from a widget level.
- `ParticleSystem.update` and `Pariticle.update` now contain a `deltaTime` argument. No changes needed from a widget level.
- Some visual difference, as now not all particles will rotate on the z-axis (50% chance). This change was maded to enhance visual fidelity.

⭐️ Added
- `clearAllParticles` added to stop method on controller: `_confettiController.stop(clearAllParticles: true);` default is false. If true particles will immediately be cleared/removed on stop. Calling `dispose` will also clear all particles immediately.
- `particleStatsCallback` added to `Confetti` widget to retrieve the `ParticleStats`. This provides info on the particle system, such as number of active and number of total particles in memory.
- `pauseEmissionOnLowFrameRate` to `Confetti` widget. Default is true. This will pause additional confetti emission if the frame rate is below 60fps, and will continue when resources are available. This can be disabled by setting to `false`, to force particle creation regardless of frame rate.

⚡️ Improved
- Various performance improvements!
  - Confetti is now conditionally reused instead of recreated, big improvement
  - 120hz refresh rate supported
  - `pauseEmissionOnLowFrameRate` boolean added to `Confetti` widget to ensure smooth 60 FPS. This may however result in no confetti appearing if other complex operations are taking up resources. Set to `false` to disable.
  - Temporary fix for issue [[#66](https://github.com/funwithflutter/flutter_confetti/issues/66)] with severe perf issues on Chrome macOS.

## [0.7.0]
⭐️ Added
- Stroke width and color can now optionally be set. `strokeWidth` (default 0) and `strokeColor` (default black). Requires a stroke width bigger than 0
- Updated to Flutter 3.0

## [0.6.0]
🔄  Changed
- Removed the random_color package and replaced with custom logic. Random colors may now be slightly different.
- Updated dependencies

🐞 Fixed
- Unmounted exception (https://github.com/funwithflutter/flutter_confetti/issues/36). Thanks Iiropel.
- Moved `.super` call to the top of `initState`.

## [0.6.0-nullsafety]
Now with null safety :) - Thanks Ali1Ammar!

## [0.5.5]
Add optional `createParticlePath` function to pass in a custom `Path` for the conveti (for example a Star path, instead of the default Rectangle path). Example updated. Thanks Artur-Wisniewski.
Fix: Animation stop event not firing. Thanks WieFel.

## [0.5.4+1]
Fix: Call play on the confetti controller from `initState`.

## [0.5.4]
Fix: Confetti emitter position set incorrectly when transitioning to a new PageView. The emitter position is now set on animation start.
Fix: Set `ConfettiControllerState.stopped` on `ConfettiWidget` dispose.

## [0.5.3]
Add `canvas` parameter.

## [0.5.2]
Fix where at certain times the Confetti widget takes too long to emit. This update ensures that particles are generated on the first frame, and when there are no longer any particles on the screen but the animation is still running.

## [0.5.1]
Fixed layout issue where the screen size and confetti position were not updated on layout changes. The package will now respond to screen layout and sizing changes.

## [0.5.0]
Massive performance improvements. Should see a significant performance boost when running the application in profile/release mode. It is now possible to add a lot more confetti without the application causing jank. It is recommended to test the use of this package on multiple devices, to ensure it does not introduce performance issues on older devices.


## [0.4.0]
This update will result in a change in the default falling speed (gravity) and drag of the confetti. You may note a difference, and might be required to modify some of these paramaters to achieve the desired result

* Added an optional `gravity` to change the speed at which the confetti falls
* Added an optional `blastDirectionality` property. The default is `BlastDirectionality.directional` where you can specify a `blastDirection` to shoot the confetti in a specific direction. Change to `BlastDirectionality.explosive` to blast confetti in random directions
* Added an optional `particleDrag` property to configure the drag to apply to the confetti

## [0.3.0]
* Provide an optional `minimumSize` and `maximumSize` to customize the size of the confetti. For example, setting a `minimumSize` equal to `Size(10,10)` and a `maximumSize` equal to `Size(20,20)` will create confetti with a size between these two parameters. Can be provided as an argument in the `ConfettiWidget`

## [0.2.0]

* Provide an optional Color List to specify specific colors for the confetti. A single color, for example `[Colors.blue]`, or multiple colors `[Colors.blue, Colors.red, Colors.green]` can be provided as an argument in the `ConfettiWidget`

## [0.1.2]

* Provide optional child widget to render below the confetti
* Changed the painter to use foregroundPainter to always paint the confetti above its child

## [0.1.1]

* Patch null pointer exception

## [0.1.0]

* Initial release. You will probably experience some performance issues if you try and create too many particles at once
* Performance optimization work will be done in later versions.
