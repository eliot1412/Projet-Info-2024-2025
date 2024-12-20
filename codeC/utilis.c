#include <stdio.h>
#include <stdlib.h>
#include "utilis.h"

// was supposed to check if the input data were negatives but dont work cause the minus is tranformed into a 0 by the script shell

int validateInput(long long id, long long capacity, long long load) {
  	if (id < 0 || capacity < 0 || load < 0) {
    		fprintf(stderr, "Erreur : donnees invalides pour ID %lld.\n", id);
    		return 0;
  	}
  	
	return 1;
}
