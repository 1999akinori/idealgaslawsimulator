//`timescale time_unit/time_precision
//This version is for three particles project 2
//SHoudl change myDrawWiat speed 4 and eraseWait


//This is where we connect the datapaths and the control paths
module mainFSM (clk, Reset_nFSM, xComp, yComp, temperature, go, xPos, yPos, colorOut, plot, Incr, Decr, compress, expand, mode);

	input clk, Reset_nFSM, go;
	input [2:0] temperature;
	input [8:0] xComp;
	input [7:0] yComp;
	input Incr, Decr;
	input compress, expand;
	input [2:0] mode;

	output [8:0] xPos;
	output [7:0] yPos;
	output [2:0] colorOut;
	output plot;

	wire Reset_nDP, enableCount,
	erase,
	enableEraseWait, enableRateDivider, enableDrawWait, enableToggle, enableBorder;
	
	wire [2:0] start;
	
	wire [23:0] rateWait;
	wire [16:0] eraseWait; 
	wire [16:0] drawWait;
	
	wire [2:0] horzshiftToggle;
	wire [2:0] vertshiftToggle;
	
	wire [2:0] ballDrawSelect;
	
	wire ResetMolesDP_n;
	wire up;
	wire enableMoleCount;
	wire enableStore;
	wire [2:0] numMoles;
	

	
	controlMoles myControlMoles (Reset_nFSM, Incr, Decr, ResetMolesDP_n, up, enableMoleCount, enableStore, clk);
	
	datapathMoles myMoles(ResetMolesDP_n, up, enableMoleCount, enableStore, clk, numMoles);
	
	
	mainControl control (
		.clk(clk),
		.Reset_nFSM(Reset_nFSM),
		.go(go),
		.drawWait(drawWait),
		.rateWait(rateWait), 
		.eraseWait(eraseWait), 

		.Reset_nDP(Reset_nDP),
		.start(start), 
		.enableDrawWait(enableDrawWait),
		.enableRateDivider(enableRateDivider),	
		.enableEraseWait(enableEraseWait),
		.enableToggle(enableToggle),
		.enableBorder(enableBorder),
		.erase(erase),
		.enableCount(enableCount),
		.ballDrawSelect(ballDrawSelect)
		
);
	
	
	
	mainDatapath datapath(
		.clk(clk), 
		.colorIn(colorIn),
		.temperature(temperature),
		.xComp(xComp),
		.yComp(yComp),
		.Reset_n(Reset_nDP), 
		.enableDrawWait(enableDrawWait),
		.enableRateDivider(enableRateDivider),
		.enableEraseWait(enableEraseWait),
		.enableCount(enableCount), 
		.enableToggle(enableToggle),
		.enableBorder(enableBorder),
				
		.start(start),
		.erase(erase),
		.ballDrawSelect(ballDrawSelect),
 
		.drawWait(drawWait),
		.rateWait(rateWait), 
		.eraseWait(eraseWait),

		.xPos(xPos), 
		.yPos(yPos),
		.colorOut(colorOut),
		.plot(plot),
		.numMoles(numMoles),
		.compress(compress),
		.expand(expand),
		.mode(mode)

		
);
	

