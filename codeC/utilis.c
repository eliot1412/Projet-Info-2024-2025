#include <stdio.h>
#include <stdlib.h>
#include "utilis.h"

int validateInput(long long id, long long capacity, long long load) {
  if (id < 0 || capacity < 0 || load < 0) {
    fprintf(stderr, "Erreur : donnees invalides pour ID %lld.\n", id);
    return 0;
  }
  return 1;
}
