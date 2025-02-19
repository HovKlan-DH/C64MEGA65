## Commodore 64 for MEGA65 (C64MEGA65)
##
## MEGA65 port done by MJoergen and sy2002 in 2023 and licensed under GPL v3

################################
## TIMING CONSTRAINTS
################################

## System board clock (100 MHz)
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports CLK]
create_clock -period 10.000 -name CLK [get_ports CLK]

## Name Autogenerated Clocks
create_generated_clock -name qnice_clk     [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT0]
create_generated_clock -name hr_clk_x1     [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT1]
create_generated_clock -name hr_clk_x2     [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT2]
create_generated_clock -name hr_clk_x2_del [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT3]
create_generated_clock -name audio_clk     [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT4]
create_generated_clock -name tmds_720p_clk [get_pins M2M/i_framework/i_clk_m2m/i_clk_hdmi_720p/CLKOUT0]
create_generated_clock -name hdmi_720p_clk [get_pins M2M/i_framework/i_clk_m2m/i_clk_hdmi_720p/CLKOUT1]
create_generated_clock -name tmds_576p_clk [get_pins M2M/i_framework/i_clk_m2m/i_clk_hdmi_576p/CLKOUT0]
create_generated_clock -name hdmi_576p_clk [get_pins M2M/i_framework/i_clk_m2m/i_clk_hdmi_576p/CLKOUT1]
create_generated_clock -name main_clk_0    [get_pins M2M/CORE/clk_gen/i_clk_c64/CLKOUT0] -master_clock [get_clocks CLK]
create_generated_clock -name main_clk_1    [get_pins M2M/CORE/clk_gen/i_clk_c64/CLKOUT0] -master_clock [get_clocks sys_clk_9975_mmcm]

## Clock divider sdcard_clk that creates the 25 MHz used by sd_spi.vhd
create_generated_clock -name sdcard_clk -source [get_pins M2M/i_framework/i_clk_m2m/i_clk_qnice/CLKOUT0] -divide_by 2 [get_pins M2M/i_framework/QNICE_SOC/sd_card/Slow_Clock_25MHz_reg/Q]

## Handle CDC of audio data
set_max_delay 8 -datapath_only -from [get_clocks] -to [get_pins -hierarchical "*audio_cdc_gen.dst_*_d_reg[*]/D"]

## QNICE's EAE combinatorial division networks take longer than the regular clock period, so we specify a multicycle path
## see also the comments in EAE.vhd and explanations in UG903/chapter 5/Multicycle Paths as well as ug911/page 25
set_multicycle_path -from [get_cells -include_replicated {{M2M/i_framework/QNICE_SOC/eae_inst/op0_reg[*]} {M2M/i_framework/QNICE_SOC/eae_inst/op1_reg[*]}}] \
   -to [get_cells -include_replicated {M2M/i_framework/QNICE_SOC/eae_inst/res_reg[*]}] -setup 3
set_multicycle_path -from [get_cells -include_replicated {{M2M/i_framework/QNICE_SOC/eae_inst/op0_reg[*]} {M2M/i_framework/QNICE_SOC/eae_inst/op1_reg[*]}}] \
   -to [get_cells -include_replicated {M2M/i_framework/QNICE_SOC/eae_inst/res_reg[*]}] -hold 2

