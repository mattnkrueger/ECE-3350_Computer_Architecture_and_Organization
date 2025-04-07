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
  wire [31:0] pc_out;
  wire [31:0] br_addr;

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
         instr[19:16],                   // read rega
         instr[15:12],                   // read regb
         instr[23:20],                   // write reg
         wr_dat,
         rf_we,
         rega,
         regb);

  alu u3 (clk,                        // alu
          rega,
          regb,
          instr[15:0],                   // immediate value
          stat[3],
          alu_op,
          instr[27:24],                  // function 
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
  $monitor("time: %d\n", $time,                   
           "instruction: %h\n", instr,            
           "ram_array[1]: %h\n", u2.ram_array[1],
           "ram_array[2]: %h\n", u2.ram_array[2],
           "ram_array[3]: %h\n", u2.ram_array[3],
           "ram_array[4]: %h\n", u2.ram_array[4],
           "ram_array[5]: %h\n", u2.ram_array[5],
           "alu_op: %h\n", alu_op,              
           "wb_sel: %b\n", wb_sel,             
           "rf_we: %b\n", rf_we,              
           "wr_dat: %h\n", wr_dat,           
           "br_sel: %b\n", br_sel,          
           "pc_rst: %b\n", pc_rst,         
           "pc_write: %b\n", pc_write,    
           "pc_sel: %b\n", pc_sel,       
           "ir_load: %b\n", ir_load);   
            
endmodule