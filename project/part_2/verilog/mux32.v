// ECE:3350 SISC processor project
// 32-bit mux

`timescale 1ns/100ps

module mux32 (in_a, in_b, sel, out);

  /*
   *  32-BIT MULTIPLEXER - mux32.v
   *
   *  Inputs:
   *   - in_a (32 bits): First input to multiplexer. Selected when sel = 0.
   *   - in_b (32 bits): Second input. Selected when sel = 1.
   *   - sel: Selects which input propagates to output.
   *
   *  Outputs:
   *   - out (32 bits): Multiplexer output.
   *
   */

  input [31:0] in_a;                          // data a (0). this is used as a bitbucket if no data is to be written back (rf_we should also be disabled unless, clear command (maybe??)). 
  input [31:0] in_b;                          // data b (output of alu)
  input sel;                                  // select signal to select either 0 or data to write back. Note that register file write_reg determines the address to be written to. 

  reg   [31:0] outreg;                        // store the output data n register

  output [31:0] out;                          // output of mux32 to be written back into the register file
   
  always @ (in_a, in_b, sel)
  begin
    if (sel == 1'b0)                          // if select is 0, select 0
      outreg = in_a;
    else
      outreg = in_b;                          // if select is 1, select data from alu output
  end

  assign out = outreg;                        // writeback

endmodule
