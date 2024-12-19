# Project-Info-2024-2025

Ce projet consiste consiste à créer un programme permettant de faire la synthèse de données d’un système de distribution d'électricité.Il utilise un script shell pour filtrer et traiter les données et un programme C pour la partie calcul.

## Comment faire pour que le programme compile et qu'il s'exécute ?
Il faut mettre les fichiers d'entrée dans le dossier input.
Lors de l'execution du programme il faut être dans le bon dossier (faire cd "chemin du fichier télécharger").
Commande pour l'éxecution : bash c-wire.sh "le chemin du fichier d'entrée" "type de station" "type de consommateur" "identifiant de centrle(optionnel)" "-h(optionnel et pour aide)"
Exemple : bash c-wire.sh input/c-wire_v00.dat hvb comp 1
Les fichiers résultats seront dans le dossier principal, les fichiers temporaires dans tmp, les graphiques dans graphs et nos eessaies dans tests.

## Comment ça fonctionne ?

La partie shell vas prendre en entrée le fichier de données et vas compiler make dans le dossier codeC, puis le shell vas sélectionner les lignes et colonnes correspondante à la demande de l'utilisateur. Le C qui recevra ces lignes par entrée directe via le shell vas additioner les valeurs de capacité et de consommation pour chaque identifiants des différentes stations demandées.
Pour lv all le programme vas faire un tri supplémentaire qui vas garder les 10 premiers et 10 derniers


## Ce que l'on a utilisé

Langage de programmation: Langage C, script shell.

Les differentes bibliothèques utilisées: stdlib.h,stdio.h,math.h,assert.h

## Auteurs
