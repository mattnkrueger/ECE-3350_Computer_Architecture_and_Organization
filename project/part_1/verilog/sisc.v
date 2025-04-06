// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);

  input clk;                          // clock signal
  input rst_f;                        // reset signal
  input [31:0] ir;                    // instruction register 

  wire rf_we;                         // writeback enable signal for register file
  wire wb_sel;                        // writeback select for mux32 (and output from alu)

  wire [3:0] alu_op;                  // alu opcode 
  wire [3:0] alu_sts;                 // alu status cc output
  wire [3:0] stat;                    // status register output
  wire [3:0] stat_en;                 // enbale for overwriting status register

  wire [31:0] rega;                   // register a into alu
  wire [31:0] regb;                   // register b into alu
  wire [31:0] wr_dat;                 // data to write back into register file
  wire [31:0] alu_out;                // alu output from operation 
  
  // Component Initialization
  ctrl u1 (clk,                       // control unit
           rst_f,
           ir[31:28],
           ir[27:24],
           stat,
           rf_we,
           alu_op,
           wb_sel); 

  rf u2 (clk,                         // register file
         ir[19:16],
         ir[15:12],
         ir[23:20],
         wr_dat,
         rf_we,
         rega,
         regb);

  alu u3 (clk,                        // alu
          rega,
          regb,
          ir[15:0],
          stat[3],
          alu_op,
          ir[27:24],
          alu_out,
          alu_sts,
          stat_en);

  mux32 u5 (alu_out,                  // mux32
            32'h00000000,
            wb_sel,
            wr_dat);

  statreg u6 (clk,                    // status register
              alu_sts,
              stat_en,
              stat);

endmodule


