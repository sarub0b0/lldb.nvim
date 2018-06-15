#include <stdio.h>

int main(void) {
    int a = 1;

    for (int i = 0; i < 1000; i++) {
        a++;
    }

    printf("%d\n", a);

    return 0;
}
