`include "vga_defines.v"

module vga_4bit_graph
(
vga_clk,reset,
fifo_read,fifo_readdata,Blank_V,
Hs,Vs,R,G,B
);
	input vga_clk;							//vga clock		
	input reset;								// reset,high level active
	output fifo_read;			//fifo read request
	input [3:0] fifo_readdata;	//fifo read data
	output Blank_V;
	//vga interface
	output Hs,Vs;
	output [1:0] R,G,B;
	
	wire DE;
	reg Hs_reg,Vs_reg;
	wire [1:0] R_reg,G_reg,B_reg;
	reg [15:0] count_h,count_v;
	reg Blank_H,Blank_V;

assign fifo_read = DE? 1'h1 : 1'h0;
assign R_reg = fifo_readdata[3]?  fifo_readdata[1:0] : (fifo_readdata[0]? 2'h3 : 2'h0);
assign G_reg = fifo_readdata[3]?  fifo_readdata[1:0] : (fifo_readdata[1]? 2'h3 : 2'h0);
assign B_reg = fifo_readdata[3]?  fifo_readdata[1:0] : (fifo_readdata[2]? 2'h3 : 2'h0);
//assign R_reg = (fifo_readdata[0]? 2'h3 : 2'h0);
//assign G_reg = (fifo_readdata[1]? 2'h3 : 2'h0);
//assign B_reg = (fifo_readdata[2]? 2'h3 : 2'h0);

//hsyc generate
always @(posedge vga_clk or posedge reset)					
begin
	if(reset) begin
		count_h<=0;
		Hs_reg<=0;
		Blank_H<=0;
	end
	else begin
		if(count_h>=`HTotal-1) count_h<=0;
		else count_h<=count_h+1'h1;				//horizontal counter
		if(count_h==`HDisplay-1) 			//horizontal blank start
		begin
			Blank_H<=1;
		end
		else if(count_h==(`HDisplay+`HSYNC_BACK)-1) 				//horizontal sync start
		begin
			Hs_reg<=1;
		end
		else if(count_h==(`HDisplay+`HSYNC_BACK+`HSYNC_WITH)-1)			//horizontal sync end
		begin
			Hs_reg<=0;
		end
		else if(count_h>=`HTotal-1)			//horizontal blank end
		begin
			Blank_H<=0;
		end
	end
end

//vsyc generate	
always @(posedge Hs_reg or posedge reset)					
begin
	if(reset) begin
		count_v<=0;
		Vs_reg<=0;
		Blank_V<=0;
	end
	else begin
		if(count_v>=`VTotal-1) count_v<=0;
		else count_v<=count_v+1'h1;			//vertical counter
		if(count_v==`VDisplay-1)				//vertical blank start
		begin
			Blank_V<=1;
		end
		if(count_v==(`VDisplay+`VSYNC_BACK)-1)				//vertical sync start
		begin
			Vs_reg<=1;
		end
		else if(count_v==(`VDisplay+`VSYNC_BACK+`VSYNC_WITH)-1)				//vertical sync end
		begin
			Vs_reg<=0;
		end
		else if(count_v>=`VTotal-1)				//vertical blank end
		begin
			count_v<=0;
			Blank_V<=0;
		end
	end
end

assign Hs=~Hs_reg;						//hsync out
assign Vs=~Vs_reg;						//vsync out
assign DE=~(Blank_H | Blank_V);		//DE out
assign R=DE?R_reg:2'h0;					//r out
assign G=DE?G_reg:2'h0;					//g out
assign B=DE?B_reg:2'h0;					//b out

endmodule

