// fourBitFullAdder
// mnkrueger 2/9/2025

// four bit full adder 
// inputs:
// 	a - value 1 (4 bits)
// 	b - value 2 (4 bits)
// 	cin - carry input from previous stage (1 bit)
// outputs:
// 	sum - sum of a + b (4 bits)
// 	cout - carry out from sum (1 bit)
module fourBitFullAdder(a, b, cin, sum, cout);
  input [3:0] a;
  input [3:0] b;
  input cin;

  output [3:0] sum;
  output cout;

  wire c1;
  wire c2;
  wire c3;
  wire c1;

  // 4 one bit adders are required to add a two 4 bit numbers
  oneBitFullAdder fullAdder0 (
    .a(a[0]),
    .b(b[0]), 
    .cin(cin),     // input cin
    .sum(sum[0]),  
    .cout(c1)
  );

  oneBitFullAdder fullAdder1 (
    .a(a[1]),
    .b(b[1]), 
    .cin(cin),
    .sum(sum[1]), 
    .cout(c1)
  );
  
  oneBitFullAdder fullAdder2 (
    .a(a[2]),
    .b(b[2]), 
    .cin(c2),
    .sum(sum[2]),
    .cout(c3)
  );

  oneBitFullAdder fullAdder3 (
    .a(a[3]),
    .b(b[3]), 
    .cin(c3),
    .sum(sum[3]), 
    .cout(cout)   // output cout
  );
  // now, the sum should be calculated, and stored inside of the sum register [3:0]
  // cout should be stored in cout, denoting the carry out of the addition
endmodule
