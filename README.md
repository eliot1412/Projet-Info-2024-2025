# C-Wire: High-Performance Electrical Grid Data Engine

[English Version](#english-version) | [Version Française](#version-française)

---

<a name="english-version"></a>
# C-Wire: High-Performance Electrical Grid Data Engine

This project is a high-performance data processing engine designed to synthesize large-scale electrical distribution datasets. It utilizes a hybrid architecture, combining Shell scripting for data stream filtering and C for advanced algorithmic aggregation.

## How to compile and execute the program?

To get started, ensure you are on the "main" branch of the repository. Click on "<> Code" and select "Download ZIP".

Extract the archive into your working directory (e.g., Documents). 

Place your input datasets in the `/input` folder. Path: `Projet-Info-2024-2025-main/input`.

Open your terminal and navigate to the project root:
`cd ~/Documents/Projet-Info-2024-2025-main`

**Execution Command:**
`bash c-wire.sh <input_file> <station_type> <consumer_type> [power_plant_id] [-h]`

*Example:* `bash c-wire.sh input/c-wire_v00.dat hvb comp 1`

Results are generated in the root directory. Temporary files are stored in `/tmp`, graphs in `/graphs`, and test outputs in `/tests`.

On some systems, the initial processing of massive datasets (>5M rows) may take up to 40 seconds due to I/O overhead. Subsequent runs are significantly faster (0.3s to 7s) thanks to optimized data structures.

## How does it work?

The Shell wrapper sanitizes the input and compiles the C engine via the Makefile. It selects the relevant data streams and pipes them into the C binary.

The core engine is built on a custom **AVL Tree (Self-Balancing Binary Search Tree)** implementation. This ensures **$O(\log n)$** time complexity for aggregation, which is critical for maintaining performance on national-scale datasets.

For **lv all** mode, the engine performs an additional sorting operation to identify the 10 most and least loaded stations based on the delta between capacity and consumption.

## Technical Stack

* **Programming Languages:** C, Shell Scripting.
* **Core Libraries:** stdlib.h, stdio.h, math.h, assert.h.
* **AI Assistance:** 15% (Initial architectural brainstorming).

## Authors
* Lucien Boyer
* Eliot Durand de Gevigney
* Marc-Antoine Abale

---
<a name="version-française"></a>
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
