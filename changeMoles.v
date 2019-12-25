//The follwing control and data paths control the process of adding and removing particles
//User adds and removes particles by pressing keys



module controlMoles (Reset_n, Incr, Decr, ResetDP_n, up, enableCount, enableStore, clk);

	input Reset_n, Incr, Decr, clk;
	output reg ResetDP_n, //resets datapath
					up, //tells the datapath to increase or decrease the number of partciles/moles
					enableCount, //enables counting
					enableStore; //enables storing the new value of up in the d flip flop in the data path
	
	
	reg [3:0] currentState, nextState;
	
	localparam   		Reset = 4'b0001,
							Load = 4'b0010,
							LoadWait = 4'b0100,
							ChangeNum = 4'b1000;

	//Next State Logic: 
	always @(*)
		begin
			case(currentState)

					Reset: begin
							if (!Reset_n)
								nextState = Reset;
							else
								nextState = Load;
						end
						
					Load: begin
							if (Decr || Incr)
								nextState = LoadWait; //Detects key push
								
							else 
								nextState = Load;
							
						end

					LoadWait: begin
	
							if (Decr || Incr)
								nextState = LoadWait;
							else
								nextState = ChangeNum; //detects finger lifted off key
						end
						
					ChangeNum: begin				
								nextState = Load;
						end
					
					default: nextState = Reset;
				endcase
			end
			
			
		// ouput logic, i.e. datapath control signals to be sent based on current state
	always @(*)
		begin
		
				ResetDP_n = 1; up = 0; enableCount = 0; enableStore = 0;  // default is 1 for active low signals
				
			case(currentState)
					Reset: begin
							ResetDP_n = 0;
						end
					
					Load: begin 
					
							enableStore = 1;
							if (Incr)
								up = 1;
							else
								up = 0;
						
							end
							
					LoadWait: begin

						end	
					
					ChangeNum: begin
							enableCount = 1;
						end
									
					//No need for default since all output values have been assigned 0 at the beginning
			endcase
		end
		
	always @(posedge clk)
		begin
		
			if(!Reset_n)
				currentState <= Reset;
			else
				currentState <= nextState;
		end	
	
	
			
endmodule




module datapathMoles(Reset_n, up, enableCount, enableStore, clk, numMoles);

	input Reset_n, up, enableCount, enableStore, clk;
	reg wUp;
	
	output [2:0] numMoles;
	
	//Stores the new value of up assigned from the control path until the user hits the next button
	always @(posedge clk)
		begin
			if(!Reset_n)
				wUp <= 0;
			else if (enableStore)
				wUp <= up;
		end
	
	molesCounter myCounter (wUp, Reset_n, enableCount, clk, numMoles);

endmodule


//Increase or decreases the mole count depending on the 'up' signal
//max number of moles is 5 
//min numbers of moles is 1
module molesCounter(up, clearn, enable, Clock, Q);
	
	input up, clearn, enable, Clock;
	output reg [2:0] Q;
	
	always @ (posedge Clock) begin
	
		if (clearn == 0) begin
			Q <= 1;	
		end
		
		else if (enable == 1) begin

			if (up) begin
				if (Q == 5)
					Q <= 5;
				else
					Q <= Q + 1;
				end
				
			else
				begin
				
					if (Q == 1)
						Q <= 1;
					else
						Q <= Q - 1;
				end 
		
		end
	
	end
	
endmodule
