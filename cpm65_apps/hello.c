#include <cpm.h>
#include "nano6502_timer.h"
int main(void) {
    cpm_printstring("Hello\r\n");
    sleep_cs(100);
    cpm_printstring("\tWorld!\r\n");
}
