#!/bin/bash

# Move CSV files to the ‘test’ folder chatgpt
#target_directory="tests"
#mkdir -p "$target_directory"
#find . -maxdepth 1 -type f -name "*.csv" -exec mv {} "$target_directory/" \;
# No need to move to test because the test file is just used to compare the results with our own results. The tests are our results that we've already put in.

# Checking the number of arguments

# Parameters
input_file="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"  # Optional
aide_optionnel="${5:-}"

#limit number of arguments, if after 5th argument different from -h exit


function afficher_aide {
    echo "Usage : $0 <fichier_entrée> <type_station> <type_consommateur> [id_centrale] [-h]"
    echo ""
    echo "Ce script permet de traiter les données des stations énergétiques en fonction du type de station,"
    echo "du type de consommateur et, éventuellement, d'un identifiant de centrale spécifique."
    echo ""
    echo "Paramètres :"
    echo "  <fichier_entrée>      Chemin vers le fichier contenant les données à traiter (obligatoire)."
    echo "  <type_station>        Type de station ('hvb', 'hva', 'lv')."
    echo "  <type_consommateur>   Type de consommateur ('comp', 'indiv', 'all')."
    echo "  [id_centrale]         Identifiant de la centrale (facultatif)."
    echo "  -h                    Affiche cette aide et quitte le programme."
    echo ""
    echo "Exemples :"
    echo "  $0 donnees.csv hvb comp                Traite les données pour les stations HVB avec des consommateurs entreprises."
    echo "  $0 donnees.csv lv all                  Traite les données pour toutes les stations LV avec tous les types de consommateurs."
    echo "  $0 donnees.csv hva comp 1          Traite les données pour la station HVA avec des entreprises connectées à la centrale 1."
    echo ""
    echo "Remarques :"
    echo "  - Les combinaisons d'arguments invalides sont 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv'. Il n'y a que des entreprises connectées aux stations HVB et HVA."
    echo "  - Les fichiers de sortie générés se trouvent dans le répertoire de travail actuel."
    echo "  - Si l'exécutable C requis n'existe pas, le script le compile automatiquement."
    echo "  - Le temps total de traitement est affiché à la fin de l'exécution."
    echo ""
}

#allows you to use the help command
if  [[ "$input_file" = "-h"  || "$type_station" = "-h"  || "$type_consommateur" = "-h" || "$id_centrale" = "-h" || "$aide_optionnel" = "-h" ]]; then
    afficher_aide
    exit 1

fi

# Check if id_centrale is defined and if it is an integer
if [ -n "$id_centrale" ]; then
    # Check if id_centrale is an integer
    if ! [[ "$id_centrale" =~ ^-?[0-9]+$ ]]; then
        echo "Erreur : Le 5eme argument et id_centrale doit être un nombre entier."
        afficher_aide
        exit 1
    fi
fi

# Check if optional_help is defined and if it is ‘-h’.
if [ -n "$aide_optionnel" ]; then
    # Check that optional_help is exactly ‘-h’.
    if [ "$aide_optionnel" != "-h" ]; then
        echo "Erreur : aide_optionnel doit être '-h' ou vide."
        afficher_aide
        exit 1
    fi

fi


