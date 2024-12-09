cut -d ',' -f 1,14 nomfichier = affiche colonne 1 et 14
cat c-wire_v00.dat | cut -d ';' -f 2,5,6,7,8 | tr '-' '0' affiche colognne 2 5 6 7 8 et remplace - par 0

awk -F';' '$1 != 1' tableau.txt > resultat.txt // garde les lignes dont la colonne 1 n'est pas égale à 1

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <chemin_fichier> <type_station> <type_consommateur> [id_centrale]"
    exit 1
fi

# Paramètres
input_file="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"  # Optionnel

# Validation des paramètres de type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva', ou 'lv'."
    exit 1
fi

# Validation des paramètres de type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Le type de consommateur doit être 'comp', 'indiv', ou 'all'."
    exit 1
fi

# Vérification des combinaisons interdites
if { [ "$type_station" = "hvb" ] || [ "$type_station" = "hva" ]; } && { [ "$type_consommateur" = "all" ] || [ "$type_consommateur" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites."
    exit 1
fi

# Vérification de l'exécutable C
c_executable="ex2"
c_source="ex2.c"

if [ ! -f "$c_executable" ]; then
    echo "L'exécutable C n'est pas présent. Compilation en cours..."
    if [ ! -f "$c_source" ]; then
        echo "Erreur : Le fichier source $c_source est introuvable."
        exit 1
    fi

    gcc -o "$c_executable" "$c_source"
    if [ $? -ne 0 ]; then
        echo "Erreur : La compilation a échoué."
        exit 1
    fi
    echo "Compilation réussie."
fi

# Verfifier la presence du dossier tmp et graphs


if [ ! -d "tmp" ]; then
  mkdir tmp
  echo "Le dossier 'tmp' a été créé."
else
  echo "Le dossier 'tmp' existe déjà."
fi

if [ ! -d "graphs" ]; then
  mkdir tmp
  echo "Le dossier 'graphs' a été créé."
else
  echo "Le dossier 'graphs' existe déjà."
fi

