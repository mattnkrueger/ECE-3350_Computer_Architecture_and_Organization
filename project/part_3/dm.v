// ECE:3350 SISC processor project
// data memory

`timescale 1ns/100ps

module dm (read_addr, write_addr, write_data, dm_we, read_data);

  /*
   *  DATA MEMORY UNIT - dm.v
   *
   *  Inputs:
   *   - read_addr (16 bits): Memory address to be read from.
   *   - write_addr (16 bits): Memory address to be written to.
   *   - write_data (32 bits): Word to be written to memory.
   *   - dm_we: Control line that, when set to 1, causes input write_data to
   *        be saved to the memory address specified by write_addr.
   *
   *  Outputs:
   *   - read_data (32 bits): Word stored in memory location read_addr. Note
   *       that if the address specified is not within the range explicitly
   *       assigned values in the datamemory.data file, this will return
   *       xxxxxxxx, not 0x00000000.
   *
   */

  input  [15:0] read_addr;
  input  [15:0] write_addr;
  input  [31:0] write_data;
  input  dm_we;
  output [31:0] read_data;
  
  reg    [31:0] ram_array [65532:0];
  reg    [31:0] read_data;
 
  // load data
  initial begin : prog_load
    // UNCOMMENT ONE OF THE FOLLOWING LINES:
    // comment out all other programs that are not in use
    // only one program can run at a time
    
    // for sorting data:
    // $readmemh("sort_data.data", ram_array);
    
    // For multiplication data:
    $readmemh("mult_data.data", ram_array);
    
    // original data 
    // $readmemh("dmem.data", ram_array);
    
    // debugging...
    $display("Data memory initialization:");
    $display("First word: %h", ram_array[0]);
    $display("Second word: %h", ram_array[1]);
    $display("Third word: %h", ram_array[2]);
    $display("Fourth word: %h", ram_array[3]);
  end

  // read process is sensitive to read address.
  // address is [15:0] because ram_array word addressable, not 
  // byte addressable.
  always @(read_addr, dm_we)
  begin
    read_data <= ram_array[read_addr];
  end
  
  // write process is sensitive to write enable
  always @(negedge dm_we)
  begin
  	ram_array[write_addr] <= write_data;
  end
  
endmodule
