# Variables de compilation
CC = gcc
CFLAGS = -Wall -Werror -g

# Fichiers objets
OBJ = main3.o avl_tree.o utilis.o

# Nom de l'exécutable
EXEC = arbre_avl

# Règle de compilation de l'exécutable
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) -o $(EXEC) $(OBJ)
	@echo "Compilation terminée."

# Règle pour compiler main3.o
main3.o: main3.c avl_tree.h utilis.h
	$(CC) $(CFLAGS) -c main3.c

# Règle pour compiler avl_tree.o
avl_tree.o: avl_tree.c avl_tree.h
	$(CC) $(CFLAGS) -c avl_tree.c

# Règle pour compiler utilis.o
utilis.o: utilis.c utilis.h
	$(CC) $(CFLAGS) -c utilis.c

# Nettoyer les fichiers objets et l'exécutable
clean:
	rm -f $(OBJ)
	@echo "Nettoyage terminé."
