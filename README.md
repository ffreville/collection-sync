# CollectionSync

Application Flutter (iOS/Android) pour gérer une collection d'objets, avec
synchronisation **directe entre téléphones sur le même réseau Wi-Fi, sans
serveur**.

## Comment ça marche

- **Stockage local** : chaque appareil garde sa collection dans une base
  SQLite embarquée (`lib/db/database.dart`, via [drift](https://drift.simonbinder.eu/)).
- **Découverte** : les appareils s'annoncent et se trouvent sur le réseau
  local via mDNS/Bonjour (`lib/sync/sync_service.dart`, via le package
  [`bonsoir`](https://pub.dev/packages/bonsoir)).
- **Transfert** : une fois deux appareils découverts, la synchro se fait par
  simple socket TCP direct entre les deux téléphones (voir le protocole
  documenté dans `SyncService._runSyncSession`).
- **Conflits** : pas de fusion automatique (CRDT). Chaque objet porte un
  `versionId` et un (ou deux, en cas de résolution de conflit) pointeur de
  version parente. Si deux appareils ont modifié le même objet indépendamment
  depuis leur dernier point commun, l'appli les considère "divergents" et
  demande à l'utilisateur de choisir quelle version garder
  (`lib/ui/conflict_resolution_screen.dart`).

## Structure

```
lib/
  db/database.dart              Schéma SQLite (table Items + champs de version)
  sync/
    device_identity.dart        Identifiant + nom persistants de l'appareil
    item_payload.dart           Format d'échange réseau d'un objet
    item_repository.dart        Création/édition/suppression (gère le versionnage)
    sync_protocol.dart          Framing des messages (JSON sur socket TCP)
    sync_service.dart           Découverte mDNS + sessions de synchro + fusion
  ui/
    home_screen.dart            Liste de la collection
    item_edit_screen.dart       Ajout / édition d'un objet
    peers_screen.dart           Appareils détectés sur le réseau + bouton "Synchroniser"
    conflict_resolution_screen.dart  Résolution manuelle des conflits
```

## Lancer le projet

Pré-requis :

- Flutter (`brew install --cask flutter`)
- Pour iOS : Xcode complet installé depuis l'App Store (pas seulement les
  Command Line Tools), + CocoaPods (`brew install cocoapods` ou `sudo gem
  install cocoapods`)
- Pour Android : Android Studio ou le SDK en ligne de commande
  (`brew install --cask android-commandlinetools`), puis accepter les
  licences (`flutter doctor --android-licenses`)

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

## Limites connues (MVP)

- La synchronisation ne fonctionne que sur le même réseau local (même
  Wi-Fi) — c'est un choix volontaire, pas une limitation technique de
  Flutter : voir la discussion sur la synchro à distance si besoin un jour.
- Pas de suppression physique des tombstones (objets supprimés) : ils
  restent en base, marqués `deleted`, pour que la suppression puisse se
  synchroniser correctement.
- Pas de photo/image sur les objets pour l'instant.
