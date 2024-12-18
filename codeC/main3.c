#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"
#include "utils.h"

int main() {
  int h;
  int *pH = &h;
  long long id, capacity, load;
  Tree *AVLproj = NULL;

  while (scanf("%lld;%lld;%lld\n", &id, &capacity, &load) == 3) {
    if (validateInput(id, capacity, load)) {
      AVLproj = insertAVL(AVLproj, id, capacity, load, pH);
    } else {
      printf("Donnees non traitees pour ID %lld.\n", id);
    }
  }

  infix(AVLproj);
  freeAVL(AVLproj);

  return 0;
}