# Timing between the two system clocks, ascal.vhd, audio, HDMI and HyperRAM is asynchronous.
set_false_path -from [get_clocks hr_clk_x1]       -to [get_clocks hdmi_720p_clk]
set_false_path   -to [get_clocks hr_clk_x1]     -from [get_clocks hdmi_720p_clk]
set_false_path -from [get_clocks hr_clk_x1]       -to [get_clocks hdmi_576p_clk]
set_false_path   -to [get_clocks hr_clk_x1]     -from [get_clocks hdmi_576p_clk]
set_false_path -from [get_clocks hr_clk_x1]       -to [get_clocks main_clk_0]
set_false_path   -to [get_clocks hr_clk_x1]     -from [get_clocks main_clk_0]
set_false_path -from [get_clocks hdmi_720p_clk]   -to [get_clocks main_clk_0]
set_false_path   -to [get_clocks hdmi_720p_clk] -from [get_clocks main_clk_0]
set_false_path -from [get_clocks hdmi_576p_clk]   -to [get_clocks main_clk_0]
set_false_path   -to [get_clocks hdmi_576p_clk] -from [get_clocks main_clk_0]
set_false_path -from [get_clocks hr_clk_x1]       -to [get_clocks main_clk_1]
set_false_path   -to [get_clocks hr_clk_x1]     -from [get_clocks main_clk_1]
set_false_path -from [get_clocks hdmi_720p_clk]   -to [get_clocks main_clk_1]
set_false_path   -to [get_clocks hdmi_720p_clk] -from [get_clocks main_clk_1]
set_false_path -from [get_clocks hdmi_576p_clk]   -to [get_clocks main_clk_1]
set_false_path   -to [get_clocks hdmi_576p_clk] -from [get_clocks main_clk_1]
set_false_path -from [get_clocks qnice_clk]       -to [get_clocks main_clk_0]
set_false_path -from [get_clocks qnice_clk]       -to [get_clocks main_clk_1]
set_false_path -from [get_clocks qnice_clk]       -to [get_clocks hdmi_720p_clk]
set_false_path -from [get_clocks qnice_clk]       -to [get_clocks hdmi_576p_clk]

set_false_path -from [get_clocks hdmi_720p_clk]   -to [get_clocks hdmi_576p_clk]
set_false_path   -to [get_clocks hdmi_720p_clk] -from [get_clocks hdmi_576p_clk]
set_false_path -from [get_clocks hdmi_720p_clk]   -to [get_clocks tmds_720p_clk]
set_false_path -from [get_clocks hdmi_720p_clk]   -to [get_clocks tmds_576p_clk]
set_false_path -from [get_clocks hdmi_576p_clk]   -to [get_clocks tmds_720p_clk]
set_false_path -from [get_clocks hdmi_576p_clk]   -to [get_clocks tmds_576p_clk]

set_false_path -from [get_clocks main_clk_0]      -to [get_clocks main_clk_1]
set_false_path -to   [get_clocks main_clk_0]    -from [get_clocks main_clk_1]

set_false_path -from [get_clocks main_clk_0]      -to [get_clocks audio_clk]
set_false_path -to   [get_clocks main_clk_0]    -from [get_clocks audio_clk] 
set_false_path -from [get_clocks main_clk_1]      -to [get_clocks audio_clk]
set_false_path -to   [get_clocks main_clk_1]    -from [get_clocks audio_clk] 

## CDC in IEC drives, handled manually in the source code
set_false_path -from [get_pins -hier id1_reg[*]/C]
set_false_path -from [get_pins -hier id2_reg[*]/C]
set_false_path -from [get_pins -hier busy_reg/C]
set_false_path -to   [get_pins M2M/CORE/i_main/i_iec_drive/c1541/drives[*].c1541_drv/c1541_track/reset_sync/s1_reg[*]/D]
set_false_path -to   [get_pins M2M/CORE/i_main/i_iec_drive/c1541/drives[*].c1541_drv/c1541_track/change_sync/s1_reg[*]/D]
set_false_path -to   [get_pins M2M/CORE/i_main/i_iec_drive/c1541/drives[*].c1541_drv/c1541_track/save_sync/s1_reg[*]/D]
set_false_path -to   [get_pins M2M/CORE/i_main/i_iec_drive/c1541/drives[*].c1541_drv/c1541_track/track_sync/s1_reg[*]/D]

## Disk type register that moves very slow (on each (re-)mount) and that is initialized with very stable signals 
set_false_path -from [get_pins M2M/CORE/i_main/i_iec_drive/dtype_reg[*][*]/C]
set_false_path -to   [get_pins M2M/CORE/i_main/i_iec_drive/dtype_reg[*][*]/D]

