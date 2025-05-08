// ECE:3350 SISC processor project
// branch adder and mux

`timescale 1ns/100ps

module br (pc_out, imm, br_sel, br_addr);

  /*
   *  BRANCH ADDRESS CALCULATOR - br.v
   *
   *  Inputs:
   *   - pc_out (16 bits): Equal to PC, which is the base that relative
   *        branch addresses are added to. Comes from the program counter
   *        module (pc.v).
   *   - imm (16 bits): The immediate value from the instruction.
   *   - br_sel: Controls whether to add the immediate value to PC
   *        (relative branch, br_sel = 0) or to add it to 0 (absolute branch,
   *        br_sel = 1).
   *
   *  Outputs:
   *   - br_addr (16 bits): The computed branch address, ready to be passed
   *        to the program counter module. This module does NOT decide
   *        whether or not the branch is taken; it only computes the
   *        potential address to be branched to.
   *
   */

  input [15:0] pc_out;                        // program counter to add relative offset to 
  input [15:0] imm;                           // immediate offset
  input br_sel;                               // branch select. if br_sel == 1 ? absolute : relative

  output [15:0] br_addr;                      // branch address to be inputted as next ir 
 
  reg [15:0] br_in;                           // branch input to add to. if br_sel == 1 ? absolute (0x0000 + immediate) : relative (pc_out + immediate)
  always @ (pc_out, br_sel)
  begin
    if (br_sel == 1'b1)
      br_in <= 16'h0000;                       // absolute branch: branch selection soley the immediate value 
    else
      br_in <= pc_out;                         // relative branch: branch input sum of current pc and immediate value (via a label or known memory address)
  end

  assign br_addr = br_in + imm;               // simply compute the offset from branch and immediate. 

endmodule
