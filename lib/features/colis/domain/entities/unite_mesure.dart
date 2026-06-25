/// Unite de mesure enum.
enum UniteMesure {
  kg,
  m3;

  String get label => this == UniteMesure.kg ? 'KG' : 'M3';

  String get value => this == UniteMesure.kg ? 'kg' : 'm3';

  static UniteMesure fromString(String value) {
    return value.toLowerCase() == 'm3' ? UniteMesure.m3 : UniteMesure.kg;
  }
}
