class Config {
  static const dev = String.fromEnvironment('release') == 'dev';
  static const release = !dev;

  static const isMP = true; // String.fromEnvironment('flavor') == 'mp';
  static const isMPGO = !isMP;
  static const flavor = isMP ? Flavor.mp : Flavor.mpgo;
}

class Flavor {
  final String name, id;

  const Flavor._(this.name, this.id);

  static const mpgo = Flavor._('MEMOplanner Go', 'memoplannergo');
  static const mp = Flavor._('MEMOplanner', 'memoplanner');
}