endmodule

 
module mainControl (clk, Reset_nFSM, go, drawWait, rateWait, eraseWait, enableToggle, enableBorder,
Reset_nDP, 
start, enableDrawWait, 
enableRateDivider, 
erase, enableEraseWait, 
ballDrawSelect,
enableCount);


	input clk;
	input Reset_nFSM, go;
	input [16:0] drawWait; //Counter signal that counts how many clock ticks we need to wait for to draw everything
	input [23:0] rateWait; //Counter signal that counts how many clock ticks we need to wait before updating the screen
	input [16:0] eraseWait; //Counter signal that counts how many clock ticks we need to wait for to ERASE everything
	
	//Enable signals used to control all the datapath counters
	output reg  Reset_nDP, 
					enableDrawWait, 
					enableRateDivider, 	
					enableEraseWait,
					enableCount, 
					enableToggle, //enable signal for switching the direction of the particles
					enableBorder, //enables the border counter which conrtols the upper container border defined by the piston
					erase;  //enables erasing
	
	//Start drawing signal. There are 4 separate sets of objects to be drawn: 
	//the piston, the PV=NRt equation, the pressure meter, and teh 5 partciles
	output reg [2:0] start; 
					
	//Selects Which particle to draw. There are five particles
	output reg [2:0] ballDrawSelect;
	
	reg [5:0] currentState, nextState;
	
	localparam   		ResetPos = 6'b000001,
							Draw = 6'b000010, // Draw State, where everything is drawn
							Wait = 6'b000100, //Wait state which conrols how fast or slow we see objects changing on the screen
							Erase = 6'b001000, //Erases everything on screnn
							UpdateShift = 6'b010000, //updates the direction of motion of the particles
							UpdatePos = 6'b100000; //Updates the positions of the particles
						
	
	//Next State Logic: 
	always @(*)
		begin
			case(currentState)

					ResetPos: begin
							if (go)
								nextState = Draw;
							else
								nextState = ResetPos;
						end
						
					Draw: begin
							if (drawWait == 0) //If done drawing everything, move on to the Wait state
								nextState = Wait;
								
							else 
								nextState = Draw;
							
						end

					Wait: begin
	
							if (rateWait == 0) //If done waiting, move on to the erase state
								nextState = Erase;
							else
								nextState = Wait;
						end
						
					Erase: begin

							if (eraseWait == 0) //If done erasing, update the motion directions of the particles
								nextState = UpdateShift;
							else
								nextState = Erase;
						end
								
					UpdateShift: begin
								nextState = UpdatePos; //Then immediately update the positions
						end
						
					UpdatePos: begin
								nextState = Draw; //Go back to draw state to draw the new particles and everything else and repeat the cycle
						
						end
					
					default: nextState = ResetPos;
				endcase
			end
	

		// ouput logic, i.e. datapath control signals to be sent based on current state
	always @(*)
		begin
		
				Reset_nDP = 1; // default is 1 because this is active low signal 
				start = 0; enableDrawWait = 0; 
				enableRateDivider = 0; 
				erase = 0; enableEraseWait = 0; enableToggle = 0; enableBorder = 0;
				ballDrawSelect = 0;
				enableCount = 0;
				
			case(currentState)
					ResetPos: begin
							Reset_nDP = 0;
							erase = 1;
							enableEraseWait = 1;
						end
					
					Draw: begin 
							enableDrawWait = 1;
							
							
							if (drawWait > 5*361 + 1300 + 100) begin
								ballDrawSelect = 0;
								start = 2; //draw piston
								end
								
							else if (drawWait > 5*361 + 1300)begin
								ballDrawSelect = 0;
								start = 4; //draw meter
							end
							
							else if (drawWait > 5*361) begin
								ballDrawSelect = 0;
								start = 3; //draw pv=nrt equation
							end
							
							else if(drawWait > 4*361)begin
								ballDrawSelect = 0;
								start = 1; //draw particle 1
								end
							else if(drawWait > 3*361)begin
								ballDrawSelect = 1;
								start = 1; //draw particle 2
								end
							else if(drawWait >2*361)begin
								ballDrawSelect = 2;
								start = 1;//draw particle 3
								end
							else if(drawWait >1*361)begin
								ballDrawSelect = 3;
								start = 1; //draw particle 4
								end
							else begin
								ballDrawSelect = 4;
								start = 1;	//draw particle 5
								end
							end
							
					Wait: begin
							enableRateDivider = 1;

						end	
					
					Erase: begin

							if(eraseWait == 0) begin
								enableBorder = 1; //must update border position on the last clock tic of the erase state before 
														//updating the motion direction of the particles
								erase = 1;
								enableEraseWait = 1;
							end
							
							else begin
								erase = 1;
								enableEraseWait = 1;
							end
								
						end
							
					UpdateShift: begin
							enableToggle = 1; //updates the toggle flip flops that hold the direction of motion of the particles
							
						end
							
					UpdatePos: begin
							enableCount = 1; //enables the counters that update the postion of the particles
						end
		
		
					//No need for default since all output values have been assigned 0 at the beginning
			endcase
		end
	
	
	
	
	always @(posedge clk)
		begin
		
			if(!Reset_nFSM)
				currentState <= ResetPos;
			else
				currentState <= nextState;
		end	
	
	
