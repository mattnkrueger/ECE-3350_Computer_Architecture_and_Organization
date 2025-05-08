// ECE:3350 SISC processor project

`timescale 1ns/100ps                    // 1ns per clock. simulation 100ps divisions

module sisc_tb_p2;

  parameter tclk = 10.0;                // period 10ns

  reg clk;                              // system clock
  reg rst_f;                            // reset signal

  // create sisc unit under test
  sisc uut (clk, rst_f);   

  // start clock at 0
  initial
  begin
    clk = 0;    
  end
	
  always
  begin
    #(tclk/2.0);                    // delay half period
    clk = ~clk;                     // invert clock        ... i guess these are fine as blocking assignments as it is just the generator... anything affected by this clock downstream should be non-blocking
  end
 
  // reset control
  initial 
  begin
    rst_f = 0;
    #20 rst_f = 1;
  end

  // ----------------------- REMOVED IR / PROGRAM MEMORY ----------------------- 
  // because we are not hardcoding a program and need to calculate branching, we 
  // cannot simply update the ir from this module. the computer's complexity is
  // increasing and thus its necessary for the sisc to produce its own signals 
  // to branch inside the program if needed. my implementation has the current 
  // instruction sourced from the im module. Note that ctrl unit determines the
  // memory location sourced (see ctrl.v and imem.data) for more details.

  // --- also ---
  // see sisc.v for monitor statements. i have removed redundant monitoring statements in this file. 
  // "... your submitted *sisc.v* should monitor the following signals: ..."

endmodule

