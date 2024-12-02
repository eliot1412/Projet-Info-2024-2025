cut -d ',' -f 1,14 nomfichier = affiche colonne 1 et 14
cat c-wire_v00.dat | cut -d ';' -f 2,5,6,7,8 | tr '-' '0' affiche colognne 2 5 6 7 8 et remplace - par 0

awk -F';' '$1 != 1' tableau.txt > resultat.txt // garde les lignes dont la colonne 1 n'est pas égale à 1
