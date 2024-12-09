cut -d ',' -f 1,14 nomfichier = affiche colonne 1 et 14
cat c-wire_v00.dat | cut -d ';' -f 2,5,6,7,8 | tr '-' '0' affiche colognne 2 5 6 7 8 et remplace - par 0

awk -F';' '$1 != 1' tableau.txt > resultat.txt // garde les lignes dont la colonne 1 n'est pas égale à 1

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
