----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- C64 for MEGA65
-- Global Constants
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.qnice_tools.all;
use work.video_modes_pkg.all;

package globals is

----------------------------------------------------------------------------------------------------------
-- QNICE Firmware
----------------------------------------------------------------------------------------------------------

-- QNICE Firmware: Use the regular QNICE "operating system" called "Monitor" while developing and
-- debugging the firmware/ROM itself. If you are using the M2M ROM (the "Shell") as provided by the
-- framework, then always use the release version of the M2M firmware: QNICE_FIRMWARE_M2M
--
-- Hint: You need to run QNICE/tools/make-toolchain.sh to obtain "monitor.rom" and
-- you need to run CORE/m2m-rom/make_rom.sh to obtain the .rom file
constant QNICE_FIRMWARE_MONITOR   : string  := "../../../QNICE/monitor/monitor.rom";    -- debug/development
constant QNICE_FIRMWARE_M2M       : string  := "../../../CORE/m2m-rom/m2m-rom.rom";   -- release

-- Select firmware here
constant QNICE_FIRMWARE           : string  := QNICE_FIRMWARE_M2M;

----------------------------------------------------------------------------------------------------------
-- Clock Speed(s)
--
-- Important: Make sure that you use very exact numbers - down to the actual Hertz - because some cores
-- rely on these exact numbers. By default M2M supports one core clock speed. In case you need more,
-- then add all the clocks speeds here by adding more constants.
----------------------------------------------------------------------------------------------------------

-- C64 core clock speeds
-- Make sure that you specify very exact values here, because these values will be used in counters
-- in main.vhd and in fpga64_sid_iec.vhd to avoid clock drift at derived clocks
constant CORE_CLK_SPEED_PAL   : natural := 31_527_778;   -- Will lead to a C64 clock of 985,243 Hz
constant CORE_CLK_SPEED_NTSC  : natural := 32_727_264;   -- @TODO: This is MiSTer's value; we will need to adjust it to ours

constant CORE_CLK_SPEED       : natural := CORE_CLK_SPEED_PAL;

-- System clock speed (crystal that is driving the FPGA) and QNICE clock speed
-- !!! Do not touch !!!
constant BOARD_CLK_SPEED      : natural := 100_000_000;
constant QNICE_CLK_SPEED      : natural := 50_000_000;   -- a change here has dependencies in qnice_globals.vhd

----------------------------------------------------------------------------------------------------------
-- Video Mode
----------------------------------------------------------------------------------------------------------

-- Rendering constants (in pixels)
--    VGA_*   size of the core's target output post scandoubler
--    FONT_*  size of one OSM character
-- A very detailed explanation/calculation for the rather "uncommon" 768x540 core output post scandoubler
-- can be found here: https://github.com/MJoergen/C64MEGA65/blob/V4/doc/graphics.md
-- If you read from the top to the bottom, then you will learn that after MiSTer crops the output,
-- we receive 384x270 pixels. Multiply by two and we have 768x540.
-- But we need to go for 720x540 so that in the 5:4 and 4:3 modes everything looks correctly.
constant VGA_DX               : natural := 720;
constant VGA_DY               : natural := 540;
--constant FONT_FILE            : string  := "../font/Anikki-16x16-m2m.rom";
constant FONT_FILE            : string  := "../font/Anikki-16x16-MegaBeauvais.rom";
constant FONT_DX              : natural := 16;
constant FONT_DY              : natural := 16;

-- Constants for the OSM screen memory
constant CHARS_DX             : natural := VGA_DX / FONT_DX;
constant CHARS_DY             : natural := VGA_DY / FONT_DY;
constant CHAR_MEM_SIZE        : natural := CHARS_DX * CHARS_DY;
constant VRAM_ADDR_WIDTH      : natural := f_log2(CHAR_MEM_SIZE);

----------------------------------------------------------------------------------------------------------
-- Commodore 64 specific devices
----------------------------------------------------------------------------------------------------------

constant C_DEV_C64_RAM        : std_logic_vector(15 downto 0) := x"0100";     -- C64's main RAM
constant C_DEV_C64_VDRIVES    : std_logic_vector(15 downto 0) := x"0101";     -- Virtual Device Management System
constant C_DEV_C64_MOUNT      : std_logic_vector(15 downto 0) := x"0102";     -- RAM to buffer disk images

----------------------------------------------------------------------------------------------------------
-- Virtual Drive Management System
----------------------------------------------------------------------------------------------------------

-- Virtual drive management system (handled by vdrives.vhd and the firmware)
-- If you are not using virtual drives, make sure that:
--    C_VDNUM        is 0
--    C_VD_DEVICE    is x"EEEE"
--    C_VD_BUFFER    is (x"EEEE", x"EEEE")
-- Otherwise make sure that you wire C_VD_DEVICE in the qnice_ramrom_devices process and that you
-- have as many appropriately sized RAM buffers for disk images as you have drives
type vd_buf_array is array(natural range <>) of std_logic_vector;
constant C_VDNUM              : natural := 1;                                          -- amount of virtual drives; if more than 5: also adjust VDRIVES_MAX in M2M/rom/shell_vars.asm, maximum is 15
constant C_VD_DEVICE          : std_logic_vector(15 downto 0) := C_DEV_C64_VDRIVES;    -- device number of vdrives.vhd device
constant C_VD_BUFFER          : vd_buf_array := (  C_DEV_C64_MOUNT,
                                                   x"EEEE");                           -- Always finish the array using x"EEEE"

----------------------------------------------------------------------------------------------------------
-- Audio filters
--
-- If you use audio filters, then you need to copy the correct values from the MiSTer core
-- that you are porting: sys/sys_top.v
----------------------------------------------------------------------------------------------------------
                                                   
-- Sample values from the C64: @TODO: Adjust to your needs 
constant audio_flt_rate : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(7056000, 32));
constant audio_cx       : std_logic_vector(39 downto 0) := std_logic_vector(to_signed(4258969, 40));
constant audio_cx0      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(3, 8));
constant audio_cx1      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(2, 8));
constant audio_cx2      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(1, 8));
constant audio_cy0      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-6216759, 24));
constant audio_cy1      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed( 6143386, 24));
constant audio_cy2      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-2023767, 24));
constant audio_att      : std_logic_vector( 4 downto 0) := "00000";
constant audio_mix      : std_logic_vector( 1 downto 0) := "00"; -- 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)
                                                   
end package globals;