endmodule




module mainDatapath (Reset_n, clk, 
mode, temperature, xComp, yComp, compress, expand, numMoles,

enableDrawWait, enableRateDivider, enableEraseWait, 
enableCount, enableToggle, enableBorder,

start, erase, ballDrawSelect, 
drawWait,rateWait, eraseWait, 

xPos, yPos, colorOut, plot);


	input [2:0] mode; //simulation mode
	input [2:0] temperature; 
	input [8:0] xComp; //X velocity component of the particles
	input [7:0] yComp; //Y velocity component of the particles
	input compress, expand; //compress or expand the piston
	input [2:0] numMoles; //External input by user
	
	input clk, Reset_n, enableRateDivider, enableEraseWait, enableDrawWait, enableCount, enableColor, enableToggle, enableBorder,
	 erase;
	 
	input [2:0] start;
	
	input [2:0] ballDrawSelect;

	
	//ouptus to besent to the control path to switch between states
	output [16:0] drawWait;
	output [23:0] rateWait;
	output [16:0] eraseWait;
	
	//Outputs to be sent to the VGA adapter
	output [8:0] xPos;
	output [7:0] yPos;
	output [2:0] colorOut;
	output plot;

	//"Active" signals for each particle
	reg ball1;
	reg ball2; 
	reg ball3;
	reg ball4;
	reg ball5;
	
	//Selects the speed of how much fast we see things updating on the screen
	//representative of the temperature of the particles
	reg [2:0]speedSelect;

	//There are 5 pairs T-flip flops each of which holds the x and y directions of each particle
	//These signals are the enable signals for fliping the value held in the flip flops
	reg [4:0] horzshiftToggle; 
	reg [4:0] vertshiftToggle;
	
	//wires coming out of the direcion flip flops
	wire [4:0] wHorzShift;
	wire [4:0] wVertShift;
	
	//wires that hold the x and y positons of all the partciles
	wire [44:0] wX; 
	wire [39:0] wY;

	//wires that hold the x and y positions of the particles to be drawn
	reg [8:0] wToX;
	reg [7:0] wToY;
	
	//position of the upper border definied by the piston
	wire [7:0] border;
	
	//0 for inversely proportional relation ship and 1 for directly proportional relations ship
	//used when updating temperature as a response to some other parameter change
	reg proportional;
	
	
	always @(*)
		begin
			case(mode)
				0: begin //manual mode
					speedSelect = temperature;
					proportional = 1; //not really neede in default mode
					end
				1: begin//moles to (or controls) temperature, with everything else held constant
					speedSelect = numMoles;
					proportional = 0;
					end
				2:begin //moles to (or controls) volume, with everything else held constant
					speedSelect = temperature;
					proportional = 1; //
					end
				3:begin //temperature to (or controls) volume, with everything else held constant
					speedSelect = temperature;
					proportional = 1;
					end
				4:begin //volume to (or controls) temperature, with everything else held constant
					proportional = 1;
					if(border < 50)
						speedSelect = 5;
					else if(border < 100)
						speedSelect = 4;
					else if(border < 150)
						speedSelect = 3;
					else if(border < 200)
						speedSelect = 2;
					else
						speedSelect = 1;
				end
				default: begin//default mode is manual
					speedSelect = temperature;
					proportional = 1;
					end
				endcase
		end
		
