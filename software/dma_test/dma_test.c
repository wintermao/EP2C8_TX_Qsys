/*
 * dma_test.c
 *
 *  Created on: 2018-2-4
 *      Author: mmh
 */


#include "system.h"
#include "sys/alt_timestamp.h"          // Interval Timer
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "sys/alt_dma.h"

#define CHAR_LENGTH    1024

static volatile int tx_done = 0;
volatile static alt_u8 chr[CHAR_LENGTH];
//callback funtion
static void done (void* handle)
{
    tx_done++;
}

int main()
{
  alt_u32 t0,t1,dt;
  alt_u32 i,timestamp_freq;
  alt_u32 *ddr_dword1,*ddr_dword2;
  alt_u32 offset_source,offset_dest,base_source,base_dest,size_byte;
  //创建DMA信道
  alt_dma_txchan txchan;
  alt_dma_rxchan rxchan;
  //DDR2_BASE
  base_source=SDRAM_BASE;
  base_dest=ONCHIP_RAM_BASE;
  //base_dest=SDRAM_BASE;
  offset_source=0x100000;
  offset_dest=0x00000;
  //offset_dest=0x200000;
  size_byte=0x1000;

  ddr_dword1=base_source+offset_source;
  ddr_dword2=base_dest+offset_dest;
	for(i=0;i<size_byte/4;i++)		//generate data,size is 1M byte
	{
	  *ddr_dword1=i;
	  ddr_dword1++;
	  *ddr_dword2=0;
	  ddr_dword2++;
	}
  timestamp_freq=alt_timestamp_freq();
  printf("system freq= %ld Hz\n", timestamp_freq);
  alt_timestamp_start();

	 //-----------------------------------------------------------
	 //打开发送通道
	 if ((txchan = alt_dma_txchan_open(DMA_0_NAME)) == NULL)
	 {
		 printf ("Failed to open transmit channel %s\n",DMA_0_NAME);
		 exit (1);
	 }
	 else
		 printf("open send success,can transmit size=0x%x\n",alt_dma_txchan_space(txchan));
	 //打开接收通道
	if ((rxchan = alt_dma_rxchan_open(DMA_0_NAME)) == NULL)
	{
	  printf ("Failed to open receive channel %s\n",DMA_0_NAME);
	  exit (1);
	}
	else
	  printf("open receive success,can receive depth=0x%x\n",alt_dma_rxchan_depth(rxchan));
	//start send
     ddr_dword1=base_source+offset_source;
     //alt_dma_txchan_ioctl(txchan, ALT_DMA_TX_STREAM_ON|ALT_DMA_SET_MODE_16, NULL);
     //alt_dma_rxchan_ioctl(rxchan, ALT_DMA_RX_STREAM_ON|ALT_DMA_SET_MODE_16, NULL);
     printf("transmit size=0x%x\n",alt_dma_txchan_space(txchan));
     if (alt_dma_txchan_send(    txchan,
    		 	 	 	 	 	 ddr_dword1,
    		 	 	 	 	 	 size_byte,
                                 NULL,
                                 NULL) < 0)
     {
         printf ("Failed to post transmit request.\n");
         exit (1);
     }
     else
     {
    	 //t0 = alt_timestamp();
    	 printf("start send.\n");
     }
     //start receive
     ddr_dword2=base_dest+offset_dest;
     if (alt_dma_rxchan_prepare( rxchan,
    		 	 	 	 	 	 ddr_dword2,
    		 	 	 	 	 	 size_byte,
    		 	 	 	 	 	 done,
                                 NULL) < 0)
     {
         printf ("Failed to post receive request.\n");
         exit (1);
     }
     else
     {
    	 t0 = alt_timestamp();
    	 printf("start receive.\n");
     }
     //-----------------------------------------------------------
     /* waiting transmit over */
     while (!tx_done);
     t1 = alt_timestamp();
     printf ("Transfer successful!\n");
     dt=t1-t0;
     printf("dma dword transmit: t0=%ld t1=%ld dt=%ld time=%fs\n", t0,t1,dt,(double)dt/timestamp_freq);
     //-----------------------------------------------------------
     ddr_dword2=base_dest+offset_dest;
     for(i=0;i<size_byte/4;i++)		//generate data,size is 1M byte
     {
    	 if( *ddr_dword2 ==i) ddr_dword2++;
    	 else break;
     }
     if(i==size_byte/4) printf("data verify ok\n");
     else printf("data verify fail,error locate=0x%x\n",i);
     //close dma channel
     alt_dma_txchan_close(txchan);
     alt_dma_rxchan_close(rxchan);

     return 0;

}