if [ "$#" -lt 3 ]; then
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Check that the file exists
if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier $input_file n'existe pas."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validate station type parameters
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Le type de station doit être exactement 'hvb', 'hva' ou 'lv'."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation of consumer type parameters
if [[ "$type_consommateur" != "indiv" && "$type_consommateur" != "comp" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Le type de station doit être exactement 'indiv', 'comp' ou 'all'."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi


# Check for forbidden combinations
if { [ "$type_station" = "hvb" ] || [ "$type_station" = "hva" ]; } && { [ "$type_consommateur" = "all" ] || [ "$type_consommateur" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites. Il n'y a que des entreprises connectées aux stations HVB et HVA"
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi


# Check the C executable
c_executable="arbre_avl"
c_source="main3.c"

CHEMIN_PROJET=$(dirname "$0")/codeC
#if [ ! -f "$CHEMIN_PROJET/$c_executable" ]; then

# Check that the executable exists
  if [ ! -f "$c_executable" ]; then
        echo "L'exécutable '$c_executable' n'existe pas. Compilation en cours..."

           # Start compilation with make
       # make -f ~/PROJET-INFO-PRE-ING-2/codeC/Makefile
        make -C "$CHEMIN_PROJET"
        if [ $? -ne 0 ]; then
             # If compilation fails
            echo "Erreur lors de la compilation. Le programme n'a pas pu être généré."
            echo "Temps d'execution : 0.0sec"
            exit 1

        else
          echo "Compilation réussie."
          fi
  else
        echo "L'exécutable '$c_executable' est déjà présent."
      echo "Compilation réussie."
  fi

# Start measuring processing time
start_time=$(date +%s.%N)
# You will need the function and put it at the end to measure the processing time at the end

# Check that the tmp and graphs folders are present and test

if [ ! -d "input" ]; then
  mkdir input
  echo "Le dossier 'input' a été créé."
else
  echo "Le dossier 'input' existe déjà."
fi

if [ ! -d "tmp" ]; then
  mkdir tmp
  echo "Le dossier 'tmp' a été créé."
else
  echo "Le dossier 'tmp' existe déjà."
fi

if [ ! -d "graphs" ]; then
  mkdir graphs
  echo "Le dossier 'graphs' a été créé."
else
  echo "Le dossier 'graphs' existe déjà."
fi


# Check that $id_centrale exists and create the combined variable.
  if [ -z "$id_centrale" ]; then
      combined_type="$type_station $type_consommateur" 
      #If id_centrale is not supplied, $id_centrale is not included.
  else
      combined_type="$type_station $type_consommateur $id_centrale"  # Otherwise, include $id_centrale in the combination.

  fi

EXECUTABLE=$(dirname "$0")/codeC/$c_executable



case "$combined_type" in
  "hvb comp $id_centrale")
    output_file="hvb_comp_${id_centrale}.csv"  # Use $id_centrale in the name of the output file
    echo "Station HVB:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check that the file has been created
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
  "hva comp $id_centrale")
    output_file="hva_comp_${id_centrale}.csv"  # Use $id_centrale in the name of the output file
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;[0-9-]+;[0-9]+;-;" | tr '-' '0' | cut -d';' --complement -f1,2,4,5,6 | tail -n+1  | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv indiv $id_centrale")
    output_file="lv_indiv_${id_centrale}.csv"  # Use $id_centrale in the name of the output file
    echo "Station LV:Capacité:Consommation (particuliers)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;-;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv comp $id_centrale")
    output_file="lv_comp_${id_centrale}.csv"  # Use $id_centrale in the name of the output file
    echo "Station LV:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;[0-9-]+;-;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
   "lv all $id_centrale")
output_file="lv_all_${id_centrale}.csv" # Output file
 echo "Station LV:Capacité:Consommation (tous)" > "$output_file"
 cat $1 | grep -E "^${id_centrale};-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" >> "$output_file"
# Check file creation
if [ -f "$output_file" ]; then
    echo "Nice"
else
    echo "Erreur : Fichier non généré."
fi
# Processing to extract the 20 stations with the highest and lowest consumption
minmax_file="tmp_${id_centrale}.csv" # Name the minmax temporary file with the 10 lowest and 10 highest consumption stations

# Add a header to the output file
echo "Station LV:Capacité:Consommation (tous)" > "$minmax_file"

# Sort stations by consumption, extracting the 10 smallest and 10 largest stations
cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | head -n 10 >> "$minmax_file" # Add the 10 stations with the lowest consumption

cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | tail -n 10 >> "$minmax_file" # Add the 10 stations with the highest consumption

# Check that the minmax_file file has been created
if [ -f "$minmax_file" ]; then
echo "Fichier temporaire généré : nice"
else
echo "Erreur : Fichier temporaire non généré."
fi

# Create a new file with the 4th column (difference between the values in the 2nd and 3rd columns)
new_file="lv_all_minmax_difference_${id_centrale}.csv"
echo "Station LV:Capacité:Consommation (tous):Différence" > "$new_file"  # Header with the new column

# Add the 4th column, which is the difference between the 2nd and 3rd columns
awk -F':' 'BEGIN {OFS=":"} {
    col2 = $2
    col3 = $3
    diff = col2 - col3   # Calcul de la différence
    print $0, diff   # Ajouter la différence à la ligne
}' "$minmax_file" | tail -n +2 | sort -t':' -k4 -n | awk '!seen[$0]++' >> "$new_file"

# Check the creation of the file with the difference
if [ -f "$new_file" ]; then
    echo "Fichier avec différence généré dans $new_file"
else
    echo "Erreur : Fichier avec différence non généré."
fi

gnuplot << EOF
set datafile separator ":"
set terminal pngcairo enhanced
set output "graphique_minmax_${id_centrale}.png"

set title "Consommation des 20 postes LV les plus et moins chargés"
set xlabel "Postes"
set ylabel "Capacité - Consommation (tous)"
set style data histograms
set style fill solid 1.0 border -1
set xtics rotate by -45
set palette defined (0 "green", 1 "red")

plot "lv_all_minmax_difference_${id_centrale}.csv" using 4:xtic(1) title 'Capacité - Consommation' lc palette
EOF

# New file without the 4th column
new_file_without_diff="lv_all_minmax_${id_centrale}.csv"

# Create a header for the new file without the 4th column
echo "Min and Max 'capacity-load' extreme nodes" > "$new_file_without_diff"
echo "Station LV:Capacité:Consommation (tous)" >> "$new_file_without_diff"

