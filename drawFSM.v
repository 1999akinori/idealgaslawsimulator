`timescale 1ns / 1ns // `timescale time_unit/time_precision


module draw (Reset_n, clk, mode, start, clear, xIn, yIn, xPos, yPos, colorOut, plot, pistonHeight, meter);
	//This module is responsible for drawing and clearing all the visual component of our project
	//It keeps track of the different states in which we draw the particle, piston, pressure meter and PV=nRT
	//We also clear the screen to move the particle, piston and meter to a new position
	
	input Reset_n,  clk, clear;
	input [2:0] start;
	input [8:0] xIn;
	input [7:0] yIn;
	input [7:0] pistonHeight;
	input [2:0] mode;
	input [6:0] meter;
	
	output [8:0] xPos;
	output [7:0]yPos;
	output [2:0] colorOut;
	output plot;
	
	wire load_x, load_y, plot, enableCount, chooseCounter, enableClearCount, choosePiston, enablePVNRT, enableMeter;
	wire [8:0] pixelCountBall;
	wire [15:0] pistonPixel;
	wire [8:0] xClearCount;
	wire [7:0] yClearCount;
	wire [10:0] countPVNRT;
	wire [6:0] pixelMeter;
	
	//Keeps track of the different states
	drawControl myControl (Reset_n, start, clear, clk, pixelCountBall, pistonPixel, xClearCount, yClearCount, load_x, load_y, plot,  enableCount,
	chooseCounter, enableClearCount, choosePiston, pistonHeight, enablePVNRT, countPVNRT, enableMeter, pixelMeter);
	//Keeps track of the x-y position and color of what is being drawn
	drawDatapath myDataPath (mode, meter, xIn, yIn, load_x, load_y, enableCount, Reset_n, clk, enableClearCount,
	chooseCounter, xPos, yPos, colorOut, pixelCountBall, xClearCount, yClearCount, choosePiston, pistonHeight, pistonPixel, enablePVNRT, countPVNRT, pixelMeter, enableMeter);
	
endmodule



