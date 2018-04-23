// vga_4bit.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ns / 1 ns
module vga_4bit (
		//avalon interface
		input  wire clk,                // clock.clk
		input  wire reset_n,            // reset.reset
		input  wire avs_s0_chipselect,	//			 .chipselect
		input  wire avs_s0_write,       //      .write
		input  wire [31:0] avs_s0_writedata,   //      .writedata
		output wire avs_s0_waitrequest, //      .waitrequest
		//vga interface
		input wire	vga_clk,						//vga clock
		output wire Hs,
		output wire Vs,
		output wire [1:0] R,
		output wire [1:0] G,
		output wire [1:0] B
	);

	reg fifo_write;
	reg [31:0] fifo_writedata;
	wire fifo_writefull;
	wire fifo_read;
	wire [3:0] fifo_readdata;
	wire fifo_readempty;
	wire reset;
	
	always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
		begin
			fifo_write <= 1'h0;
			fifo_writedata <= 32'h0;
		end
		else
		begin
			if(avs_s0_chipselect && avs_s0_write)	begin					//new data
				fifo_writedata <= avs_s0_writedata;
				fifo_write <= 1'h1;															//start write
			end	else begin
				fifo_writedata <= fifo_writedata;
				if(avs_s0_waitrequest==1'h0) fifo_write <= 1'h0;	//wait waitrequest invalid
				else fifo_write <= fifo_write;
			end
		end
	end
	assign avs_s0_waitrequest = fifo_writefull;
	assign reset = !reset_n;

	
//initial dcfifo parameter
	dcfifo	dcfifo_component (
				.wrclk (clk),
				.rdreq (fifo_read),
				.aclr (reset),
				.rdclk (vga_clk),
				.wrreq (fifo_write),
				.data (fifo_writedata),
				.rdempty (),
				.wrusedw (),
				.wrfull (fifo_writefull),
				.q (fifo_readdata)
				// synopsys translate_off
				,
				.rdfull (),
				.rdusedw (),
				.wrempty ()
				// synopsys translate_on
				);
	defparam
		dcfifo_component.intended_device_family = "Cyclone IV",
		dcfifo_component.lpm_numwords = 2048,
		dcfifo_component.lpm_showahead = "ON",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = 32,
		dcfifo_component.lpm_width_r = 4,
		dcfifo_component.lpm_widthu = 11,
		dcfifo_component.lpm_widthu_r = 4,
		dcfifo_component.overflow_checking = "ON",
		dcfifo_component.rdsync_delaypipe = 3,
		dcfifo_component.underflow_checking = "ON",
		dcfifo_component.use_eab = "ON",
		dcfifo_component.wrsync_delaypipe = 3;
		
	vga_4bit_graph vga_4bit_graph_component(
		.vga_clk (vga_clk),
		.reset (reset),
		.fifo_read (fifo_read),
		.fifo_readdata (fifo_readdata),
		.Hs (Hs),
		.Vs (Vs),
		.R (R),
		.G (G),
		.B (B)
	);
		
endmodule
