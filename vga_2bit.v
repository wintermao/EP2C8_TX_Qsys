`define BRIGHTNESS 	3					//定义8级彩条的亮度
`define BLACK		0					//定义黑色亮度级别
//`define HDisplay	800				//定义有效显示宽度
//`define VDisplay	600					//定义有效显示高度
//`define HTotal		1056				//定义HTotal
//`define VTotal		628					//定义VTotal
//`define HSYNC_WITH	128					//行同步宽度

`define HDisplay	80				//定义有效显示宽度
`define VDisplay	60					//定义有效显示高度
`define HTotal		104				//定义HTotal
`define VTotal		88					//定义VTotal
`define HSYNC_WITH	12					//行同步宽度

`define HSYNC_FRONT	4					//行同步前肩
`define HSYNC_BACK	8					//行同步后肩
`define VSYNC_WITH	4					//场同步宽度
`define VSYNC_FRONT	1					//场同步前肩
`define VSYNC_BACK	23					//场同步后肩

module vga_2bit(clock,reset_n,Hs,Vs,Blank,R,G,B,SEL);	//定义模块结构
				
	input clock,SEL;						//定义输入时钟引脚
	input reset_n;
	output Hs,Vs,Blank;
	output [1:0] R,G,B;
	
	reg Hs_reg,Vs_reg;
	reg [1:0] R_reg,G_reg,B_reg;
	reg [15:0] count_h,count_v;
	reg [1:0] Patten;
	reg Blank_H,Blank_V;

//patten select
always @(posedge SEL or negedge reset_n)
begin
	if(!reset_n) begin
		Patten<=0;
	end	else begin
		Patten<=Patten+1;
	end
end

//hsyc generate
always @(posedge clock or negedge reset_n)					
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

always @(posedge clock or negedge reset_n)
begin
	if(!reset_n) begin
		R_reg<=0;
		G_reg<=0;
		B_reg<=0;
	end	
	else if(count_h<=`HDisplay-1) begin
		if(Patten==0)	begin				//Patten 0,4 level gry
			if(count_h==`HDisplay-1) begin
				R_reg<=2'h0;
				G_reg<=2'h0;
				B_reg<=2'h0;
			end	else if(count_h==`HDisplay/4-1) begin
				R_reg<=2'h1;
				G_reg<=2'h1;
				B_reg<=2'h1;
			end	else if(count_h==`HDisplay/4*2-1) begin
				R_reg<=2'h2;
				G_reg<=2'h2;
				B_reg<=2'h2;
			end else if(count_h==`HDisplay/4*3-1) begin
				R_reg<=2'h3;
				G_reg<=2'h3;
				B_reg<=2'h3;
			end
		end	else if(Patten==1) begin				//Patten 1,red
			R_reg<=`BRIGHTNESS;
			G_reg<=0;
			B_reg<=0;
		end	else if(Patten==2) begin					//Patten 2,white
			R_reg<=`BRIGHTNESS;
			G_reg<=`BRIGHTNESS;
			B_reg<=`BRIGHTNESS;
		end	else if(Patten==3) begin					//Patten 3,8 color bar
			if(count_h==`HDisplay-1)	begin						//white
				R_reg<=`BRIGHTNESS;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h==`HDisplay/8-1)	begin		//yellow
				R_reg<=`BRIGHTNESS;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BLACK;
			end	else if(count_h==`HDisplay/8*2-1)	begin		//青色
				R_reg<=`BLACK;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h==`HDisplay/8*3-1)	begin		//green
				R_reg<=`BLACK;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BLACK;
			end	else if(count_h==`HDisplay/8*4-1)	begin		//粉色
				R_reg<=`BRIGHTNESS;
				G_reg<=`BLACK;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h==`HDisplay/8*5-1)	begin		//red
				R_reg<=`BRIGHTNESS;
				G_reg<=`BLACK;
				B_reg<=`BLACK;
			end	else if(count_h==`HDisplay/8*6-1)	begin		//blue
				R_reg<=`BLACK;
				G_reg<=`BLACK;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h==`HDisplay/8*7-1)	begin		//black
				R_reg<=`BLACK;
				G_reg<=`BLACK;
				B_reg<=`BLACK;
			end
		end		
	end else begin
		R_reg<=R_reg;
		G_reg<=R_reg;
		B_reg<=R_reg;
	end
end

assign Hs=~Hs_reg;						//hsync out
assign Vs=~Vs_reg;						//vsync out
assign Blank=~(Blank_H | Blank_V);		//blank out
assign R=Blank?R_reg:0;					//r out
assign G=Blank?G_reg:0;					//g out
assign B=Blank?B_reg:0;					//b out
endmodule

