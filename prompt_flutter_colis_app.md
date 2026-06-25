# PROMPT — Application Flutter "Colis Manager" (Architecture Senior DDD + SOLID)

---

## 🎯 CONTEXTE & OBJECTIF

Tu es un développeur Flutter senior expert en **Domain-Driven Design (DDD)**, **principes SOLID**, et architecture propre (**Clean Architecture**). Tu dois créer une application mobile Flutter complète, maintenable et évolutive.

**Problème métier :** Les transitaires (agents de fret) communiquent les informations de colis via des bots Messenger ou sites dispersés. L'utilisateur veut centraliser tous ces colis dans une seule app, organisée par transitaire et par mode de transport.

---

## 📐 ARCHITECTURE OBLIGATOIRE

### Pattern : Clean Architecture + DDD + SOLID

```
lib/
├── core/
│   ├── error/
│   │   ├── failures.dart          # Sealed class : ServerFailure, CacheFailure, etc.
│   │   └── exceptions.dart
│   ├── usecases/
│   │   └── usecase.dart           # Interface générique UseCase<Type, Params>
│   ├── utils/
│   │   ├── image_cropper_util.dart
│   │   └── text_parser_util.dart  # Parser le texte collé (tracking, poids, prix)
│   └── theme/
│       └── app_theme.dart
│
├── features/
│   ├── transitaire/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transitaire.dart        # Entité pure (pas de dépendance Flutter)
│   │   │   ├── repositories/
│   │   │   │   └── transitaire_repository.dart  # Interface abstraite
│   │   │   └── usecases/
│   │   │       ├── add_transitaire.dart
│   │   │       ├── get_all_transitaires.dart
│   │   │       └── delete_transitaire.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── transitaire_model.dart  # Étend l'entité + sérialisation JSON
│   │   │   ├── datasources/
│   │   │   │   └── transitaire_local_datasource.dart  # SQLite / Hive
│   │   │   └── repositories/
│   │   │       └── transitaire_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── transitaire_bloc.dart
│   │       │   ├── transitaire_event.dart
│   │       │   └── transitaire_state.dart
│   │       ├── pages/
│   │       │   ├── transitaire_list_page.dart   # Page principale
│   │       │   └── transitaire_detail_page.dart # Modes de transport
│   │       └── widgets/
│   │           └── transitaire_card.dart
│   │
│   ├── transport/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transport_mode.dart     # Enum + entité : AERIEN, MARITIME
│   │   │   ├── repositories/
│   │   │   │   └── transport_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_transport_mode.dart
│   │   │       └── get_transport_modes_by_transitaire.dart
│   │   ├── data/  (même structure)
│   │   └── presentation/
│   │       ├── bloc/  (TransportBloc)
│   │       ├── pages/
│   │       │   └── transport_mode_page.dart  # Liste des colis par mode
│   │       └── widgets/
│   │           └── transport_mode_card.dart
│   │
│   └── colis/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── colis.dart              # Entité principale
│       │   │   ├── colis_status.dart       # Enum : NON_LIVRE, LIVRE
│       │   │   └── unite_mesure.dart       # Enum : KG, M3
│       │   ├── repositories/
│       │   │   └── colis_repository.dart
│       │   └── usecases/
│       │       ├── add_colis.dart
│       │       ├── get_colis_by_transport.dart
│       │       ├── update_colis_status.dart         # Changement d'état (unitaire)
│       │       ├── bulk_update_colis_status.dart    # Changement d'état (multiple)
│       │       ├── calculate_total_amount.dart      # Montant total sélection
│       │       ├── calculate_total_weight.dart      # Poids/Volume total sélection
│       │       └── parse_colis_from_text.dart       # Parser le texte collé
│       ├── data/
│       │   ├── models/
│       │   │   └── colis_model.dart
│       │   ├── datasources/
│       │   │   └── colis_local_datasource.dart
│       │   └── repositories/
│       │       └── colis_repository_impl.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── colis_bloc.dart
│           │   ├── colis_event.dart
│           │   └── colis_state.dart
│           ├── pages/
│           │   ├── colis_list_page.dart         # Liste avec sélection multiple
│           │   └── add_colis_page.dart          # Formulaire + coller texte + image
│           └── widgets/
│               ├── colis_card.dart
│               ├── colis_selection_bar.dart     # Barre de sélection multiple
│               ├── total_summary_widget.dart    # Affiche montant + poids total
│               └── paste_text_dialog.dart       # Dialog pour coller le texte
│
└── injection_container.dart   # GetIt — injection de dépendances
```

