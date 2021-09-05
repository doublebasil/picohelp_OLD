// Include the essential pico library
#include "pico/stdlib.h"
// Include pico's hardware ADC library, remember to add hardware_adc to CMakeLists.txt
#include "hardware/adc.h"
// Include io library to allow printing
#include <stdio.h>

/* This program continually prints the ADC value from ADC pin 0 and 1
 */

int main() {
	stdio_init_all();		// This allows serial printing

	uint16_t readingPin0;	// ADC reading should return a 12 bit int
	uint16_t readingPin1;

	// Initilise the ADC functions (doesn't take any input)
	adc_init();
	
	// Initialise the ADC pins using the GPIO pin number for the pin
	// For example, ADC pin 0 has GPIO number 26
	
	// Initialise ADC pin 0 (GPIO pin 26)
	adc_gpio_init(26);
	// Initialise ADC pin 1 (GPIO pin 27)
	adc_gpio_init(27);

	while(true) {
		// Select the ADC pin 0
		adc_select_input(0);
		// Read from selected ADC pin
		readingPin0 = adc_read();
		// Repeat for ADC pin 1
		adc_select_input(1);
		readingPin1 = adc_read();
		// Print to serial
		printf("Pin 0 = %d \t Pin 1 = %d \n", readingPin0, readingPin1);
		// Sleep to prevent excessive console output
		sleep_ms(100);
	}

}
