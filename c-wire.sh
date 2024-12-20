#!/bin/bash

# Move CSV files to the ‘test’ folder chatgpt
#target_directory="tests"
#mkdir -p "$target_directory"
#find . -maxdepth 1 -type f -name "*.csv" -exec mv {} "$target_directory/" \;
# No need to move to test because the test file is just used to compare the results with our own results. The tests are our results that we've already put in.

# Checking the number of arguments

# Parameters
input_file="$1"
station_type="$2"
consumer_type="$3"
power_plant_id="${4:-}"  # Optional
optional_help="${5:-}"

#limit number of arguments, if after 5th argument different from -h exit


function show_help {
    echo "Usage : $0 <fichier_entrée> <station_type> <consumer_type> [power_plant_id] [-h]"
    echo ""
    echo "Ce script permet de traiter les données des stations énergétiques en fonction du type de station,"
    echo "du type de consommateur et, éventuellement, d'un identifiant de centrale spécifique."
    echo ""
    echo "Paramètres :"
    echo "  <fichier_entrée>      Chemin vers le fichier contenant les données à traiter (obligatoire)."
    echo "  <station_type>        Type de station ('hvb', 'hva', 'lv')."
    echo "  <consumer_type>   Type de consommateur ('comp', 'indiv', 'all')."
    echo "  [power_plant_id]         Identifiant de la centrale (facultatif)."
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
if  [[ "$input_file" = "-h"  || "$station_type" = "-h"  || "$consumer_type" = "-h" || "$power_plant_id" = "-h" || "$optional_help" = "-h" ]]; then
    show_help
    exit 1

fi

# Check if power_plant_id is defined and if it is an integer
if [ -n "$power_plant_id" ]; then
    # Check if power_plant_id is an integer
    if ! [[ "$power_plant_id" =~ ^-?[0-9]+$ ]]; then
        echo "Erreur : Le 5eme argument et power_plant_id doit être un nombre entier."
        show_help
        exit 2
    fi
fi

# Check if optional_help is defined and if it is ‘-h’.
if [ -n "$optional_help" ]; then
    # Check that optional_help is exactly ‘-h’.
    if [ "$optional_help" != "-h" ]; then
        echo "Erreur : optional_help doit être '-h' ou vide."
        show_help
        exit 3
    fi

fi


if [ "$#" -lt 3 ]; then
    show_help
    echo "Temps utile de traitement : 0.0sec"
    exit 4
fi

# Check that the file exists
if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier $input_file n'existe pas."
    show_help
    echo "Temps utile de traitement : 0.0sec"
    exit 5
fi

# Validate station type parameters
if [[ "$station_type" != "hvb" && "$station_type" != "hva" && "$station_type" != "lv" ]]; then
    echo "Erreur : Le type de station doit être exactement 'hvb', 'hva' ou 'lv'."
    show_help
    echo "Temps utile de traitement : 0.0sec"
    exit 6
fi

# Validation of consumer type parameters
if [[ "$consumer_type" != "indiv" && "$consumer_type" != "comp" && "$consumer_type" != "all" ]]; then
    echo "Erreur : Le type de station doit être exactement 'indiv', 'comp' ou 'all'."
    show_help
    echo "Temps utile de traitement : 0.0sec"
    exit 7
fi


# Check for forbidden combinations
if { [ "$station_type" = "hvb" ] || [ "$station_type" = "hva" ]; } && { [ "$consumer_type" = "all" ] || [ "$consumer_type" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites. Il n'y a que des entreprises connectées aux stations HVB et HVA"
    show_help
    echo "Temps utile de traitement : 0.0sec"
    exit 8
fi


# Check the C executable
c_executable="arbre_avl"
c_source="main3.c"

PROJECT_PATH=$(dirname "$0")/codeC
#if [ ! -f "$PROJECT_PATH/$c_executable" ]; then

# Check that the executable exists
  if [ ! -f "$c_executable" ]; then
        echo "L'exécutable '$c_executable' n'existe pas. Compilation en cours..."

           # Start compilation with make
       # make -f ~/PROJET-INFO-PRE-ING-2/codeC/Makefile
        make -C "$PROJECT_PATH"
        if [ $? -ne 0 ]; then
             # If compilation fails
            echo "Erreur lors de la compilation. Le programme n'a pas pu être généré."
            echo "Temps d'execution : 0.0sec"
            exit 9

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
  rm -rf tmp
  mkdir tmp
  echo "Le dossier 'tmp' a été supprimé et recréé."
fi

if [ ! -d "graphs" ]; then
  mkdir graphs
  echo "Le dossier 'graphs' a été créé."
else
  echo "Le dossier 'graphs' existe déjà."
fi


# Check that $power_plant_id exists and create the combined variable.
  if [ -z "$power_plant_id" ]; then
      combined_type="$station_type $consumer_type" 
      #If power_plant_id is not supplied, $power_plant_id is not included.
  else
      combined_type="$station_type $consumer_type $power_plant_id"  # Otherwise, include $power_plant_id in the combination.

  fi

EXECUTABLE=$(dirname "$0")/codeC/$c_executable



case "$combined_type" in
  "hvb comp $power_plant_id")
    output_file="hvb_comp_${power_plant_id}.csv"  # Use $power_plant_id in the name of the output file
    echo "Station HVB:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$power_plant_id;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check that the file has been created
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
        exit 10
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
  "hva comp $power_plant_id")
    output_file="hva_comp_${power_plant_id}.csv"  # Use $power_plant_id in the name of the output file
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$power_plant_id;[0-9-]+;[0-9]+;-;" | tr '-' '0' | cut -d';' --complement -f1,2,4,5,6 | tail -n+1  | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
        exit 11
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv indiv $power_plant_id")
    output_file="lv_indiv_${power_plant_id}.csv"  # Use $power_plant_id in the name of the output file
    echo "Station LV:Capacité:Consommation (particuliers)" > "$output_file"
    cat $1 | grep -E "^$power_plant_id;-;[0-9-]+;[0-9]+;-;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
        exit 12
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv comp $power_plant_id")
    output_file="lv_comp_${power_plant_id}.csv"  # Use $power_plant_id in the name of the output file
    echo "Station LV:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$power_plant_id;-;[0-9-]+;[0-9]+;[0-9-]+;-;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Check file creation
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
        exit 13
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
   "lv all $power_plant_id")
