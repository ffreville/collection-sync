# CollectionSync

Application Flutter (iOS/Android) pour gérer des collections d'objets, avec
synchronisation **directe entre téléphones sur le même réseau Wi-Fi, sans
serveur**.

Le concept complet (Utilisateurs → Univers → Collections à schéma libre →
Objets) est détaillé dans [docs/spec-universes-collections.md](docs/spec-universes-collections.md).
Des maquettes visuelles existent aussi dans [design/collectionsync/](design/collectionsync/), et
l'icône/écran de lancement dans [design/collectionsync-icon/](design/collectionsync-icon/).

## Comment ça marche

- **Stockage local** : chaque appareil garde ses données dans une base
  SQLite embarquée (`lib/db/database.dart`, via [drift](https://drift.simonbinder.eu/)) :
  `Universes`, `Collections` (avec un schéma de champs en JSON) et `Items`.
- **Découverte** : les appareils s'annoncent et se trouvent sur le réseau
  local via mDNS/Bonjour (`lib/sync/sync_service.dart`, via le package
  [`bonsoir`](https://pub.dev/packages/bonsoir)).
- **Transfert** : une fois deux appareils découverts, la synchro se fait par
  simple socket TCP direct entre les deux téléphones. Une session synchronise
  dans l'ordre les Univers, puis les Collections, puis les Objets (voir le
  protocole documenté dans `SyncService._runSyncSession` /
  `SyncService._syncKind`).
- **Conflits** : pas de fusion automatique (CRDT). Chaque entité synchronisée
  porte un `versionId` et un (ou deux, en cas de résolution de conflit)
  pointeur de version parente (`lib/sync/entities.dart`). Si deux appareils
  ont modifié la même entité indépendamment depuis leur dernier point commun,
  l'appli la considère "divergente" et demande à l'utilisateur de choisir
  quelle version garder (`lib/ui/conflict_resolution_screen.dart`).
- **Qui reçoit quoi automatiquement** : l'appareil qui *accepte* une connexion
  entrante applique tout ce que l'autre envoie, comme avant. L'appareil qui
  *lance* la synchro, lui, ne récupère pas automatiquement le contenu de
  l'autre (qu'il ne possède pas) : ces changements atterrissent dans
  `SyncService.pendingChanges`, groupés par Univers/Collection, et l'utilisateur
  choisit lesquels accepter sur `lib/ui/review_changes_screen.dart`. Son propre
  contenu (celui qu'il possède) continue de partir automatiquement vers l'autre
  appareil — voir `SyncService._runSyncSession`.
- **Droits** : chaque Univers (et par héritage ses Collections/Objets)
  appartient à un `ownerId`. On édite librement ce qu'on possède ; le contenu
  reçu d'un autre utilisateur via la synchro s'affiche en lecture seule, et
  les dépôts (`lib/sync/repositories.dart`) refusent l'écriture dessus même
  en cas de bug d'UI.

## Structure

```
lib/
  db/database.dart              Schéma SQLite : KnownUsers, Universes, Collections, Items
  models/field_schema.dart      Types de champs personnalisés + CollectionSchema
  sync/
    device_identity.dart        Identité (nom choisi à l'onboarding) de cet appareil
    entities.dart                Interface commune + logique de fusion (decideMerge)
    universe_payload.dart       Format d'échange réseau d'un Univers
    collection_payload.dart     Format d'échange réseau d'une Collection
    item_payload.dart           Format d'échange réseau d'un Objet
    conflicts.dart              Types de conflit (Univers/Collection/Objet)
    repositories.dart           Création/édition/suppression (gère versionnage + droits RW)
    sync_protocol.dart          Framing des messages (JSON sur socket TCP)
    sync_service.dart           Découverte mDNS + sessions de synchro + fusion
  ui/
    onboarding_screen.dart      Choix du nom au premier lancement
    users_screen.dart           Vous + utilisateurs déjà synchronisés
    universes_screen.dart       Univers d'un utilisateur
    collections_screen.dart     Collections d'un Univers
    collection_editor_screen.dart  Constructeur de schéma (champs, catégories, états)
    items_screen.dart           Liste/grille d'objets + recherche/filtres
    item_edit_screen.dart       Fiche objet, formulaire généré depuis le schéma
    peers_screen.dart           Appareils détectés sur le réseau + bouton "Synchroniser"
    conflict_resolution_screen.dart  Résolution manuelle des conflits (3 types)
```

## Lancer le projet

Pré-requis :

- Flutter (`brew install --cask flutter`)
- Pour iOS : Xcode complet installé depuis l'App Store (pas seulement les
  Command Line Tools), + CocoaPods (`brew install cocoapods` ou `sudo gem
  install cocoapods`)
- Pour Android : Android Studio ou le SDK en ligne de commande
  (`brew install --cask android-commandlinetools`), puis accepter les
  licences (`flutter doctor --android-licenses`) ; un JDK 21 est recommandé
  (`brew install openjdk@21` + `flutter config --jdk-dir=...`), les JDK trop
  récents cassent le build Gradle actuel.

Vérifier l'état de l'installation :

```bash
flutter doctor
```

Lancer sur un appareil/simulateur connecté :

```bash
flutter run
```

Régénérer le code de la base de données après une modification du schéma
(`lib/db/database.dart`) :

```bash
dart run build_runner build
```

Régénérer l'icône d'app / l'écran de lancement après une modification des
images source (`assets/icon/*.png`, régénérées elles-mêmes par
`design/collectionsync-icon/generate_assets.py` à partir du design) :

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Limites connues (MVP)

- La synchronisation ne fonctionne que sur le même réseau local (même
  Wi-Fi) — c'est un choix volontaire, pas une limitation technique de
  Flutter.
- Pas de suppression physique des tombstones (entités supprimées) : elles
  restent en base, marquées `deleted`, pour que la suppression puisse se
  synchroniser correctement.
- Le champ `photo` est envoyé en base64 dans le protocole de synchro (image
  compressée côté client via `image_picker`) ; un type `file` générique
  (pièce jointe de taille libre) est prévu mais pas encore implémenté — voir
  §5 du document de spec.
- Un `User` = une identité par installation de l'app ; un même humain sur
  deux appareils compte comme deux utilisateurs distincts pour l'instant.
- Les données sont amenées à être réinitialisées (`flutter clean` /
  désinstallation) pendant le développement — pas de migration de schéma
  n'est maintenue tant que le modèle bouge.
