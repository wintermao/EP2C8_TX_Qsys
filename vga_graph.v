`define BRIGHTNESS 	3			// brightness level
`define BLACK		0					//black level
`define HDisplay	800			//horizontal active
`define VDisplay	600			//vertical active
`define HTotal		1056		//HTotal
`define VTotal		628			//VTotal
`define HSYNC_WITH	128		//hsync width
`define HSYNC_FRONT	40		//hsync front porch
`define HSYNC_BACK	88		//hsync back porch
`define VSYNC_WITH	4			//vsync width
`define VSYNC_FRONT	1			//vsync front porch
`define VSYNC_BACK	23		//vsync back porch

`define	AddrData			2'h00
`define	AddrControl		2'h01

module vga_graph
(
clk,reset_n,
chipselect,address,write,writedata,
vga_clk,Hs,Vs,Blank,R,G,B
);
	//avalon interface	
	input clk;						//avalon clock
	input reset_n;				//avalon reset,low level active
	input chipselect;			//avalon chip select
	input [1:0] address;	//avalon address
	input write;					//avalon write	
	input [15:0] writedata;	//avalon write data
	//vga interface
	input vga_clk;				//vga clock
	output Hs,Vs,Blank;
	output [1:0] R,G,B;
	
	reg Hs_reg,Vs_reg;
	reg [1:0] R_reg,G_reg,B_reg;
	reg [15:0] count_h,count_v;
	reg [1:0] Patten;
	reg Blank_H,Blank_V;

	reg [3:0] count_fifo_read=0;
	wire fifo_read;

	always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
		begin
			//data initial
		end
		else
		begin
			if(chipselect && write)		//avalon write 
			begin
				case(address)
					`AddrData:			fifo_data <= writedata;
					`AddrControl:		fifo_control <= writedata;
				endcase
			end
		end
	end
	
//fifo read clock
always @(posedge vga_clk or negedge reset_n)					
begin
	if(!reset_n) begin
		count_fifo_read<=0;
	end
	else begin
		if(count_fifo_read<7)	count_fifo_read<=count_fifo_read+1;
		else count_fifo_read<=0;
	end
end
assign fifo_read=((count_fifo_read==0)&Blank)?1:0;

//fifo read
always @(posedge vga_clk or negedge reset_n)					
begin
	if(!reset_n) begin
		fifo_q<=0;
		R_reg<=0;
		G_reg<=0;
		B_reg<=0;
	end
	else begin
		if(fifo_read==1) begin
			fifo_q<=q;
		end	else begin
			fifo_q<=fifo_q>>2;
		end
		R_reg<=fifo_q[1:0];
		G_reg<=fifo_q[1:0];
		B_reg<=fifo_q[1:0];
	end
end

//hsyc generate
always @(posedge vga_clk or negedge reset_n)					
begin
	if(!reset_n) begin
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
always @(posedge Hs_reg or negedge reset_n)					
begin
	if(!reset_n) begin
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
assign Blank=~(Blank_H | Blank_V);		//blank out
assign R=Blank?R_reg:0;					//r out
assign G=Blank?G_reg:0;					//g out
assign B=Blank?B_reg:0;					//b out
endmodule

