//This version is for three particles project 2

module myUpCounter (clearn, enable, clock, Q);
	//for the particle's x position and y position
	input clearn, enable, clock;
	output reg [4:0] Q;
	
	always @ (posedge clock)
		begin
		if (clearn == 0)
			Q <= 5'b0;	
		else if (enable == 1)
			if(Q >= 5'd18)
				Q <= 5'd0;
			else
				Q <= Q + 5'b1;
		end
		
endmodule


module pixelCounter (clearn, enable, clock, Q);
	//counting total pixel of the particle
	input clearn, enable, clock;
	output reg [8:0] Q; 
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 9'd0;	
		else if (enable == 1)
			if(Q >= 9'd360) //total pixel - 1
				Q <= 9'd0;
			else
				Q <= Q +9'd1;
		end
		
endmodule

module myXClearDownCounter (clearn, enable,  Clock, Q);
	//xcounter for clearing the screen
	input clearn, enable, Clock;
	output reg [8:0] Q;
	wire [8:0] w;
	assign w = 319;
	
	always @ (posedge Clock)
		begin

		if (clearn == 0)
			Q <= w;
			
	
		else if (enable ) begin
			if (Q == 0)
				Q <= w;
			else
				Q <= Q - 1;
				
				end
		end
		
endmodule



module myYClearDownCounter (clearn, enable, clock, Q);
	//ycounter for clearing the screen
	input clearn, enable, clock;
	output reg [7:0] Q;
	wire [7:0] w;
	assign w = 239;
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= w;
			
		else if (enable == 1) begin
			if (Q == 0)
				Q <= w;
			else
				Q <= Q - 1;
				
				end
		end
		
endmodule

module screenCounter (clearn, enable, clock, Q);
	//total pixel of the screen
	//used when clearing the screen
	input clearn, enable, clock;
	output reg [16:0] Q;
	wire [16:0] w;
	assign w = 76799;
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= w;
			
		else if (enable == 1) begin
			if (Q == 0)
				Q <= w;
			else
				Q <= Q - 1;
				
				end
		end
		
endmodule

module pistonXcounter (clearn, enable, clock, Q);
	input clearn, clock, enable;
	output reg [7:0]Q;
	wire [7:0] w;
	assign w = 219;
	
	always @ (posedge clock)
	begin
		if (clearn == 0)
			Q <= w;	
		else if (enable == 1)
			if(Q == 0)
				Q <= w;
			else
				Q <= Q - 1;
	end
endmodule


module pistonYcounter (clearn, enable, clock, height, Q);
	input [7:0]height;
	input clearn, clock, enable;
	output reg [7:0]Q;
	
	always @ (posedge clock)
	begin
		if (clearn == 0)
			Q <= height - 1;	
		else if (enable == 1)
			if(Q == 0)
				Q <= height - 1;
			else 
				Q <= Q - 1;
	end
endmodule

module pistonCounter (clearn, enable, clock, height, Q);
	input [7:0]height;
	input clearn, clock, enable;
	output reg [15:0]Q;
	
	wire [15:0]totalPixel;
	assign totalPixel = (height * 8'd220) - 1;
	
	always @ (posedge clock)
	begin
		if (clearn == 0)
			Q <= 0;	
		else if (enable == 1)
			if(Q >= totalPixel)
				Q <= 0;
			else
				Q <= Q + 1;
	end
endmodule


module XpvnrtCounter (clearn, enable, clock, Q);
	input clearn, enable, clock;
	output reg [6:0] Q; //10100 - 1
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 7'b0;	
		else if (enable == 1)
			if(Q >= 7'd64)
				Q <= 7'd0;
			else
				Q <= Q + 7'd1;
		end
		
endmodule

module YpvnrtCounter (clearn, enable, clock, Q);

	input clearn, enable, clock;
	output reg [4:0] Q; //10100 - 1
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 5'b0;	
		else if (enable == 1)
			if(Q >= 5'd19)
				Q <= 5'd0;
			else
				Q <= Q + 5'd1;
		end
endmodule

module pvnrtCounter (clearn, enable, clock, Q);

	input clearn, enable, clock;
	output reg [10:0] Q; 
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 11'd0;	
		else if (enable == 1)
			if(Q >= 11'd1299)
				Q <= 11'd0;
			else
				Q <= Q + 11'd1;
		end
endmodule



module XmeterCounter (clearn, enable, clock, Q);

	input clearn, enable, clock;
	output reg [2:0] Q; //10100 - 1
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 0;	
		else if (enable == 1)
			if(Q >= 4)
				Q <= 0;
			else
				Q <= Q + 1;
		end
		
endmodule

//Ycounter for meter uses same value as pvNRT y counter

module mterCounter(clearn, enable, clock, Q);
	input clearn, enable, clock;
	output reg [6:0] Q; 
	
	always @ (posedge clock)
		begin

		if (clearn == 0)
			Q <= 0;	
		else if (enable == 1)
			if(Q >= 99)
				Q <= 0;
			else
				Q <= Q + 1;
		end

endmodule





