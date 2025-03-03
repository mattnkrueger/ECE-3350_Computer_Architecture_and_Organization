// oneBitFullAdder.v
// mnkrueger 2/9/2025

// full adder
// inputs:
// 	a - value 1 (1 bits)
// 	b - value 2 (1 bits)
// 	cin - carry input from previous stage (1 bit)
// outputs:
// 	sum - sum of a + b (1 bit)
// 	cout - carry out from sum (1 bit)
module oneBitFullAdder(a, b, cin, sum, cout);
	input a;
    input b;
    input cin;

	output sum;
    output cout;

	reg sum;
    reg cout;
	
	// always block: triggered by sensitivity list (a,b,c)
	// sum <- bitwise xor a,b,cin (nonblocking assignment delay of 2 time units)
	// cout <- calculates the carry out bit (nonblocking assignment delay of 2 time units)
	always @(a or b or cin) begin  
		sum = #2 a ^ b ^ cin; 
		cout = #2 (a & b) | (a & cin) | (b & cin); 
	end

endmodule
