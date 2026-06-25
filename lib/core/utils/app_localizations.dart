import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  bool get isFrench => locale.languageCode == 'fr';

  String translate(String fr, String en) => isFrench ? fr : en;

  static final Map<String, Map<String, String>> _strings = {
    'colis': {'fr': 'Colis', 'en': 'Package'},
    'poids': {'fr': 'Poids', 'en': 'Weight'},
    'volume': {'fr': 'Volume', 'en': 'Volume'},
    'livré': {'fr': 'Livré', 'en': 'Delivered'},
    'non_livré': {'fr': 'Non Livré', 'en': 'Not Delivered'},
    'aérien': {'fr': 'Aérien', 'en': 'Air'},
    'maritime': {'fr': 'Maritime', 'en': 'Sea'},
    'tracking': {'fr': 'Numéro de tracking', 'en': 'Tracking number'},
    'prix_fret': {'fr': 'Fret (Ar)', 'en': 'Freight (Ar)'},
    'aucun_colis': {'fr': 'Aucun colis', 'en': 'No packages'},
    'aucun_transitaire': {'fr': 'Aucun transitaire', 'en': 'No agents'},
    'ajouter': {'fr': 'Ajouter', 'en': 'Add'},
    'modifier': {'fr': 'Modifier', 'en': 'Edit'},
    'supprimer': {'fr': 'Supprimer', 'en': 'Delete'},
    'annuler': {'fr': 'Annuler', 'en': 'Cancel'},
    'enregistrer': {'fr': 'Enregistrer', 'en': 'Save'},
    'rechercher': {'fr': 'Rechercher par tracking...', 'en': 'Search by tracking...'},
    'tous': {'fr': 'Tous', 'en': 'All'},
    'selectionnes': {'fr': 'sélectionné(s)', 'en': 'selected'},
    'marquer_livre': {'fr': 'Marquer comme Livré', 'en': 'Mark as Delivered'},
    'exporter_pdf': {'fr': 'Exporter en PDF', 'en': 'Export to PDF'},
    'coller_texte': {'fr': 'Coller le texte', 'en': 'Paste text'},
    'parser': {'fr': 'Parser', 'en': 'Parse'},
    'photo_colis': {'fr': 'Photo du colis (optionnel)', 'en': 'Package photo (optional)'},
    'camera': {'fr': 'Caméra', 'en': 'Camera'},
    'galerie': {'fr': 'Galerie', 'en': 'Gallery'},
    'transitaire': {'fr': 'Transitaire', 'en': 'Agent'},
    'nouveau_colis': {'fr': 'Nouveau colis', 'en': 'New package'},
    'modifier_colis': {'fr': 'Modifier le colis', 'en': 'Edit package'},
    'colis_ajoute': {'fr': 'Colis ajouté avec succès', 'en': 'Package added successfully'},
    'colis_modifie': {'fr': 'Colis modifié avec succès', 'en': 'Package updated successfully'},
    'colis_supprime': {'fr': 'Colis supprimé', 'en': 'Package deleted'},
    'transitaire_ajoute': {'fr': 'Transitaire ajouté avec succès', 'en': 'Agent added successfully'},
    'aucun_resultat': {'fr': 'Aucun résultat', 'en': 'No results'},
    'reinitialiser_filtres': {'fr': 'Réinitialiser les filtres', 'en': 'Reset filters'},
    'confirmer_suppression': {'fr': 'Êtes-vous sûr de vouloir supprimer', 'en': 'Are you sure you want to delete'},
  };

  static String get(String key, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isFr = locale.languageCode == 'fr';
    return _strings[key]?[isFr ? 'fr' : 'en'] ?? key;
  }
}