# Delete the 4th column (difference) from the `new_file.
awk -F':' 'BEGIN {OFS=":"} { $4=""; print $1, $2, $3 }' "$new_file" | tail -n +2 >> "$new_file_without_diff"

 # Check the creation of the file
if [ -f "$new_file_without_diff" ]; then
echo "Fichier "lv_all_minmax_${id_centrale}.csv" généré : $new_file_without_diff"
else
echo "Erreur : Fichier sans différence non généré."
fi
mv tmp_${id_centrale}.csv tmp/
mv lv_all_minmax_difference_${id_centrale}.csv tmp/
mv graphique_minmax_${id_centrale}.png graph/
# Confirmation
echo "Traitement terminé. Les résultats sont dans $new_file_without_diff et dans $output_file."
    ;;
    "hvb comp")
    output_file="hvb_comp.csv"
    echo "Station HVB:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
  "hva comp")
    output_file="hva_comp.csv" # Output file
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;[0-9-]+;[0-9]+;-;" | tr '-' '0' | cut -d';' --complement -f1,2,4,5,6 | tail -n+1  | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv indiv")
    output_file="lv_indiv.csv" # Output file
     echo "Station LV:Capacité:Consommation (particuliers)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;-;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv comp")
    output_file="lv_comp.csv" # Output file
     echo "Station LV:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;-;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv all")
    output_file="lv_all.csv" # Output file
     echo "Station LV:Capacité:Consommation (tous)" > "$output_file"
     cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Nice"
    else
        echo "Erreur : "lv_all" non généré."
    fi
# Processing to extract the 20 stations with the highest and lowest consumption
minmax_file="tmp.csv" # Name the minmax temporary file with the 10 lowest and 10 highest consumption stations

# Add a header to the output file
echo "Station LV:Capacité:Consommation (tous)" > "$minmax_file"

# Sort stations by consumption, extracting the 10 smallest and 10 largest stations
cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | head -n 10 >> "$minmax_file" # Add the 10 stations with the lowest consumption

cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | tail -n 10 >> "$minmax_file" # Add the 10 stations with the highest consumption

 # Check the creation of the file
if [ -f "$minmax_file" ]; then
    echo "Fichier temporaire généré : nice"
else
    echo "Erreur : Fichier temporaire non généré."
fi

# Create a new file with the 4th column (difference between the values in the 2nd and 3rd columns)
    new_file="lv_all_minmax_difference.csv"
    echo "Station LV:Capacité:Consommation (tous):Différence" > "$new_file"  # Header with the new column

# Add the 4th column, which is the difference between the 2nd and 3rd columns
    awk -F':' 'BEGIN {OFS=":"} {
        col2 = $2
        col3 = $3
        diff = col2 - col3   # Calcul de la différence
        print $0, diff   # Ajouter la différence à la ligne
    }' "$minmax_file" | tail -n +2 | sort -t':' -k4 -n | awk '!seen[$0]++' >> "$new_file"

     # Check the creation of the file
    if [ -f "$new_file" ]; then
        echo "Fichier avec différence généré : $new_file"
    else
        echo "Erreur : Fichier avec différence non généré."
    fi


gnuplot << EOF
set datafile separator ":"
set terminal pngcairo enhanced
set output "graphique_minmax.png"

set title "Consommation des 20 postes LV les plus et moins chargés"
set xlabel "Postes"
set ylabel "Capacité - Consommation (tous)"
set style data histograms
set style fill solid 1.0 border -1
set xtics rotate by -45
set palette defined (0 "green", 1 "red")

plot "lv_all_minmax_difference.csv" using 4:xtic(1) title 'Capacité - Consommation' lc palette
EOF

# New file without the 4th column
new_file_without_diff="lv_all_minmax.csv"

# Create a header for the new file without the 4th column
echo "Min and Max 'capacity-load' extreme nodes" > "$new_file_without_diff"
echo "Station LV:Capacité:Consommation (tous)" >> "$new_file_without_diff"

# Delete the 4th column (difference) from the `new_file`
awk -F':' 'BEGIN {OFS=":"} { $4=""; print $1, $2, $3 }' "$new_file" | tail -n +2>> "$new_file_without_diff"

 # Check the creation of the file
if [ -f "$new_file_without_diff" ]; then
    echo "Fichier "lv_all_minmax.csv" généré : $new_file_without_diff"
else
    echo "Erreur : Fichier sans différence non généré."
fi
mv tmp.csv tmp/
mv lv_all_minmax_difference.csv tmp/
mv graphique_minmax.png graph/
# Confirmation
echo "Traitement terminé. Les résultats sont dans $new_file_without_diff et dans $new_file."
    ;;
  *)
    echo "Choix invalide, les arguments possibles sont hva comp, hvb comp, lv indiv, lv comp ou lv all"
    exit 1
    ;;
esac

# End of treatment time measurement
end_time=$(date +%s.%N)

# Calculating and displaying time
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps utile de traitement : ${elapsed_time}sec"
