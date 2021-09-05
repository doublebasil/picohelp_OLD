#include "pico/stdlib.h"
// stdio.h is needed for printing to console
// You could alternatively use iostream!
#include <stdio.h>

int main() {
	// Initialise stdio to print to console. VERY IMPORTANT
	stdio_init_all();

	while (true) {
		// Print something to the console
		printf("Hello, world! \n");
		// Sleep for a second
		sleep_ms(1000);
	}
}
