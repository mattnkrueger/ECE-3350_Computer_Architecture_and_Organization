/*
 * Class: Computer Architecture and Organization, James Maxtead - University of Iowa
 * Program: Computer Organization and Embedded Systems, Problem 4.2
 * Author: Matt Krueger
 * Date: 4/28
 *
 * Task: 
 * Assume that a memory location BINARY contains a 16-bit pattern.
 * It is desired to display these bits as a string of 0s and 1s on a 
 * display device that has the interface depicted in Figure 3.3.
 * Write a RISC-style program that accomplishes this task.
 */  

#include <iostream>

// +------------+
// | Figure 3.3 |
// +------------+
//
// Keyboard Interface
// ------------------
//
//             7  |   6  |   5  |   4  |   3  |   2  |   1   |   0  |
//          +-------------------------------------------------------+
// 0x4000   |                                                       |      KBD_DATA
//          +-------------------------------------------------------+
// 0x4004   |                          |      |      |  KIN  | KIRQ |      KBD_STATUS
//          +-------------------------------------------------------+
// 0x4008   |                          |      |      |  KIE  |      |      KBD_CONT
//          +-------------------------------------------------------+
//    
//
// Display Interface     
// -----------------
//
//             7  |   6  |   5  |   4  |   3  |   2  |   1   |   0  |
//          +-------------------------------------------------------+
// 0x4010   |                                                       |      DISP_DATA
//          +-------------------------------------------------------+
// 0x4014   |                          |      | DOUT |       | DIRQ |      DISP_STATUS
//          +-------------------------------------------------------+
// 0x4018   |                          |      |      |  DIE  |      |      DISP_CONT
//          +-------------------------------------------------------+
  
  /**
   * @brief streams characters to the screen 
   * 
   * Streaming used here rather than buffered as that is how displays work.
   * Shifts out the data sequentially (16b) to build a character to display.
   * 
   * @param msg           - simulated message to display to the screen
   * @param DISP_STATUS   - display status register
   * @param DISP_DATA     - display data register
   * @param DISP_CONT     - display control register
   */
  void display_character(uint16_t msg, volatile uint8_t* DISP_STATUS, volatile uint8_t* DISP_DATA, volatile uint8_t* DISP_CONT) {
    *DISP_CONT &= ~0x2; // disable interrupt
    
    for (int i = 15; i >= 0; i--) {
      uint8_t bit = (msg >> i) & 0x1;  
      uint8_t char_to_display = (bit == 0) ? '0' : '1';
      
      while ((*DISP_STATUS & 0x4) != 0);   // while still displaying something (simulating)

      *DISP_DATA = char_to_display;   // buffer the character
    
      *DISP_STATUS |= 0x4;            // DOUT pulse to send character
      *DISP_STATUS &= ~0x4;
    }
    
    *DISP_CONT |= 0x2;  
  }

int main () {
  // uint16_t BINARY = 0b0000000000000000;
  // this method wont work as placed in RAM... RISC is memory mapped.
  // Pretty sure this is to avoid storing the bits in the cache which results in incorrect data as mostly stale.
  // Harwiring these (memory mapping) solves this

  // simulated memory!!! Without this a segmentation fault is given
  uint8_t memory[0x5000] = {0};

  // DISPLAY INTERFACE
  // volatile as its a hardware register / interrupt NOT to be optimized by the compiler; Memory is subject to change
  volatile uint8_t* DISP_DATA   = &memory[0x4010];
  volatile uint8_t* DISP_STATUS = &memory[0x4014];
  volatile uint8_t* DISP_CONT   = &memory[0x4018];

  // BINARY (simulated display status)
  uint16_t BINARY = 0b1010110101101001; // random sequence

  // simulated perpetual polling 
  while (1) {
    display_character(BINARY, DISP_STATUS, DISP_DATA, DISP_CONT);

    // simulated delay usin)g a burn loop; volatile again to NOT be optimized by compiler
    for (volatile int i = 0; i < 10000; i++);
  }

  return 0;
}
