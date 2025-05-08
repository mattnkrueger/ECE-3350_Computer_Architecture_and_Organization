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

  // additional connections for part 3
  wire rb_sel;                        // register bank select for X register operations
  wire [3:0] rb_addr;                // selected register address for reading regb
  wire [31:0] wb_data;               // data to be written back (either ALU or memory)

  // COMPONENT INITIALIZATION
  Ctrl sisc_ctrl (
    .clk(clk),
    .rst_f(rst_f),
    .opcode(instr[31:28]),
    .mm(instr[27:24]),
    .stat(stat),
    .rf_we(rf_we),
    .alu_op(alu_op),
    .wb_sel(wb_sel),
    .br_sel(br_sel),
    .pc_rst(pc_rst),
    .pc_write(pc_write),
    .pc_sel(pc_sel),
    .ir_load(ir_load),
    .mem_we(mem_we),
    .rb_sel(rb_sel)                  // add rb_sel control signal PART 3
  );

  // mux for selecting regb address (for STX instruction) PART 3
  mux4 regb_sel_mux (
    .in_a(instr[15:12]),            // normal Rd field
    .in_b(instr[23:20]),            // Rs field for STX
    .sel(rb_sel),
    .out(rb_addr)
  );

  // updated register file instantiation to use rb_addr
  rf sisc_rf (
    .clk(clk),
    .read_rega(instr[19:16]),       // Rs
    .read_regb(rb_addr),            // selected between Rd and Rs based on rb_sel
    .write_reg(instr[23:20]),       // Rd
    .write_data(wb_data),           // changed from wr_dat to wb_data
    .write_en(rf_we),
    .read_data_a(rega),
    .read_data_b(regb)
  );

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

  // mux for selecting between ALU result and memory data for writeback
  mux32 wb_mux (
    .in_a(alu_out),                 // ALU result
    .in_b(dm_read_data),            // MEmory data
    .sel(wb_sel),
    .out(wb_data)                   // Output to register file write data
  );

  // data memory connections
  assign dm_addr = alu_out[15:0];           // Address comes from ALU output
  assign dm_write_data = regb;              // Data to write comes from regb

  dm sisc_dm (
    .clk(clk),
    .addr(dm_addr),
    .write_data(dm_write_data),
    .write_en(mem_we),
    .read_data(dm_read_data)
  );
             
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