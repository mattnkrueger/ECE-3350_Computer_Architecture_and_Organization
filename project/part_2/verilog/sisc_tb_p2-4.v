// ECE:3350 SISC processor project

`timescale 1ns/100ps                    // 1ns per clock. simulation 100ps divisions

module sisc_tb;

  parameter tclk = 10.0;                // period 10ns

  reg clk;                              // system clock
  reg rst_f;                            // reset signal
  reg [31:0] ir;                        // ir

  // create sisc unit under test
  // part 2 includes ir sourced from imem hex instructions
  sisc uut (clk, rst_f, ir);

  // start clock at 0
  initial
  begin
    clk = 0;    
  end
	
  always
  begin
    #(tclk/2.0);                    // delay half period
    clk = ~clk;                     // invert clock
  end
 
  // reset control
  initial 
  begin
    rst_f = 0;

    // wait for 20 ns;
    #20; 

    rst_f = 1;
  end

  // TODO -> do something here to source the data

  // Monitor important signals
  initial
  begin
    $monitor("Time=%0d IR=%h R1=%h R2=%h R3=%h R4=%h R5=%h",
             $time, ir, 
             uut.my_rf.ram_array[1],                            
             uut.my_rf.ram_array[2],
             uut.my_rf.ram_array[3],
             uut.my_rf.ram_array[4],
             uut.my_rf.ram_array[5]);
  end

endmodule
