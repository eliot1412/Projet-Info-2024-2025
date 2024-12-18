#ifndef AVL_TREE_H
#define AVL_TREE_H

typedef struct _tree {
  long long id;
  long long capacity;
  long long load;
  struct _tree *pLeft;
  struct _tree *pRight;
  int balance;
} Tree;

Tree *rotateLeft(Tree *pRoot);
Tree *rotateRight(Tree *pRoot);
Tree *doubleRotateLeft(Tree *pRoot);
Tree *doubleRotateRight(Tree *pRoot);
Tree *balanceAVL(Tree *pRoot);
Tree *createAVL(long long i, long long c, long long l);
Tree *insertAVL(Tree *a, long long i, long long c, long long l, int *h);
void infix(Tree *p);
void prefix(Tree *p);
void freeAVL(Tree *pTree);

#endif
