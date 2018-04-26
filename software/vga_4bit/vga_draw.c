#include "alt_types.h"

int size=800*600/2;

void color8(alt_u8 *vga_buffer)
{
	int i;
	for(i=0;i<size;i++)
	{
		switch(((i+1)%400)/50)
		{
		case 0: *(vga_buffer+i)=0x0;break;
		case 1: *(vga_buffer+i)=0x11;break;
		case 2: *(vga_buffer+i)=0x22;break;
		case 3: *(vga_buffer+i)=0x33;break;
		case 4: *(vga_buffer+i)=0x44;break;
		case 5: *(vga_buffer+i)=0x55;break;
		case 6: *(vga_buffer+i)=0x66;break;
		case 7: *(vga_buffer+i)=0x77;break;
		default:break;
		}
	}
}
void gray4(alt_u8 *vga_buffer)
{
	int i;
	for(i=0;i<size;i++)
	{
		switch(((i+1)%400)/100)
		{
		case 0: *(vga_buffer+i)=0x88;break;
		case 1: *(vga_buffer+i)=0x99;break;
		case 2: *(vga_buffer+i)=0xaa;break;
		case 3: *(vga_buffer+i)=0xbb;break;
		default:break;
		}
	}
}
void clr(alt_u8 *vga_buffer)
{
	int i;
	for(i=0;i<size;i++) *(vga_buffer+i)=0x0;
}

void line(int x,int y,int xx,int yy,alt_u8 *vga_buffer)
{
	float k;
	int dx,dy,x0,x1,y0,y1,fx,fy,i;
	if(x>=xx) {x0=xx;x1=x;}
	else {x0=x;x1=xx;}
	if(y>=yy) {y0=yy;y1=y;}
	else {y0=y;y1=yy;}
	dx=x1-x0;
	dy=y1-y0;
	k=(y1-y0)/(x1-x0);
	for(i=0;i<dx;i++)
	{
		fx=x0+i;
		fy=y0+k*i;
		if(fx & 1) *(vga_buffer+(fx-1+fy*800)/2)=*(vga_buffer+(fx-1+fy*800)/2) | 0xb0;
		else *(vga_buffer+(fx+fy*800)/2)=*(vga_buffer+(fx-1+fy*800)/2) | 0x0b;
	}
}

