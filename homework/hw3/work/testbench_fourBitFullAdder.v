// testbench_fourBitFullAdder
// mnkrueger 2/9/2025

// testbench_fourBitFullAdder
// inputs:
// 	none
// outputs:
// 	none
module testbench_fourBitFullAdder;
	// simulated signals
	reg [3:0] a;
	reg [3:0] b;
	reg cin;

	wire sum;
	wire cout;

	// implement four bit adder
	fourBitFullAdder fbfa (
      .a(a), 
      .b(b), 
      .cin(cin), 
      .sum(sum), 
      .cout(cout)
    );

	// INITIALZE
	initial begin
		// test case 1
		// a=0, b=0, cin=0
		// expected sum=0 (0000)
		// expected cout=0
		a = 4'b0000;
		b = 4'b0000;
		cin = 1'b0;

		#50; 
		$monitor("Test 1: %04b + %04b + %04b -> sum = %04b, carry = %04b", a, b, cin, sum, cout);
		
		// test case 2
		// a=1, b=1, cin=0
		// expected sum=2 (0010)
		// expected cout=0
		a = 4'b0000;
		b = 4'b0000;
		cin = 1'b0;

		#50; 
		$monitor("Test 1: %04b + %04b + %04b -> sum = %04b, carry = %04b", a, b, cin, sum, cout);

		// test case 3
		// a=3, b=4, cin=0
		// expected sum=7 (0111)
		// expected cout=0
		a = 4'b0000;
		b = 4'b0000;
		cin = 1'b0;

		#50; 
		$monitor("Test 1: %04b + %04b + %04b -> sum = %04b, carry = %04b", a, b, cin, sum, cout);

		// test case 4
		// a=7, b=8, cin=1
		// expected sum=0 (0000)
		// expected cout=1 
		a = 4'b0000;
		b = 4'b0000;
		cin = 1'b0;

		#50; 
		$monitor("Test 1: %04b + %04b + %04b -> sum = %04b, carry = %04b", a, b, cin, sum, cout);

		// test case 5
		// a=15, b=5, cin=1
		// expected sum=5 (0101)
		// expected cout=1	
		a = 4'b0000;
		b = 4'b0000;
		cin = 1'b0;

		#50; 
		$monitor("Test 1: %04b + %04b + %04b -> sum = %04b, carry = %04b", a, b, cin, sum, cout);

		$finish;
	end

endmodule
