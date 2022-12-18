/// {@template confetti_controller_state}
/// Represents the current state of the Confetti animation.
///
/// This enum has two possible values:
/// - `playing`: the Confetti animation is currently playing.
/// - `stopped`: the Confetti animation is currently stopped.
/// - `stoppedAndCleared`: the Confetti animation is currently stopped and all
/// particles are immediately cleared.
/// - `disposed`: the Confetti animation has been disposed.
/// {@endtemplate}
enum ConfettiControllerState {
  playing,
  stopped,
  stoppedAndCleared,
  disposed,
}
