#!/bin/bash

# Déplacement des fichiers CSV dans le dossier "test" chatgpt
#target_directory="tests"
#mkdir -p "$target_directory"
#find . -maxdepth 1 -type f -name "*.csv" -exec mv {} "$target_directory/" \;
# pas de deplacement vers test car fichier test sert juste a comparer les resultats avec nos resultats a nous. Les test sont nos resultats a nous qu on deja mettre

# Vérification du nombre d'arguments

# Paramètres
input_file="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"  # Optionnel
aide_optionnel="${5:-}"

#limiter nombre d arguments si apres 5eme argument different de -h exit
#if [ $# -gt 5 ]; then

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

#permet d'utiliser la commande  d'aide
if  [[ "$input_file" = "-h"  || "$type_station" = "-h"  || "$type_consommateur" = "-h" || "$id_centrale" = "-h" || "$aide_optionnel" = "-h" ]]; then
    afficher_aide
    exit 1

fi

# Vérifier si id_centrale est défini et si c'est un entier
if [ -n "$id_centrale" ]; then
    # Vérifier si id_centrale est un nombre entier
    if ! [[ "$id_centrale" =~ ^-?[0-9]+$ ]]; then
        echo "Erreur : Le 5eme argument et id_centrale doit être un nombre entier."
        afficher_aide
        exit 1
    fi
fi

# Vérifier si aide_optionnel est défini et si c'est "-h"
if [ -n "$aide_optionnel" ]; then
    # Vérifier si aide_optionnel est exactement "-h"
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