## The high level reset signals are slow enough so that we can afford a false path
set_false_path -from [get_pins M2M/i_framework/i_reset_manager/reset_m2m_n_o_reg/C]
set_false_path -from [get_pins M2M/i_framework/i_reset_manager/reset_core_n_o_reg/C]

################################
## PLACEMENT CONSTRAINTS
################################

# Place HyperRAM close to I/O pins
create_pblock pblock_i_hyperram
add_cells_to_pblock pblock_i_hyperram [get_cells [list M2M/i_framework/i_hyperram]]
resize_pblock pblock_i_hyperram -add {SLICE_X0Y200:SLICE_X7Y224}

# Place MAX10 close to I/O pins
create_pblock pblock_MAX10
add_cells_to_pblock pblock_MAX10 [get_cells [list M2M/i_framework/MAX10]]
resize_pblock pblock_MAX10 -add {SLICE_X0Y150:SLICE_X7Y174}

# Place Keyboard close to I/O pins
create_pblock pblock_m65driver
add_cells_to_pblock pblock_m65driver [get_cells [list M2M/i_framework/i_m2m_keyb/m65driver]]
resize_pblock pblock_m65driver -add {SLICE_X0Y225:SLICE_X7Y243}

# Place SD card controller in the middle between the left and right FPGA boundary because the output ports are at the opposide edges
create_pblock pblock_sdcard
add_cells_to_pblock pblock_sdcard [get_cells [list M2M/i_framework/QNICE_SOC/sd_card]]
resize_pblock pblock_sdcard -add {SLICE_X67Y178:SLICE_X98Y193}

# Place phase-shifted VGA output registers near the actual output buffers
create_pblock pblock_vga
add_cells_to_pblock pblock_vga [get_cells [list M2M/i_framework/i_analog_pipeline/VGA_OUT_PHASE_SHIFTED.*]]
resize_pblock pblock_vga -add SLICE_X0Y75:SLICE_X5Y99

################################
## Pin to signal mapping
################################

## Interface to MAX10
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports max10_tx]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports max10_rx]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports max10_clkandsync]

## USB-RS232 Interface (rxd, txd only; rts/cts are not available)
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports UART_RXD]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports UART_TXD]

## MEGA65 smart keyboard controller
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports kb_io0]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports kb_io1]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports kb_io2]

## Micro SD Connector (this is the slot at the bottom side of the case under the cover)
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports SD_RESET]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports SD_CLK]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports SD_MOSI]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports SD_MISO]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports SD_CD]

## Micro SD Connector (external slot at back of the cover)
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports SD2_RESET]
set_property -dict {PACKAGE_PIN G2  IOSTANDARD LVCMOS33} [get_ports SD2_CLK]
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33} [get_ports SD2_MOSI]
set_property -dict {PACKAGE_PIN H2  IOSTANDARD LVCMOS33} [get_ports SD2_MISO]
set_property -dict {PACKAGE_PIN K1  IOSTANDARD LVCMOS33} [get_ports SD2_CD]

## Joystick port A
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports joy_1_up_n]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports joy_1_down_n]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports joy_1_left_n]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports joy_1_right_n]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports joy_1_fire_n]

## Joystick port B
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports joy_2_up_n]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports joy_2_down_n]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports joy_2_left_n]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports joy_2_right_n]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports joy_2_fire_n]

# Paddles
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports paddle[0]]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports paddle[1]]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports paddle[2]]
set_property -dict {PACKAGE_PIN J22 IOSTANDARD LVCMOS33} [get_ports paddle[3]]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports paddle_drain]

## PWM Audio
set_property -dict {PACKAGE_PIN L6  IOSTANDARD LVCMOS33} [get_ports pwm_l]
set_property -dict {PACKAGE_PIN F4  IOSTANDARD LVCMOS33} [get_ports pwm_r]

