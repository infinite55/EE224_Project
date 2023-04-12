module mul(input signed [16:0] a, input signed [16:0] b, output reg signed  [16:0] d);
 
    reg signed [33:0] sum;

    always @* begin
      sum = a * b ;
      d = sum >>> 15;
	end
  
endmodule


//Complex Multiplication
module cmul(input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1);
	 wire signed [16:0] w[3:0];
	 mul m0(x2,x1,w[0]);
	 mul m1(y2,y1,w[1]);
	 mul m2(x1,y2,w[2]);
	 mul m3(x2,y1,w[3]);
	 always @(*) begin
		 a1 <= w[0] - w[1];
		 b1 <= w[2] + w[3];
	 end
endmodule

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
		 a1 <= w[2];
		 b1 <= w[3];
	 end
endmodule
	 
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
	reg signed [16:0] f=17'b0_0_101101010000010; //sqrt1/2
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

module RTwo
	(input enable,
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
		if (enable == 1) begin
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

module RThree
	(input enable, 
	 input signed [16:0] x1, 
	 input signed [16:0] y1, 
	 input signed [16:0] x2, 
	 input signed [16:0] y2,
	 output reg signed [16:0] a1, 
	 output reg signed [16:0] b1, 
	 output reg signed [16:0] a2, 
	 output reg signed [16:0] b2);
	 
	wire signed [16:0] w[3:0];
	reg signed [16:0] f=17'b0_0_101101010000010;
	assign w[0] = x1;
	assign w[1] = y1;
	mul m5((x2 - y2),f,w[2]);
	mul m6((x2 + y2),f,w[3]);
	always @(*) begin
		if (enable == 1) begin
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

3-qubit QFT
module QFTrial
	(input [2:0]x,
	 output reg signed [16:0]y1,
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
	 
	 wire signed [16:0] w[5:0][3:0];
	 wire signed [16:0] w2[7:0][1:0];
	 wire signed [16:0] w3[7:0][1:0];
	 reg signed [16:0] h[2:0][1:0]; //haramard inputs
	 reg signed [16:0] y [7:0][1:0];
	 
	 
	 
	 genvar i,j,k;
	 integer p,l;
	 always @(*) begin 
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
		Hadamard H1(h[2][0],17'b0,h[2][1],17'b0,w[0][0],w[0][1],w[0][2],w[0][3]);
		RTwo R2_1(x[1],w[0][0],w[0][1],w[0][2],w[0][3],w[1][0],w[1][1],w[1][2],w[1][3]);
		RThree R3_1(x[0],w[1][0],w[1][1],w[1][2],w[1][3],w[2][0],w[2][1],w[2][2],w[2][3]);
		
	 //The x1 block
		Hadamard H2(h[1][0],17'b0,h[1][1],17'b0,w[3][0],w[3][1],w[3][2],w[3][3]);
		RTwo R2_2(x[0],w[3][0],w[3][1],w[3][2],w[3][3],w[4][0],w[4][1],w[4][2],w[4][3]);

	 //The x2 block
		Hadamard H3(h[0][0],17'b0,h[0][1],17'b0,w[5][0],w[5][1],w[5][2],w[5][3]); 
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
		y1 <= y[0][0]; y2 <= y[0][1];
		y3 <= y[1][0]; y4 <= y[1][1];
		y5 <= y[2][0]; y6 <= y[2][1];
		y7 <= y[3][0]; y8 <= y[3][1];
		y9 <= y[4][0]; y10 <= y[4][1];
		y11 <= y[5][0]; y12 <= y[5][1];
		y13 <= y[6][0]; y14 <= y[6][1];
		y15 <= y[7][0]; y16 <= y[7][1];
	 end
endmodule

//Square wave signal 
module skook (input clk, output reg [3:0]state, output reg im,output reg signed [16:0] c, output reg sq);
	reg signed [16:0] x[7:0][1:0];
	genvar i,j,m;
	integer l,p=0,k=0;

	reg signed [16:0] y [7:0][1:0];
	wire signed [16:0] w [7:0][7:0][1:0];
	wire signed [16:0] w1 [7:0][7:0][1:0];
	reg [2:0]e; reg exc;
	reg signed [16:0] t[7:0];
	wire signed [16:0] t1[7:0][2:0];
	integer q,r;
	initial begin
		sq =0;
	end
	reg [80:0]v[7:0];
	reg [80:0] gap=5_500_000;
	reg [80:0] counter=0;
	
	always @(*) begin
		x[7][0]=0;									x[7][1]=0;
		x[6][0]=0;									x[6][1]=0;
		x[5][0]=0;									x[5][1]=0;
		x[4][0]=0;									x[4][1]=0;
		x[3][0]=0;									x[3][1]=0;
		x[2][0]=0;									
		x[2][1]=0;
		x[1][0]=17'b0_0_101101010000010;//17'b0_1_000000000000000;//17'b0_0_101101010000010;		
		x[1][1]=0;
		x[0][0]=17'b0_0_101101010000010;;//17'b0_0_101101010000010; //17'b0_1_000000000000000;		
		x[0][1]=0;
	end
	
	generate 
	for(i=0; i<8;i=i+1) begin : eet
		QFTrial Q(i,w[i][0][0],w[i][0][1],
				w[i][1][0],w[i][1][1],w[i][2][0],
				w[i][2][1],w[i][3][0],w[i][3][1],
				w[i][4][0],w[i][4][1],w[i][5][0],
				w[i][5][1],w[i][6][0],w[i][6][1],
				w[i][7][0],w[i][7][1]);
	end
	for(i=0; i<8; i=i+1) begin : bub
		for(j=0; j<8; j=j+1)	begin : tt
		//mul m1 (x[i],w[i][j][0],w1[i][j][0]);
		//mul m2 (x[i],w[i][j][1],w1[i][j][1]);
		cmul m1(x[i][0],x[i][1],w[i][j][0],w[i][j][1],w1[i][j][0],w1[i][j][1]);

		end
	end

	endgenerate

	always @(*) begin
		for(l=0;l<8; l=l+1) begin
			y[l][0] <= w1[0][l][0] + w1[1][l][0]+ w1[2][l][0] + w1[3][l][0] + w1[4][l][0] + w1[5][l][0] + w1[6][l][0] + w1[7][l][0]; 
			y[l][1] <= w1[0][l][1] + w1[1][l][1]+ w1[2][l][1] + w1[3][l][1] + w1[4][l][1] + w1[5][l][1] + w1[6][l][1] + w1[7][l][1];

		 end
	end
	always@(*) begin
		c<= y[p][k];
	end
	
	generate 
		for (m=0; m<8;m=m+1) begin :yeet
			mul(y[m][0],y[m][0],t1[m][0]);
			mul(y[m][1],y[m][1],t1[m][1]);
			//t1[m][2]= t1[m][0]+ t1[m][1];
		end
		
	endgenerate
	
   always@(posedge clk) begin
	for (r=0; r<8; r=r+1) begin
		t[r]<=t1[r][0]+ t1[r][1];
	end
	/*t[7]=0;
	t[6]=0;
	t[5]=0;
	t[4]=0;
	t[3]=0;
	t[2]=0;
	t[1]=17'b0_0_100000000000000;
	t[0]=17'b0_0_100000000000000;*/

	for (q=0; q<8;q=q+1) begin
		v[q]<=(25_000_00 * t[q]) >>>11;
	end
	counter <= counter +1;
	
	if (counter == 1*gap) sq <= 1;
	if (counter == 1*gap + v[0]) sq <= 0;
	if (counter == 2*gap + v[0]) sq <= 1;
	if (counter == 2*gap + v[0]+v[1]) sq <= 0;
	if (counter == 3*gap + v[0]+v[1]) sq <= 1;
	if (counter == 3*gap + v[0]+v[1]+v[2]) sq <= 0;
	if (counter == 4*gap + v[0]+v[1]+v[2]) sq <= 1;
	if (counter == 4*gap + v[0]+v[1]+v[2]+v[3]) sq <= 0;
	if (counter == 5*gap + v[0]+v[1]+v[2]+v[3]) sq <= 1;
	if (counter == 5*gap + v[0]+v[1]+v[2]+v[3]+v[4]) sq <= 0;
	if (counter == 6*gap + v[0]+v[1]+v[2]+v[3]+v[4]) sq <= 1;
	if (counter == 6*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]) sq <= 0;
	if (counter == 7*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]) sq <= 1;
	if (counter == 7*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]) sq <= 0;
	if (counter == 8*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]) sq <= 1;
	if (counter == 8*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) sq <= 0;
	//else if (counter == 10 + 9*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) sq <= ~sq;
	else if (counter == 10 + 17*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) 
	begin
		//sq <= ~sq;
		counter <= 0;
		sq<=0;
	
	//if (counter == 1) sq <= ~sq;
	//else if (counter == 10) sq <= ~sq;
   /*if (counter == 1*gap) sq <= ~sq;
	if (counter == 1*gap + v[0]) sq <= ~sq;
	if (counter == 2*gap + v[0]) sq <= ~sq;
	if (counter == 2*gap + v[0]+v[1]) sq <= ~sq;
	if (counter == 3*gap + v[0]+v[1]) sq <= ~sq;
	if (counter == 3*gap + v[0]+v[1]+v[2]) sq <= ~sq;
	if (counter == 4*gap + v[0]+v[1]+v[2]) sq <= ~sq;
	if (counter == 4*gap + v[0]+v[1]+v[2]+v[3]) sq <= ~sq;
	if (counter == 5*gap + v[0]+v[1]+v[2]+v[3]) sq <= ~sq;
	if (counter == 5*gap + v[0]+v[1]+v[2]+v[3]+v[4]) sq <= ~sq;
	if (counter == 6*gap + v[0]+v[1]+v[2]+v[3]+v[4]) sq <= ~sq;
	if (counter == 6*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]) sq <= ~sq;
	if (counter == 7*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]) sq <= ~sq;
	if (counter == 7*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]) sq <= ~sq;
	if (counter == 8*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]) sq <= ~sq;
	if (counter == 8*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) sq <= 0;
	//else if (counter == 10 + 9*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) sq <= ~sq;
	else if (counter == 10 + 17*gap + v[0]+v[1]+v[2]+v[3]+v[4]+v[5]+v[6]+v[7]) 
	begin
		//sq <= ~sq;
		counter <= 0;
		sq<=0;
	end*/
end
end
endmodule