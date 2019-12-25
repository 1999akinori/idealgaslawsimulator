
//Checks if there is a collision between two particles by looking at the distance between
//their centers
module checkCollision ( ball1x, ball1y, ball2x, ball2y, collision);

	parameter ballWidth = 19; // includes centre point
	input [8:0] ball1x;
	input [7:0] ball1y;
	input [8:0] ball2x;
	input [7:0] ball2y;
	
	output collision;
	
	wire [9:0] wBall1x;
	wire [8:0] wBall1y;
	wire [9:0] wBall2x;
	wire [8:0] wBall2y;
	
	assign wBall1x = {1'b0, ball1x};
	assign wBall1y = {1'b0, ball1y};
	assign wBall2x = {1'b0, ball2x};
	assign wBall2y = {1'b0, ball2y};
	
	
	wire [9:0] deltax;
	wire [8:0] deltay;
	wire [9:0] absDeltax;
	wire [8:0] absDeltay;
	
	assign deltax = ball2x - ball1x;
	assign deltay = ball2y - ball1y;
	
	
	absoluteValue #(.w(9)) abs1(deltax, absDeltax);
	absoluteValue #(.w(8)) abs2(deltay, absDeltay);
	
	assign collision = (absDeltax <= (ballWidth)) && (absDeltay <= (ballWidth));
	
endmodule


//Calculates the absoltue value of a number
module absoluteValue (num, absNum);

	parameter w = 8; //when setting width only specify the magnitude of the number, the sign bit will be automatically added in
	//this implementation
	input [w: 0] num;
	output reg [w: 0] absNum;

	always @(*) begin
	  if (num[w] == 1'b1) begin
		 absNum = -num;
	  end
	  else begin
		 absNum = num;
	  end
	end
	
endmodule
	