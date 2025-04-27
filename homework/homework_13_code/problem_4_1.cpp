/*
 * Class: Computer Architecture and Organization, James Maxtead - University of Iowa
 * Program: Computer Organization and Embedded Systems, Problem 4.1
 * Author: Matt Krueger
 * Date: 4/28
 *
 * Task:
 * Write a program that displays the contents of ten bytes of 
 * the main memory in hexadecimal format on a line of a display device.
 * The ten bytes start at location LOC in the memory, and there are two 
 * hex characters per byte. The contents of successive bytes should be 
 * separated by a space when displayed.
 *
 */  

#include <iostream>
#include <iomanip> // hex formatting


/**
 * @brief display the bytes stroed in LOC
 * 
 * print each byte stream individually to the screen as a hex, simulating an object dump
 * 
 * @param ptr 
 * @param size 
 */
void display_bytes(char *ptr, int size) {
  for (int i = 0; i < size; i++) {
    std::cout << std::hex                       // specify hex 
              << std::setw(2)                   // width of two as we use 1byte (hex is a nibble; two nibbles = byte). ex handling 0a -> a -> width 2 -> _a -> fill 0 -> 0a
              << std::setfill('0')              // fill msb with char '0'
              << static_cast<int>(*(ptr++))
              << " ";
  }
}

int main () {
  char memory[10] = {0x40, 0x0A, 0x60, 0x42, 0x0F, 0x25, 0x0C, 0x07, 0x08, 0x10};   
  char* LOC = memory;
  display_bytes(LOC, 10);

  return 0;
}
