#!/bin/bash

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <chemin_fichier> <type_station> <type_consommateur> [id_centrale]"
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Paramètres
input_file="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"  # Optionnel

# Vérification de l'existence du fichier
if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier $input_file n'existe pas."
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation des paramètres de type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva', ou 'lv'."
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation des paramètres de type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Le type de consommateur doit être 'comp', 'indiv', ou 'all'."
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Vérification des combinaisons interdites
if { [ "$type_station" = "hvb" ] || [ "$type_station" = "hva" ]; } && { [ "$type_consommateur" = "all" ] || [ "$type_consommateur" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites."
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Vérification de l'exécutable C
c_executable="ex2"
c_source="ex2.c"

if [ ! -f "$c_executable" ]; then
    echo "L'exécutable C n'est pas présent. Compilation en cours..."
    if [ ! -f "$c_source" ]; then
        echo "Erreur : Le fichier source $c_source est introuvable."
        echo "Temps utile de traitement : 0.0sec"
        exit 1
    fi

    gcc -o "$c_executable" "$c_source"
    if [ $? -ne 0 ]; then
        echo "Erreur : La compilation a échoué."
        echo "Temps utile de traitement : 0.0sec"
        exit 1
    fi
    echo "Compilation réussie."
fi

# Début de la mesure du temps de traitement
start_time=$(date +%s.%N)
# il faudra la fonction et la mettre a la fin pour mesurer le temps de traitement a la fin

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

echo "HVB ? HVA ? LV ?"
read choix

case "$choix" in
  'hvb')
    cat c-wire_v00.dat | tr '-' '0' | awk -F';' '$2 != 0 && $3 == 0 && $4 == 0 ' | cut -d';' --complement -f1,3,4,5,6
    ;;
  'hva')
    cat c-wire_v00.dat | tr '-' '0' | awk -F';' '$2 == 0 && $3 != 0 && $4 == 0' | cut -d';' --complement -f1,2,4,5,6
    ;;
  'lv')
    cat c-wire_v00.dat | tr '-' 0 | awk -F';' '$4 != 0'  | cut -d';' --complement -f1,2,3,5,6 > main
    ;;
  *)
    echo "Choix invalide"
    ;;
esac

# Génération du fichier de sortie
output_file="filtered_data.csv"
echo "Capacity,Company,Individual,Load" > "$output_file"
awk -F';' "{ if ($awk_command) printf \"%s,%s,%s,%s\\n\", \$7, \$5, \$6, \$8 }" "$input_file" >> "$output_file"

# Exécution de l'exécutable C
./$c_executable "$output_file"

# Fin de la mesure du temps de traitement
end_time=$(date +%s.%N)

# Calcul et affichage de la durée
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps utile de traitement : ${elapsed_time}sec"

# Confirmation
echo "Traitement terminé. Les résultats sont dans $output_file."
