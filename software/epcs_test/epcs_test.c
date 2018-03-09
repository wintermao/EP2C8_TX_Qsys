/*
 * epcs_test.c
 *
 *  Created on: 2018-2-4
 *      Author: mmh
 */

 #include "system.h"
 #include <stdio.h>
 #include "alt_types.h"
 #include "sys/alt_flash.h"
 #include "sys/alt_flash_dev.h"
 #define test_size 32


void epcs()

{
 int i;
 unsigned char  epcsbuf[test_size];
 int ret_code;
 alt_flash_fd*  my_epcs;//������
 int offset;
 my_epcs = alt_flash_open_dev("/dev/epcs_flash");//��FLASH��������ȡ���
 if(my_epcs==NULL) printf("open %s failed!\n",EPCS_FLASH_NAME);

 ret_code = alt_epcs_flash_get_info (my_epcs, my_epcs->region_info,my_epcs->number_of_regions);//��ȡ����оƬ��Ϣ
 if(ret_code==0) printf("get epcs flash info error!\n");
 printf("offset=%d\n",my_epcs->region_info[0].offset);
 printf("size=%d\n",my_epcs->region_info[0].region_size);
 printf("numberOfBlock=%d\n",my_epcs->region_info[0].number_of_blocks);
 printf("blockSize=%d\n",my_epcs->region_info[0].block_size);

 offset=(my_epcs->region_info[0].number_of_blocks-1) * my_epcs->region_info[0].block_size;//ָ�����һ��block
 ret_code = alt_epcs_flash_read(my_epcs, my_epcs->region_info->offset+offset, epcsbuf, test_size); //��test_size�ֽ�

 printf("read epcs: ");
  for(i=0;i<test_size;i++)
  {
   printf("%02x ",epcsbuf[i]);
  }
  printf("\nafter erase:\n");
  ret_code = alt_epcs_flash_erase_block(my_epcs,my_epcs->region_info->offset+offset);//������8��
  ret_code = alt_epcs_flash_read(my_epcs, my_epcs->region_info->offset+offset, epcsbuf, test_size); //��test_size�ֽ�
  printf("read epcs: ");
	for(i=0;i<test_size;i++)
	{
	 printf("%02x ",epcsbuf[i]);
	}
  printf("\nwrite epcs:\n");
  for(i=0;i<test_size;i++)
   epcsbuf[i]=i;
 ret_code = alt_epcs_flash_write(my_epcs, my_epcs->region_info->offset+offset, epcsbuf, test_size); //дtest_size�ֽ�
 ret_code = alt_epcs_flash_read(my_epcs, my_epcs->region_info->offset+offset, epcsbuf, test_size); //��test_size�ֽ�
 printf("read epcs: ");
	for(i=0;i<test_size;i++)
	{
	 printf("%02x ",epcsbuf[i]);
	}
  printf("\n");
}

int main()
{
	epcs();
	return 0;
}
