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
