enum ColisStatus {
  enTransit,
  livre;

  String get label {
    switch (this) {
      case ColisStatus.enTransit:
        return 'En transit';
      case ColisStatus.livre:
        return 'Livré';
    }
  }

  String get value {
    switch (this) {
      case ColisStatus.enTransit:
        return 'en_transit';
      case ColisStatus.livre:
        return 'livre';
    }
  }

  bool get isNonLivre => this != ColisStatus.livre;

  static ColisStatus fromString(String value) {
    switch (value) {
      case 'en_transit':
        return ColisStatus.enTransit;
      case 'livre':
        return ColisStatus.livre;
      default:
        return ColisStatus.enTransit;
    }
  }
}
