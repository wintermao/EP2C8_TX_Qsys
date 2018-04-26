/*
 * vga_4bit.c
 *
 *  Created on: 2018-4-24
 *      Author: mmh
 */


#include "system.h"
#include "sys/alt_timestamp.h"          // Interval Timer
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "sys/alt_dma.h"
#include "io.h"

extern int time_1s;
static volatile int tx_done = 0;
alt_u32 *vga_buffer,*vga_display;
alt_u32 size_8,size_32;
alt_dma_txchan txchan;
unsigned int VGA_isr_context_ptr; // 定义全局变量以储存isr_context指针

void dma_start(alt_dma_txchan txchan,alt_u32 *s_addr,alt_u32 t_size);
//callback funtion
static void done (void* handle)
{
    tx_done++;
    //dma_start(txchan,vga_buffer,size_8);
}
void dma_start(alt_dma_txchan txchan,alt_u32 *s_addr,alt_u32 t_size)
{
    //IOWR(VGA_4BIT_0_BASE,1,0);
    alt_dma_txchan_send(txchan, s_addr,	 t_size, done, NULL);
}

void VGA_ISR(void* VGA_isr_context_ptr)
{
  // 应答中断，将STATUS寄存器清零
  IOWR(VGA_4BIT_0_BASE,1,0);
  dma_start(txchan,vga_buffer,size_8);
  // 用户中断代码
}

void vga_init()
{
	void* isr_context_ptr = (void*) &VGA_isr_context_ptr;
	alt_ic_isr_register(
			 VGA_4BIT_0_IRQ_INTERRUPT_CONTROLLER_ID, // 中断控制器标号，从system.h复制
			 VGA_4BIT_0_IRQ,     // 硬件中断号，从system.h复制
			 VGA_ISR,              // 中断服务子函数
			 isr_context_ptr,        // 指向与设备驱动实例相关的数据结构体
			 0x0);
	IOWR(VGA_4BIT_0_BASE,1,0);
}

int main()
{
	alt_u32 t0,t1,dt;
  alt_u32 i,timestamp_freq;
  int tx_done_last;

  tx_done_last=tx_done;
  vga_buffer=SDRAM_BASE+0x100000;
  vga_display=VGA_4BIT_0_BASE;
  size_8=800*600/2;
  size_32=size_8/4;
  Timer_Initial();
  timestamp_freq=alt_timestamp_freq();
  printf("system timestamp freq= %ld Hz\n", timestamp_freq);

	 //open transmit channel
	 if ((txchan = alt_dma_txchan_open("/dev/dma_0")) == NULL)
	 {
		 printf ("Failed to open transmit channel /dev/dma_0\n");
		 exit (1);
	 }
	 else
		 printf("open transmit channel /dev/dma_0 success\n");

	//start send
	alt_dma_txchan_ioctl(txchan,  ALT_DMA_SET_MODE_32, NULL);
	alt_dma_txchan_ioctl(txchan,  ALT_DMA_TX_ONLY_ON, vga_display);

	for(i=0;i<size_8;i++)
	{
		switch(((i+1)%400)/50)
		{
		case 0: *((alt_u8*)vga_buffer+i)=0x0;break;
		case 1: *((alt_u8*)vga_buffer+i)=0x11;break;
		case 2: *((alt_u8*)vga_buffer+i)=0x22;break;
		case 3: *((alt_u8*)vga_buffer+i)=0x33;break;
		case 4: *((alt_u8*)vga_buffer+i)=0x44;break;
		case 5: *((alt_u8*)vga_buffer+i)=0x55;break;
		case 6: *((alt_u8*)vga_buffer+i)=0x66;break;
		case 7: *((alt_u8*)vga_buffer+i)=0x77;break;
		default:break;
		}
	}

	//dma_start(txchan,vga_buffer,size_8);
	vga_init();
	while(1)
	{
		int j;
		if(time_1s==1)
		{
			time_1s=0;
			j++;
			printf("transtims is %4d\n",tx_done-tx_done_last);
			tx_done_last=tx_done;
		}

		switch(j%4)
		{
		case 0:color8((alt_u8*)vga_buffer);break;
		case 1:clr((alt_u8*)vga_buffer);break;
		//case 2:gray4((alt_u8*)vga_buffer);break;
		case 2:line(10,10,600,400,(alt_u8*)vga_buffer);break;
		case 3:clr((alt_u8*)vga_buffer);break;
		default:break;
		}

	}

	alt_dma_txchan_close(txchan);
	return 0;
}
