// ECE:3350 SISC processor project
// instruction memory

`timescale 1ns/100ps

module im (read_addr, read_data);

  /*
   *  INSTRUCTION MEMORY - im.v
   *
   *  Inputs:
   *   - read_addr (16 bits): The address of the instruction to read.
   *
   *  Outputs:
   *   - read_data (32 bits): The instruction specified by address read_addr.
   *
   */

  input [15:0] read_addr;                     // address to be read 2^16 = 65536 addresses, which is the address space of our "ram" inside sisc model
  output [31:0] read_data;                    // data contents of address. Resolution 32 bits. 2^32 = 4294967296 (unsigned) 
  
  reg [31:0] ram_array [65535:0];             // array with elements of 32 bit (1 word). There are 65536 elements. 65536x32x8 = 256KB storage
  reg [31:0] read_data;                       // register containing data accessed in memory array

  // load program into ram array
  initial begin : prog_load
    // UNCOMMENT ONE OF THE FOLLOWING LINES:
    // comment out all other programs that are not in use
    // only one program can run at a time
    
    // For sorting program:
    // $readmemh("sort_instr.data", ram_array);
    
    // for multiplication program:
    $readmemh("mult_instr.data", ram_array);
    
    // original program 
    // $readmemh("imem.data", ram_array);

    // debugging...
    $display("Instruction memory initialization:");
    $display("First instruction: %h", ram_array[0]);
    $display("Second instruction: %h", ram_array[1]);
    $display("Third instruction: %h", ram_array[2]);
  end
 
  // read process is sensitive to read address.
  // address is [15:0] because ram_array is word addressable, not byte addressable.
  always @(read_addr)
  begin
    read_data <= ram_array[read_addr[15:0]];
  end
  
endmodule
