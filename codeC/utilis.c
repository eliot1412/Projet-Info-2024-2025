#include <stdio.h>
#include <stdlib.h>
#include "utilis.h"

int validateInput(long long id, long long capacity, long long load) {
    // Fonction pour obtenir le premier chiffre d'un nombre
    long long getFirstDigit(long long number) {
        while (number >= 10) {
            number /= 10;
        }
        return number;
    }
    // Vérifier si le premier chiffre de id, capacity ou load est égal à 0
    if (getFirstDigit(capacity) == 0 || getFirstDigit(load) == 0) {
        printf("Erreur: Id ou capacité ou consommation est négative.\n");
        exit(102);  // Sortie avec le code d'erreur 102
    }

    // Vérifier si les valeurs sont négatives
    if (capacity < 0 || load < 0) {
        printf("Erreur : donnees invalides pour ID %lld.\n", id);
        exit(102);  // Sortie avec le code d'erreur 102
    }

    return 1;  // Les données sont valides
}
