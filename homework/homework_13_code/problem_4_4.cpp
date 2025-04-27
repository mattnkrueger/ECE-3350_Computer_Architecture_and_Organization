/*
 * Class: Computer Architecture and Organization, James Maxtead - University of Iowa
 * Program: Computer Organization and Embedded Systems, Problem 4.4
 * Author: Matt Krueger
 * Date: 4/28
 *
 * Task:
 * Using two 7-segment displays of the type shown in Figure 3.17, and the timer
 * interface registers in Figure 3.14, write a RISC-style program that flashes
 * the repeating sequence of numbers 0, 1, 2, ..., 98, 99, 0, .... Each number
 * is to be displayed for one second. Assume that the counter in the timer circuit
 * is driven by a 100-MHz clock.
 */  

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
 * The change simply uses 
 * 
 * @param tens_place - the tens place digit (0-9)
 * @param ones_place - the ones place digit (0-9)
 * @param DISP_STATUS 
 * @param DISP_DATA 
 * @param DISP_CONT 
 */
void display_to_seven_segments(uint8_t tens_place, uint8_t ones_place, volatile uint8_t* DISP_STATUS, volatile uint8_t* DISP_DATA, volatile uint8_t* DISP_CONT) {
  uint8_t tens_code = seven_segment_codes[tens_place];
  uint8_t ones_code = seven_segment_codes[ones_place];

  *DISP_CONT &= ~0x2; // disable interrupts

  // send the tens place digit (to the left display)
  while ((*DISP_STATUS & 0x4) != 0);    // blocking
  
  // SIMULATING
  *DISP_DATA = tens_code;
  *DISP_STATUS |= 0x4;            // DOUT pulse to send character
  *DISP_STATUS &= ~0x4;

  // Send the ones place digit (to the right display)
  while ((*DISP_STATUS & 0x4) != 0);    // blocking
  
  // SIMULATING
  *DISP_DATA = ones_code;
  *DISP_STATUS |= 0x4;            // DOUT pulse to send character
  *DISP_STATUS &= ~0x4;

  // print to terminal 
  std::cout << "displaying " << (int) tens_place << (int) ones_place << ": ";
  
  // print the binary representation of the tens place segment code
  std::cout << "tens=";
  for (int i = 6; i >= 0; i--) {
    std::cout << ((tens_code >> i) & 1);
  }

  // print the binary representation of the ones place segment code
  std::cout << ", ones=";
  for (int i = 6; i >= 0; i--) {
    std::cout << ((ones_code >> i) & 1);
  }

  std::cout << '\n';
}

/**
 * @brief extracted display sub
 * 
 * @param DISP_STATUS 
 */
void pulse_display(volatile uint8_t* DISP_STATUS) {
    *DISP_STATUS |= 0x4;            // Set DOUT bit to send character
    *DISP_STATUS &= ~0x4;           // Clear DOUT bit
}

/**
 * @brief extracted display sub
 * 
 * @param DISP_STATUS 
 */
void display_digit(uint8_t digit, volatile uint8_t* DISP_STATUS, volatile uint8_t* DISP_DATA) {
    uint8_t segment_code = seven_segment_codes[digit];
    
    while ((*DISP_STATUS & 0x4) != 0);    // Wait if display is busy
    *DISP_DATA = segment_code;            // Load segment code to data register
    pulse_display(DISP_STATUS);           // Pulse display to send character
}

/**
 * @brief extracted display sub
 * 
 * @param DISP_STATUS 
 */
void display_number(uint8_t number, volatile uint8_t* DISP_STATUS, volatile uint8_t* DISP_DATA, volatile uint8_t* DISP_CONT) {
    uint8_t tens = number / 10;
    uint8_t ones = number % 10;
    
    *DISP_CONT &= ~0x2;                   // Disable interrupts
    
    // Send tens place digit to left display
    display_digit(tens, DISP_STATUS, DISP_DATA);
    
    // Send ones place digit to right display
    display_digit(ones, DISP_STATUS, DISP_DATA);
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
    if (counter > 99) {
        std::cout << "-- RESTARTING COUNTER --\n";
        counter = 0;
    }

    uint8_t tens = counter / 10;
    uint8_t ones = counter % 10;
    
    display_to_seven_segments(tens, ones, DISP_STATUS, DISP_DATA, DISP_CONT);
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
