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

  // additional connections for part 2
  wire ir_load;
  wire br_sel;
  wire pc_rst;
  wire pc_sel;
  wire pc_write;

  wire [31:0] instr;
  wire [31:0] read_addr;
  wire [31:0] read_data;
  wire [15:0] pc_out;
  wire [15:0] br_addr;
  wire [15:0] imm;

  // Component Initialization
  im sisc_im (read_addr,                   // instruction memory
          read_data);

  ir sisc_ir (clk,                         // instruction register
        ir_load,
        read_data, 
        instr);

  ctrl sisc_ctrl (clk,                       // control unit
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

  rf sisc_rf (clk,                         // register file
         instr[19:16],                   // read rega
         instr[15:12],                   // read regb
         instr[23:20],                   // write reg
         wr_dat,
         rf_we,
         rega,
         regb);

  alu sisc_alu (clk,                        // alu
          rega,
          regb,
          instr[15:0],                   // immediate value
          stat[3],
          alu_op,
          instr[27:24],                  // function 
          alu_out,
          alu_sts,
          stat_en);

  mux32 sisc_mux32 (alu_out,                  // mux32
            32'h00000000,             
            wb_sel,
            wr_dat);

  statreg sisc_statreg (clk,                    // status register
              alu_sts,
              stat_en,
              stat);

  pc sisc_pc (clk,                         // program counter
        br_addr,
        pc_sel,
        pc_write,
        pc_rst,
        pc_out);

  assign read_addr = {16'h0000, pc_out}; // Connect PC to memory address
  assign imm = instr[15:0]; // Extract immediate field

  br sisc_br (pc_out,                      // branch calculator
        imm,
        br_sel,
        br_addr);
             
  initial
  $monitor("time: %d\n", $time,                   
           "instruction: %h\n", instr,            
           "PC: %h\n", pc_out,
           "R1: %h\n", sisc_rf.ram_array[1],
           "R2: %h\n", sisc_rf.ram_array[2],
           "R3: %h\n", sisc_rf.ram_array[3],
           "ALU_OP: %h\n", alu_op,              
           "BR_SEL: %b\n", br_sel,          
           "PC_WRITE: %b\n", pc_write,    
           "PC_SEL: %b\n", pc_sel);   
            
endmodule