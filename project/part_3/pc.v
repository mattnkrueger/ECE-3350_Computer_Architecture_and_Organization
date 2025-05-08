// ECE:3350 SISC processor project
// program counter

`timescale 1ns/100ps

module pc (clk, br_addr, pc_sel, pc_write, pc_rst, pc_out);

  /*
   *  PROGRAM COUNTER - pc.v
   *
   *  Inputs:
   *   - clk: System clock; positive edge active
   *   - br_addr (16 bits): The branch address computed by the br module.
   *   - pc_sel: This control bit tells the pc module whether to save the branch
   *        address (pc_sel = 1) or PC+1 (pc_sel = 0) to the program counter.
   *   - pc_write: When this control bit changes to 1, the selected value (either
   *        the branch address or PC+1) is saved to pc_out and held there until
   *        the next time pc_en is set to 1.
   *   - pc_rst: This resets the program counter to 0x0000 when set to 1.
   *
   *  Outputs:
   *   - pc_out (16 bits): This is the current value of the program counter, to
   *        be used in the instruction memory (im.v) module.
   *
   */

  input clk;                        // system clock
  input [15:0] br_addr;             // computed branch address
  input pc_sel;                     // if pc_sel == 1 ? save branch : normal increment of pc
  input pc_write;                   // if pc_write == 1 ? output pc : hold pc until pc_en set
  input pc_rst;                     // if pc_rst == 1 ? reset program counter : continue
  output [15:0] pc_out;             // points to the next instruction in memory

  reg [15:0] pc_in;                 // next program counter (SHOULDNT THIS BE AN INPUT???)
  reg [15:0] pc_out;                // output of the next instruction in memory
 
  // program counter latch
  always @(posedge clk)
  begin
    if (pc_rst == 1'b1)
      pc_out <= 16'h0000;            // reset pc to 0x0000
    else
      if (pc_write == 1'b1)
        pc_out <= pc_in;             // set pc to pc_in which is calculated below
  end
  
  always @(br_addr, pc_out, pc_sel)
  begin
    if (pc_sel == 1'b0)
      pc_in <= pc_out + 1;            // no branch; increment current program counter by one. Incremented by 1 because 256KB of word length of 32. Each instruction takes one 'row' of memory in the array
    else
      pc_in <= br_addr;               // branch; add current program counter to branch address
  end

endmodule
