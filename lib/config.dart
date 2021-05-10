class Config {
  static const alpha = String.fromEnvironment('release') == 'alpha';
  static const beta = alpha || String.fromEnvironment('release') == 'beta';
  static const release = !beta;

  static const isMP = String.fromEnvironment('flavor') == 'mp';
  static const isMPGO = !isMP;
  static const flavor = isMP ? Flavor.mp : Flavor.mpgo;
}

class Flavor {
  final String name, id, tag;
  const Flavor._(this.name, this.id, this.tag);
  static const mpgo = Flavor._('MEMOplanner Go', 'memoplannergo', 'mpgo');
  static const mp = Flavor._('MEMOplanner', 'memoplanner', 'mp');
}
