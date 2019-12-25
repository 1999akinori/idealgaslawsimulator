module borderCounter (enableTemptoVol, enableMoltoVol, clearn, enable, compressIn, expandIn, temp, numMoles, clk , Q);

	//Controls the vertical position of piston for all modes------------------------------------------
	input enable, compressIn, expandIn, clk, clearn;
	output reg [7:0] Q; //the current position of the piston
	reg [7:0] min, max;
	reg compress, expand;
	
	always @ (posedge clk) begin
		if (clearn == 0) begin
			Q <= min;	
		end
		else if (enable) begin 
			if (compress) begin //update Q(current position of piston) until it reaches the max value
					if (Q == max)
						Q <= max;
					else
						Q <= Q + 1;
					end
					
			else if (expand) begin //update Q(current position of piston) until it reaches the max value
					if (Q == min)
						Q <= min;
					else
						Q <= Q - 1;
				end 
		end
	end
	//-----------------------------------------------------------------------------------------------
	
	//Determines how to border is controlled---------------------------------------------------------
	always@(*)begin
		if(enableMoltoVol)begin
			max = newBorderMol;
			min = newBorderMol;
			compress = moleCompress;
			expand = moleExpand;
		end
		else if(enableTemptoVol) begin
			max = newBorderTemp;
			min = newBorderTemp;
			compress = tempCompress;
			expand = tempExpand;
		end
		else begin
			max = 200;
			min = 1;
			compress = compressIn;
			expand = expandIn;
		end
	end
	//-----------------------------------------------------------------------------------------------
	
	//the number of moles controls the piston--------------------------------------------------------
	input [2:0] numMoles;
	input enableMoltoVol;
	wire [7:0] newBorderMol;
	assign newBorderMol = 200 - 40*numMoles + 1; //converts number of moles (1-5) to the border of the piston
	reg moleCompress;
	reg moleExpand;
	
	always @ (posedge clk)begin
			if(newBorderMol > Q && enableMoltoVol) begin //if newBorder is greater than the current position of Piston it must compress
				moleCompress <= 1;
				moleExpand <= 0;
				end
				
			else if(newBorderMol < Q && enableMoltoVol) begin // if newBorder is less than the current position of Piston it must expand
				moleExpand <= 1;
				moleCompress <= 0;
				end
	end
	//-----------------------------------------------------------------------------------------------
	
	
	//the temperature controls the volume of the piston----------------------------------------------
	input [2:0] temp;
	input enableTemptoVol;
	wire [7:0] newBorderTemp;
	assign newBorderTemp = 160 - 40*temp + 1; //converts temperature (0-4) to border value
	reg tempCompress;
	reg tempExpand;
	
	always @ (posedge clk)begin
			if((Q < newBorderTemp) && enableTemptoVol) begin // compares current and intended piston location to determine whether to expand or compress
				tempCompress <= 1;
				tempExpand <= 0;
				end
			else if((newBorderTemp < Q) && enableTemptoVol) begin
				tempExpand <= 1;
				tempCompress <= 0;
				end
	end
	//-----------------------------------------------------------------------------------------------
endmodule
