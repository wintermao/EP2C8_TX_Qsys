//------------------------------------------------
//   spi master testbench
//   2018.3.14
//   create by mmh
//------------------------------------------------

 `timescale 1ns/1ns
 
  `define delay 10
  `define addr_rx 			3'h0
  `define addr_tx 			3'h1
  `define addr_status 	3'h2
  `define addr_control	3'h3
  `define addr_divide 	3'h4
  `define addr_chipsel 	3'h5
 
 module vga_2bit_tb;
  
 vga_2bit tb(clock,reset_n,Hs,Vs,Blank,R,G,B,SEL);

	reg clock,SEL;						//定义输入时钟引脚
	reg reset_n;
	wire Hs,Vs,Blank;
	wire [1:0] R,G,B;

	// Generates serial clock of time period 10
 initial                         
   begin
     clk = 0;
     forever #5 clk = !clk;
   end
   
 initial                         
   begin
     reset_n = 1;
     #5
     reset_n = 0;
     #5
     reset_n = 1;
   end


 endmodule

 /*************************************** END OF TB ***********************************************************************/