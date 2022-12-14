/// {@template blast_directionality}
/// Specifies the directionality of the blast for the particles.
///
/// This enum has two possible values:
/// - `directional`: the blast has a specific direction that must be provided.
/// - `explosive`: the blast has no particular direction and will blast in all
/// directions.
/// {@endtemplate}
enum BlastDirectionality {
  directional,
  explosive,
}