//Dependiong on the number of moles, activate the correct number of particles		
	always @(*)
		begin
			if (numMoles == 5)
				begin
					ball1 = 1;
					ball2 = 1;
					ball3 = 1;
					ball4 = 1; 
					ball5 = 1;
				end

			else if (numMoles == 4)
				begin
					ball1 = 1;
					ball2 = 1;
					ball3 = 1;
					ball4 = 1;
					ball5 = 0;
				end	
				
			else if (numMoles == 3)
				begin
					ball1 = 1;
					ball2 = 1;
					ball3 = 1;
					ball4 = 0;
					ball5 = 0;
				end	
				
			else if (numMoles == 2)
				begin
					ball1 = 1;
					ball2 = 1;
					ball3 = 0;
					ball4 = 0;
					ball5 = 0;
				end
				
			else 
				begin
					ball1 = 1;
					ball2 = 0;
					ball3 = 0;
					ball4 = 0;
					ball5 = 0;
				end
			
			
		end
	
	
	//Instantiate wait counter
	myRateDivider rateDividerCounter(Reset_n, speedSelect, enableRateDivider, clk, proportional, rateWait);
	
	//Instantiate the erase counter that waits for everything to be erased
	myEraseWait erasewaitCounter(Reset_n, enableEraseWait, clk, eraseWait);


	//Instaniates the draw counter which waits for everything to be drawn
	myDrawWait #(.numParticles(5)) drawWaitCounter (Reset_n, enableDrawWait, clk, border, drawWait);
	
	
	//Each pair of T flip flops holds the direction of motion along the x and y axes for each particle.
	//1 is increasing in the defined positive direction, and 0 is decreasing.
	//I.e. 1 is right for x and down for y while 0 is left for x and up for y
	myTff horzShiftReg1(enableToggle, horzshiftToggle[0], clk,  wHorzShift[0], Reset_n); //Stores the direction for horizontal TFlipFlop
	myTff vertShiftReg1(enableToggle, vertshiftToggle[0], clk, wVertShift[0], Reset_n);  //Stores the direction for vertical TFlipFlop
	
	myTff horzShiftReg2(enableToggle, horzshiftToggle[1], clk,  wHorzShift[1], Reset_n);
	myTff vertShiftReg2(enableToggle, vertshiftToggle[1], clk, wVertShift[1], Reset_n);
	
	myTff horzShiftReg3(enableToggle, horzshiftToggle[2], clk,  wHorzShift[2], Reset_n);
	myTff vertShiftReg3(enableToggle, vertshiftToggle[2], clk, wVertShift[2], Reset_n);

	myTff horzShiftReg4(enableToggle, horzshiftToggle[3], clk,  wHorzShift[3], Reset_n);
	myTff vertShiftReg4(enableToggle, vertshiftToggle[3], clk, wVertShift[3], Reset_n);
	
	myTff horzShiftReg5(enableToggle, horzshiftToggle[4], clk,  wHorzShift[4], Reset_n);
	myTff vertShiftReg5(enableToggle, vertshiftToggle[4], clk, wVertShift[4], Reset_n);
	
	
	//Each pair of counters holds the x and y positions of each particle
	//The input parameter defiens where the starting position of each particle is
	myXCounter xC1 (wHorzShift[0], Reset_n, enableCount, xComp, clk, wX[8:0]);
	myYCounter #(.startPos(60)) yC1 (wVertShift[0], Reset_n, enableCount, yComp, border, clk, wY[7:0]);
	
	myXCounter #(.startPos(130)) xC2 (wHorzShift[1], Reset_n, enableCount, xComp, clk, wX[17:9]);
	myYCounter #(.startPos(60)) yC2 (wVertShift[1], Reset_n, enableCount, yComp, border, clk, wY[15:8]);
	
	myXCounter #(.startPos(150)) xC3 (wHorzShift[2], Reset_n, enableCount, xComp, clk, wX[26:18]);
	myYCounter #(.startPos(100)) yC3 (wVertShift[2], Reset_n, enableCount, yComp, border, clk, wY[23:16]);
	
	myXCounter xC4 (wHorzShift[3], Reset_n, enableCount, xComp, clk, wX[35:27]);
	myYCounter #(.startPos(190)) yC4 (wVertShift[3], Reset_n, enableCount, yComp, border, clk, wY[31:24]);
	
	myXCounter #(.startPos(120)) xC5 (wHorzShift[4], Reset_n, enableCount, xComp, clk, wX[44:36]);
	myYCounter #(.startPos(200)) yC5 (wVertShift[4], Reset_n, enableCount, yComp, border, clk, wY[39:32]);
	
	
	//collision wire is 1 if there has been a collision detected
	//With 5 balls, there is a totla number of 10 possible collisions that could take place,
	//so we instatitae a collision module for each possible collision
	//Note: must pass in the width of the particles in pixels in order to detect correct collisions
	wire[9:0] collision;						
	checkCollision #(.ballWidth(19)) Check1and2 (wX[8:0] + 9, wY[7:0] + 9, wX[17:9] + 9, wY[15:8] + 9, collision[0]);
	checkCollision #(.ballWidth(19)) Check1and3 (wX[8:0] + 9, wY[7:0] + 9, wX[26:18] + 9, wY[23:16] + 9, collision[1]);
	checkCollision #(.ballWidth(19)) Check1and4 (wX[8:0] + 9, wY[7:0] + 9, wX[35:27] + 9, wY[31:24] + 9, collision[2]);
	checkCollision #(.ballWidth(19)) Check1and5 (wX[8:0] + 9, wY[7:0] + 9, wX[44:36] + 9, wY[39:32] + 9, collision[3]);
	
	
	checkCollision #(.ballWidth(19)) Check2and3 (wX[17:9] + 9, wY[15:8] + 9, wX[26:18] + 9, wY[23:16] + 9, collision[4]);
	checkCollision #(.ballWidth(19)) Check2and4 (wX[17:9] + 9, wY[15:8] + 9, wX[35:27] + 9, wY[31:24] + 9, collision[5]);
	checkCollision #(.ballWidth(19)) Check2and5 (wX[17:9] + 9, wY[15:8] + 9, wX[44:36] + 9, wY[39:32] + 9, collision[6]);
	
	checkCollision #(.ballWidth(19)) Check3and4 (wX[26:18] + 9, wY[23:16] + 9, wX[35:27] + 9, wY[31:24] + 9, collision[7]);
	checkCollision #(.ballWidth(19)) Check3and5 (wX[26:18] + 9, wY[23:16] + 9, wX[44:36] + 9, wY[39:32] + 9, collision[8]);
	
	checkCollision #(.ballWidth(19)) Check4and5 (wX[35:27] + 9, wY[31:24] + 9, wX[44:36] + 9, wY[39:32] + 9, collision[9]);
	
	
	//border counter that updates the border of the piston
	borderCounter myBorderCount( (mode == 3), (mode == 2), Reset_n, enableBorder, compress, expand, temperature, numMoles, clk, border);
	
	
	//meter counter that updates the pressure meter position
	wire [6:0] meter;
	meterCounter pressureMeter(Reset_n, mode == 0, speedSelect, numMoles, border, clk, meter);
	
	
	//this block updates the whether the particles direction should fliiped or not depending on whether there is a collision with another particle
	//or with the walls of the containers
	always@(*)
		begin
		
			//toggle the direction of motion if there is a collision with the walls
			horzshiftToggle[0] = ( ((wX[8:0] == 6) && (wHorzShift[0] == 0)) || ((wX[8:0] >= 204) && (wHorzShift[0] == 1)) )? 1:0;
			vertshiftToggle[0] = ( ((wY[7:0] == border) && (wVertShift[0] == 0)) || ((wY[7:0] >= 205) && (wVertShift[0] == 1)) )? 1:0;
			horzshiftToggle[1] = ( ((wX[17:9] == 6) && (wHorzShift[1] == 0)) || ((wX[17:9] >= 204) && (wHorzShift[1] == 1)) )? 1:0;
			vertshiftToggle[1] = ( ((wY[15:8] == border) && (wVertShift[1] == 0)) || ((wY[15:8] >= 205) && (wVertShift[1] == 1)) )? 1:0;
			horzshiftToggle[2] = ( ((wX[26:18] == 6) && (wHorzShift[2] == 0)) || ((wX[26:18] >= 204) && (wHorzShift[2] == 1)) )? 1:0;
			vertshiftToggle[2] = ( ((wY[23:16] == border) && (wVertShift[2] == 0)) || ((wY[23:16] >= 205) && (wVertShift[2] == 1)) )? 1:0;
			horzshiftToggle[3] = ( ((wX[35:27] == 6) && (wHorzShift[3] == 0)) || ((wX[35:27] >= 204) && (wHorzShift[3] == 1)) )? 1:0;
			vertshiftToggle[3] = ( ((wY[31:24] == border) && (wVertShift[3] == 0)) || ((wY[31:24] >= 205) && (wVertShift[3] == 1)) )? 1:0;
			horzshiftToggle[4] = ( ((wX[44:36] == 6) && (wHorzShift[4] == 0)) || ((wX[44:36] >= 204) && (wHorzShift[4] == 1)) )? 1:0;
			vertshiftToggle[4] = ( ((wY[39:32] == border) && (wVertShift[4] == 0)) || ((wY[39:32] >= 205) && (wVertShift[4] == 1)) )? 1:0;
			
			//If there is a collision between two balls and the two balls are currently active then toggle their directions of motion
			if(collision[0] && ball1 && ball2)
				begin
					horzshiftToggle[0] = 1;
					vertshiftToggle[0] = 1;
					horzshiftToggle[1] = 1;
					vertshiftToggle[1] = 1;
				end
				
			if(collision[1] && ball1 && ball3)
				begin
					horzshiftToggle[0] = 1;
					vertshiftToggle[0] = 1;
					horzshiftToggle[2] = 1;
					vertshiftToggle[2] = 1;
				end
				
			if(collision[2] && ball1 && ball4)
				begin
					horzshiftToggle[0] = 1;
					vertshiftToggle[0] = 1;
					horzshiftToggle[3] = 1;
					vertshiftToggle[3] = 1;
				end
				
			if(collision[3] && ball1 && ball5)
				begin
					horzshiftToggle[0] = 1;
					vertshiftToggle[0] = 1;
					horzshiftToggle[4] = 1;
					vertshiftToggle[4] = 1;
				end
			
			if(collision[4] && ball2 && ball3)
				begin
					horzshiftToggle[1] = 1;
					vertshiftToggle[1] = 1;
					horzshiftToggle[2] = 1;
					vertshiftToggle[2] = 1;
				end
				
			if(collision[5] && ball2 && ball4)
				begin
					horzshiftToggle[1] = 1;
					vertshiftToggle[1] = 1;
					horzshiftToggle[3] = 1;
					vertshiftToggle[3] = 1;
				end
				
				
			if(collision[6] && ball2 && ball5)
				begin
					horzshiftToggle[1] = 1;
					vertshiftToggle[1] = 1;
					horzshiftToggle[4] = 1;
					vertshiftToggle[4] = 1;
				end
				
			if(collision[7] && ball3 && ball4)
				begin
					horzshiftToggle[2] = 1;
					vertshiftToggle[2] = 1;
					horzshiftToggle[3] = 1;
					vertshiftToggle[3] = 1;
				end
				
			if(collision[8] && ball3 && ball5)
				begin
					horzshiftToggle[2] = 1;
					vertshiftToggle[2] = 1;
					horzshiftToggle[4] = 1;
					vertshiftToggle[4] = 1;
				end
				
			if(collision[9] && ball4 && ball5)
				begin
					horzshiftToggle[3] = 1;
					vertshiftToggle[3] = 1;
					horzshiftToggle[4] = 1;
					vertshiftToggle[4] = 1;
				end
				
			end
	
	
	//This block selects which ball to draw depending on the signal that comes from the control path
	always @(*)
		begin
			case (ballDrawSelect)
				0: begin
						if (ball1)
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
						else
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
					end
					
				1: begin
						if (ball2)
							begin
							wToX = wX[17:9];
							wToY = wY[15:8];
							end
							
						else
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
					end
					
				2: begin
						if (ball3)
							begin
							wToX = wX[26:18];
							wToY = wY[23:16];
							end
						else
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
					end
					
				3: begin
						if (ball4)
							begin
							wToX = wX[35:27];
							wToY = wY[31:24];
							end
						else
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
					end

				4: begin
						if (ball5)
							begin
							wToX = wX[44:36];
							wToY = wY[39:32];
							end
						else
							begin
							wToX = wX[8:0];
							wToY = wY[7:0];
							end
					end
					
				default: begin
					wToX = wX[8:0];
					wToY = wY[7:0];
					end
					
			endcase
		end
	
	
		//Instatiates the datapath and contol path that draw objects pixel by pixel
		draw part2(Reset_n, clk, mode, start, erase, wToX, wToY, wColor, xPos, yPos, colorOut, plot, border, meter);
	
	
