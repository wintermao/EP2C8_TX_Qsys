/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */
#include <stdio.h>
#include "sys/alt_timestamp.h"
#include "sys/alt_irq.h"
#include "sdram_master.h"
#include "system.h"
#include "io.h"
#include <unistd.h>

#define SDRAM_MASTER_INST_BASE SDRAM_MASTER_0_BASE
#define SDRAM_U1_BASE SDRAM_BASE+0x100000
//#define SDRAM_U2_BASE UART2_BASE+4
//#define SDRAM_U2_BASE ONCHIP_RAM_BASE
//#define SDRAM_U2_BASE SDRAM_BASE+0x200000
#define SDRAM_U2_BASE DMA_RECEIVE_0_BASE
#define LENGTH 0x10000

void DMA_interrupts(void* context);
int dma_flag=0;
int main()
{
    unsigned char i;
    int temp;
    alt_u32 t0,t1,dt,timestamp_freq;

    timestamp_freq=alt_timestamp_freq();

    IOWR(SDRAM_MASTER_INST_BASE,STATUS_ADDR,0);
    alt_ic_isr_register(SDRAM_MASTER_0_IRQ_INTERRUPT_CONTROLLER_ID,SDRAM_MASTER_0_IRQ,DMA_interrupts,NULL,NULL);
    for(i=0;i<100;i++)
        IOWR_8DIRECT(SDRAM_U1_BASE,i,i+1);
    
    IOWR(SDRAM_MASTER_INST_BASE,S_ADDR,SDRAM_U1_BASE);
    IOWR(SDRAM_MASTER_INST_BASE,D_ADDR,SDRAM_U2_BASE);
    IOWR(SDRAM_MASTER_INST_BASE,LONGTH,LENGTH);
    IOWR(SDRAM_MASTER_INST_BASE,CONTROL,2);
    //IOWR(SDRAM_MASTER_INST_BASE,START_ADDR,1);
    
    temp=IORD(SDRAM_MASTER_INST_BASE,S_ADDR);
    printf("S_ADDR:w,r==0x%x,0x%x\n",SDRAM_U1_BASE,temp);
    temp=IORD(SDRAM_MASTER_INST_BASE,D_ADDR);
    printf("D_ADDR:w,r==0x%x,0x%x\n",SDRAM_U2_BASE,temp);
    temp=IORD(SDRAM_MASTER_INST_BASE,LONGTH);
    printf("LONGTH:w,r==0x%x,0x%x\n",LENGTH,temp);
    alt_timestamp_start();
    //start dma
    t0 = alt_timestamp();
    IOWR(SDRAM_MASTER_INST_BASE,START_ADDR,1);
    /*
    while(IORD(SDRAM_MASTER_INST_BASE,STATUS_ADDR)!=1){
    printf("waiting...!\n");
    break;
    };
    */

    while(dma_flag==0)
    {

    };
    t1 = alt_timestamp();
    dt=t1-t0;
	dma_flag=0;
	printf("transmit time : t0=%ld t1=%ld dt=%ld time=%fs\n", t0,t1,dt,(double)dt/timestamp_freq);
	/*
	for(i=0;i<=LENGTH;i++){
	j=IORD_8DIRECT(SDRAM_U1_BASE,i);
	printf("SDRAM_U1:i,j == %d, %d\n",i,j);
    }

    for(i=0;i<=LENGTH;i++){
        j=IORD_8DIRECT(SDRAM_U2_BASE,i);
        printf("SDRAM_U2:i,j == %d, %d\n",i,j);
    }    
*/

  printf("Hello from Nios II!\n");

  return 0;
}

void DMA_interrupts(void* context)
{
	dma_flag=1;
	IOWR(SDRAM_MASTER_INST_BASE,STATUS_ADDR,0);
}
