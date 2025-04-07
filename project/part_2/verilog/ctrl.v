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

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, ir_load);
  input clk;                                        // clock signal
  input rst_f;                                      // reset signal
  input [3:0] opcode;                               // opcode from the instruction register
  input [3:0] mm;                                   // memory address from the instruction register. used for branch absolute
  input [3:0] stat;                                 // status register CCs

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

  // opcode values (aligns with what is in imem.data)
  parameter NOOP   = 0;
  parameter REG_OP = 1;
  parameter REG_IM = 2;     
  parameter SWAP   = 3;   // not implemented
  parameter BRA    = 4;   // not implemented
  parameter BRR    = 5;
  parameter BNE    = 6;
  parameter BNR    = 7;
  parameter JPA    = 8;   // not implemented
  parameter JPR    = 9;   // not implemented
  parameter LOD    = 10;  // not implemented
  parameter STR    = 11;  // not implemented
  parameter CALL   = 12;  // not implemented
  parameter RET    = 13;  // not implemented
  parameter HLT    = 15;
   
  // state registers
  reg [2:0] present_state;
  reg [2:0] next_state;

  // start at state 0
  initial
    present_state = start0;

  // check for resets. If reset, set state to 1
  always @(posedge clk, negedge rst_f)              // SEQUENTIAL -> non blocking
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  // determine next state
  always @(present_state, rst_f)                   // COMBINATIONAL -> blocking   
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
  always @(*)               // COMBINATIONAL -> blocking. also swithing sensitivity list to * to include all inputs (considered best practice in industry)
  begin

    // default signals subject to change during current pipeline stage
    rf_we   = 1'b0;                     
    wb_sel  = 1'b0;                      
    alu_op  = 4'b0000;                    

    // additional for part 2
    br_sel   = 1'b0;          // if 1 -> absolute, 0 -> offset             
    pc_rst   = 1'b0;          // if 1 -> reset,    0 -> continue
    pc_sel   = 1'b0;          // if 1 -> branch,   0 -> increment pc
    pc_write = 1'b0;          // if 1 -> save,     0 -> do not save
    ir_load  = 1'b0;          // if 1 -> load ir,  0 -> do not load                
        
    case(present_state)

      // 1. (F)etch
      // load ir from memory, increment pc
      fetch:
        begin
          ir_load  = 1'b1;                    // load 
          pc_sel   = 1'b0;                   // increment
          pc_write = 1'b1;                   // save 
        end

      // 2. (D)ecode
      // determine opcode, check for branches based on status register. Output to alu execute stage
      decode:
        begin
          // default signals
          br_sel = 1'b0;
          pc_sel = 1'b0;
          pc_write = 1'b1;  // default to write the prev incremented pc

          case(opcode)
            BRR: // Branch if register equals zero
            begin 
              if (stat[0] == 1'b1)              // if z flag is set, then branch
              begin 
                br_sel   = 1'b0;                // relative
                pc_sel   = 1'b1;
                pc_write = 1'b1;
              end
            end
            
            BNR: // Branch if register not equals zero
            begin 
              if (stat[0] == 1'b0)              // if z flag is not set, then branch
              begin 
                br_sel   = 1'b0;                // relative     
                pc_sel   = 1'b1;  
                pc_write = 1'b1;  
              end
            end
            
            BNE: // Branch not equal (unconditional or conditional) absolute 
            begin 
              
              if (mm == 4'h0 || (mm == 4'h1 && stat[0] == 1'b0))  // if mm = 0 (see imem.data) which declares unconditional branch, or if mm = 1 (which declares conditional branch) and z flag is not set. NOT EQUAL TO ZERO
                begin 
                  br_sel = 1'b1;                // absolute
                  pc_sel = 1'b1;   
                  pc_write = 1'b1;
                end
            end

            default:
            begin
              br_sel = 1'b0;
              pc_sel = 1'b0;
              pc_write = 1'b1;
            end
          endcase
        end

      // 3. (C)ompute
      execute:                 
        begin
          if (opcode == REG_OP)
            begin
              alu_op = 4'b0001;               
            end

          if (opcode == REG_IM)
            begin
              alu_op = 4'b0011;                
            end

          // what was in part 1should be sufficient; this handles the two types of call formats. All that was needed for part 2 was branching logic & additional signals
          // dont do anything for branching. the changes should take effect on the next load. ALU not required.
        end

      // 4. (M)emory
      mem:                    
        begin
          if (opcode == REG_OP)
            begin
              alu_op = 4'b0000;                 
            end

          if (opcode == REG_IM)
            begin
              alu_op = 4'b0010;                 
            end
        end

      // 5. (W)riteback
      writeback:             
        begin
          if (opcode == REG_OP || opcode == REG_IM)
            begin
              rf_we  = 1'b1;
            end
        end

      // otherwise
      default:      
        begin
          rf_we    = 1'b0;                     
          wb_sel   = 1'b0;                      
          alu_op   = 4'b0000;                    
          br_sel   = 1'b0;                        
          pc_rst   = 1'b0;                         
          pc_sel   = 1'b0;                          
          pc_write = 1'b0;                          
          ir_load  = 1'b0;                          
        end
      
    endcase
  end

endmodule
