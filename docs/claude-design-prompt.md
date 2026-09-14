# Prompt pour Claude Design — CollectionSync

Copiez-collez le bloc ci-dessous dans Claude Design.

---

Conçois les maquettes mobiles (iOS/Android) d'une application appelée
**CollectionSync**. C'est une app de gestion de collections d'objets
(figurines, comics, timbres, vinyles... tout type de collection), dont la
particularité est de se synchroniser directement entre téléphones sur le
même Wi-Fi, sans aucun serveur ni compte en ligne.

## Structure de l'app

Chaque utilisateur organise ses collections ainsi :

```
Utilisateur → Univers (ex. "Marvel", "Disney") → Collection (ex. "Figurines Marvel Legends") → Objets
```

On peut aussi voir les univers/collections d'autres utilisateurs avec qui on
s'est déjà synchronisé, en **lecture seule** (les siens restent en
lecture/écriture).

Chaque Collection a un **schéma de champs personnalisé** défini par
l'utilisateur à sa création (types : texte, texte long, entier, décimal,
booléen, date, choix unique dans une liste, photo, lien URL). 7 champs sont
toujours présents par défaut pour garder l'affichage lisible : Nom,
Catégorie, Photo, Quantité, Valeur estimée, État, Notes — les champs
personnalisés de la collection apparaissent en dessous, dans une section à
part sur la fiche objet.

## Écrans à concevoir

1. **Onboarding / choix du nom** — premier lancement, on choisit son nom
   d'utilisateur (affiché aux autres lors des synchros).
2. **Liste des utilisateurs** — soi-même en premier (badge "vous", accès
   complet), puis chaque personne déjà synchronisée au moins une fois
   (badge "lecture seule"), avec indicateur en ligne/hors ligne (détecté en
   direct sur le Wi-Fi).
3. **Liste des Univers** d'un utilisateur sélectionné — vignettes/cartes,
   possibilité d'en créer un nouveau (soi-même uniquement).
4. **Liste des Collections** d'un Univers — cartes avec aperçu (ex. mosaïque
   des dernières photos ajoutées), nombre d'objets.
5. **Création/édition d'une Collection** — nom, constructeur de champs
   personnalisés (ajouter un champ : libellé + type, glisser pour réordonner
   éventuellement), édition de la liste des catégories possibles, édition de
   la liste des états possibles.
6. **Liste des objets d'une collection** — deux vues : **liste** (compacte,
   texte) et **grille** (cartes avec photo en avant, façon galerie) avec un
   sélecteur pour basculer entre les deux ; barre de recherche + filtres
   (catégorie, état, champs personnalisés).
7. **Fiche objet** (création/édition) — champs par défaut en haut (avec la
   photo bien mise en valeur), champs personnalisés de la collection dans
   une section "Détails" en dessous, générée dynamiquement selon le schéma.
8. **Écran de synchronisation** — liste des appareils détectés sur le Wi-Fi
   avec bouton "Synchroniser", état de progression, et affichage du nombre
   de conflits éventuels après une synchro.
9. **Résolution de conflit** — quand un objet (ou une collection/univers) a
   été modifié différemment sur deux appareils : affichage côte à côte des
   deux versions, choix explicite de laquelle garder (pas de fusion
   automatique).

## Ton / style

Application grand public, chaleureuse mais épurée — l'utilisateur va y
passer du temps à admirer ses objets, donc les photos doivent respirer
(grandes vignettes, peu de bordures/chrome autour). Un style neutre qui
s'adapte à n'importe quel type de collection (pas de thème "super-héros"
appuyé même si l'exemple est Marvel) : palette sobre avec un accent de
couleur, typographie claire, coins arrondis doux, mode sombre pris en
charge. Prioriser la lisibilité des listes/formulaires denses (schéma de
champs, filtres) autant que le plaisir visuel de la vue grille.

## Plateforme

Mobile d'abord (iPhone + Android), portrait. Pas besoin de version tablette
ni web pour cette première passe.

---