## VGA via VDAC
set_property -dict {PACKAGE_PIN U15  IOSTANDARD LVCMOS33} [get_ports {VGA_RED[0]}]
set_property -dict {PACKAGE_PIN V15  IOSTANDARD LVCMOS33} [get_ports {VGA_RED[1]}]
set_property -dict {PACKAGE_PIN T14  IOSTANDARD LVCMOS33} [get_ports {VGA_RED[2]}]
set_property -dict {PACKAGE_PIN Y17  IOSTANDARD LVCMOS33} [get_ports {VGA_RED[3]}]
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports {VGA_RED[4]}]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports {VGA_RED[5]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports {VGA_RED[6]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports {VGA_RED[7]}]

set_property -dict {PACKAGE_PIN Y14  IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[0]}]
set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[1]}]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[2]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[3]}]
set_property -dict {PACKAGE_PIN Y13  IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[4]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[5]}]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[6]}]
set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVCMOS33} [get_ports {VGA_GREEN[7]}]

set_property -dict {PACKAGE_PIN W10  IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[0]}]
set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[1]}]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[2]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[3]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[4]}]
set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[5]}]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[6]}]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33} [get_ports {VGA_BLUE[7]}]

set_property -dict {PACKAGE_PIN W12  IOSTANDARD LVCMOS33} [get_ports VGA_HS]
set_property -dict {PACKAGE_PIN V14  IOSTANDARD LVCMOS33} [get_ports VGA_VS]

set_property -dict {PACKAGE_PIN AA9  IOSTANDARD LVCMOS33} [get_ports vdac_clk]
set_property -dict {PACKAGE_PIN V10  IOSTANDARD LVCMOS33} [get_ports vdac_sync_n]
set_property -dict {PACKAGE_PIN W11  IOSTANDARD LVCMOS33} [get_ports vdac_blank_n]

# HDMI output
set_property -dict {PACKAGE_PIN Y1   IOSTANDARD TMDS_33}  [get_ports tmds_clk_n]
set_property -dict {PACKAGE_PIN W1   IOSTANDARD TMDS_33}  [get_ports tmds_clk_p]
set_property -dict {PACKAGE_PIN AB1  IOSTANDARD TMDS_33}  [get_ports {tmds_data_n[0]}]
set_property -dict {PACKAGE_PIN AA1  IOSTANDARD TMDS_33}  [get_ports {tmds_data_p[0]}]
set_property -dict {PACKAGE_PIN AB2  IOSTANDARD TMDS_33}  [get_ports {tmds_data_n[1]}]
set_property -dict {PACKAGE_PIN AB3  IOSTANDARD TMDS_33}  [get_ports {tmds_data_p[1]}]
set_property -dict {PACKAGE_PIN AB5  IOSTANDARD TMDS_33}  [get_ports {tmds_data_n[2]}]
set_property -dict {PACKAGE_PIN AA5  IOSTANDARD TMDS_33}  [get_ports {tmds_data_p[2]}]

## HyperRAM (standard)
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports hr_clk_p]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[0]}]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[1]}]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[2]}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[3]}]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[4]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[5]}]
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[6]}]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports {hr_d[7]}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33 PULLUP FALSE SLEW FAST DRIVE 16} [get_ports hr_rwds]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr_reset]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr_cs0]

## Additional HyperRAM on trap-door PMOD
## Pinout is for one of these: https://github.com/blackmesalabs/hyperram
#set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr2_clk_p]
#set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr2_clk_n]
#set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[0]}]
#set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[1]}]
#set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[2]}]
#set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[3]}]
#set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[4]}]
#set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[5]}]
#set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[6]}]
#set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports {hr2_d[7]}]
#set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr2_rwds]
#set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr2_reset]
#set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33 PULLUP FALSE} [get_ports hr_cs1]

## Configuration and Bitstream properties
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
