/// Text parser utility for extracting colis information from pasted text.
///
/// Parses tracking number, weight, unit, and freight price from
/// text copied from transitaire bots/sites.

class ParsedColisData {
  final String? trackingNumber;
  final double? poids;
  final String? unite;
  final double? prixFret;

  const ParsedColisData({
    this.trackingNumber,
    this.poids,
    this.unite,
    this.prixFret,
  });
}

class TextParserResult {
  final ParsedColisData? data;
  final Map<String, String> errors;

  const TextParserResult({this.data, this.errors = const {}});

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => !hasErrors && data != null;
}

class TextParserUtil {
  /// Regex patterns for extracting colis information.
  static final RegExp _trackingRegex = RegExp(
    r'tracking\s*n[°o]?\s*:?\s*(\d+)',
    caseSensitive: false,
  );

  static final RegExp _poidsRegex = RegExp(
    r'(?:poids|volume)\s*(?:de\s*ce\s*colis\s*est)?\s*:?\s*([\d.]+)\s*(KG|M3|kg|m3)',
    caseSensitive: false,
  );

  static final RegExp _prixRegex = RegExp(
    r'prix\s*(?:du\s*fret\s*(?:de\s*ce\s*colis\s*est)?)?\s*:?\s*([\d.]+)\s*Ar',
    caseSensitive: false,
  );

  /// Parse the given text and extract colis data.
  ///
  /// Returns a [TextParserResult] with extracted data and/or field-specific errors.
  static TextParserResult parse(String text) {
    final errors = <String, String>{};

    // Extract tracking number
    final trackingMatch = _trackingRegex.firstMatch(text);
    final trackingNumber = trackingMatch?.group(1);
    if (trackingNumber == null) {
      errors['tracking'] = 'Numéro de tracking non trouvé dans le texte';
    }

    // Extract weight and unit
    final poidsMatch = _poidsRegex.firstMatch(text);
    double? poids;
    String? unite;
    if (poidsMatch != null) {
      poids = double.tryParse(poidsMatch.group(1) ?? '');
      unite = poidsMatch.group(2)?.toUpperCase();
      if (poids == null || poids <= 0) {
        errors['poids'] = 'Le poids doit être un nombre positif';
      }
    } else {
      errors['poids'] = 'Poids non trouvé dans le texte';
    }

    // Extract freight price
    final prixMatch = _prixRegex.firstMatch(text);
    double? prixFret;
    if (prixMatch != null) {
      prixFret = double.tryParse(prixMatch.group(1) ?? '');
      if (prixFret == null || prixFret < 0) {
        errors['prix'] = 'Le prix du fret doit être un nombre positif ou zéro';
      }
    } else {
      errors['prix'] = 'Prix du fret non trouvé dans le texte';
    }

    if (errors.isNotEmpty) {
      return TextParserResult(
        errors: errors,
        data: ParsedColisData(
          trackingNumber: trackingNumber,
          poids: poids,
          unite: unite,
          prixFret: prixFret,
        ),
      );
    }

    return TextParserResult(
      data: ParsedColisData(
        trackingNumber: trackingNumber!,
        poids: poids!,
        unite: unite!,
        prixFret: prixFret!,
      ),
    );
  }
}
