#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct _tree{
    int id;
    int capacity;
    int load;
    struct _tree* pLeft;
    struct _tree* pRight;
    int           balance;
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
    Tree* pPivot  = pRoot->pRight;
    pRoot->pRight = pPivot->pLeft;
    pPivot->pLeft = pRoot;
    // update balance ids
    int eqa = pRoot->balance;        
    int eqp = pPivot->balance;        
    pRoot->balance  = eqa - max2(eqp, 0) - 1;
    pPivot->balance = min3(eqa-2, eqa+eqp-2, eqp-1); 
    // return new root
    pRoot = pPivot;
    return pRoot;
}
Tree* rotateRight(Tree* pRoot){
    if(pRoot==NULL || pRoot->pLeft == NULL){
        exit(201);
    }
    // update pointeurs
    Tree* pPivot  = pRoot->pLeft;
    pRoot->pLeft = pPivot->pRight;
    pPivot->pRight = pRoot;
    // update balance ids
    int eqa = pRoot->balance;        
    int eqp = pPivot->balance;        
    pRoot->balance  = eqa - min2(eqp, 0) + 1;
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



Tree* createAVL(int i,int c,int l){
    Tree* pNew = malloc(sizeof(Tree));
    if(pNew == NULL ){
        exit(10);
    }
    pNew->id  = i;
    pNew->capacity  = c;
    pNew->load  = l;
    pNew->pLeft  = NULL;
    pNew->pRight = NULL;
    pNew->balance= 0;
    return pNew;
}

int searchAVL(Tree* pTree, int v){
    if(pTree == NULL){
        return 0;
    }
    else if(pTree->id == v){
        return 1;
    }
    else if(v > pTree->id){
        return searchAVL(pTree->pRight, v);
    }
    else{
        return searchAVL(pTree->pLeft, v);
    }
}

Tree* insertAVL(Tree* a, int i,int c,int l,int* h) {
    if (a == NULL) {
        *h = 1;
        return createAVL(i,c,l);
    } else if (i < a->id) {
        a->pLeft = insertAVL(a->pLeft, i,c,l, h);
        *h = -*h;
    } else if (i > a->id) {
        a->pRight = insertAVL(a->pRight, i,c,l, h);
    } else {
        a->capacity =  c;
        a->load += l;
        *h = 0; // L'élément est déjà présent dans l'arbre ne rien faire ! Il faut surement changer ça
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
        printf("[%02d(%2d)]", p->id, p->balance);
        infix(p->pRight);
    }
}

void prefix(Tree* p){
    if(p!=NULL){
        printf("[%02d(%2d)]", p->id, p->balance);
        prefix(p->pLeft);
        prefix(p->pRight);
    }
}





int main(){
	int h;
	int* pH = &h;
	int v1,v2,v3;
    Tree* AVLproj = NULL;
	
	while ( scanf("%d;%d;%d\n",&v1,&v2,&v3) == 3){
		
			AVLproj = insertAVL(AVLproj,v1,v2,v3,pH);
		
	}


return 0;
}


