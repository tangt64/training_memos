#include <stdlib.h>
#include <time.h>

int getRandInt(){
   srand(time(NULL)); 
   return rand() % 10;
}
