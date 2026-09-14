# CollectionSync — Univers, Collections à schéma libre, Utilisateurs

Ce document reprend ce qui a été demandé, le reformule pour vérifier qu'on est
d'accord sur le concept, propose une structure de données, et détaille les
étapes pour l'implémenter. Rien n'est codé à ce stade — c'est la base de
discussion avant de passer au prompt de design puis à l'implémentation.

## 1. Ce qui est demandé (reformulation)

- On peut choisir un **nom d'utilisateur** dans l'app (au lieu du nom
  d'appareil générique actuel).
- Un écran liste les **utilisateurs** avec qui on s'est synchronisé au moins
  une fois. On peut consulter leurs collections en **lecture seule**. Les
  siennes sont en **lecture/écriture**.
- Un utilisateur organise ses collections par **Univers** (ex. Marvel,
  Disney).
- Dans un Univers, on crée des **Collections**.
- À la création d'une Collection, on définit la **liste des champs** qu'elle
  contient, chacun avec un type (texte, date, booléen, entier, photo,
  fichier, + suggestions ci-dessous).
- Certains champs sont **par défaut** (affichés directement, pour garder
  l'écran simple), les champs **personnalisés** sont regroupés ailleurs sur
  la fiche objet.
- La **Catégorie** est un champ par défaut, mais la liste des catégories
  possibles se définit **par collection** (ce n'est pas une liste globale
  fixe).
- Une fois la Collection créée : ajout, édition, suppression d'objets dedans.

C'est un changement d'échelle important par rapport à ce qui existe (une
seule table `Items` à colonnes fixes) : on passe à un modèle où
**l'utilisateur définit lui-même la structure de ses données**, avec
plusieurs niveaux (Utilisateur → Univers → Collection → Objet).

## 2. Types de champs

Demandés : texte, date, booléen, entier, photo, fichier.

Proposition complète (à valider) :

| Type | Usage | Remarque |
|---|---|---|
| `text` | texte court (nom, éditeur...) | |
| `long_text` | texte multi-ligne (notes, description) | remplace l'actuel "Notes" |
| `int` | entier (quantité, numéro d'édition...) | |
| `decimal` | nombre décimal (prix, valeur estimée) | affiché avec devise |
| `boolean` | case à cocher (ex. "complet", "signé") | |
| `date` | date (acquisition, sortie...) | |
| `enum` | choix unique dans une liste **définie par la collection** | sert pour Catégorie et État |
| `photo` | une image | voir §5 pour les implications sync |
| `file` | fichier quelconque (PDF, certif d'authenticité...) | voir §5 |
| `url` | lien (fiche produit, cote en ligne...) | *suggestion, optionnel* |
| `multi_select` | plusieurs choix dans une liste définie | *suggestion, ex. tags — optionnel, peut attendre* |
| `rating` | note en étoiles (0–5) | *suggestion, optionnel* |

Je propose de démarrer avec les 9 premiers (jusqu'à `file`), et de garder
`multi_select`/`rating` pour plus tard si besoin — pas nécessaire pour une v1.

## 3. Champs par défaut proposés

Pour que la fiche objet reste lisible même avec un gros paquet de champs
personnalisés, une Collection a toujours ces champs "de base" (visibles
directement dans la liste/fiche), le reste va dans une section "Champs
personnalisés" repliable :

| Champ | Type | Notes |
|---|---|---|
| Nom | `text` | obligatoire |
| Catégorie | `enum` | liste d'options définie à la création de la collection |
| Photo | `photo` | optionnel |
| Quantité | `int` | défaut 1 |
| Valeur estimée | `decimal` | optionnel |
| État | `enum` | liste par défaut (Neuf / Très bon état / Bon état / État moyen / Abîmé), personnalisable comme Catégorie |
| Notes | `long_text` | optionnel |

Ces 7 champs sont **toujours présents** (mais peuvent être laissés vides) —
c'est ce qui permet à la vue liste/grille d'avoir un affichage cohérent
quelle que soit la collection, avant même de regarder les champs
personnalisés propres à chaque collection.

## 4. Modèle de données proposé

```
User          — une identité (vous, ou une personne avec qui vous synchronisez)
  └─ Universe          — regroupement thématique (Marvel, Disney...), appartient à un User
       └─ Collection         — schéma de champs + règles (catégories/états possibles)
            └─ Item               — un objet, avec ses valeurs de champs
```

Points clés :

- **User** : en v1, un User = une identité par installation de l'app (donc
  aujourd'hui ≈ `DeviceIdentity`, juste avec un nom choisi par vous plutôt
  qu'un nom d'appareil générique). *Un même humain sur deux appareils =
  deux Users distincts* pour l'instant — unifier "plusieurs appareils, un
  seul humain" est possible plus tard mais ajoute de la complexité (il
  faudrait alors gérer les conflits entre appareils d'un même User, pas
  seulement entre Users différents). Je propose de le laisser de côté pour
  cette v1 et de le noter comme amélioration future.
- **Universe** et **Collection** utilisent le même mécanisme de versionnage
  que les Items aujourd'hui (`versionId` / `parentVersionId` /
  `parentVersionId2`, tombstone `deleted`) — donc le même protocole de sync
  et la même résolution de conflit manuelle s'appliquent à eux aussi.
- **Collection.fields** : je propose de stocker la liste des champs comme un
  **JSON unique** sur la Collection (`[{key, label, type, isDefault,
  options?}, ...]`) plutôt qu'une table séparée. Raison : le schéma d'une
  collection est édité comme un tout (on ne fusionne pas un champ à la fois
  entre appareils), donc un blob JSON versionné comme le reste de la
  Collection est plus simple que synchroniser une table enfant ligne par
  ligne, pour un gain de flexibilité nul en pratique ici.
- **Item.values** : de même, les valeurs des champs personnalisés d'un objet
  sont stockées en JSON (`{fieldKey: value}`), sauf les 7 champs par défaut
  du §3 qui restent des colonnes normales (comme aujourd'hui) pour permettre
  le tri/la recherche efficaces dans la liste/grille.
- **Droits RW/RO** : un `ownerId` sur Universe (hérité par Collection et
  Item) détermine qui peut éditer. L'app n'affiche les contrôles d'édition
  que si `ownerId == monIdentity.id`. Conséquence pratique intéressante :
  comme un contenu n'est légitimement modifié que par son propriétaire, les
  vrais conflits de fusion ne peuvent survenir qu'entre plusieurs appareils
  *du même* User — dans le futur, pas dans cette v1 où User = 1 appareil.
  Le mécanisme de conflit reste utile et actif, mais se déclenchera
  rarement en v1.

## 5. Photos et fichiers : implication sur la synchro

Nouveau problème posé par les champs `photo`/`file` : le protocole actuel
n'échange que du JSON texte (voir `sync_protocol.dart`). Une image doit
voyager elle aussi entre les deux téléphones.

Proposition v1 : pour le champ **`photo`** uniquement, compresser/redimensionner
l'image côté client (ex. max 1600px, JPEG) puis l'inclure en base64 dans le
payload JSON de l'objet — le réseau local est rapide, quelques centaines de
Ko par photo restent gérables sans changer le protocole.

Le champ **`file`** (taille arbitraire, non compressible) est plus délicat :
je propose de le reporter à une v2 avec un vrai mécanisme de transfert par
blocs (le pair envoie d'abord les métadonnées, l'autre demande le contenu
seulement s'il ne l'a pas déjà, transfert en chunks) plutôt que de l'inclure
dans le JSON. À valider : voulez-vous `file` dès la v1 malgré cette
complexité, ou seulement `photo` pour commencer ?

## 6. Écrans à prévoir

1. **Choix du nom d'utilisateur** — à la première ouverture (et modifiable
   ensuite), remplace le nom d'appareil auto-généré actuel.
2. **Liste des utilisateurs** — vous (RW) en premier, puis chaque personne
   avec qui une synchro a déjà eu lieu au moins une fois (RO), avec un
   indicateur "en ligne maintenant" basé sur la découverte mDNS en direct.
   *(Remplace/étend l'actuel écran "Peers", qui n'était qu'une liste
   éphémère d'appareils détectés à l'instant T — il faut désormais la
   mémoriser durablement.)*
3. **Liste des Univers** d'un utilisateur sélectionné.
4. **Liste des Collections** d'un Univers.
5. **Création/édition d'une Collection** — nom, liste des champs
   personnalisés (type, libellé, obligatoire ou non), liste des catégories
   possibles, liste des états possibles.
6. **Liste des objets d'une Collection** — vue liste (actuelle) *et* vue
   grille avec photos, plus recherche/filtre (par nom, catégorie, état,
   champs personnalisés).
7. **Fiche objet** (création/édition) — champs par défaut en haut, champs
   personnalisés de la collection en dessous, généré dynamiquement à partir
   du schéma de la Collection.
8. Écran de résolution de conflits (déjà existant) — étendu pour pouvoir
   afficher un conflit sur un Univers ou une Collection, pas seulement un
   Item.

## 7. Étapes de réalisation proposées

1. **Modèle de données** — nouvelles tables `Users`, `Universes`,
   `Collections` (avec `fieldsJson`), refonte d'`Items` (`collectionId`,
   colonnes fixes pour les 7 champs par défaut + `valuesJson` pour le reste).
   Migration : comme les données actuelles ne sont que des données de test,
   je propose de repartir à zéro plutôt que d'écrire une migration — à
   confirmer.
2. **Identité utilisateur** — écran de choix de nom, remplace
   `DeviceIdentity` par un `User` nommé.
3. **Constructeur de schéma de Collection** — création/édition d'une
   Collection avec sa liste de champs typés et ses listes de
   catégories/états.
4. **Formulaire d'objet dynamique** — génère le formulaire de saisie/édition
   à partir du schéma de la Collection courante.
5. **Navigation Univers → Collections → Objets** — remplace l'écran unique
   "Ma collection" actuel par cette hiérarchie.
6. **Vue grille + recherche/filtres** sur la liste d'objets.
7. **Écran "Utilisateurs"** — remplace/étend "Peers" en liste persistante,
   avec statut RW/RO et en ligne/hors ligne.
8. **Extension du protocole de sync** — Universes et Collections suivent le
   même schéma manifest/request/items que les Items aujourd'hui ; ajout du
   support des photos en base64 dans le payload d'un Item.
9. **Application des droits RW/RO** — dans l'UI (masquer les actions
   d'édition) et dans la couche `ItemRepository`/équivalents (refuser
   l'écriture sur un contenu dont on n'est pas propriétaire, même en cas de
   bug d'UI).

## 8. Points à trancher avant de coder

- Champ `file` (fichiers volumineux) dès la v1, ou seulement `photo` pour
  commencer (§5) ?
- On repart à zéro sur les données locales existantes, ou vous tenez à
  garder ce qui a déjà été saisi en test (§7, étape 1) ?
- Le nom d'utilisateur est-il modifiable après coup, avec quel effet sur les
  Univers/Collections déjà synchronisés chez d'autres (on garde l'ancien nom
  affiché chez eux jusqu'à la prochaine synchro, ou on précise que le nom
  peut "traîner" un peu) ?
- Les listes de catégories/états définies sur une Collection : un
  utilisateur qui les modifie après coup (renomme/supprime une catégorie)
  impacte-t-il les objets qui l'utilisaient déjà ? (proposition simple :
  oui, la valeur du champ enum stockée sur l'objet reste du texte libre en
  interne — si l'option a disparu de la liste, elle continue à s'afficher
  telle quelle sur les objets existants, juste plus proposée pour les
  nouveaux objets).
