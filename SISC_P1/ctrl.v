// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel);
  input clk, rst_f;
  input [3:0] opcode, mm, stat;
  output reg rf_we, wb_sel;
  output reg [3:0] alu_op;
  
  // state parameter declarations
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcode parameter declarations
  parameter NOOP = 0, REG_OP = 1, REG_IM = 2, SWAP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7;
  parameter JPA = 8, JPR = 9, LOD = 10, STR = 11, CALL = 12, RET = 13, HLT = 15;
	
  // addressing modes
  parameter AM_IMM = 8;

  // state register and next state signal
  reg [2:0]  present_state, next_state;
  
// initial procedure to initialize the present state to 'start0'.
  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end
  
  /* The following combinational procedure determines the next state of the fsm. */

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

  always @(present_state, opcode)
  begin

    // default values for control signals
    rf_we = 1'b0;    // disabled write option
    wb_sel = 1'b0;   // mux select default to alu writeback
    alu_op = 4'b0000; // NOP
    
    case(present_state)
	// if in early stages of fsm -> 
	// register file write still disabled (need to read)
	// write back no
	// no operation by alu
      start0, start1, fetch:
        begin
          rf_we = 1'b0; 
          wb_sel = 1'b0; 
          alu_op = 4'b0000;
        end
        
      decode:
        begin

        // no changes to write enable and mux select (need to read)
          rf_we = 1'b0;
          wb_sel = 1'b0;
          
          case(opcode)
                NOP:    alu_op = NOP;
       		ADD:    alu_op = ADD;
        	ADI:    alu_op = ADI;
        	SUB:    alu_op = SUB;
        	NOT:    alu_op = NOT;
        	OR:     alu_op = OR;
        	AND:    alu_op = AND; // this is updating the operation code sent to the ALU mapping current value to wanted value...
        	XOR:    alu_op = XOR; // essentially just passing what the current opcode is as we already know constants parameters representing the opcode
        	ROR:    alu_op = ROR;
        	ROL:    alu_op = ROL;
        	SHR:    alu_op = SHR;
        	SHL:    alu_op = SHL;
        	HLT:    alu_op = HLT;
		default: NOP
          endcase
        end
        
      execute:
	// ALU execution
        begin
          rf_we = 1'b0;
          
          if (opcode == REG_IM)
            wb_sel = 1'b1; // write back eneabled -> mux to output alu result
          else
            wb_sel = 1'b0;
        end
        
      mem:
	// keep we disabled
        begin
          rf_we = 1'b0;
        end
        
      writeback:
	// write alu result into the RF
        begin
          case(opcode)
            REG_OP, REG_IM:
              rf_we = 1'b1; 
            SWAP:
              rf_we = 1'b1; 
            default:
              rf_we = 1'b0;
          endcase
        end
        
      default:
	// default values 
	// register file write still disabled (need to read)
	// write back no
	// no operation by alu
        begin
          rf_we = 1'b0;
          wb_sel = 1'b0;
          alu_op = 4'b0000;
        end
    endcase
  end

// Halt on HLT instruction
  
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
      $stop;
    end
  end
  
endmodule
