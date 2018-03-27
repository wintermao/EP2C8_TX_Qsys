//------------------------------------------------
//   spi master testbench
//   2018.3.14
//   create by mmh
//------------------------------------------------

 `timescale 1ns/1ns
 `define delay 12.5
 
 module vga_2bit_tb;
 	reg clk,SEL;						//定义输入时钟引脚
	reg reset_n;
	wire Hs,Vs,Blank;
	wire [1:0] R,G,B; 
 vga_2bit tb(clk,reset_n,Hs,Vs,Blank,R,G,B,SEL);



	// Generates serial clock of time period 10
 initial                         
   begin
     clk = 0;
     forever #`delay clk = !clk;
   end
   
 initial                         
   begin
     reset_n = 1;
     #`delay
     reset_n = 0;
     #`delay
     reset_n = 1;
     
     #`delay
     SEL = 0;
     #`delay
     SEL = 1;
     #`delay
     SEL = 0;
     #`delay
     SEL = 1;     
     #`delay
     SEL = 0;
     #`delay
     SEL = 1;
   end


 endmodule

 /*************************************** END OF TB ***********************************************************************/