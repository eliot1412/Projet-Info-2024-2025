#include <stdio.h>
#include <stdlib.h>
#include "avl_tree.h"
#include "utilis.h"

int main() {
  int h;
  int *pH = &h;
  long long id, capacity, load; // we put the variables in long long because there was an overflow otherwise with c-wire_v00 in input
  Tree *AVLproj = NULL;

  while (scanf("%lld;%lld;%lld\n", &id, &capacity, &load) == 3) { // take the data in input in a certain way and check if the form of the data is ok
    if (validateInput(id, capacity, load)) { // dont work because the minus "-" is tranformed in a 0 in the script shell 
      AVLproj = insertAVL(AVLproj, id, capacity, load, pH);
    } else {
      printf("Donnees non traitees pour ID %lld.\n", id);
    }
  }

  infix(AVLproj); // Print the tree containing the data (the data printed will be redirected in the output file by the script shell)
  freeAVL(AVLproj); // Free every node of the tree with a recursive function in order to not have memory leak

  return 0;
}
