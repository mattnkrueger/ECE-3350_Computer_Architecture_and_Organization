// ECE:3350 SISC processor project
// data memory

`timescale 1ns/100ps

module dm (clk, addr, write_data, mem_we, read_data);

  /*
   *  DATA MEMORY - dm.v
   *
   *  Inputs:
   *   - clk: System clock; positive edge active
   *   - addr (16 bits): The address to read from or write to
   *   - write_data (32 bits): Data to write when mem_we is 1
   *   - mem_we: Write enable signal. When 1, write_data is written to addr
   *
   *  Outputs:
   *   - read_data (32 bits): Data read from addr
   *
   */

  input clk;                        // system clock
  input [15:0] addr;                // memory address
  input [31:0] write_data;          // data to write
  input mem_we;                     // write enable
  output [31:0] read_data;          // data read from memory

  reg [31:0] ram_array [65535:0];   // 256KB memory (65536 words of 32 bits)
  reg [31:0] read_data;             // output register

  // initialize memory to 0
  initial
  begin
    for (integer i = 0; i < 65536; i = i + 1)
      ram_array[i] <= 32'h00000000;
    read_data <= 32'h00000000;
  end

  // read process - always reads current address
  always @(addr)
  begin
    read_data <= ram_array[addr];
  end

  // write process - writes on positive edge of clock when mem_we is 1
  always @(posedge clk)
  begin
    if (mem_we == 1'b1)
      ram_array[addr] <= write_data;
  end

endmodule 