// ECE:3350 SISC processor project
// main sisc module

`timescale 1ns/100ps  

module sisc (clk, rst_f);             // removed ir as sisc internally should handle memory. There are loops now; the program execution is not sequential

  input clk;                          // clock signal
  input rst_f;                        // reset signal

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
  im u10 (read_addr,                   // instruction memory
          read_data);

  ir u9 (clk,                         // instruction register
        ir_load,
        read_data, 
        instr);

  ctrl u1 (clk,                       // control unit
           rst_f,
           instr[31:28],              // opcode
           instr[27:24],              // mm (funct for alu)
           stat,
           rf_we,
           alu_op,
           wb_sel, 
           br_sel,                    
           pc_rst,                    
           pc_write,
           pc_sel,
           ir_load); 
  // control unit outputs signals that affect downstream components

  rf u2 (clk,                         // register file
         ir[19:16],                   // read rega
         ir[15:12],                   // read regb
         ir[23:20],                   // write reg
         wr_dat,
         rf_we,
         rega,
         regb);

  alu u3 (clk,                        // alu
          rega,
          regb,
          ir[15:0],                   // immediate value
          stat[3],
          alu_op,
          ir[27:24],                  // function 
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

  pc u7 (clk,                         // program counter
        br_addr,
        pc_sel,
        pc_write,
        pc_rst,
        pc_out);


  br u8 (pc_out,                      // branch calculator
        imm,
        br_sel,
        br_addr);
             
  initial
  $monitor("time: " $time,
           "ir: %h\n", ir,                        // %h
           "ram_array[1]: %h\n", u2.ram_array[1], // %h
           "ram_array[2]: %h\n", u2.ram_array[2], // %h
           "ram_array[3]: %h\n", u2.ram_array[3], // %h
           "ram_array[4]: %h\n", u2.ram_array[4], // %h
           "ram_array[5]: %h\n", u2.ram_array[5], // %h
           "alu_op: %h\n", alu_op,                // %h
           "wb_sel: %b\n", wb_sel,                // %b
           "rf_we: %b\n", rf_we,                  // %b
           "wr_dat: %h\n", wr_dat,                // %h
           "br_sel: %b\n", br_sel,                // %b
           "pc_rst: %b\n", pc_rst,                // %b
           "pc_write: %b\n", pc_write,            // %b
           "pc_sel: %b\n", pc_sel,                // %b
           "ir_load: %b\n", ir_load,              // %b
           "instr: %h\n", instr);                 // %h

endmodule


