#!/bin/bash

# Vérification du nombre d'arguments


# Paramètres
input_file="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"  # Optionnel
aide_optionnel="${5:-}"

#limiter nombre d arguments si apres 5eme argument different de -h exit
#if [ $# -gt 5 ]; then


#permet d'utiliser la commande  d'aide
if  [[ "$input_file" = "-h"  || "$type_station" = "-h"  || "$type_consommateur" = "-h" || "$id_centrale" = "-h" || "$aide_optionnel" = "-h" ]]; then
    echo "aide"
    
    exit 1

fi

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <chemin_fichier> <type_station> <type_consommateur> [id_centrale]"
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Vérification de l'existence du fichier
if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier $input_file n'existe pas."
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Validation des paramètres de type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" && "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva', ou 'lv'. Le type de consommateur doit être 'comp', 'indiv', ou 'all'"
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi

# Vérification des combinaisons interdites
if { [ "$type_station" = "hvb" ] || [ "$type_station" = "hva" ]; } && { [ "$type_consommateur" = "all" ] || [ "$type_consommateur" = "indiv" ]; }; then
    echo "Erreur : Les options 'hvb all', 'hvb indiv', 'hva all', et 'hva indiv' sont interdites. Il n'y a que des entreprises connectées aux stations HVB et HVA"
    echo "Temps utile de traitement : 0.0sec"
    exit 1
fi


# Vérification de l'exécutable C
c_executable="arbre_avl"
c_source="main3.c"

#CHEMIN_PROJET=~/Téléchargements/Projet-Info-2024-2025-main/codeC
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


if [ ! -d "tests" ]; then
  mkdir tests
  echo "Le dossier 'tests' a été créé."
else
  echo "Le dossier 'tests' existe déjà."
fi

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

#EXECUTABLE=~/Téléchargements/Projet-Info-2024-2025-main/codeC/$c_executable
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
    ;;
    "lv all $id_centrale")
    file="lv_all_${id_centrale}.csv"  # Utilisation de $id_centrale dans le nom du fichier temporaire
    echo "Station LV:Capacité:Consommation (tous)" > "$file"
    cat $1 | grep -E "^$id_centrale;-;[0-9-]+;[0-9]+;[0-9-]+;[0-9-]+;[0-9-]+" | tr '-' '0' | cut -d';' --complement -f1,2,3,5,6 | tail -n+1  | "$EXECUTABLE" >> "$file"
    # Vérification de la création du fichier
    if [ -f "$file" ]; then
        echo "Fichier généré avec succès : $file"
    else
        echo "Erreur : Fichier non généré."
    fi
    minmax_file="lv_all_minmax_${id_centrale}.csv"
    echo "Station LV:Capacité:Consommation (tous)" > "$minmax_file"
    #Traitement pour générer lv_all_minmax.csv
    sort -t':' -k3 -nr "$file" | tail -n +2 | head -n 10 >> "$minmax_file" # Les 10 plus grandes consommations
    sort -t':' -k3 -n "$file" | tail -n +2 | head -n 10 >> "$minmax_file" # Les 10 plus petites consommations
   #Vérification de la création du fichier minmax
        if [ -f "$minmax_file" ]; then
            echo "Fichier min/max généré avec succès : $minmax_file"
        else
            echo "Erreur : Fichier min/max non généré."
    fi
    ;;
  'hvb comp')
    output_file="hvb_comp.csv"
    echo "Station HVA:Capacité:Consommation (entreprises)" > "$output_file"
    cat $1 | grep -E "^[0-9]+;[0-9]+;-;-;" | tr '-' '0' | cut -d';' --complement -f1,3,4,5,6 | tail -n+1 | "$EXECUTABLE" | sort -t ':' -k2 -n >> "$output_file"
    # Vérification de la création du fichier
    if [ -f "$output_file" ]; then
        echo "Fichier généré avec succès : $output_file"
    else
        echo "Erreur : Fichier non généré."
    fi
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
    minmax_file="lv_all_minmax.csv"
    echo "LV ID:Capacity in kWh:Consumption Company in kWh" > "$minmax_file"
    #Traitement pour générer lv_all_minmax.csv
    sort -t':' -k3 -nr "$output_file" | tail -n +2 | head -n 10 >> "$minmax_file" # Les 10 plus grandes consommations
    sort -t':' -k3 -n "$output_file" | tail -n +2 | head -n 10 >> "$minmax_file" # Les 10 plus petites consommations
   #Vérification de la création du fichier minmax
        if [ -f "$minmax_file" ]; then
            echo "Fichier min/max généré avec succès : $minmax_file"
        else
            echo "Erreur : Fichier min/max non généré."
    fi
    ;;
  *)
    echo "Choix invalide, les arguments possibles sont hva comp, hvb comp, lv indiv, lv comp ou lv all"
    exit 1
    ;;
esac

#GENERATION FICHIER DE SORTIE
#output_file="filtered_data.csv"
#echo "Individual,Capacity,Load" > "$output_file"
#awk -F';' '{ printf "%s,%s,%s\n",$6, $7, $8 }' "$input_file" >> "$output_file"

# Fin de la mesure du temps de traitement
end_time=$(date +%s.%N)

# Calcul et affichage de la durée
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps utile de traitement : ${elapsed_time}sec"

# Confirmation
echo "Traitement terminé. Les résultats sont dans $output_file."

#sort -k2 -t';' -n "$output_file" 
