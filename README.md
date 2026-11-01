# CollectionSync

Application Flutter (iOS/Android, et une version web) pour gérer des
collections d'objets, avec synchronisation **directe entre appareils sur le
même réseau Wi-Fi, sans serveur**.

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
  simple socket TCP direct entre les deux téléphones
  (`lib/sync/socket_channel.dart`). Une session synchronise
  dans l'ordre les Univers, puis les Collections, puis les Objets (voir le
  protocole documenté dans `SyncService._runSyncSession` /
  `SyncService._syncKind`).
- **Appairage par QR code (WebRTC)** : un navigateur ne peut faire ni mDNS
  ni socket TCP. La version web (et l'app, en secours) se connecte donc par un
  canal de données WebRTC direct (`lib/sync/webrtc_pairing.dart`). Sans
  serveur de signalisation, les deux appareils échangent leur description de
  connexion par QR code : l'un « démarre » et affiche un code, l'autre le
  scanne et affiche sa réponse, que le premier scanne à son tour. Aucun
  serveur STUN/TURN n'est configuré, donc même Wi-Fi obligatoire. Le
  protocole de synchro qui passe ensuite dans ce canal est exactement le même
  qu'en TCP (`MessageChannel`, `lib/sync/sync_protocol.dart`).
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
    sync_protocol.dart          Messages + interface de transport (MessageChannel)
    socket_channel.dart         Transport TCP (natif)
    lan/                        Découverte mDNS + connexion TCP (natif ; absent sur le web)
    webrtc_pairing.dart         Appairage par QR code + transport WebRTC
    webrtc_signal.dart          Encodage des QR codes, découpage des messages en trames
    sync_service.dart           Sessions de synchro + fusion
  ui/
    onboarding_screen.dart      Choix du nom au premier lancement
    users_screen.dart           Vous + utilisateurs déjà synchronisés
    universes_screen.dart       Univers d'un utilisateur
    collections_screen.dart     Collections d'un Univers
    collection_editor_screen.dart  Constructeur de schéma (champs, catégories, états)
    items_screen.dart           Liste/grille d'objets + recherche/filtres
    item_edit_screen.dart       Fiche objet, formulaire généré depuis le schéma
    peers_screen.dart           Appareils détectés sur le réseau + bouton "Synchroniser"
    qr_sync_screen.dart         Synchro par QR code (démarrer / rejoindre)
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

## Version web (pour les iPhone sans compte développeur)

La même application tourne dans un navigateur : `flutter build web`. La base
SQLite y est compilée en WebAssembly et stockée dans le navigateur
(`lib/db/connection/web.dart`), et la synchro passe par l'appairage QR code.
Deux fichiers de `web/` sont nécessaires :

- `sqlite3.wasm` : récupéré depuis la [release GitHub de sqlite3.dart](https://github.com/simolus3/sqlite3.dart/releases)
  correspondant à la version du package `sqlite3` dans `pubspec.lock`. À
  mettre à jour en même temps que ce package.
- `drift_worker.js` : compilé depuis `tool/drift_worker.dart`. À regénérer
  après une mise à jour de drift :

```bash
dart compile js -O4 -o web/drift_worker.js tool/drift_worker.dart
```

**Hébergement** : le workflow `.github/workflows/deploy-web.yml` publie le
site sur GitHub Pages à chaque push sur `main`. Pour l'activer, aller dans
Settings → Pages → Source : « GitHub Actions ». Pages sur un dépôt privé
demande un compte GitHub payant. Le HTTPS de Pages est indispensable : la
caméra et le stockage persistant ne marchent pas en HTTP.

**Sur iPhone** : ouvrir le site dans Safari, puis Partager → « Sur l'écran
d'accueil ». Installée ainsi, l'app est à l'abri du nettoyage automatique
des données que Safari applique aux sites peu visités.

Limites de la version web :

- pas de découverte automatique : toujours passer par le QR code ;
- pas de sauvegarde/restauration de fichier : la base vit dans le stockage
  du navigateur ;
- la recherche de code-barres peut échouer si l'API interrogée refuse les
  requêtes venant d'un navigateur (CORS) ;
- le réseau doit autoriser le mDNS : les navigateurs masquent l'adresse IP
  locale derrière un nom `xxx.local`, que l'autre appareil doit résoudre.

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
