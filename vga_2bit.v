`define BRIGHTNESS 	3					//����8������������
`define BLACK		0					//�����ɫ���ȼ���
`define HDisplay	800				//������Ч��ʾ���
`define VDisplay	600					//������Ч��ʾ�߶�
`define HTotal		1056				//����HTotal
`define VTotal		628					//����VTotal
`define HSYNC_WITH	128					//��ͬ�����
`define HSYNC_FRONT	40					//��ͬ��ǰ��
`define HSYNC_BACK	88					//��ͬ�����
`define VSYNC_WITH	4					//��ͬ�����
`define VSYNC_FRONT	1					//��ͬ��ǰ��
`define VSYNC_BACK	23					//��ͬ�����

module vga_2bit(clock,reset_n,Hs,Vs,Blank,R,G,B,SEL);	//����ģ��ṹ
				
	input clock,SEL;						//��������ʱ������
	input reset_n;
	output Hs,Vs,Blank;
	output [1:0] R,G,B;
	
	reg [36:0] count;					//����������Ĵ���
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
		Blank_V<=0;
	end
	else begin
		count_v<=count_v+1'h1;			//vertical counter
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
		if(Patten==0)	begin				//Patten 0,4���ҽ�
			if(count_h<`HDisplay/4) begin
				R_reg<=2'h0;
				G_reg<=2'h0;
				B_reg<=2'h0;
			end	else if(count_h<`HDisplay/2) begin
				R_reg<=2'h1;
				G_reg<=2'h1;
				B_reg<=2'h1;
			end	else if(count_h<`HDisplay/4*3) begin
				R_reg<=2'h2;
				G_reg<=2'h2;
				B_reg<=2'h2;
			end else begin
				R_reg<=2'h3;
				G_reg<=2'h3;
				B_reg<=2'h3;
			end
		end	else if(Patten==1) begin				//Patten 1,�쳡
			R_reg<=`BRIGHTNESS;
			G_reg<=0;
			B_reg<=0;
		end	else if(Patten==2) begin					//Patten 2,�׳�
			R_reg<=`BRIGHTNESS;
			G_reg<=`BRIGHTNESS;
			B_reg<=`BRIGHTNESS;
		end	else if(Patten==3) begin					//Patten 3,8������
			if(count_h<`HDisplay/8)	begin						//��ɫ
				R_reg<=`BRIGHTNESS;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h<`HDisplay/8*2)	begin		//��ɫ
				R_reg<=`BRIGHTNESS;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BLACK;
			end	else if(count_h<`HDisplay/8*3)	begin		//��ɫ
				R_reg<=`BLACK;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h<`HDisplay/8*4)	begin		//��ɫ
				R_reg<=`BLACK;
				G_reg<=`BRIGHTNESS;
				B_reg<=`BLACK;
			end	else if(count_h<`HDisplay/8*5)	begin		//��ɫ
				R_reg<=`BRIGHTNESS;
				G_reg<=`BLACK;
				B_reg<=`BRIGHTNESS;
			end	else if(count_h<`HDisplay/8*6)	begin		//��ɫ
				R_reg<=`BRIGHTNESS;
				G_reg<=`BLACK;
				B_reg<=`BLACK;
			end	else if(count_h<`HDisplay/8*7)	begin		//��ɫ
				R_reg<=`BLACK;
				G_reg<=`BLACK;
				B_reg<=`BRIGHTNESS;
			end	else begin
				R_reg<=`BLACK;
				G_reg<=`BLACK;
				B_reg<=`BLACK;
			end
		end		
	end
end

assign Hs=~Hs_reg;						//�����ͬ��
assign Vs=~Vs_reg;						//�����ͬ��
assign Blank=~(Blank_H | Blank_V);		//���ʹ���ź�
assign R=Blank?R_reg:0;					//���R����
assign G=Blank?G_reg:0;					//���G����
assign B=Blank?B_reg:0;					//���B����
endmodule

