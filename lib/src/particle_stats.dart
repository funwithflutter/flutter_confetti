/// {@template particle_stats}
/// Information about the particle system.
/// {@endtemplate}
class ParticleStats {
  /// {@macro particle_stats}
  const ParticleStats({
    required this.numberOfParticles,
    required this.activeNumberOfParticles,
  });

  /// The number of particles in memory. These will be cleared when the
  /// controller is destroyed or the animation is finished.
  final int numberOfParticles;

  /// The number of particles currently active and visible on screen.
  final int activeNumberOfParticles;

  /// Returns an empty [ParticleStats] with all values set to 0.
  factory ParticleStats.empty() =>
      const ParticleStats(numberOfParticles: 0, activeNumberOfParticles: 0);

  @override
  String toString() =>
      'ParticleStats(numberOfParticles: $numberOfParticles, activeParticles: $activeNumberOfParticles)';
}
