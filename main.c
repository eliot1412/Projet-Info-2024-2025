#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct _tree{
int id;
struct _tree* pLeft;
struct _tree* pRight;
int balance;
} Tree;

int min2(int a, int b){
return a < b ? a : b;
}
int max2(int a, int b){
return a > b ? a : b;
}
int min3(int a, int b, int c){
return min2(a, min2(b, c));
}
int max3(int a, int b, int c){
return max2(a, max2(b, c));
}

Tree* rotateLeft(Tree* pRoot){
if(pRoot==NULL || pRoot->pRight == NULL){
exit(200);
}
// update pointeurs
Tree* pPivot = pRoot->pRight;
pRoot->pRight = pPivot->pLeft;
pPivot->pLeft = pRoot;
// update balance values
int eqa = pRoot->balance;
int eqp = pPivot->balance;
pRoot->balance = eqa - max2(eqp, 0) - 1;
pPivot->balance = min3(eqa-2, eqa+eqp-2, eqp-1);
// return new root
//
pRoot = pPivot;
return pRoot;
}
Tree* rotateRight(Tree* pRoot){
if(pRoot==NULL || pRoot->pLeft == NULL){
exit(201);
}
// update pointeurs
Tree* pPivot = pRoot->pLeft;
pRoot->pLeft = pPivot->pRight;
pPivot->pRight = pRoot;
// update balance values
int eqa = pRoot->balance;
int eqp = pPivot->balance;
pRoot->balance = eqa - min2(eqp, 0) + 1;
pPivot->balance = max3(eqa+2, eqa+eqp+2, eqp+1); 
// return new root

pRoot = pPivot;
return pRoot;
}

Tree* doubleRotateLeft(Tree* pRoot){
if(pRoot==NULL || pRoot->pRight == NULL){
exit(202);
}
pRoot->pRight = rotateRight(pRoot->pRight);
return rotateLeft(pRoot);
}
Tree* doubleRotateRight(Tree* pRoot){
if(pRoot==NULL || pRoot->pLeft == NULL){
exit(203);
}
pRoot->pLeft = rotateLeft(pRoot->pLeft);
return rotateRight(pRoot);
}
Tree* balanceAVL(Tree* pRoot){
if(pRoot == NULL){
exit(205);
}

if(pRoot->balance >= 2){
if(pRoot->pRight == NULL){
exit(206);
}
if(pRoot->pRight->balance >= 0){
// LEFT SIMPLE
pRoot = rotateLeft(pRoot);
}
else{
// LEFT DOUBLE
pRoot = doubleRotateLeft(pRoot);
}
}
else if(pRoot->balance <= -2){
if(pRoot->pLeft == NULL){
exit(207);// Si l'arbre est déséquilibré à gauche
}
if(pRoot->pLeft->balance <= 0){
// RIGHT SIMPLE
pRoot = rotateRight(pRoot);
}
else{
// RIGHT DOUBLE
pRoot = doubleRotateRight(pRoot);
}
}
return pRoot;
}

Tree* createAVL(int v){
Tree* pNew = malloc(sizeof(Tree));
if(pNew == NULL){
exit(10);
}
pNew->value = v;
pNew->pLeft = NULL;
pNew->pRight = NULL;
pNew->balance= 0;
return pNew;
}

int searchAVL(Tree* pTree, int v){
if(pTree == NULL){
return 0;
}
else if(pTree->value == v){
return 1;
}
else if(v > pTree->value){
return searchAVL(pTree->pRight, v);
}
else{
return searchAVL(pTree->pLeft, v);
}
}

Tree* insertAVL(Tree* a, int e, int* h) {
if (a == NULL) {
*h = 1;
return createAVL(e);
} else if (e < a->value) {
a->pLeft = insertAVL(a->pLeft, e, h);
*h = -*h;
} else if (e > a->value) {
a->pRight = insertAVL(a->pRight, e, h);
} else {
*h = 0; // L'élément est déjà présent dans l'arbre
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


void infix(Tree* p){
if(p!=NULL){
infix(p->pLeft);
printf("[%02d(%2d)]", p->value, p->balance);
infix(p->pRight);
}
}

void prefix(Tree* p){
if(p!=NULL){
printf("[%02d(%2d)]", p->value, p->balance);
prefix(p->pLeft);
prefix(p->pRight);
}
}

Tree* suppMax(Tree* pTree, int* pValue ){
if(pTree == NULL || pValue == NULL){
exit(100);
}
if(pTree->pRight != NULL){
pTree->pRight = suppMax(pTree->pRight, pValue);
}
else{
// Store address to free
Tree* pRemove = pTree;
// exchange number values
*pValue = pTree->value;
// link left child
pTree = pTree->pLeft;
// free
free(pRemove);
}
return pTree;
}

Tree* removeAVL(Tree* pTree, int v){
if(pTree != NULL){
if(v < pTree->value){
pTree->pLeft = removeAVL(pTree->pLeft, v);
}
else if(v > pTree->value){
pTree->pRight = removeAVL(pTree->pRight, v);
}
else{
if(pTree->pLeft != NULL && pTree->pRight != NULL){
// suppmin / suppmax
pTree->pLeft = suppMax(pTree->pLeft, &(pTree->value) );
}
else{
// remove directly
// send child back
Tree* pChild = pTree->pLeft;
if(pChild == NULL){
pChild = pTree->pRight;
}
free(pTree);
pTree = pChild;
}
}
}
return pTree;
}

int main(){
	int v1,v2,v3;
	int sum2;
	int sum3;
	
	while ( scanf("%d;%d;%d\n",&v1,&v2,&v3) == 3){
		
			sum2 += v2;
			sum3 += v3;
		
	}


return 0;
}




