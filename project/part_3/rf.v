// ECE:3350 SISC processor project
// register file

`timescale 1ns/100ps

module rf (clk, read_rega, read_regb, write_reg, write_data, rf_we, rsa, rsb);

  /*
   *  REGISTER FILE - rf.v
   *
   *  Inputs:
   *   - read_rega (4 bits): Address to be read for RA.
   *   - read_regb (4 bits): Address to be read for RB.
   *   - write_reg (4 bits): Address of register to be written to when rf_we
   *        is set to 1.
   *   - write_data (32 bits): Data to write to register write_reg when rf_we
   *        is set to 1.
   *   - rf_we: Write enable. When this is set to 1, the data on write_data
   *        is copied into register write_reg.
   *
   *  Outputs:
   *     NOTE - rsa and rsb latch the selected register file contents on the
   *     positive edge of the clock.
   *   - rsa (32 bits): Contents of register read_rega. Note that R0 is always
   *        read as 0x00000000, for both RA and RB.
   *   - rsb (32 bits): Contents of register read_regb.
   *
   */

  input  clk;                                   // clock signal
  input  [3:0]  read_rega;                      // address in memory to read into register a
  input  [3:0]  read_regb;                      // address in memory to read into register b
  input  [3:0]  write_reg;                      // address in memory to write register contents to 
  input  [31:0] write_data;                     // data to write to register contents
  input  rf_we;                                 // register file writeback enable signal
  
  output [31:0] rsa;                            // register a output from register file
  output [31:0] rsb;                            // register b output from register file
  
  reg    [31:0] ram_array [15:0];               // simulated ram 
  reg    [31:0] rsa;                            // register a from register file
  reg    [31:0] rsb;                            // register b from register file

  integer i; 

  // clear contents in all registers
  initial
  begin
     for (i = 0; i < 16; i = i + 1) begin
       ram_array[i] <= 32'H00000000;
	 end
     rsa <= 32'H00000000;                       // additionally clear the outputs to alu
     rsb <= 32'H00000000;                       // additionally clear the outputs to alu
  end

  // read process is sensitive to read address.
  // reg 0 always returns 0 to allow boot strapping
  always @(posedge clk)
  begin
    if (read_rega == 4'H0)
      rsa <= 32'H00000000;                      
    else
      rsa <= ram_array[read_rega];             
  end

  // same for rsb. if this is 0, return 0
  always @(posedge clk)
  begin
    if (read_regb == 4'H0)
      rsb <= 32'H00000000;
    else    
      rsb <= ram_array[read_regb];            
  end

  // write process is sensitive to write enable
  always @(posedge clk)
  begin
    if (rf_we == 1'b1)
      ram_array[write_reg] <= write_data;       // only write to register in ram array if the rf_we is enabled
  end
  
endmodule
