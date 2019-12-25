module meterCounter (clearn, enable, temp, numMoles, border, clk , Q); //enableMoltoVol is the signal we use to switch between modes
	input  enable, clk, clearn;
	input [2:0] numMoles;
	input [2:0] temp;
	input [7:0] border;
	output reg [6:0] Q; //position of meter on the scale
	reg right; // increments Q by +1
	reg left;  // increments Q by -1
	
	reg [2:0] volLevel;
	wire [6:0] pressureLevel;
	
	always@(*)
	begin 
		//Pressure and volume is inversely proportional. So when border is small, the volume level is high.
		//However, we intentioanlly assign a small volLevel value since the contribution of volume to pressure is inversely proportional
		//where as temp and numMoles are left on its own since their increase results in proportional increase of pressure
		if(border < 50)
			volLevel = 1;
		else if(border < 100)
			volLevel = 2;
		else if(border < 150)
			volLevel = 3;
		else if(border < 200)
			volLevel = 4;
		else
			volLevel = 5;
	end
	
	assign pressureLevel = (volLevel + temp + numMoles )*5; //calculates the pressure based on the contribution from volume, temperature, and number of Moles

	//updates the position of the meter
	always @ (posedge clk) begin
		if (clearn == 0) begin
			Q <= 30;	
		end
		else if (enable)
			begin
			if (right) begin
					if (Q == pressureLevel)
						Q <= pressureLevel;
					else
						Q <= Q + 1;
					end
			else if (left) begin
					if (Q == pressureLevel)
						Q <= pressureLevel;
					else
						Q <= Q - 1;
				end 
		end
	end
	
	//Determines if pressure level is increasing or decreasing
	always @ (posedge clk)begin
			if(pressureLevel > Q ) begin
				right <= 1;
				left <= 0;
				end
			else if(pressureLevel < Q ) begin
				left <= 1;
				right <= 0;
				end
	end
endmodule
