#Setup.tcl
# Setup pin setting

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

#SYSTEM
set_location_assignment PIN_18 -to clock
set_location_assignment PIN_53 -to sdram_clk
set_location_assignment PIN_67 -to reset_n

#I2C
set_location_assignment PIN_129 -to SDA_MASTER
set_location_assignment PIN_112 -to SCL_MASTER

#UART
set_location_assignment PIN_69 -to RXD_1
set_location_assignment PIN_70 -to TXD_1
set_location_assignment PIN_71 -to RXD_2
set_location_assignment PIN_72 -to TXD_2

#LED
set_location_assignment PIN_63 -to LED[0]
set_location_assignment PIN_51 -to LED[1]
set_location_assignment PIN_120 -to LED[2]
set_location_assignment PIN_132 -to LED[3]

#SDRAM CONTROL
#set_location_assignment PIN_189 -to sdram_cke
set_location_assignment PIN_122 -to sdram_ba[0]
set_location_assignment PIN_121 -to sdram_ba[1]
set_location_assignment PIN_134 -to sdram_dqm[0]
set_location_assignment PIN_52 -to sdram_dqm[1]
set_location_assignment PIN_126 -to sdram_cas_n
#set_location_assignment PIN_106 -to sdram_cs_n
set_location_assignment PIN_125 -to sdram_ras_n
set_location_assignment PIN_133 -to sdram_we_n

#SDRAM ADDRESS	
set_location_assignment PIN_118 -to sdram_addr\[0\]
set_location_assignment PIN_115 -to sdram_addr\[1\]
set_location_assignment PIN_114 -to sdram_addr\[2\]
set_location_assignment PIN_113 -to sdram_addr\[3\]
set_location_assignment PIN_65 -to sdram_addr\[4\]
set_location_assignment PIN_64 -to sdram_addr\[5\]
set_location_assignment PIN_60 -to sdram_addr\[6\]
set_location_assignment PIN_59 -to sdram_addr\[7\]
set_location_assignment PIN_58 -to sdram_addr\[8\]
set_location_assignment PIN_57 -to sdram_addr\[9\]
set_location_assignment PIN_119 -to sdram_addr\[10\]
set_location_assignment PIN_55 -to sdram_addr\[11\]

#SDRAM DATA
set_location_assignment PIN_144 -to sdram_dq[0]
set_location_assignment PIN_143 -to sdram_dq[1]
set_location_assignment PIN_142 -to sdram_dq[2]
set_location_assignment PIN_141 -to sdram_dq[3]
set_location_assignment PIN_139 -to sdram_dq[4]
set_location_assignment PIN_137 -to sdram_dq[5]
set_location_assignment PIN_136 -to sdram_dq[6]
set_location_assignment PIN_135 -to sdram_dq[7]
set_location_assignment PIN_48 -to sdram_dq[8]
set_location_assignment PIN_47 -to sdram_dq[9]
set_location_assignment PIN_45 -to sdram_dq[10]
set_location_assignment PIN_44 -to sdram_dq[11]
set_location_assignment PIN_43 -to sdram_dq[12]
set_location_assignment PIN_42 -to sdram_dq[13]
set_location_assignment PIN_41 -to sdram_dq[14]
set_location_assignment PIN_40 -to sdram_dq[15]

#LVDS IN
set_location_assignment PIN_89 -to RCLK
set_location_assignment PIN_74 -to RA
set_location_assignment PIN_76 -to RB
set_location_assignment PIN_81 -to RC
set_location_assignment PIN_87 -to RD
