----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Configuration data for the Shell
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2021 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config is
port (
   -- bits 27 .. 12:    select configuration data block; called "Selector" hereafter
   -- bits 11 downto 0: address the up to 4k the configuration data
   address_i   : in std_logic_vector(27 downto 0);
   
   -- config data
   data_o      : out std_logic_vector(15 downto 0)
);
end config;

architecture beh of config is

--------------------------------------------------------------------------------------------------------------------
-- String and character constants (specific for the Anikki-16x16 font)
--------------------------------------------------------------------------------------------------------------------

constant CHR_LINE_1  : character := character'val(196);
constant CHR_LINE_5  : string := CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1;
constant CHR_LINE_10 : string := CHR_LINE_5 & CHR_LINE_5;
constant CHR_LINE_50 : string := CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10;

--------------------------------------------------------------------------------------------------------------------
-- Welcome Screen (Selectors 0x0000 .. 0x00FF) 
--------------------------------------------------------------------------------------------------------------------

constant SEL_WELCOME : std_logic_vector(15 downto 0) := x"0000";
constant SCR_WELCOME : string :=

   "Commodore 64 for MEGA65 V0.1 [WIP]\n" &
   "MiSTer port by MJoergen & sy2002 in 2021\n\n" &
   
   "Powered by MiSTer2MEGA65 V0.1 [WIP]\n" &
   
   "\n\nPLACEHOLDER FOR CORE DOCUMENTATION\n\n" &
   
   "You can for example show the keyboard map.\n" &
   "And explain how the help menu works.\n" & 
   
   "\n\nPress Space to continue.\n\n\n";

--------------------------------------------------------------------------------------------------------------------
-- Set start folder for file browser (Selector 0x0100) 
--------------------------------------------------------------------------------------------------------------------

constant SEL_DIR_START : std_logic_vector(15 downto 0) := x"0100";

constant DIR_START     : string := "/m2m";

--------------------------------------------------------------------------------------------------------------------
-- Load one or more mandatory or optional BIOS/ROMs  (Selectors 0x0200 .. 0x02FF) 
--------------------------------------------------------------------------------------------------------------------

-- Data structure: Word 0: Flags, Word 1+: full path to BIOS/ROM
-- Flags: bit 0: 1=mandatory
--        bit 1: 1=hide this file from the file browser
--        bit 2: 1=needs magic byte mapping
--        bit 3: 1=increasing the selector by 3 leads to one more BIOS/ROM

-- You need to create the desired amount SEL_ROM_x_FLAG, SEL_ROM_x_FILE and SEL_ROM_x_MAGIC constants
-- and add them to the addr_decode process
--
-- Make sure that each block consists of exactly 4 selectors, so that the firmware can trust, that
-- adding 4 to the selector in case of flag bit 3 = 1 always leads to the next valid selector block
--
-- About "magic": @TODO: This is a future feature: While reading the ROM/BIOS: Certain bytes within
-- the file can be extracted and mapped to general purpose control flags (M2M$CFD_ADDR and 2M$CFD_DATA)
--
-- About "device": This is the device ID that you want to load the BIOS/ROM to. Make sure that you are always using
-- symbolic names here and that you are adjusting the process "qnice_ramrom_devices" in mega95.vhd accordingly  

-- TODO REFACTOR: USE RECORDS AND A RETRIEVAL FUNCTION
constant SEL_ROM_1_FLAG   : std_logic_vector(15 downto 0) := x"0200";
constant SEL_ROM_1_FILE   : std_logic_vector(15 downto 0) := x"0201";
constant SEL_ROM_1_MAGIC  : std_logic_vector(15 downto 0) := x"0202";
constant SEL_ROM_1_DEVICE : std_logic_vector(15 downto 0) := x"0203";
constant ROM_1_FLAG       : std_logic_vector(15 downto 0) := x"000" & "1011"; -- mandatory, hide, no magic, there is more
constant ROM_1_FILE       : string := "/m2m/logo.rom";

constant SEL_ROM_2_FLAG   : std_logic_vector(15 downto 0) := x"0204"; 
constant SEL_ROM_2_FILE   : std_logic_vector(15 downto 0) := x"0205";
constant SEL_ROM_2_MAGIC  : std_logic_vector(15 downto 0) := x"0206";
constant SEL_ROM_2_DEVICE : std_logic_vector(15 downto 0) := x"0207";
constant ROM_2_FLAG       : std_logic_vector(15 downto 0) := x"000" & "0000"; -- optional, do not hide, no magic, no more roms
constant ROM_2_FILE       : string := "/m2m/test_opt.rom";
   
--------------------------------------------------------------------------------------------------------------------
-- Address Decoding 
--------------------------------------------------------------------------------------------------------------------

begin

addr_decode : process(all)
   
   -- return ASCII value of given string at the position defined by address_i(11 downto 0)
   function str2data(str : string) return std_logic_vector is
   variable strpos : integer;
   begin
      strpos := to_integer(unsigned(address_i(11 downto 0))) + 1;
      if strpos <= str'length then
         return std_logic_vector(to_unsigned(character'pos(str(strpos)), 16));
      else
         return (others => '0'); -- zero terminated strings
      end if;
   end;
   
begin
   data_o <= x"EEEE";
   
   case address_i(27 downto 12) is   
      when SEL_WELCOME     => data_o <= str2data(SCR_WELCOME);
      when SEL_DIR_START   => data_o <= str2data(DIR_START);
      
      -- BIOS / ROM section
      -- @TODO: Add the desired amount of SEL_ROM_x_FLAG and SEL_ROM_x_FILE constants here
      when SEL_ROM_1_FLAG  => data_o <= ROM_1_FLAG;
      when SEL_ROM_1_FILE  => data_o <= str2data(ROM_1_FILE);
      when SEL_ROM_2_FLAG  => data_o <= ROM_2_FLAG;
      when SEL_ROM_2_FILE  => data_o <= str2data(ROM_2_FILE);
   
      when others => null;
   end case;
end process;

end beh;
