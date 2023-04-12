
/*
Contains the code for QFT implementation, with the focus on 
computing coefficients iteratively for all states in superposition
*/


//Multiplication of 17-bit signed inputs 
module mul(input signed [16:0] a, input signed [16:0] b, output reg signed  [16:0] d);
 
    reg signed [33:0] sum;

    always @* begin //'always' block means it will execute continuously as long as the module is powered on; @* means that the block will execute whenever any input to the module changes
      sum = a * b ;
      d = sum >>> 15; //result of multiplication is shifted right by 15bits, effectively discarding the lower 16bits of the result(dividing 'sum' by 2^15)
	end
  
endmodule

//Generates a 1Hz clock signal from a faster clock signal 'clk' 
module slowClock(clk, reset, clk_1Hz);
input clk, reset; //reset input signal tht resets the clk_1Hz output signal
output clk_1Hz;

reg clk_1Hz;
reg [27:0] counter; //internal 28-bit counter to count the number of cycles in the clk signal 

always@(posedge reset or posedge clk) // executes on the positive edge of either the reset or clk input
begin
    if (reset == 1'b1) // if reset is asserted, clk_1Hz and counter are both reset to 0
        begin
            clk_1Hz <= 0;
            counter <= 0;
        end
    else
        begin
            counter <= counter + 1;
            if ( counter == 25_000_000)
                begin
                    counter <= 0; 
                    clk_1Hz <= ~clk_1Hz; //toggles the output every 25million cycles(corresponding to 1second at a 25MHz clock rate)
                end
        end
end
endmodule

//Complex Multiplication of (x1+i*y1) and (x2+i*y2)
// four inputs: x1, y1, x2, y2(signed 17bit numbers)
// two outputs: a1, b1
module cmul(input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1);
	 wire signed [16:0] w[3:0]; //array of 4signed 17-bit numbers
	 mul m0(x2,x1,w[0]);
	 mul m1(y2,y1,w[1]);
	 mul m2(x1,y2,w[2]);
	 mul m3(x2,y1,w[3]);
	 always @(*) begin
		 a1 <= w[0] - w[1]; //x1*x2-y1*y2 (real)
		 b1 <= w[2] + w[3]; //x1*y2+x2*y1 (imaginary)
	 end
endmodule

//multiplication of 3complex numbers(x1+i*y1), (x2+i*y2), (x3+i*y3)
module cmul3
	(input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 input signed [16:0] x3, 
	 input signed [16:0] y3,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1);
	 wire signed [16:0] w[4:0];
	 cmul c0(x1,y1,x2,y2,w[0],w[1]);
	 cmul c1(x3,y3,w[0],w[1],w[2],w[3]);
	 always @(*) begin
		 a1 <= w[2];// x1*x2*x3-y1*y2*x3-x1*y2*y3-y1*x2*y3
		 b1 <= w[3];//x1*y2*x3+y1*x2*x3+x1*x2*y3-y1*y2*y3
	 end
endmodule
	 
//Hadamard transform	on an arbitrary qubit state: r|0>+u|1>; where r=x1+i*y1 and u=x2+i*y2 
module Hadamard
	(input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1, 
	 output reg signed [16:0] a2, 
	 output reg signed [16:0] b2);
	 
	wire signed [16:0] w[3:0];
	reg signed [16:0] f=17'b0_0_101101010000010; //sqrt of 1/2 (notation: sign_pre-decimal_decimals)
	mul m1((x2 + x1),f,w[0]);
	mul m2((y1 + y2),f,w[1]);
	mul m3((x1 - x2),f,w[2]);
	mul m4((y1 - y2),f,w[3]);
	always @(*) 
	begin
		a1 <= w[0]; //real part of |0>
		b1 <= w[1];//imaginary part of |0>
		a2 <= w[2];//real part of |1>
		b2 <= w[3];//imaginary part of |1>
	end //output=(a1+i*b1)|0> + (a2+i*b2)|1>
endmodule

//Controlled-Phase gate(multiply i with the coefficient of |1>) r|0>+u|1>; where r=x1+i*y1 and u=x2+i*y2  
module RTwo
	(input enable, //control
	 input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1, 
	 output reg signed [16:0] a2, 
	 output reg signed [16:0] b2);
	 
	wire signed [16:0] w[3:0];
	assign w[0] = x1; 
	assign w[1] = y1;  
	assign w[2] = -y2;
	assign w[3] = x2;
	always @(*) begin
		if (enable == 1) begin //apply phase gate when control is 1
			a1 <= w[0];
			b1 <= w[1];
			a2 <= w[2];
			b2 <= w[3];
		end
		else begin 
			a1<= x1;
			b1<= y1;
			a2<= x2;
			b2<= y2;
		end
	end
endmodule


//Controlled T-gate(multiply sqrt{1/2}+i*sqrt{1/2} to |1> if control is 1)
module RThree
	(input enable, //control
	 input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1, 
	 output reg signed [16:0] a2, 
	 output reg signed [16:0] b2);
	 
	wire signed [16:0] w[3:0];
	reg signed [16:0] f=17'b0_0_101101010000010; //sqrt of 1/2
	assign w[0] = x1;
	assign w[1] = y1;
	mul m5((x2 - y2),f,w[2]);//real
	mul m6((x2 + y2),f,w[3]);//imag
	always @(*) begin
		if (enable == 1) begin //apply T-gate if control is 1
			a1 <= w[0];  //x1
			b1 <= w[1];  //y1
			a2 <= w[2];  //(x2-y2)/sqrt{2}
			b2 <= w[3];  //(x2+y2)/sqrt{2}
		end
		else begin
			a1<= x1;
			b1<= y1;
			a2<= x2;
			b2<= y2;
		end
	end
endmodule

//QFT for single state as input
module QFTrial
	(input [2:0]x, //input 3bit vector
	 output reg signed [16:0]y1, //yi's are bits to represent the coefficients in binary form
	 output reg signed [16:0]y2,
	 output reg signed [16:0]y3,
	 output reg signed [16:0]y4,
	 output reg signed [16:0]y5,
	 output reg signed [16:0]y6,
	 output reg signed [16:0]y7,
	 output reg signed [16:0]y8,
	 output reg signed [16:0]y9,
	 output reg signed [16:0]y10,
	 output reg signed [16:0]y11,
	 output reg signed [16:0]y12,
	 output reg signed [16:0]y13,
	 output reg signed [16:0]y14,
	 output reg signed [16:0]y15,
	 output reg signed [16:0]y16);
	 
	 wire signed [16:0] w[5:0][3:0];//2D array of wires with dimensions 6x4 and 17-bit signed elements
	 wire signed [16:0] w2[7:0][1:0]; //2D array of wires with dimensions 8x2 and 17-bit signed elements
	 wire signed [16:0] w3[7:0][1:0];
	 reg signed [16:0] h[2:0][1:0]; //haramard input; dim=3x2
	 reg signed [16:0] y [7:0][1:0];
	 
	 
	 
	 genvar i,j,k;
	 integer p,l; //p=number of bits(3); l=number of output states(8)
	 always @(*) begin //16bit input coefficients in binary form
		for (p=0;p<3;p=p+1) begin
			if (x[p]==1) begin
				h[p][0] = 17'b0_0_000000000000000;
				h[p][1] = 17'b0_1_000000000000000;
			end
			else begin
				h[p][0] = 17'b0_1_000000000000000;
				h[p][1] = 17'b0_0_000000000000000;
			end
		end
	end
	
	 //The x0 block
		Hadamard H1(h[2][0],17'b0,h[2][1],17'b0,w[0][0],w[0][1],w[0][2],w[0][3]); //hadamard on first qubit
		RTwo R2_1(x[1],w[0][0],w[0][1],w[0][2],w[0][3],w[1][0],w[1][1],w[1][2],w[1][3]);//phase on first qubit with second as control
		RThree R3_1(x[0],w[1][0],w[1][1],w[1][2],w[1][3],w[2][0],w[2][1],w[2][2],w[2][3]);//T-gate on 1st with 3rd qubit as control
		
	 //The x1 block
		Hadamard H2(h[1][0],17'b0,h[1][1],17'b0,w[3][0],w[3][1],w[3][2],w[3][3]); //hadamard on 2nd qubit
		RTwo R2_2(x[0],w[3][0],w[3][1],w[3][2],w[3][3],w[4][0],w[4][1],w[4][2],w[4][3]);//phase on 2nd qubit with 3rd as control 

	 //The x2 block
		Hadamard H3(h[0][0],17'b0,h[0][1],17'b0,w[5][0],w[5][1],w[5][2],w[5][3]);//hadamard on 3rd qubit 
		
	//Swap first and 3rd qubit and tensor product	
	 generate 
		 for(i=0;i<2;i=i+1) begin : beep 
			for(j=0;j<2;j=j+1) begin : boop 
				for(k=0;k<2;k=k+1) begin : scoop 
					cmul c1 (w[4][(2*j)],w[4][(2*j)+1],w[2][(2*k)],w[2][(2*k)+1],w2[(4*i) + (2*j) + (k)][0],w2[(4*i) + (2*j) + (k)][1]);
					cmul c2 (w[5][(2*i)],w[5][(2*i)+1],w2[(4*i) + (2*j) + (k)][0],w2[(4*i) + (2*j) + (k)][1],w3[(4*i) + (2*j) + (k)][0],w3[(4*i) + (2*j) + (k)][1]);
				end
			end
		end	
	 endgenerate
	 always @(*) begin
	 for(l=0;l<8; l=l+1) begin
		y[l][0]<=w3[l][0];
		y[l][1]<=w3[l][1];
	 end
		y1 <= y[0][0]; y2 <= y[0][1]; //real nd imag coeff of state |000> in FT basis
		y3 <= y[1][0]; y4 <= y[1][1]; //real nd imag coeff of state |001> in FT basis
		y5 <= y[2][0]; y6 <= y[2][1]; //real nd imag coeff of state |010> in FT basis
		y7 <= y[3][0]; y8 <= y[3][1]; //real nd imag coeff of state |011> in FT basis
		y9 <= y[4][0]; y10 <= y[4][1]; //real nd imag coeff of state |100> in FT basis
		y11 <= y[5][0]; y12 <= y[5][1]; //real nd imag coeff of state |101> in FT basis
		y13 <= y[6][0]; y14 <= y[6][1]; //real nd imag coeff of state |110> in FT basis
		y15 <= y[7][0]; y16 <= y[7][1]; //real nd imag coeff of state |111> in FT basis
	 end
endmodule


//QFT for an arbitrary 3-qubit input state 
module clkbiny (input clk, output reg [2:0]state, output reg im, output reg signed [16:0] c); //im outputs 1 if the coefficients in display are imaginary otherwise 0
	reg signed [16:0] x[7:0][1:0];
	genvar i,j;
	integer l,p=0,k=0;

	reg signed [16:0] y [7:0][1:0];
	wire signed [16:0] w [7:0][7:0][1:0]; //3D-array w[i][j][k], s.t. i is the indexing for input state which can be in a superposition of 8possible states, j is the indexing for one of the 8states in the output, k is for real and im coeff
	wire signed [16:0] w1 [7:0][7:0][1:0];
	reg [2:0]e; reg exc;
	always @(*) begin //combinational always block that executes whenever there is a change in any of its input variables
	//sets the initial value(here 1/sqrt{2}|000> + i/sqrt{2}|001>) 	
		x[7][0]=0;									x[7][1]=0;
		x[6][0]=0;									x[6][1]=0;
		x[5][0]=0;									x[5][1]=0;
		x[4][0]=0;									x[4][1]=0;
		x[3][0]=0;									x[3][1]=0;
		x[2][0]=0;									x[2][1]=0;
		x[1][0]=0;									
		x[1][1]=17'b0_0_101101010000010;
		x[0][0]=17'b0_0_101101010000010;//17'b0_1_000000000000000;		
		x[0][1]=0;
	end
	
	generate //generates hardware instances of a module called QFTrial(calculates QFT for any superposed state)
	for(i=0; i<8;i=i+1) begin : eet
		QFTrial Q(i,w[i][0][0],w[i][0][1],
				w[i][1][0],w[i][1][1],w[i][2][0],
				w[i][2][1],w[i][3][0],w[i][3][1],
				w[i][4][0],w[i][4][1],w[i][5][0],
				w[i][5][1],w[i][6][0],w[i][6][1],
				w[i][7][0],w[i][7][1]);
	end
	for(i=0; i<8; i=i+1) begin : bub //each iteration corresponds to a different input x[i]
		for(j=0; j<8; j=j+1)	begin : tt //each iteration corresponds to a different complex w[i][j] value
		//mul m1 (x[i],w[i][j][0],w1[i][j][0]);
		//mul m2 (x[i],w[i][j][1],w1[i][j][1]);
		cmul m1(x[i][0],x[i][1],w[i][j][0],w[i][j][1],w1[i][j][0],w1[i][j][1]); //complex multiplication of the initial state coefficients with the coefficients achieved in the output for each state

		end
	end

	endgenerate

	always @(*) begin //calculates the final output values of the QFT by summing up the w1 values
		for(l=0;l<8; l=l+1) begin
			y[l][0] <= w1[0][l][0] + w1[1][l][0]+ w1[2][l][0] + w1[3][l][0] + w1[4][l][0] + w1[5][l][0] + w1[6][l][0] + w1[7][l][0]; 
			y[l][1] <= w1[0][l][1] + w1[1][l][1]+ w1[2][l][1] + w1[3][l][1] + w1[4][l][1] + w1[5][l][1] + w1[6][l][1] + w1[7][l][1];

		 end
	end
	
	slowClock clock_generator(clk, reset, clk_1Hz); 
	always@(posedge clk_1Hz) begin //sequential always block that executes on the positive edge of clk_1Hz
		im<=k;
	   c<= y[p][k];
		state <= p;
		
		k<= k + 1;
		if ( k == 2) begin
				  k <= 0; //if k reaches a value of 2, it is reset to 0
				  p=p+1;
				  if(p==8)// if p reaches a value of 8, reset it to 0
				  p<=0;
		end
	end

endmodule