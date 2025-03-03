// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);
    // Inputs: 
    //
    // 1-Bit Inputs:
    //  clk - clock signal
    //  rst_f - reset signal
    //
    // 32-Bit Inputs:
    //  ir - Instruction Register
    input clk, rst_f;
    input [31:0] ir;

    // Outputs:
    //  None
    // Wires: exhaustive list of wires on the diagram
    //  ir[31:28] of instruction[31:0] -> CTRL
    //  ir[27:24] of instruction[31:0] -> CTRL
    //  ir[19:16] of instruction[31:0] -> RF
    //  ir[23:20] of instruction[31:0] -> RF
    //  ir[15:12] of instruction[31:0] -> RF
    //  ir[15:0] of instruction[31:0] -> ALU
    //  CLK (SISC_tb) -> CTRL, RF, STATREG, & ALU
    //  RST_F (SISC_tb) -> CTRL 
    //  RF output A -> ALU
    //  RF output B -> ALU
    //  CTRL -> RF
    //  ALU Control -> STATREG
    //  ALU CC -> STATREG 
    //  ALU Out -> MUX32 0
    //  0 -> MUX32 1
    //  MUX32 -> RF
    //  CTRL -> ALU
    //  CTRL -> MUX32
    wire [31:0] mux_out;    // mux out
    wire [31:0] rsa;        // rf out
    wire [31:0] rsb;        // rf out
    wire [31:0] alu_result; // alu out 32-bit
    wire [3:0] stat;        // alu status output
    wire [3:0] stat_en;     // alu status enable
    wire [3:0] stat_out;    // status reg out
    wire rf_we;             // register file write enable from control
    wire [3:0] alu_op;      // ALU operation from control
    wire wb_sel;            // write back select from control

    // Control Unit Instantiation (CTRL)
    // 
    // Signature:
    //  module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel);
    ctrl sisc_ctrl (
        .clk(clk),
        .rst_f(rst_f),
        .opcode(ir[31:28]),
        .mm(ir[27:24]), 
        .stat(stat_out),
        .rf_we(rf_we),              // output 
        .alu_op(alu_op),            // output
        .wb_sel(wb_sel)             // output
    );
    
    // Register File Instantiation (RF)
    //
    // Signature:
    //  module rf (clk, read_rega, read_regb, write_reg, write_data, rf_we, rsa, rsb);
    rf sisc_rf (
        .clk(clk),
        .read_rega(ir[19:16]),         
        .read_regb(ir[15:12]),    
        .write_reg(ir[23:20]),   
        .write_data(mux_out),      
        .rf_we(rf_we),              
        .rsa(rsa),                  // output 
        .rsb(rsb)                   // output 
    );

    // Status Register Instantiation (STAT)
    //
    // Signature:
    //  module statreg (clk, in, enable, out);
    statreg sisc_statreg (
        .clk(clk),
        .in(stat),
        .enable(stat_en),
        .out(stat_out)             // output
    );

    // Arithmetic Logic Unit Instantiation (ALU)
    //
    // Signature:
    //  module alu (clk, rsa, rsb, imm, c_in, alu_op, funct, alu_result, stat, stat_en);
    alu sisc_alu (
        .clk(clk),
        .rsa(rsa),
        .rsb(rsb),
        .imm(ir[15:0]),
        .c_in(1'b0),              // 0 as carry-in
        .alu_op(alu_op),
        .alu_result(alu_result),  // output
        .stat(stat),              // output
        .stat_en(stat_en)         // output
    );

    // Multiplexor (MUX32)
    //
    // Signature:
    //  module mux32 (in_a, in_b, sel, out);
    mux32 sisc_mux32 (
        .in_a(alu_result),
        .in_b(32'b0),
        .sel(wb_sel),
        .out(mux_out)             // output
    );

    // Monitoring the required signals - (via Part 1.pdf)
    initial begin
        $monitor("Time: %0t, IR=%h, R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, ALU_OP=%h, WB_SEL=%b, RF_WE=%b, Write_Data=%h", 
                $time, ir, sisc_rf.ram_array[1], sisc_rf.ram_array[2], sisc_rf.ram_array[3], 
                sisc_rf.ram_array[4], sisc_rf.ram_array[5], alu_op, wb_sel, rf_we, mux_out);
    end

endmodule