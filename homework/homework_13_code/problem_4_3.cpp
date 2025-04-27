/*
 * Class: Computer Architecture and Organization, James Maxtead - University of Iowa
 * Program: Computer Organization and Embedded Systems, Problem 4.3
 * Author: Matt Krueger
 * Date: 4/28
 *
 * Task:
 * Using the seven-segment display in Figure 3.17 and the timer 
 * interface registers in Figure 3.14, write a RISC-style program
 * that flashes decimal digits in the repeating sequence 0, 1, 2, ..., 9, 0, .... 
 * Each digit is to be displayed for one second. Assume that the counter in the timer
 * circuit is driven by a 100-MHz clock.
 */  

// Figure 3.14: Timer register
//         7  |   6  |   5  |   4  |   3  |   2  |   1  |   0  |
//        +----------------------------------------------------+
// 0x4020 |                               |  TON | ZERO | TIRQ |    TIM_STATUS
//        +----------------------------------------------------+
// 0x4024 |                        |  UP  | FREE | RUN  | TIE  |    TIM_CONT
//        +----------------------------------------------------+
// 0x4028 |                 Initial Count Value                |    TIM_INIT
//        +----------------------------------------------------+
// 0x402C |                 Current Count Value                |    TIM_COUNT
//        +----------------------------------------------------+

// Figure 3.17: 7-segment display
//         a
//        -----
//     f |     | b
//       | -g- |
//     e |     | c
//        -----
//         d
//
//    Number | a b c d e f g
//    -------|--------------
//      0    | 1 1 1 1 1 1 0
//      1    | 0 1 1 0 0 0 0
//      2    | 1 1 0 1 1 0 1
//      3    | 1 1 1 1 0 0 1
//      4    | 0 1 1 0 0 1 1
//      5    | 1 0 1 1 0 1 1
//      6    | 1 0 1 1 1 1 1
//      7    | 1 1 1 0 0 0 0
//      8    | 1 1 1 1 1 1 1
//      9    | 1 1 1 1 0 1 1


#include <iostream>

const uint8_t seven_segment_codes[] = {
    0b1111110,  // 0
    0b0110000,  // 1
    0b1101101,  // 2
    0b1111001,  // 3
    0b0110011,  // 4
    0b1011011,  // 5
    0b1011111,  // 6
    0b1110000,  // 7
    0b1111111,  // 8
    0b1111011   // 9
};
 
/**
 * @brief simulate 7-segment
 * 
 * simulate DISP registers by sending out current code. Additionally, the current counter is printed to the screen.
 * this process is parallel and not sequentially streamed like the previous problem. 7-segments use shift register with output buffer
 * to correctly display code.
 * 
 * @param current_num - current counter
 * @param DISP_STATUS 
 * @param DISP_DATA 
 * @param DISP_CONT 
 */
void display_to_seven_segment(uint8_t current_num, volatile uint8_t* DISP_STATUS, volatile uint8_t* DISP_DATA, volatile uint8_t* DISP_CONT) {
  uint8_t code = seven_segment_codes[current_num];

  *DISP_CONT &= ~0x2; // disable interrupts

  while ((*DISP_STATUS & 0x4) != 0);    // blocking
  
  // SIMULATING
  *DISP_DATA = code;
  *DISP_STATUS |= 0x4;            // DOUT pulse to send character
  *DISP_STATUS &= ~0x4;

  // print to terminal 
  std::cout << "displaying " << (int) current_num << ": ";
  
  // Print the binary representation of the segment code identical process as previous problem except this time we arent streaming (treated as parallel by data out... this code is just for testing)
  for (int i = 6; i >= 0; i--) {
    std::cout << ((code >> i) & 1);
  }

  std::cout << '\n';
}

int main () {
  // copy pasted from prev prob...
  uint8_t memory[0x5000] = {0};
  volatile uint8_t* DISP_DATA   = &memory[0x4010];
  volatile uint8_t* DISP_STATUS = &memory[0x4014];
  volatile uint8_t* DISP_CONT   = &memory[0x4018];

  // for timer 
  volatile uint8_t* TIM_STATUS = &memory[0x4020];
  volatile uint8_t* TIM_CONT   = &memory[0x4024];
  volatile uint32_t* TIM_INIT  = (volatile uint32_t*)&memory[0x4028];
  volatile uint32_t* TIM_COUNT = (volatile uint32_t*)&memory[0x402C];


  int counter = 0;
  while (1) {
    // handle counter rollover 
    if (counter > 9) {
        std::cout << "-- RESTARTING COUNTER --\n";
        counter = 0;
    }

    display_to_seven_segment(counter, DISP_STATUS, DISP_DATA, DISP_CONT);
    counter++;

    // not abstracting the delay into its own method as it is small
    // THIS IS A 32 BIT, making this process easier than 8bit used in Embedded Systems:
    *TIM_INIT = 100000000;  // 100 MHz clock, so 100,000,000 cycles = 1 second
    *TIM_COUNT = 0;         // start at 0
    *TIM_CONT |= 0x8;       // set UP bit to count up
    *TIM_CONT |= 0x2;       // set RUN bit to start timer
    // no timer interrupts programmed, 
    
    // SIMULATING -- just setting this so blocking loop allows for continuation of program. YES, this isnt how it would work in an actual implementation, 
    // but we were not required to add all sorts of control signals, so this should suffice
    *TIM_STATUS |= 0x2;
    
    while ((*TIM_STATUS & 0x2) == 0); // wait until ZERO bit set (overflow)
    *TIM_CONT &= ~0x2;                // clear RUN bit to stop the timer
    
    // Clear the ZERO bit for next iteration
    *TIM_STATUS &= ~0x2;
  }
  
  return 0;
}
