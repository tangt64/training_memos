#include <stdio.h>

// forward declaration from my_lib.a
int getRandInt();
void printInteger(int *inValue);
// forward declaration from my_shared_lib.so
int negateIfOdd(int inValue);

int main(){

    printf("Press Enter to repeat\n\n");
    do{
        int n = getRandInt();
        n = negateIfOdd(n);
        printInteger(&n);

    } while (getchar() == '\n');
   
    return 0;
}
