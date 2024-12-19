# Projet-Info-2024-2025

Ce projet consiste à créer un programme permettant de faire la synthèse de données d’un système de distribution d'électricité.Il utilise un script shell pour filtrer et traiter les données et un programme C pour la partie calcul.

## Comment faire pour que le programme compile et qu'il s'exécute ?
Il faut mettre les fichiers d'entrée dans le dossier input. (chemin : Projet-Info-2024-2025-main/input).
Lors de l'exécution du programme il faut être dans le bon dossier (faire cd "chemin du fichier télécharger").
Exemple : cd ~/Documents/Projet-Info-2024-2025-main (peu importe le chemin il faut être dans Projet-Info-2024-2025-main).
Commande pour l'éxecution : bash c-wire.sh input/"le fichier d'entrée" "type de station" "type de consommateur" "identifiant de centrale (optionnel)" "-h (optionnel et pour aide)"
Exemple : bash c-wire.sh input/c-wire_v00.dat hvb comp 1
Les fichiers résultats seront dans le dossier principal, les fichiers temporaires dans tmp, les graphiques dans graphs et nos essais dans tests.
Sur certains ordinateurs la première exécution peut prendre 30 secondes mais les suivantes seront beacoup plus rapides (entre 0.3 et 6 secondes).

## Comment ça fonctionne ?

La partie shell va prendre en entrée le fichier de données et va compiler make dans le dossier codeC, puis le shell vas sélectionner les lignes et colonnes correspondantes à la demande de l'utilisateur. Le C qui recevra ces lignes par entrée directe via le shell vas additionner les valeurs de capacité et de consommation pour chaque identifiant des différentes stations demandées.
Pour lv all le programme vas faire un tri supplémentaire qui vas garder les 10 premières et 10 dernières stations. Puis il va les trier par leur capacité moins la consommation. 


## Ce que l'on a utilisé

Langage de programmation: Langage C, script shell.
Les différentes bibliothèques utilisées: stdlib.h,stdio.h,math.h,assert.h.
Chat gpt : 15% (notamment pour se lancer dans le projet).

## Auteurs
Lucien Boyer
Eliot Durand de Gevigney
Marc-Antoine 