output_file="lv_all_${power_plant_id}.csv" # Output file
 echo "Station LV:Capacité:Consommation (tous)" > "$output_file"
 cat $1 | grep -E "^${power_plant_id};-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
# Check file creation
if [ -f "$output_file" ]; then
    echo "Nice"
else
    echo "Erreur : Fichier non généré."
    exit 14
fi
# Processing to extract the 20 stations with the highest and lowest consumption
minmax_file="tmp_${power_plant_id}.csv" # Name the minmax temporary file with the 10 lowest and 10 highest consumption stations

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
exit 15
fi

# Create a new file with the 4th column (difference between the values in the 2nd and 3rd columns)
new_file="lv_all_minmax_difference_${power_plant_id}.csv"
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
    exit 16
fi

gnuplot << EOF
set datafile separator ":"
set terminal pngcairo enhanced
set output "minmax_graph_${power_plant_id}.png"

set title "Consommation des 20 postes LV les plus et moins chargés"
set xlabel "Postes"
set ylabel "Capacité - Consommation (tous)"
set style data histograms
set style fill solid 1.0 border -1
set xtics rotate by -45
set palette defined (0 "green", 1 "red")

plot "lv_all_minmax_difference_${power_plant_id}.csv" using 4:xtic(1) title 'Capacité - Consommation' lc palette
EOF

# New file without the 4th column
new_file_without_diff="lv_all_minmax_${power_plant_id}.csv"

# Create a header for the new file without the 4th column
echo "Min and Max 'capacity-load' extreme nodes" > "$new_file_without_diff"
echo "Station LV:Capacité:Consommation (tous)" >> "$new_file_without_diff"

# Delete the 4th column (difference) from the `new_file.
awk -F':' 'BEGIN {OFS=":"} { $4=""; print $1, $2, $3 }' "$new_file" | tail -n +2 >> "$new_file_without_diff"

 # Check the creation of the file
if [ -f "$new_file_without_diff" ]; then
echo "Fichier "lv_all_minmax_${power_plant_id}.csv" généré : $new_file_without_diff"
else
echo "Erreur : Fichier sans différence non généré."
exit 17
fi
mv tmp_${power_plant_id}.csv tmp/
mv lv_all_minmax_difference_${power_plant_id}.csv tmp/
mv minmax_graph_${power_plant_id}.png graphs/
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
        exit 18
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
        exit 19
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
        exit 20
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
        exit 21
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv all")
    output_file="lv_all.csv" # Output file
     echo "Station LV:Capacité:Consommation (tous)" > "$output_file"
     cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
     # Check the creation of the file
    if [ -f "$output_file" ]; then
        echo "Nice"
    else
        echo "Erreur : "lv_all" non généré."
        exit 22
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
    echo "Fichier temporaire généré"
else
    echo "Erreur : Fichier temporaire non généré."
    exit 23
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
        exit 24
    fi


gnuplot << EOF
set datafile separator ":"
set terminal pngcairo enhanced
set output "minmax_graph.png"

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
    exit 25
fi
mv tmp.csv tmp/
mv lv_all_minmax_difference.csv tmp/
mv minmax_graph.png graphs/
# Confirmation
echo "Traitement terminé. Les résultats sont dans $new_file_without_diff et dans $new_file."
    ;;
  *)
    echo "Choix invalide, les arguments possibles sont hva comp, hvb comp, lv indiv, lv comp ou lv all"
    exit 26
    ;;
esac

# End of treatment time measurement
end_time=$(date +%s.%N)

# Calculating and displaying time
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps utile de traitement : ${elapsed_time}sec"
make clean -C "$PROJECT_PATH"
