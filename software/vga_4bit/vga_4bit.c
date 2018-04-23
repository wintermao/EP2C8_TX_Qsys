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

static volatile int tx_done = 0;
alt_u32 *vga_buffer,*vga_display;
alt_u32 size_8,size_32;
alt_dma_txchan txchan;

//callback funtion
static void done (void* handle)
{
    tx_done=1;
    dma_start(txchan,vga_buffer,size_8);
}
void dma_start(alt_dma_txchan txchan,alt_u32 *s_addr,alt_u32 t_size)
{
	alt_dma_txchan_send(txchan, s_addr,	 t_size, done, NULL);
}
int main()
{
	alt_u32 t0,t1,dt;
  alt_u32 i,timestamp_freq;

  vga_buffer=SDRAM_BASE+0x1000000;
  vga_display=VGA_4BIT_BASE;
  size_8=800*600/2;
  size_32=size_8/4;

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
	dma_start(txchan,vga_buffer,size_8);
	for(i=0;i<size_8;i++)
	{
		*((alt_u8*)vga_buffer+i)=0x11;
		//*((alt_u8*)vga_buffer+i)=0x22;
		//*((alt_u8*)vga_buffer+i)=0x44;
		//*((alt_u8*)vga_buffer+i)=0x77;
		
	}
	while(1)
	{

	}
  alt_dma_txchan_close(txchan);
	return 0;
}
