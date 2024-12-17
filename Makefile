CC = gcc
CFLAGS = -Wall -Werror -g

# Les fichiers objets
OBJ = main3.o avl_tree.o utils.o

# Nom de l'exécutable
EXEC = arbre_avl

# Règle de compilation de l'exécutable
$(EXEC): $(OBJ)
	$(CC) $(CFLAGS) -o $(EXEC) $(OBJ)

# Règle pour compiler main3.o
main3.o: main3.c avl_tree.h utils.h
	$(CC) $(CFLAGS) -c main3.c

# Règle pour compiler avl_tree.o
avl_tree.o: avl_tree.c avl_tree.h
	$(CC) $(CFLAGS) -c avl_tree.c

# Règle pour compiler utils.o
utils.o: utils.c utils.h
	$(CC) $(CFLAGS) -c utils.c

# Nettoyer les fichiers objets et l'exécutable
clean:
	rm -f $(OBJ) $(EXEC)
