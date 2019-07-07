#include <stdio.h>

int main(int argc, char const *argv[]) {

    int a = 1;

    for (int i = 0; i < 3; i++) {
        a++;
    }

    printf("%d %s\n", a, argv[1]);

    return 0;
}