---

## 🧱 ENTITÉS DOMAINE (Domain Entities)

### `Transitaire`
```dart
class Transitaire extends Equatable {
  final String id;
  final String nom;
  final String? logoPath;
  final DateTime createdAt;

  // Règle métier : nom non vide, id généré (UUID)
}
```

### `TransportMode`
```dart
class TransportMode extends Equatable {
  final String id;
  final String transitaireId;
  final TransportType type;  // enum : aerien | maritime
  final String? description;
}

enum TransportType { aerien, maritime }
```

### `Colis`
```dart
class Colis extends Equatable {
  final String id;
  final String transportModeId;
  final String trackingNumber;
  final double poids;          // valeur numérique
  final Unitemesure unite;     // KG ou M3 selon le mode
  final double prixFret;       // en Ariary
  final ColisStatus statut;    // NON_LIVRE | LIVRE
  final String? imagePath;     // chemin image croppée (optionnel)
  final DateTime dateAjout;

  // Règle métier : poids > 0, prixFret >= 0
}

enum ColisStatus { nonLivre, livre }
enum UniteMessure { kg, m3 }
```

---

## 🔧 FONCTIONNALITÉS À IMPLÉMENTER

### 1. Gestion des Transitaires
- Lister tous les transitaires (page d'accueil)
- Ajouter un transitaire (nom + logo optionnel)
- Supprimer un transitaire (avec confirmation + cascade sur les colis)
- Modifier un transitaire

### 2. Gestion des Modes de Transport
- Lister les modes de transport d'un transitaire
- Ajouter un mode : **Aérien** (unité : KG ou M3) ou **Maritime** (unité : M3 uniquement)
- Chaque mode affiche : nombre de colis, total poids/volume, total montant

### 3. Ajout de Colis (Feature principale)

#### a) Parsing automatique de texte collé
L'utilisateur colle ce texte :
```
Estimation tracking n°:  465441716960265
Le poids de ce colis est: 0.5KG
Le prix du fret de ce colis est: 33750Ar
```

Le parser (`TextParserUtil`) extrait via **RegExp** :
- `trackingNumber` → `465441716960265`
- `poids` → `0.5`
- `unite` → `KG`
- `prixFret` → `33750`

**Règles du parser :**
- Regex tracking : `tracking\s*n[°o]?\s*:?\s*(\d+)`
- Regex poids : `poids\s*(?:de\s*ce\s*colis\s*est)?\s*:?\s*([\d.]+)\s*(KG|M3|kg|m3)`
- Regex prix : `prix\s*(?:du\s*fret\s*de\s*ce\s*colis\s*est)?\s*:?\s*([\d.]+)\s*Ar`
- Si champs manquants → afficher erreur ciblée par champ

#### b) Capture + crop automatique d'image
- L'utilisateur prend une photo ou sélectionne depuis la galerie
- La librairie **`image_cropper`** s'ouvre automatiquement en mode crop manuel guidé
- L'image croppée est sauvegardée en local (`path_provider`)
- Elle s'affiche en miniature sur la card du colis

#### c) Statut initial
- Tout colis ajouté a automatiquement le statut **NON_LIVRE**

### 4. Sélection Multiple & Actions Groupées
- Mode sélection activé par **appui long** sur une card colis
- Checkbox apparaît sur chaque card en mode sélection
- Bouton **"Tout sélectionner"** dans l'AppBar
- **Barre d'action en bas** (BottomSheet ou BottomAppBar) affichant :
  - Nombre de colis sélectionnés
  - Montant total (ex: `125 000 Ar`)
  - Poids/Volume total (ex: `3.5 KG` ou `2.0 M3`)
  - Bouton **"Marquer comme Livré"** → change le statut en LIVRE pour tous les sélectionnés

### 5. Affichage & Filtres
- Filtrer par statut : Tous | Non Livrés | Livrés
- Trier par date d'ajout (récent → ancien)
- Recherche par numéro de tracking
- Badge compteur sur chaque mode de transport (ex: `12 colis · 3 non livrés`)

---

## 📦 PACKAGES FLUTTER À UTILISER

```yaml
dependencies:
  flutter_bloc: ^8.1.5          # State management
  equatable: ^2.0.5             # Comparaison d'entités
  get_it: ^7.6.7                # Injection de dépendances
  sqflite: ^2.3.2               # Base de données locale SQLite
  path_provider: ^2.1.2         # Chemins fichiers locaux
  image_picker: ^1.1.2          # Sélection image / caméra
  image_cropper: ^7.0.1         # Crop automatique de l'image
  uuid: ^4.3.3                  # Génération d'IDs uniques
  intl: ^0.19.0                 # Formatage dates et montants
  dartz: ^0.10.1                # Either<Failure, Success> pour les usecases
  flutter_slidable: ^3.1.0      # Swipe actions sur les cards
```

---

## 🗄️ SCHÉMA BASE DE DONNÉES SQLite

```sql
-- Table transitaires
CREATE TABLE transitaires (
  id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  logo_path TEXT,
  created_at TEXT NOT NULL
);

-- Table transport_modes
CREATE TABLE transport_modes (
  id TEXT PRIMARY KEY,
  transitaire_id TEXT NOT NULL,
  type TEXT NOT NULL,          -- 'aerien' | 'maritime'
  description TEXT,
  FOREIGN KEY (transitaire_id) REFERENCES transitaires(id) ON DELETE CASCADE
);

-- Table colis
CREATE TABLE colis (
  id TEXT PRIMARY KEY,
  transport_mode_id TEXT NOT NULL,
  tracking_number TEXT NOT NULL,
  poids REAL NOT NULL,
  unite TEXT NOT NULL,         -- 'kg' | 'm3'
  prix_fret REAL NOT NULL,
  statut TEXT NOT NULL DEFAULT 'non_livre',  -- 'non_livre' | 'livre'
  image_path TEXT,
  date_ajout TEXT NOT NULL,
  FOREIGN KEY (transport_mode_id) REFERENCES transport_modes(id) ON DELETE CASCADE
);
```

---

## 🎨 UI/UX GUIDELINES

### Navigation
```
HomePage (TransitaireListPage)
  └── TransitaireDetailPage (modes de transport)
        └── TransportModePage (liste des colis)
              └── AddColisPage (formulaire)
```

### Comportements UI importants
1. **HomePage** : GridView ou ListView des transitaires avec avatar/logo
2. **TransportModePage** :
   - En-tête sticky : total poids + total montant du mode
   - FAB (FloatingActionButton) pour ajouter un colis
   - Appui long → mode sélection multiple
3. **AddColisPage** :
   - TextArea pour coller le texte → bouton **"Parser"** → remplissage auto des champs
   - Les champs restent éditables après parsing
   - Section image : bouton caméra + galerie → crop auto → miniature
4. **Mode sélection** :
   - AppBar change (fond coloré, bouton fermer sélection, "Tout sélectionner")
   - BottomSheet persistant avec total en temps réel
5. **Statut visuel** :
   - NON_LIVRE → badge rouge / orange
   - LIVRE → badge vert avec icône check

### Couleurs suggérées
- Primaire : `#1565C0` (bleu fret maritime)
- Accent aérien : `#0288D1`
- Accent maritime : `#00695C`
- Statut non livré : `#E53935`
- Statut livré : `#2E7D32`

---

## ✅ RÈGLES DE CODE OBLIGATOIRES

### SOLID
- **S** — Chaque classe a une seule responsabilité (parser, repository, bloc séparés)
- **O** — `ColisRepository` est une interface : on peut changer SQLite → Hive sans toucher au domaine
- **L** — Les `UseCases` retournent `Either<Failure, T>` via `dartz`
- **I** — Interfaces spécifiques : `TransitaireLocalDatasource` ≠ `ColisLocalDatasource`
- **D** — Tout est injecté via `GetIt`, jamais instancié directement dans les widgets

### DDD
- Les entités du domaine ne dépendent d'**aucun** package externe
- Les `UseCases` encapsulent toute la logique métier
- Les `Models` (data layer) étendent les `Entities` (domain layer) et ajoutent `fromMap`/`toMap`
- Le `Bloc` ne contient **aucune** logique métier, il délègue aux `UseCases`

### Qualité
- Pas de `BuildContext` dans les blocs
- Gérer tous les états : Loading, Success, Error, Empty
- Les erreurs affichées à l'utilisateur sont des messages lisibles (pas de stack trace)
- Les `Stream` et controllers doivent être `dispose()`és

---

## 📋 ORDRE D'IMPLÉMENTATION RECOMMANDÉ

```
Phase 1 — Core & Setup
  [x] Configurer GetIt (injection_container.dart)
  [x] Créer core/error/ (Failure, Exception)
  [x] Créer core/usecases/usecase.dart
  [x] Créer core/utils/text_parser_util.dart (avec tests unitaires)

Phase 2 — Feature Transitaire (end-to-end)
  [x] Domain : Entité, Repository interface, UseCases
  [x] Data : Model, Datasource SQLite, Repository impl
  [x] Presentation : Bloc, Pages, Widgets

Phase 3 — Feature Transport Mode (end-to-end)
  [x] Même structure que Transitaire

Phase 4 — Feature Colis (end-to-end)
  [x] Domain : Entité, Repository interface, UseCases
  [x] Data : Model, Datasource SQLite, Repository impl
  [x] Presentation : Bloc + états de sélection multiple
  [x] Widgets : ColisCard, SelectionBar, TotalSummary

Phase 5 — Features transverses
  [x] image_picker + image_cropper intégration
  [x] TextParserUtil → PasteTextDialog
  [x] Filtres & recherche
  [x] Calcul totaux en temps réel

Phase 6 — Polish
  [x] Gestion erreurs globale
  [x] États vides (EmptyState widgets)
  [x] Animations de transition
  [x] Tests unitaires des UseCases et du parser
```

---

## 🧪 TESTS À ÉCRIRE

```dart
// test/features/colis/domain/usecases/parse_colis_from_text_test.dart
group('TextParserUtil', () {
  test('doit extraire tracking, poids et prix correctement', () { ... });
  test('doit retourner une erreur si le tracking est absent', () { ... });
  test('doit accepter KG et M3 comme unités', () { ... });
  test('doit ignorer les espaces supplémentaires', () { ... });
});
```

---

## 📌 NOTES COMPLÉMENTAIRES

- **Aérien** : unité peut être `KG` ou `M3` (configurable à la création du mode)
- **Maritime** : unité forcée à `M3` uniquement
- Le calcul du total poids dans la sélection multiple respecte l'unité du mode de transport
- Si deux colis d'unités différentes sont sélectionnés (impossible normalement car groupés par mode), afficher les deux totaux séparément
- L'image est **optionnelle** : un colis peut être ajouté sans photo
- La suppression d'un transitaire supprime en cascade tous ses modes et colis (ON DELETE CASCADE en SQLite)
- Prévoir un export futur (PDF ou Excel) : le domaine ne doit pas être couplé à l'UI pour faciliter cet ajout

---

*Ce document est le cahier des charges complet. Implémente feature par feature en respectant l'ordre des phases. Commence par la Phase 1.*
