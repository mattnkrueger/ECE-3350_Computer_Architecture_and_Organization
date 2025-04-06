// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel);
  input clk;                                        // clock signal
  input rst_f;                                      // reset signal
  input [3:0] opcode;                               // opcode from the instruction register
  input [3:0] mm;                                   // memory mode from the instruction register
  input [3:0] stat;                                 // status register CCs

  output reg rf_we;                                 // register file writeback enable signal
  output reg wb_sel;                                // writeback select signal
  output reg [3:0] alu_op;                          // alu operation signal
  
  // fsm states
  parameter start0 = 0;
  parameter start1 = 1;                             // start after resetting the sisc
  parameter fetch = 2;                              // (F)etch 
  parameter decode = 3;                             // (D)ecode
  parameter execute = 4;                            // (C)ompute
  parameter mem = 5;                                // (M)emory
  parameter writeback = 6;                          // (W)riteback
   
  // current accepted opcodes. Note that the opcode input is 4 bits. These are 4 bit codes that are checked 
  parameter NOOP = 0;
  parameter REG_OP = 1;
  parameter REG_IM = 2;
  parameter SWAP = 3;
  parameter BRA = 4;
  parameter BRR = 5;
  parameter BNE = 6;
  parameter BNR = 7;
  parameter JPA = 8;
  parameter JPR = 9;
  parameter LOD = 10;
  parameter STR = 11;
  parameter CALL = 12;
  parameter RET = 13;
  parameter HLT = 15;
  	
  // addressing modes
  // parameter AM_IMM = 8;

  // state registers
  reg [2:0]  present_state, next_state;

  // start at state 0
  initial
    present_state = start0;

  // check for resets. If reset, set state to 1
  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  // determine next state
  always @(present_state, rst_f)
  begin
    case(present_state)
      start0:
        next_state = start1;
      start1:
	  if (rst_f == 1'b0) 
        next_state = start1;
	 else
         next_state = fetch;
      fetch:
        next_state = decode;
      decode:
        next_state = execute;
      execute:
        next_state = mem;
      mem:
        next_state = writeback;
      writeback:
        next_state = fetch;
      default:
        next_state = start1;
    endcase
  end

  // Halt on HLT instruction
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt.");                // precedural delay to ensure message printed as expected
      $stop;                                // pause simulation
    end
  end
    
  // create control signals from the inputs
  // determine the instruction format (note this is little endian. I think the image in the book is big endian, so i mirror register contents. This aligns more with what is provided in the project)
  // a) register operand format
  // b) immediate operand format
  // c) call format
  always @(present_state, opcode)
  begin

    rf_we  = 1'b0;                          // set rf_we to 0 (no writebacks)
    wb_sel = 1'b0;                          // set select to 0 (select 0)
    alu_op = 4'b0000;                       // set opcode to nop 
        
    case(present_state)

      execute:                              // operations for (C)ompute state
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0001;               
        if (opcode == REG_IM)
          alu_op = 4'b0011;                
      end

      mem:                                  // operations for (M)emory state
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0000;                 
        if (opcode == REG_IM)
          alu_op = 4'b0010;                 
      end

      writeback:                            // operations for (W)riteback state
      begin
        if (opcode == REG_OP || opcode == REG_IM)
          rf_we  = 1'b1;
      end

      default:                              // default - nothing happens
      begin
        rf_we  = 1'b0;
        wb_sel = 1'b0;
        alu_op = 4'b0000;
      end
      
    endcase
  end

endmodule
