// oneBitFullAdder.v
// mnkrueger 2/9/2025

// full adder
// inputs (1-bit):
// 	a - bit 1
// 	b - bit 2
// 	cin - carry bit from previous stage (if any)
// outputs:
// 	sum - sum of three input bits
// 	cout - carry bit to pass into next stage
module fullAdder(a, b, cin, sum, cout);
	input a, b, cin;
	output sum, cout;
	reg sum, cout;
	
	// always block: triggered by sensitivity list (a,b,c)
	// sum <- bitwise xor a,b,cin (nonblocking assignment delay of 2 time units)
	// cout <- calculates the carry out bit (nonblocking assignment delay of 2 time units)
	always @(a or b or cin) begin  
		sum = #2 a ^ b ^ cin; 
		cout = #2 (a & b) | (a & cin) | (b & cin); // if any two inputs (a, b, cin) are 1, then a carry out bit is produced. else no bit produced 
	end
endmodule