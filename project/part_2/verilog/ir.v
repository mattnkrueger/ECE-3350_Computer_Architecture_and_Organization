// ECE:3350 SISC processor project
// instruction register

`timescale 1ns/100ps

module ir (clk, ir_load, read_data, instr);

  /*
   *  INSTRUCTION REGISTER - ir.v
   *
   *  Inputs:
   *   - clk: System clock; positive edge active
   *   - ir_load: if ir_load is = 1, the IR is loaded with read_data
   *   - read_data (32 bits): the 32 bit instruction from instruction memory
   *
   *  Outputs:
   *   - instr (32 bits): the 32 bit saved instruction
   *
   */
  
  input         clk;
  input         ir_load;
  input  [31:0] read_data;
  output [31:0] instr;
 
  reg [31:0] instr;
 
  // instruction register
  initial
    instr <= 32'h00000000;        // at boot, start at the 0th (fisrt) instruction in memory

  always @(posedge clk)           // at positive edge of clock (this is a pipelined sisc, so a new five step pipeline begins on each clock)
    if (ir_load == 1'b1)          // if load signal present, the current instruction becomes the instruction passed into module
      instr <= read_data;

endmodule