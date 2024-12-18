#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include "avl_tree.h"

// Définition des fonctions de l'AVL (insert, rotations, équilibrage, etc.)

int min2(int a, int b) { return a < b ? a : b; }
int max2(int a, int b) { return a > b ? a : b; }
int min3(int a, int b, int c) { return min2(a, min2(b, c)); }
int max3(int a, int b, int c) { return max2(a, max2(b, c)); }

Tree *rotateLeft(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pRight == NULL) {
    exit(200);
  }
  Tree *pPivot = pRoot->pRight;
  pRoot->pRight = pPivot->pLeft;
  pPivot->pLeft = pRoot;
  int eqa = pRoot->balance;
  int eqp = pPivot->balance;
  pRoot->balance = eqa - max2(eqp, 0) - 1;
  pPivot->balance = min3(eqa - 2, eqa + eqp - 2, eqp - 1);
  pRoot = pPivot;
  return pRoot;
}

Tree *rotateRight(Tree *pRoot) {
  if (pRoot == NULL || pRoot->pLeft == NULL) {
    exit(201);
  }
  Tree *pPivot = pRoot->pLeft;
  pRoot->pLeft = pPivot->pRight;
  pPivot->pRight = pRoot;
  int eqa = pRoot->balance;
  int eqp = pPivot->balance;
  pRoot->balance = eqa - min2(eqp, 0) + 1;
  pPivot->balance = max3(eqa + 2, eqa + eqp + 2, eqp + 1);
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
      pRoot = rotateLeft(pRoot);
    } else {
      pRoot = doubleRotateLeft(pRoot);
    }
  } else if (pRoot->balance <= -2) {
    if (pRoot->pLeft == NULL) {
      exit(207);
    }
    if (pRoot->pLeft->balance <= 0) {
      pRoot = rotateRight(pRoot);
    } else {
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
    printf("%02lld:%02lld:%02lld\n", p->id, p->capacity, p->load);
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
