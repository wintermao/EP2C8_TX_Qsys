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
#define UART_NAME UART2_NAME

static volatile int tx_done = 0;
volatile static alt_u8 chr[CHAR_LENGTH];
//callback funtion
static void done (void* handle)
{
    tx_done++;
}

int main()
{
  FILE *fp;
  alt_u32 t0,t1,dt;
  alt_u32 i,timestamp_freq;
  alt_u32 *ddr_dword1,*ddr_dword2;
  alt_u32 offset_source,offset_dest,base_source,base_dest,size_byte;
  //创建DMA信道
  alt_dma_txchan txchan;
  alt_dma_rxchan rxchan;
  //DDR2_BASE
  base_source=SDRAM_BASE;
  base_dest=DMA_0_WRITE_MASTER_DMA_RECEIVE_0_BASE;
  //base_dest=UART1_BASE+2;
  offset_source=0x100000;
  size_byte=0x1000;
  if((fp=fopen(UART_NAME,"w"))==NULL)
  {
	  printf("open %s fail!\n",UART_NAME);
	  exit(1);
  }
  else fprintf(fp,"open %s success\r\n",UART_NAME);

  ddr_dword1=base_source+offset_source;
	for(i=0;i<size_byte/4;i++)		//generate data,size is 1M byte
	{
	  *ddr_dword1=i;
	  ddr_dword1++;
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

	//start send
     ddr_dword1=base_source+offset_source;
     alt_dma_txchan_ioctl(txchan,  ALT_DMA_SET_MODE_16, NULL);
     alt_dma_txchan_ioctl(txchan,  ALT_DMA_TX_ONLY_ON, base_dest);
     if (alt_dma_txchan_send(    txchan,
    		 	 	 	 	 	 ddr_dword1,
    		 	 	 	 	 	 size_byte,
    		 	 	 	 	 	 done,
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
     //-----------------------------------------------------------
     /* waiting transmit over */
     while (!tx_done);
     t1 = alt_timestamp();
     printf ("Transfer successful!\n");
     dt=t1-t0;
     printf("dma dword transmit: t0=%ld t1=%ld dt=%ld time=%fs\n", t0,t1,dt,(double)dt/timestamp_freq);
     //-----------------------------------------------------------
     //close dma channel
     alt_dma_txchan_close(txchan);
     fclose(fp);
     return 0;

}