endmodule
	
	

//myDrawWait waits for everything to be drawn on the screen by counting down from the total number of pixels that have to be drawn	
module myDrawWait (Reset_n, enable, Clock, pistonHeight, Q);


	parameter numParticles = 1;
	
	input Clock, Reset_n, enable;
	input [7:0] pistonHeight;
	output reg [16:0] Q;
	wire [16:0] w;
	assign w = numParticles*361 /*361 pixels for each pixel to be drawn*/ 
					+ 220*pistonHeight /* number of pixels to be drawn for the piston*/ 
					+ 1300 /*numbe of pixels to be drawn for the PV=NRT equation*/ 
					+ 100 /*number of pixels to be drawn for the pressure meter*/;
	
	always @(posedge Clock)
		begin
				
			if (Reset_n == 0)
				Q <= w;
			
			else if (enable) begin
				if (Q == 0)
					Q <= w;
				
				else 
					Q <= Q - 1;
			end 
				
		end
				
endmodule
	
	
	
//Rate divider counter that counts how many clock tics to wait for before erasing and updating objects
//on the screen
module myRateDivider (Reset_n, speedSelect, enable, Clock, proportional, Q);

	input Clock, Reset_n, enable, proportional;
	input [2:0]speedSelect;
	output reg [23:0] Q;
	reg [23:0]w;
	
	localparam   		speed5 = 100999,  // 25 frame/sec
							speed4 = 249999, //  20 frames/sec
							speed3 = 999999, //  15 frames/sec
							speed2 = 2499999, //  10 frames/sec
							speed1 = 9999999; //  5 frames/sec

	always@(*)
		begin
			
			//directly propotional relationship, will increase speed everytime speedSelect increases
			if(proportional)begin
				case (speedSelect)
				1: w = speed1;
				2: w = speed2;
				3: w = speed3;
				4: w = speed4;
				5: w = speed5;
				default: w = speed1;
				endcase
			end
			
			
			else begin
				//inversly proportional relationship, will decrease speed everytime speedSelect increases
				case (speedSelect)
				1: w = speed5;
				2: w = speed4;
				3: w = speed3;
				4: w = speed2;
				5: w = speed1;
				default: w = speed5;
			endcase
			end
		end

	//counter
	always @(posedge Clock)
		begin
				
			if (Reset_n == 0)
				Q <= w;
			
			else if (enable) begin
				if (Q == 0)
					Q <= w;
				
				else 
					Q <= Q - 1;
			end 
				
		end
				
endmodule


//waits for entire screen to be erased
module myEraseWait (Reset_n, enable, Clock, Q);

	input Clock, Reset_n, enable;
	output reg [16:0] Q;
	wire [16:0] w;
	assign w = 76799; //should be 19199 for 160 by 120; should be 76800 for 320 by 240
	
	always @(posedge Clock)
		begin
				
			if (Reset_n == 0)
				Q <= w;
			
			else if (enable) begin
				if (Q == 0)
					Q <= w;
				
				else 
					Q <= Q - 1;
			end 
				
		end
				
endmodule


//T flip flop to hold the direction of motion for the particles
module myTff (enable, myToggle, myClock, Q, clearn);
	input myToggle, myClock, clearn, enable;
	output reg Q;
	
	always @ (posedge myClock) begin
	
		if (clearn == 0)
			Q <= 0; 
		else if (enable)
			Q <= myToggle ^ Q;
			
		end
		
endmodule

