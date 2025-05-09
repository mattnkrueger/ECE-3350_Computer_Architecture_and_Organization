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
  wire mem_we;                        // memory write enable signal

  wire [31:0] instr;
  wire [15:0] read_addr;
  wire [31:0] read_data;
  wire [15:0] pc_out;
  wire [15:0] br_addr;
  wire [15:0] imm;
  wire [31:0] dm_read_data;           // data memory read data
  wire [31:0] dm_write_data;          // data memory write data
  wire [15:0] dm_addr;                // data memory address

  // Component Initialization
  // purely structual verilog, so all of this is happening concurrently... no ordering of modules required
  ctrl sisc_ctrl (clk,                       // control unit
           rst_f,
           instr[31:28],              // opcode
           instr[27:24],              // mm (funct for alu) also used for branching ; ex if 0 for bne unconditional branch, if 1 check for z in prev alu stage
           stat,
           rf_we,
           alu_op,
           wb_sel, 
           br_sel,                    
           pc_rst,                    
           pc_write,
           pc_sel,
           ir_load,
           mem_we);                   // memory write enable

  rf sisc_rf (clk,                        // register file
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
          instr[27:24],                  // function (memory mode for branching in ctrl)
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

  br sisc_br (pc_out,                      // branch calculator
        imm,
        br_sel,
        br_addr);

  im sisc_im (pc_out,                   // instruction memory
          read_data);

  ir sisc_ir (clk,                         // instruction register
        ir_load,
        read_data, 
        instr);

  // Data memory connections
  assign dm_addr = alu_out[15:0];           // use ALU output as memory address
  assign dm_write_data = regb;              // use register B as write data
  assign dm_read_data = dm_read_data;       // connect read data back to itself (for now)

  dm sisc_dm (clk,                          // data memory
        dm_addr,
        dm_write_data,
        mem_we,
        dm_read_data);
             
  // Monitor important signals
  initial
  begin
    // updated monitor statement to include signals ALU_OP, BR_SEL, PC_WRITE, and PC_SEL defined in project directions
    $monitor("Time = %0d R1 = %h R2 = %h R3 = %h ALU_OP = %b BR_SEL = %b PC_WRITE = %b PC_SEL = %b MEM_WE = %b",
             $time, 
             sisc_rf.ram_array[1],                            
             sisc_rf.ram_array[2],
             sisc_rf.ram_array[3],
             sisc_ctrl.alu_op,
             sisc_ctrl.br_sel,
             sisc_ctrl.pc_write,
             sisc_ctrl.pc_sel,
             sisc_ctrl.mem_we);
  end

endmodule