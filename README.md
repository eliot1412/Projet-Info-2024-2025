# Projet-Info-2024-2025

Ce projet consiste à créer un programme permettant de faire la synthèse de données d’un système de distribution d'électricité.Il utilise un script shell pour filtrer et traiter les données et un programme C pour la partie calcul.

## Comment faire pour que le programme compile et qu'il s'exécute ?

Quand vous êtes dans le github, il faut tout d'abord être dans la branche "main", ensuite cliquer sur "<> Code", et enfin tout télécharger en zip (Download ZIP)

Ensuite vous devrez extraire l'entièreté du zip dans un repertoire. 
Exemple : Documents ou Dossier Personnel

Il faut mettre les fichiers d'entrée que vous voulez dans le dossier input. (chemin : Projet-Info-2024-2025-main/input).

Lors de l'exécution du programme il faut être dans le bon dossier (faire cd "chemin du fichier télécharger").

Exemple : cd ~/Documents/Projet-Info-2024-2025-main (peu importe le chemin il faut être dans Projet-Info-2024-2025-main).

Commande pour l'éxecution : bash c-wire.sh input/"le fichier d'entrée" "type de station" "type de consommateur" "identifiant de centrale (optionnel)" "-h (optionnel et pour aide)"
Exemple : bash c-wire.sh input/c-wire_v00.dat hvb comp 1

Les fichiers résultats seront dans le dossier principal, les fichiers temporaires (les fichiers temporaires sont uniquement pour les cas de lv_all.csv, lv_all_minmax.csv (avec des centrales aussi si vous le mettez)) dans tmp, les graphiques (les stations lv_all_minmax.csv (avec des centrales aussi si vous le mettez) uniquement) dans graphs et nos essais dans tests.

Sur certains ordinateurs la première exécution du programme par un nouveau fichier d'entrée de beaucoup de données peut prendre jusqu'à 40 secondes mais les suivantes seront beacoup plus rapides (entre 0.3 et 7 secondes).

Il y a déjà un premier fichier dans input pour tester le programme et il est nommé "c-wire_v00.dat", on laisse l'utilisateur rajouter d'autres fichier dans le dossier input selon ses besoins. 

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
Marc-Antoine Abale