# Vérification de l'existence du fichier
if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier $input_file n'existe pas."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation des paramètres de type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Le type de station doit être exactement 'hvb', 'hva' ou 'lv'."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation des paramètres de type de consommateur
if [[ "$type_consommateur" != "indiv" && "$type_consommateur" != "comp" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Le type de station doit être exactement 'indiv', 'comp' ou 'all'."
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Vérification des combinaisons interdites
if { [ "$type_station" = "hvb" ] || [ "$type_station" = "hva" ]; } && { [ "$type_consommateur" = "all" ] || [ "$type_consommateur" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites. Il n'y a que des entreprises connectées aux stations HVB et HVA"
    afficher_aide
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi


# Vérification de l'exécutable C
c_executable="arbre_avl"
c_source="main3.c"

CHEMIN_PROJET=$(dirname "$0")/codeC

# Vérifier si l'exécutable existe
  if [ ! -f "$c_executable" ]; then
        echo "L'exécutable '$c_executable' n'existe pas. Compilation en cours..."

        # Lancer la compilation avec make
       # make -f ~/PROJET-INFO-PRE-ING-2/codeC/Makefile
        make -C "$CHEMIN_PROJET"
        if [ $? -ne 0 ]; then
            # Si la compilation échoue
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

# Début de la mesure du temps de traitement
start_time=$(date +%s.%N)
# il faudra la fonction et la mettre a la fin pour mesurer le temps de traitement a la fin

# Verfifier la presence du dossier tmp et graphs et test

if [ ! -d "input" ]; then
  mkdir input
  echo "Le dossier 'input' a été créé."
else
  echo "Le dossier 'input' existe déjà."
fi


#if [ ! -d "tests" ]; then
  #mkdir tests
  #echo "Le dossier 'tests' a été créé."
#else
#echo "Le dossier 'tests' existe déjà."
#fi

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

#TRIAGE SWITCH CASE
#si hvb != 0 alor garder ligne
#cat c-wire_v00.dat | tr '-' 0 | awk -F';' '$2 != 0' | awk -F';' '$3 = 0'

#cat c-wire_v00.dat| tr '-' '0' | awk -F ';' '$2 != 0 && $3 == 0 && $4 == 0' 

#cat c-wire_v00.dat | tr '-' '0' | awk -F';' '$2 != 0 && $3 == 0 && $4 == 0' | cut -d';' --complement -f3,4,5,6

#si hvb = 0 supp ligne 
#=> si hva = 0 alor c est hvb 
#=> si hva != 0 alor c est hva

#si hva != 0 alor garder ligne
#si hvb = 0 supp ligne
#=> si lv = 0 alor c est hva
#=> si hva != 0 alor c est lv

#si lv != 0 alor garder 

# Ajouter un en-tête au fichier CSV
#cat c-wire_v25.dat | tr '-' 0 | awk -F';' '$4 != 0'  | cut -d';' --complement -f1,2,3,4,5,6,8 | awk -F';' '$1 != 0' | tail -n+2 > temp1.csv 

# Vérification de l'existence de $id_centrale et création de la variable combinée
  if [ -z "$id_centrale" ]; then
      combined_type="$type_station $type_consommateur"  # Si id_centrale n'est pas fourni, on n'inclut pas $id_centrale.
  else
      combined_type="$type_station $type_consommateur $id_centrale"  # Sinon, on inclut $id_centrale dans la combinaison.
  fi

EXECUTABLE=$(dirname "$0")/codeC/$c_executable



case "$combined_type" in
  "hvb comp $id_centrale")
    output_file="hvb_comp_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier de sortie
    echo "Station HVB:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
  "hva comp $id_centrale")
    output_file="hva_comp_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier de sortie
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;[0-9-]+;[0-9]+;-;" | tr '-' '0' | cut -d';' --complement -f1,2,4,5,6 | tail -n+1  | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv indiv $id_centrale")
    output_file="lv_indiv_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier de sortie
    echo "Station LV:Capacité:Consommation (particuliers)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;-;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv comp $id_centrale")
    output_file="lv_comp_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier de sortie
    echo "Station LV:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;[0-9-]+;-;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    "lv all $id_centrale")
    file="lv_all_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier temporaire
    echo "Station LV:Capacité:Consommation (tous)" > "$file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1  | "$EXECUTABLE" >> "$file"
    
    # Traitement pour extraire les 10 postes avec la plus forte et la plus faible consommation
    minmax_file="tmp_${id_centrale}.csv" # Nom du fichier de temporaire minmax avec 10 plus petite et 10 plus grande

    # Ajouter un en-tête au fichier de sortie
    echo "Station LV:Capacité:Consommation (tous)" > "$minmax_file"

    # Trier les postes par consommation, extraire les 10 plus bas et les 10 plus hauts
    cat "$file" | tail -n +2 | sort -t':' -k3 -n | head -n 10 >> "$minmax_file" # Ajout des 10 postes avec la plus faible consommation

    cat "$file" | tail -n +2 | sort -t':' -k3 -n | tail -n 10 >> "$minmax_file" # Ajout des 10 postes avec la plus forte consommation

    # Vérification de la création du fichier min/max
    if [ -f "$minmax_file" ]; then
        echo "Fichier temp généré : nice"
    else
        echo "Erreur : Fichier temp non généré."
    fi

     # Création du fichier lv_allminmax.csv avec la colonne 4 calculée
    temp_file="lv_all_minmax_${id_centrale}.csv"
    echo "Min and Max 'capacity-load' extreme nodes" > "$temp_file"
    echo "Station LV:Capacité:Consommation (tous)" >> "$temp_file"

    # Utilisation de awk pour ajouter la colonne 4, tri et suppression des doublons
    awk -F':' 'BEGIN {OFS=":"} {
        col4 = $2 - $3  # Calcul de la colonne 4
        print $0, col4   # Affichage de la ligne avec la nouvelle colonne
    }' "$minmax_file" | tail -n +2 | sort -t':' -k4 -n | awk '!seen[$0]++' | cut -d':' -f1-3 >> "$temp_file"
    # Vérification de la création du fichier min/max
    if [ -f "$temp_file" ]; then
        echo "Fichier minmax généré : $temp_file"
    else
        echo "Erreur : Fichier minmax non généré."
    fi
    mv tmp_${id_centrale}.csv tmp/
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $temp_file et dans $output_file."
        ;;
  'hvb comp')
    output_file="hvb_comp.csv"
    echo "Station HVB:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
  'hva comp')
    output_file="hva_comp.csv" # Fichier de sortie
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;[0-9-]+;[0-9]+;-;" | tr '-' '0' | cut -d';' --complement -f1,2,4,5,6 | tail -n+1  | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    'lv indiv')
    #1;-;1;1;-;-;241999040;-
    output_file="lv_indiv.csv" # Fichier de sortie
     echo "Station LV:Capacité:Consommation (particuliers)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;-;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    'lv comp')
    output_file="lv_comp.csv" # Fichier de sortie
     echo "Station LV:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;-;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
    # Confirmation
    echo "Traitement terminé. Les résultats sont dans $output_file."
    ;;
    'lv all')
    output_file="lv_all.csv" # Fichier de sortie
     echo "Station LV:Capacité:Consommation (tous)" > "$output_file"
     cat $1 | grep -E "^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0'  | cut -d';' --complement -f1,2,3,5,6 | tail -n+1 | "$EXECUTABLE" >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Nice"
    else
        echo "Erreur : Fichier non généré."
    fi
