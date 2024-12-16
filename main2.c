#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include<math.h>
#include<string.h>
#include<float.h>
#include<errno.h>
#include<assert.h>

FILE *fichier = NULL;

typedef struct _tree {
  long long id;
  long long capacity;
  long long load;
  struct _tree *pLeft;
  struct _tree *pRight;
  int balance;
} Tree;

int min2(int a, int b) { return a < b ? a : b; }
int max2(int a, int b) { return a > b ? a : b; }
int min3(int a, int b, int c) { return min2(a, min2(b, c)); }
int max3(int a, int b, int c) { return max2(a, max2(b, c)); }

Tree *rotateLeft(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pRight == NULL) {
    exit(200);
  }
  // update pointeurs
  Tree *pPivot = pRoot->pRight;
  pRoot->pRight = pPivot->pLeft;
  pPivot->pLeft = pRoot;
  // update balance ids
  int eqa = pRoot->balance;
  int eqp = pPivot->balance;
  pRoot->balance = eqa - max2(eqp, 0) - 1;
  pPivot->balance = min3(eqa - 2, eqa + eqp - 2, eqp - 1);
  // return new root
  pRoot = pPivot;
  return pRoot;
}

Tree *rotateRight(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pLeft == NULL) {
    exit(201);
  }
  // update pointeurs
  Tree *pPivot = pRoot->pLeft;
  pRoot->pLeft = pPivot->pRight;
  pPivot->pRight = pRoot;
  // update balance ids
  int eqa = pRoot->balance;
  int eqp = pPivot->balance;
  pRoot->balance = eqa - min2(eqp, 0) + 1;
  pPivot->balance = max3(eqa + 2, eqa + eqp + 2, eqp + 1);
  // return new root

  pRoot = pPivot;
  return pRoot;
}

Tree *doubleRotateLeft(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pRight == NULL) {
    exit(202);
  }
  pRoot->pRight = rotateRight(pRoot->pRight);
  return rotateLeft(pRoot);
}
Tree *doubleRotateRight(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pLeft == NULL) {
    exit(203);
  }
  pRoot->pLeft = rotateLeft(pRoot->pLeft);
  return rotateRight(pRoot);
}
Tree *balanceAVL(Tree *pRoot) {
  if (pRoot == NULL) {
    exit(205);
  }

  if (pRoot->balance >= 2) {
    if (pRoot->pRight == NULL) {
      exit(206);
    }
    if (pRoot->pRight->balance >= 0) {
      // LEFT SIMPLE
      pRoot = rotateLeft(pRoot);
    } else {
      // LEFT DOUBLE
      pRoot = doubleRotateLeft(pRoot);
    }
  } else if (pRoot->balance <= -2) {
    if (pRoot->pLeft == NULL) {
      exit(207); // Si l'arbre est déséquilibré à gauche
    }
    if (pRoot->pLeft->balance <= 0) {
      // RIGHT SIMPLE
      pRoot = rotateRight(pRoot);
    } else {
      // RIGHT DOUBLE
      pRoot = doubleRotateRight(pRoot);
    }
  }
  return pRoot;
}

Tree *createAVL(long long i, long long c, long long l) {
  Tree *pNew = malloc(sizeof(Tree));
  if (pNew == NULL) {
    exit(10);
  }
  pNew->id = i;
  pNew->capacity = c;
  pNew->load = l;
  pNew->pLeft = NULL;
  pNew->pRight = NULL;
  pNew->balance = 0;
  return pNew;
}

Tree *insertAVL(Tree *a, long long i, long long c, long long l, int *h) {
  if (a == NULL) {
    *h = 1;
    return createAVL(i, c, l);
  } else if (i < a->id) {
    a->pLeft = insertAVL(a->pLeft, i, c, l, h);
    *h = -*h;
  } else if (i > a->id) {
    a->pRight = insertAVL(a->pRight, i, c, l, h);
  } else {
    if (a->capacity + c < 0) {
      printf("Erreur : la capacite devient negative pour ID=%lld.\n", i);
      exit(300);
    }
    a->capacity += c;
    a->load += l;
    *h = 0;
    return a;
  }

  if (*h != 0) {
    a->balance += *h;
    a = balanceAVL(a);
    if (a->balance == 0) {
      *h = 0;
    } else {
      *h = 1;
    }
  }
  return a;
}

void infix(Tree *p) {
  if (p != NULL) {
    infix(p->pLeft);
    printf("%02lld ; %02lld ; %02lld\n", p->id, p->capacity, p->load);
    infix(p->pRight);
  }
}

void prefix(Tree *p) {
  if (p != NULL) {
    printf("[%02lld(%2d)]", p->id, p->balance);
    prefix(p->pLeft);
    prefix(p->pRight);
  }
}

void freeAVL(Tree *pTree) {
  if (pTree != NULL) {
    freeAVL(pTree->pLeft);
    freeAVL(pTree->pRight);
    free(pTree);
  }
}



int validateInput(long long id, long long capacity, long long load) {
  if (id < 0 || capacity < 0 || load < 0) {
    fprintf(stderr, "Erreur : donnees invalides pour ID %lld.\n", id);
    return 0;
  }
  return 1;
}

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