module drawControl (Reset_n, start, clear, clk, pixelCountBall, pistonPixel, xClearCount, yClearCount, load_x, load_y, plot, 
 enableCount, chooseCounter, enableClearCount, choosePiston, pistonHeight, enablePVNRT, countPVNRT, enableMeter, pixelMeter);
	//control for the datapath that is resposible for drawing each shapes
	//Keeps track of the objects being drawn and its order
	
	input Reset_n, clear, clk;
	input [2:0] start; //Chooses to draw between piston, Pv=nRT, and the balls
	
	input [8:0] pixelCountBall; //the number of pixels drawn for the ball
	input [15:0] pistonPixel; //the number of pixels drawn for the piston
	input [10:0] countPVNRT; //the number of pixels drawn for the Pv=nRT
	input [6:0] pixelMeter; // the number of pixels drawn for the pressure meter
	
	input [8:0] xClearCount; //x position counter for clearing the screen
	input [7:0] yClearCount; //y position counter for clearing the screen
	input [7:0] pistonHeight;//the height of the piston we are drawing
	
	output reg load_x, load_y, plot, enableCount, chooseCounter, enableClearCount, choosePiston, enablePVNRT, enableMeter;
	
	
	
	reg[5:0] currentState, nextState;
	
	wire [15:0] pistonUpperBound; //the number of pixels needed to be drawn for piston
	assign pistonUpperBound = (pistonHeight *  8'd220) - 1; //changes with the current height of the piston
	
	localparam 		LoadX = 6'b000001,
						DrawPVNRT = 6'b000010,
						DrawBall 	= 6'b000100,
						DrawPiston = 6'b001000,
						Clear = 6'b010000,
						DrawMeter = 6'b100000;
						  
	//Next State Logic: 
	always @(*)
		begin
			case(currentState)
					LoadX: begin
							if (!Reset_n)
								nextState = LoadX;
								
							else if (clear)
								nextState = Clear;
								
							else
								if (start == 4) //Pressure meter
									nextState = DrawMeter;
								else if (start == 3) // PV=nRT
									nextState = DrawPVNRT;
								else if(start == 1) //Particle
									nextState = DrawBall;
								else if(start == 2) // Piston
									nextState = DrawPiston;
								else
									nextState = LoadX;
							end
					DrawMeter: begin
						if (!Reset_n)
								nextState = LoadX;
							else if (clear)
								nextState = Clear;
							else if ( ((pixelMeter < 99))) //99 represents the total pixel needed to be drawn minus 1
								nextState = DrawMeter;
							else 
								nextState = DrawPVNRT;
					end
					DrawPVNRT:begin
						if (!Reset_n)
								nextState = LoadX;
							else if (clear)
								nextState = Clear;
							else if ( ((countPVNRT < 11'd1299)))
								nextState = DrawPVNRT;
							else 
								nextState = DrawBall;
					end
					DrawBall: begin
							if (!Reset_n)
								nextState = LoadX;
							else if (clear)
								nextState = Clear;
							else if ( ((pixelCountBall < 9'd360)))
								nextState = DrawBall;
							else 
								nextState = LoadX;
						end
						
					DrawPiston: begin
							if (!Reset_n)
								nextState = LoadX;
							else if (clear)
								nextState = Clear;
							else if ( ((pistonPixel < pistonUpperBound)) ) //UpperBound changes depending on piston height
								nextState = DrawPiston;
							else 
								nextState = DrawMeter;
						end
						
					Clear: begin //clear the screen
							if (xClearCount == 0  && yClearCount == 0)
								nextState = LoadX;
							else
								nextState = Clear;
						end	
					default: nextState = LoadX;
				endcase
			end
	
	
	
	// ouput logic, i.e. datapath control signals to be sent based on current state
	always @(*)
		begin
			//To avoid latches:
			load_x = 0;
			load_y = 0;
			plot = 0; //tells the VGA to display
			//enable signals for the counters of respective item to be drawn
			enableCount = 0;
			chooseCounter = 0; //choose between drawing and clearing the screen
			enableClearCount = 0;
			choosePiston = 0;
			enablePVNRT = 0;
			enableMeter = 0;
			
			case(currentState)
					LoadX: begin
							load_x = 1;
							load_y = 1;
							end
					DrawMeter:begin
							plot = 1;
							enableMeter = 1;
					end
					DrawPVNRT: begin
							plot = 1;
							enablePVNRT = 1;
					end
					DrawBall: begin 
								plot = 1;
								enableCount = 1;
							end
							
					DrawPiston: begin 
								plot = 1;
								choosePiston = 1;
							end
							
							
					Clear: begin
								chooseCounter = 1;
								enableClearCount = 1;
								plot = 1;
							end
					//No need for default since all output values have been assigned 0 at the beginning
			endcase
		end
	
	
	//currentState registers
	
	always @(posedge clk)
		begin
		
			if(!Reset_n)
				currentState <= LoadX;
			else
				currentState <= nextState;
		end
		
endmodule


module drawDatapath(mode, meterPosition, xIn, yIn, load_x, load_y, enableCount, Reset_n, clk, enableClearCount, chooseCounter, xPos, yPos, colorOut, pixelCountBall,
xClearCount, yClearCount,choosePiston, pistonHeight, pistonPixel, enablePVNRT, countPVNRT, pixelMeter, enableMeter);
	//The datapath module for drawing each objects
	//Tells the VGA display what x-y position to modify to what color
	
	input [8:0] xIn; //x Position of the left top corner of the shape drawn
	input [7:0] yIn; //y Position of the left top corner of the shape drawn
	input choosePiston;
	input [7:0] pistonHeight;
	input load_x, load_y, Reset_n, clk, enableCount, enableClearCount, chooseCounter, enablePVNRT;
	input [2:0] mode; //Selects which relationship e.g. manual, Volume to Moles, etc...
	input [6:0] meterPosition; //position of the meter in the scale
	
	output reg [8:0] xPos; 
	output reg [7:0] yPos;
	output reg [2:0] colorOut;
	output [8:0] xClearCount;
	output [7:0] yClearCount;
	
	reg [8:0] xInit; //stores the value of the left top corner of the object
	reg [7:0] yInit;
	
	//Loads the top left corner
	always @(posedge clk)
		begin
			if(!Reset_n) begin
				xInit <= 9'b0;
				yInit <= 8'b0;
			end
			
			else begin
				if(load_x) begin
					xInit <= xIn;
				end
				
				if(load_y) begin
					yInit <= yIn;
				end
			end
		end

	
	//----Particle--------------------------------------------------------------------------------------
	wire [4:0] xIncr, yIncr;
	wire [2:0]memoryOut;
	output [8:0] pixelCountBall; //used in the FSM to determine when to move to nextState
	
	myUpCounter xCounter (Reset_n, enableCount, clk, xIncr);
	myUpCounter yCounter (Reset_n, ((xIncr == 0) && (enableCount))? 1'b1:1'b0, clk, yIncr); // Note: clearing the counters or setting them to 0 
	pixelCounter pixCounter (Reset_n, enableCount, clk, pixelCountBall);							//is controlled by the gloabl Reset_n signal.
	rom361x3 rom1(xIncr + (19)*yIncr, clk, memoryOut);
	//--------------------------------------------------------------------------------------------------
	
	//----Clearing the background-----------------------------------------------------------------------
	wire [8:0] xClearPos;
	wire [7:0] yClearPos;
	wire [16:0]backgroundPixel;
	wire [2:0]backgroundColorOut;
	
	myXClearDownCounter XClearCounter(Reset_n, enableClearCount, clk, xClearPos);
	myYClearDownCounter YClearCounter(Reset_n, ((xClearPos == 0) && enableClearCount)? 1'b1:1'b0, clk, yClearPos);
	screenCounter backgroundCouter(Reset_n,chooseCounter, clk, backgroundPixel);
	rom76800x3 rom2(backgroundPixel, clk,backgroundColorOut);
	
	assign xClearCount = xClearPos; ///technically xClearPos and yClearPos could just be output instead of wire
	assign yClearCount = yClearPos;
	//--------------------------------------------------------------------------------------------------
	
	
	//----Piston----------------------------------------------------------------------------------------
	wire [7:0] xPistIncr,yPistIncr;
	wire [2:0] pistonColor;
	output [15:0]pistonPixel; //used in FSM to determine when to move to nextState
	
	pistonXcounter p1 (Reset_n, choosePiston, clk, xPistIncr);
	pistonYcounter p2 (Reset_n, ((xPistIncr == 0) && (choosePiston))? 1'b1:1'b0, clk, pistonHeight, yPistIncr);
	pistonCounter  p3 (Reset_n, choosePiston, clk, pistonHeight, pistonPixel);
	piston61600x3 rom4piston ((16'd61599 - (219 - xPistIncr) - 220*(pistonHeight - 1 - yPistIncr)), clk, pistonColor);
	//Piston is drawn from bottom right corner to top left corner
	//both x and y counter for Piston are down counters
	//--------------------------------------------------------------------------------------------------	
	
	//----PV=nRT----------------------------------------------------------------------------------------
	wire [6:0] Xpvnrt; //increments the initial x and y position for the PV=nRT
	wire [4:0] Ypvnrt;
	
	wire [2:0] Colorpvnrt; //manual mode
	wire [2:0] ColorntoT;
	wire [2:0] ColorVton;
	wire [2:0] ColorVtoT;
	
	reg [2:0] colorSelected; //mode chooses which relationship to display
	
	output [10:0] countPVNRT; //keeps track of the pixel being drawn
	
	XpvnrtCounter pvnrt1(Reset_n, enablePVNRT, clk, Xpvnrt);
	YpvnrtCounter pvnrt2(Reset_n, ((Xpvnrt == 0) && (enablePVNRT))? 1'b1:1'b0, clk, Ypvnrt);
	pvnrtCounter pvnrt3(Reset_n, enablePVNRT, clk, countPVNRT);
	
	//roms storing the mif of each relation
	pvnrt  romPVNRT(Xpvnrt + (65)*Ypvnrt, clk, Colorpvnrt);
	ntoT romNtoT(Xpvnrt + (65)*Ypvnrt, clk, ColorntoT);
	Vton romVton(Xpvnrt + (65)*Ypvnrt, clk, ColorVton);
	VtoT romVtoT(Xpvnrt + (65)*Ypvnrt, clk, ColorVtoT);
	
	always @(*) //chooses the image
		begin
			case(mode)
				0: colorSelected = Colorpvnrt;
				1: colorSelected = ColorntoT;
				2: colorSelected = ColorVton;
				default: colorSelected = ColorVtoT;
			endcase
		end
	//--------------------------------------------------------------------------------------------------
	
	//----Pressure meter--------------------------------------------------------------------------------
	input enableMeter;
	wire [2:0] xMeter;
	wire [6:0] yMeter;
	output [6:0] pixelMeter;
	wire [2:0] colorMeter;
	
	XmeterCounter meterX (Reset_n, enableMeter, clk, xMeter);
	YpvnrtCounter meterY(Reset_n, ((xMeter == 0) && (enableMeter))? 1'b1:1'b0, clk, yMeter);
	mterCounter meterCount(Reset_n, enableMeter, clk, pixelMeter);
	meter meterROM(xMeter + 5*(yMeter),clk, colorMeter);
	//--------------------------------------------------------------------------------------------------

	
	//Selects what is being drawn-----------------------------------------------------------------------
	wire [7:0] xChoose, yChoose;
	wire [2:0] colorChoose;	
	
	always@(*)begin
		if(chooseCounter)begin
			xPos = xClearPos;
			yPos = yClearPos;
			colorOut = backgroundColorOut;
		end
		else if(choosePiston)begin
			xPos = xPistIncr + 6; //+6 accounts for the border of the container
			yPos = yPistIncr;
			colorOut = pistonColor;
		end
		else if(enablePVNRT)begin
			//235 and 190 accounts is the top left corner of PV=nRT
			//Xpvnrt and Ypvnrt increments from those value
			xPos = 235 + Xpvnrt; 
			yPos = 190 + Ypvnrt;
			colorOut = colorSelected;
		end
		else if(enableMeter)begin
			//238 and 100 accounts is the top left corner of the Meter when the meterPosition is lowest on the scale
			// meterPosition accounts for when the pressure level changes and the xPosition of the scale changes
			// xMeter and yMeter increments for drawing the meter
			xPos = 238 + meterPosition + xMeter;
			yPos = 100 + yMeter;
			colorOut = colorMeter;
		end
		else begin //drawing particles
			//xInit and yInit is the left top corner of the particle
			// xIncr and yIncr changes xPos and yPos to draw the whole particle
			xPos = xInit + xIncr;
			yPos = yInit + yIncr;
			colorOut = memoryOut;
		end
	end
	//--------------------------------------------------------------------------------------------------
endmodule
			
				
	
	
	
	
	
				
				
	