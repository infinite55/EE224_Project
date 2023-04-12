
/*
Hadamard gate implementation
Demonstration as a square wave signal on DSO
*/

module mul(input signed [12:0] a, input signed [12:0] b, output reg signed  [12:0] d);
 
    reg signed [25:0] sum;

    always @* begin
      sum = a * b ;
      d = sum >>> 11;
	end
  
endmodule

module square(input clk, input reset, input [12:0] a, output reg sq);
//input clk, a, reset;
//output sq;

//reg sq;
reg [27:0] counter;
reg [40:0]v; 
//(25_000_000 * a) >>>11;

always@(posedge reset or posedge clk)
begin
v<=(25_000_00 * a) >>>11;
    if (reset == 1'b1)
        begin
            sq <= 0;
            counter <= 0;
        end
    else
        begin
            counter <= counter + 1;
            if ( counter == 25_000_00)
                begin
                    counter <= 0;
						  sq <= ~sq;
                end
				if ( counter == v)
                begin
                    sq <= ~sq;
                end
        end
end
endmodule

module Hadamard
	(input signed [12:0] x1, 
	 input signed [12:0] y1, 
	 input signed [12:0] x2, 
	 input signed [12:0] y2,
	 output reg signed [12:0] a1, 
	 output reg signed [12:0] b1, 
	 output reg signed [12:0] a2, 
	 output reg signed [12:0] b2);
	 
	wire signed [12:0] w[3:0];
	reg signed [12:0] f=12'b0_0_10110101000;
	mul m1((x2 + x1),f,w[0]);
	mul m2((y1 + y2),f,w[1]);
	mul m3((x1 - x2),f,w[2]);
	mul m4((y1 - y2),f,w[3]);
	always @(*) 
	begin
		a1 <= w[0];
		b1 <= w[1];
		a2 <= w[2];
		b2 <= w[3];
	end
endmodule

module sqwakev (input clk, output reg  signed [11:0] c, output reg sq);
	 reg signed [12:0] c1=0;//12'b1_00000000000; 
	 reg signed [12:0] d1=0; 
	 reg signed [12:0] c2=12'b0_1_00000000000; 
	 reg signed [12:0] d2=0;
	 reg signed [12:0] e = 12'b0_1_00000000000;
    reg signed [12:0] f=12'b0_0_10110101000;
	 wire signed [12:0] w1[3:0];
	 wire signed [12:0] w2[3:0];
	 wire signed [12:0] w3[3:0];
	 reg [12:0] a;
	 wire ee;
    Hadamard H1(12'b0_1_00000000000,0,0,0,w1[0],w1[1],w1[2],w1[3]);
	 //Hadamard H2(w1[0],w1[1],w1[2],w1[3],w2[0],w2[1],w2[2],w2[3]);
	 mul m1(w1[0],w1[0],w3[0]);
	 mul m4(w1[1],w1[1],w3[2]);
	 
	 always @(*) begin
		a<= w3[0] +w3[2]; //12'b0_0_001000000000;
	 end
	 //Hadamard H2(w1[0],w1[1],w1[2],w1[3],w2[0],w2[1],w2[2],w2[3]);
	 square s (clk, 0, a, ee);
	 always @(*) begin
	 c<=w2[0];
	 sq<=ee;
	 end
endmodule