# Traitement pour extraire les 10 postes avec la plus forte et la plus faible consommation
minmax_file="tmp.csv" # Nom du fichier de temporaire minmax avec 10 plus petite et 10 plus grande

# Ajouter un en-tête au fichier de sortie
echo "Station LV:Capacité:Consommation (tous)" > "$minmax_file"

# Trier les postes par consommation, extraire les 10 plus bas et les 10 plus hauts
cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | head -n 10 >> "$minmax_file" # Ajout des 10 postes avec la plus faible consommation

cat "$output_file" | tail -n +2 | sort -t':' -k3 -n | tail -n 10 >> "$minmax_file" # Ajout des 10 postes avec la plus forte consommation

# Vérification de la création du fichier min/max
if [ -f "$minmax_file" ]; then
    echo "Fichier min/max généré : nice"
else
    echo "Erreur : Fichier min/max non généré."
fi

 # Création du fichier lv_allminmax.csv avec la colonne 4 calculée
temp_file="lv_all_minmax.csv"
echo "Min and Max 'capacity-load' extreme nodes" > "$temp_file"
echo "Station LV:Capacité:Consommation (tous)" >> "$temp_file"

# Utilisation de awk pour ajouter la colonne 4, tri et suppression des doublons
awk -F':' 'BEGIN {OFS=":"} {
    col4 = $2 - $3  # Calcul de la colonne 4
    print $0, col4   # Affichage de la ligne avec la nouvelle colonne
}' "$minmax_file" | tail -n +2 | sort -t':' -k4 -n | awk '!seen[$0]++' | cut -d':' -f1-3 >> "$temp_file"
# Vérification de la création du fichier min/max
if [ -f "$temp_file" ]; then
    echo "Fichier min/max généré : $temp_file"
else
    echo "Erreur : Fichier min/max non généré."
fi
mv tmp.csv tmp/
# Confirmation
echo "Traitement terminé. Les résultats sont dans $temp_file et dans $output_file."
    ;;
  *)
    echo "Choix invalide, les arguments possibles sont hva comp, hvb comp, lv indiv, lv comp ou lv all"
    exit 1
    ;;
esac


#dire dans le read me que l utilisateur doit mettre le fichier de donnes csv dans input
# graphs

# sudo apt update
# sudo apt install gnuplot

# gnuplot
# set terminal pngcairo size 800,600
# set output 'graphique_barres.png'
# set title 'Graphs '
# set xlabel 'Consommation dans l ordre croissant'
# set ylabel 'Valeurs de la Consommation'
# set style data histograms
# set style fill solid border -1
# plot "$temp_file" using 2:xtic(1) title 'Série y', \
#      "$temp_file" using 3:xtic(1) title 'Série z'
# exit

#GENERATION FICHIER DE SORTIE
#output_file="filtered_data.csv"
#echo "Individual,Capacity,Load" > "$output_file"
#awk -F';' '{ printf "%s,%s,%s\n",$6, $7, $8 }' "$input_file" >> "$output_file"

# Fin de la mesure du temps de traitement
end_time=$(date +%s.%N)

# Calcul et affichage de la durée
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps utile de traitement : ${elapsed_time}sec"
