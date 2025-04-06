// ECE:3350 SISC computer project
// finite state machine

// PROJECT PART 2 DIRECTIONS:
// Modify control unit to include signals:
//    BR_SEL
//    PC_RST
//    PC_WRITE
//    PC_SEL
//    IR_LOAD

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, instr, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, ir_load);
  input clk;                                        // clock signal
  input rst_f;                                      // reset signal
  input [3:0] opcode;                               // opcode from the instruction register
  input [3:0] mm;                                   // memory mode from the instruction register
  input [3:0] stat;                                 // status register CCs
  input [31:0] instr;                               // current instruction from the im

  output reg rf_we;                                 // register file writeback enable signal
  output reg wb_sel;                                // writeback select signal
  output reg [3:0] alu_op;                          // alu operation signal

  output reg br_sel;
  output reg pc_rst;
  output reg pc_write;
  output reg pc_sel;
  output reg ir_load;
  
  // fsm states
  parameter start0    = 0;
  parameter start1    = 1;                          // start after resetting the sisc
  parameter fetch     = 2;                          // (F)etch 
  parameter decode    = 3;                          // (D)ecode
  parameter execute   = 4;                          // (C)ompute
  parameter mem       = 5;                          // (M)emory
  parameter writeback = 6;                          // (W)riteback
   
  // state registers
  reg [2:0] present_state;
  reg [2:0] next_state;

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
      #5 $display ("Halt.");                // precedural delay of 5ns to ensure message printed as expected
      $stop;                                // pause simulation
    end
  end

  // non starting states - 5 stage pipeline of sisc machine 
  always @(present_state, opcode)
  begin

    // default signals subject to change during current pipeline stage
    rf_we  = 1'b0;                          // set rf_we to 0 (no writebacks)
    wb_sel = 1'b0;                          // set select to 0 (select 0)
    alu_op = 4'b0000;                       // set opcode to nop 
    br_sel = 1'b0;                          // no branch selected; normal operation
    pc_rst = 1'b0;                          // no reset of pc; normal operation
    pc_sel = 1'b0;                          // normal increment of pc
    ir_load = 1'b0;                         // do not load ir. this is only done inside of the fetch state.
        
    case(present_state)

      // 1. (F)etch
        fetch:
        begin
          ir_load = 1'b1;                     // load the next instruction; testbench should handle program simulation 
          pc_sel = 1'b0;                      // increment program counter; saves PC+1 to the program counter
        end

      // 2. (D)ecode
      decode:
        begin
          // determine whether branch signals are to be used. 
          if (opcode == )
          

          // need to do something here to include the branching
        end

      // 3. (C)ompute
      execute:                 
        begin
          if (opcode == REG_OP)
            alu_op = 4'b0001;               
          if (opcode == REG_IM)
            alu_op = 4'b0011;                
        end

      // 4. (M)emory
      mem:                    
        begin
          if (opcode == REG_OP)
            alu_op = 4'b0000;                 
          if (opcode == REG_IM)
            alu_op = 4'b0010;                 
        end

      // 5. (W)riteback
      writeback:             
        begin
          if (opcode == REG_OP || opcode == REG_IM)
            rf_we  = 1'b1;
        end

      // otherwise
      default:      
        begin
          rf_we  = 1'b0;
          wb_sel = 1'b0;
          alu_op = 4'b0000;
        end
      
    endcase
  end

endmodule
