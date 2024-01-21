#include <stdio.h>

int main() {
	printf("Build: ");
	printf(__DATE__);
	printf(" ");
	printf(__TIME__);
	printf("\n");
	return 0;
}
