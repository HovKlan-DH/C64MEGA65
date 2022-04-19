----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Configuration data for the Shell
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
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

-- !!! DO NOT TOUCH !!!
constant CHR_LINE_1  : character := character'val(196);
constant CHR_LINE_5  : string := CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1 & CHR_LINE_1;
constant CHR_LINE_10 : string := CHR_LINE_5 & CHR_LINE_5;
constant CHR_LINE_50 : string := CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10 & CHR_LINE_10;

--------------------------------------------------------------------------------------------------------------------
-- Welcome and Help Screens (Selectors 0x1000 .. 0x1FFF) 
--------------------------------------------------------------------------------------------------------------------

-- define the amount of WHS array elements: between 1 and 16
constant WHS_RECORDS   : natural := 2;

-- define the maximum amount of pages per WHS array element: between 1 and 256
-- (this is necessary because Vivado does not support unconstrained arrays in a record)
constant WHS_MAX_PAGES : natural := 3;

 -- !!! DO NOT TOUCH !!!
constant SEL_WHS           : std_logic_vector(15 downto 0) := x"1000";
type WHS_DATA_TYPE is array (0 to WHS_MAX_PAGES - 1) of string;
type WHS_RECORD_TYPE is record
   page_count : natural;
   page_data  : WHS_DATA_TYPE;
end record;
type WHS_RECORD_ARRAY_TYPE is array (0 to WHS_RECORDS - 1) of WHS_RECORD_TYPE; 

-- START YOUR CONFIGURATION BELOW THIS LINE

-- Define all your screens as string constants. They will be synthesized as ROMs.
-- You can name these string constants as you want to, as long as you make them part of the WHS array (see below).
--
-- WHS array position 0 is defined as the "Welcome Screen" as controled by WELCOME_ACTIVE and WELCOME_AT_RESET.
-- If you are not using a Welcome Screen but only Help menu items, then you need to leave WHS array pos. 0 empty by
-- setting page_count to 0 and by adding two empty strings ("", "").
-- 
-- WHS array position 1 and onwards is for all the Option Menu items tagged as "Help": The first one in the
-- Options menu is WHS array pos. 1, the second one in the menu is WHS array pos. 2 and so on.
--
-- Maximum 16 WHS array positions: The selector's bits 11 downto 8 select the WHS array position; 0=Welcome Screen
-- That means a maximum of 15 menu items in the Options menu can be tagged as "Help"
-- The selector's bits 7 downto 0 are selecting the page within the WHS array, so maximum 256 pages per Welcome Screen or Help menu item
-- 
-- Within a selector's address range, address 0 is the beginning of the string itself, while address 0xFFF of the 4k
-- window contains the amount of pages, so each zero-terminated string can be up to 4095 bytes = 4094 characters long.

constant SCR_WELCOME : string :=

   "\n Commodore 64 for MEGA65 Version 1\n\n" &
   
   " MiSTer port 2022 by MJoergen & sy2002\n" &   
   " Powered by MiSTer2MEGA65\n\n\n" &
     
   " While the C64 is running: Press the HELP key\n" &
   " to mount drives and to configure the core.\n\n" &
   
   " Both SD card slots are supported: The card\n" &
   " in the back has higher precedence than the\n" &
   " card at the bottom of the MEGA65.\n\n" &
   
   " While you are in the file browser:\n" &
   "   F1: Switch to internal SD card\n" &
   "   F3: Switch to external SD card\n" & 
   
   "\n\n Press Space to continue.";
   
constant HELP_1 : string :=

   "\n Commodore 64 for MEGA65 Version 1\n\n" &
   
   " MiSTer port 2022 by MJoergen & sy2002\n" &   
   " Powered by MiSTer2MEGA65\n\n" &
     
   " When browsing disk images to mount a drive:\n\n" &
   " Cursor up/down:     File up/down\n" &
   " Cursor left/right:  Page up/down\n" &
   " Run/Stop:           Cancel browsing\n" &
   " F1:                 Internal SD card\n" &
   " F3:                 External SD card\n" &
   " Enter:              Mount drive\n\n" &
   
   " Cursor right to learn more.       (1 of 3)\n" &
   " Press Space to close the help screen.";

constant HELP_2 : string :=

   "\n Commodore 64 for MEGA65 Version 1\n\n" &
   
   " =====================================\n" &   
   " \n" &
     
   " X:\n\n" &
   " A\n" &
   " B\n" &
   " C\n" &
   " D\n" &
   " E\n" &
   " F\n\n" &
   
   " Crsr left: Prev  Crsr right: Next (2 of 3)\n" &
   " Press Space to close the help screen.";

constant HELP_3 : string :=

   "\n Commodore 64 for MEGA65 Version 1\n\n" &
   
   " =====================================\n" &   
   " \n" &
     
   " Z:\n\n" &
   " M\n" &
   " N\n" &
   " O\n" &
   " P\n" &
   " Q\n" &
   " R\n\n" &
   
   " Cursor left to go back.           (3 of 3)\n" &
   " Press Space to close the help screen.";

-- You need to construct this array of records according to your Welcome Screen and Help Menu structure
-- page_count is the amount of pages per WHS array entry
-- page_data needs at least two entries of type string, so if you have zero pages, than you need to write ("", "") and
-- if you have one page, then you need to add an empty string for example (SCR_WELCOME, "")
-- Anyway, you need to have WHS_MAX_PAGES entries per page_data because Vivado does not support unconstrained arrays in a record 
constant WHS : WHS_RECORD_ARRAY_TYPE := (
   (page_count => 1, page_data => (SCR_WELCOME, "", "")),
   (page_count => 3, page_data => (HELP_1, HELP_2, HELP_3))
);

--------------------------------------------------------------------------------------------------------------------
-- Set start folder for file browser (Selector 0x0100) 
--------------------------------------------------------------------------------------------------------------------

constant SEL_DIR_START     : std_logic_vector(15 downto 0) := x"0100";  -- !!! DO NOT TOUCH !!!

-- START YOUR CONFIGURATION BELOW THIS LINE

constant DIR_START         : string := "/c64";

--------------------------------------------------------------------------------------------------------------------
-- General configuration settings: Reset, Pause, OSD behavior, Ascal
--------------------------------------------------------------------------------------------------------------------

constant SEL_GENERAL       : std_logic_vector(15 downto 0) := x"0110";  -- !!! DO NOT TOUCH !!!

-- START YOUR CONFIGURATION BELOW THIS LINE

-- keep the core in RESET state after the hardware starts up and after pressing the MEGA65's reset button 
constant RESET_KEEP        : boolean := false;

-- alternative to RESET_KEEP: keep the reset line active for this amount of "QNICE loops" (see shell.asm)
-- "0" means: deactivate this feature
constant RESET_COUNTER     : natural := 100;

-- put the core in PAUSE state if any OSD opens
constant OPTM_PAUSE        : boolean := false;

-- show the welcome screen in general
constant WELCOME_ACTIVE    : boolean := true;

-- shall the welcome screen also be shown after the core is reset?
-- (only relevant if WELCOME_ACTIVE is true)
constant WELCOME_AT_RESET  : boolean := true;

-- keyboard and joystick connection during reset and OSD
constant KEYBOARD_AT_RESET : boolean := false;
constant JOY_1_AT_RESET    : boolean := false;
constant JOY_2_AT_RESET    : boolean := false;

constant KEYBOARD_AT_OSD   : boolean := false;
constant JOY_1_AT_OSD      : boolean := false;
constant JOY_2_AT_OSD      : boolean := false;

-- Avalon Scaler settings (see ascal.vhd, used for HDMI output only)
-- 0=set ascal mode (via QNICE's ascal_mode_o) to the value of the config.vhd constant ASCAL_MODE
-- 1=do nothing, leave ascal mode alone, custom QNICE assembly code can still change it via M2M$ASCAL_MODE
--               and QNICE's CSR will be set to not automatically sync ascal_mode_i 
-- 2=keep ascal mode in sync with the QNICE input register ascal_mode_i:
--   use this if you want to control the ascal mode for example via the Options menu
--   where you would wire the output of certain options menu bits with ascal_mode_i
constant ASCAL_USAGE       : natural := 2;
constant ASCAL_MODE        : natural := 0;   -- see ascal.vhd for the meaning of this value

--------------------------------------------------------------------------------------------------------------------
-- Load one or more mandatory or optional BIOS/ROMs  (Selectors 0x0200 .. 0x02FF) 
--------------------------------------------------------------------------------------------------------------------

-- !!! CAUTION: CURRENTLY NOT YET SUPPORTED BY THE FIRMWARE !!!

--------------------------------------------------------------------------------------------------------------------
-- "Help" menu / Options menu  (Selectors 0x0300 .. 0x0307) 
--------------------------------------------------------------------------------------------------------------------

-- !!! DO NOT TOUCH !!! Selectors for accessing the menu configuration data
constant SEL_OPTM_ITEMS       : std_logic_vector(15 downto 0) := x"0300";
constant SEL_OPTM_GROUPS      : std_logic_vector(15 downto 0) := x"0301";
constant SEL_OPTM_STDSEL      : std_logic_vector(15 downto 0) := x"0302";
constant SEL_OPTM_LINES       : std_logic_vector(15 downto 0) := x"0303";
constant SEL_OPTM_START       : std_logic_vector(15 downto 0) := x"0304";
constant SEL_OPTM_ICOUNT      : std_logic_vector(15 downto 0) := x"0305";
constant SEL_OPTM_MOUNT_DRV   : std_logic_vector(15 downto 0) := x"0306";
constant SEL_OPTM_SINGLESEL   : std_logic_vector(15 downto 0) := x"0307";
constant SEL_OPTM_MOUNT_STR   : std_logic_vector(15 downto 0) := x"0308";
constant SEL_OPTM_DIMENSIONS  : std_logic_vector(15 downto 0) := x"0309";
constant SEL_OPTM_HELP        : std_logic_vector(15 downto 0) := x"0310";

-- !!! DO NOT TOUCH !!! Configuration constants for OPTM_GROUPS (shell.asm and menu.asm expect them to be like this)
constant OPTM_G_TEXT       : integer := 0;                -- text that cannot be selected
constant OPTM_G_CLOSE      : integer := 16#00FF#;         -- menu items that closes menu
constant OPTM_G_STDSEL     : integer := 16#0100#;         -- item within a group that is selected by default
constant OPTM_G_LINE       : integer := 16#0200#;         -- draw a line at this position
constant OPTM_G_START      : integer := 16#0400#;         -- selector / cursor position after startup (only use once!)
constant OPTM_G_HEADLINE   : integer := 16#1000#;         -- like OPTM_G_TEXT but will be shown in a brigher color
constant OPTM_G_MOUNT_DRV  : integer := 16#8800#;         -- line item means: mount drive; first occurance = drive 0, second = drive 1, ...
constant OPTM_G_HELP       : integer := 16#A000#;         -- line item means: help screen; first occurance = WHS(1), second = WHS(2), ...
constant OPTM_G_SINGLESEL  : integer := 16#8000#;         -- single select item

-- START YOUR CONFIGURATION BELOW THIS LINE:

-- String with which %s will be replaced in case the menu item is of type OPTM_G_MOUNT_DRV
constant OPTM_S_MOUNT         : string :=  "<Mount Drive>";

-- Size of menu and menu items
-- CAUTION: 1. End each line (also the last one) with a \n and make sure empty lines / separator lines are only consisting of a "\n"
--             Do use a lower case \n. If you forget one of them or if you use upper case, you will run into undefined behavior.
--          2. Start each line that contains an actual menu item (multi- or single-select) with a Space character,
--             otherwise you will experience visual glitches.
constant OPTM_SIZE         : natural := 26;  -- amount of items including empty lines:
                                             -- needs to be equal to the number of lines in OPTM_ITEM and amount of items in OPTM_GROUPS

-- Net size of the Options menu on the screen in characters (excluding the frame, which is hardcoded to two characters)
-- We advise to use OPTM_SIZE as height, but there might be reasons for you to change it.
constant OPTM_DX           : natural := 23;
constant OPTM_DY           : natural := OPTM_SIZE;
                                             
constant OPTM_ITEMS        : string :=

   " C64 for MEGA65\n"        &
   "\n"                       &
   " 8:%s\n"                  &  -- %s will be replaced by OPTM_S_MOUNT when not mounted and by the filename when mounted
   "\n"                       &
   " Flip joystick ports\n"   &
   "\n"                       &
   " SID\n"                   &
   "\n"                       &
   " 6581\n"                  &
   " 8580\n"                  &
   "\n"                       &
   " Post-processing\n"       &
   "\n"                       &
   " HDMI: CRT emulation\n"   &
   " HDMI: Zoom-in\n"         &
   " Audio improvements\n"    &
   "\n"                       &
   " Advanced\n"              &
   "\n"                       &
   " VGA: Retro 15KHz RGB\n"  &
   " HDMI: Force 60Hz\n"      &
   " HDMI: Flicker-free\n"    &
   "\n"                       &
   " Info & Help\n"           &
   "\n"                       &      
   " Close Menu\n";
        
constant OPTM_G_MOUNT_8       : integer := 1;
constant OPTM_G_MOUNT_9       : integer := 2;   -- not used, yet; each drive needs a unique group ID
constant OPTM_G_FLIP_JOYS     : integer := 3;
constant OPTM_G_SID           : integer := 4;
constant OPTM_G_CRT_EMULATION : integer := 5;
constant OPTM_G_HDMI_ZOOM     : integer := 6;
constant OPTM_G_IMPROVE_AUDIO : integer := 7;
constant OPTM_G_VGA_RETRO     : integer := 8;
constant OPTM_G_HDMI_60HZ     : integer := 9;
constant OPTM_G_HDMI_FF       : integer := 10;
constant OPTM_G_INFO_HELP     : integer := 11;

type OPTM_GTYPE is array (0 to OPTM_SIZE - 1) of integer range 0 to 65535;
constant OPTM_GROUPS       : OPTM_GTYPE := ( OPTM_G_HEADLINE,
                                             OPTM_G_LINE,
                                             OPTM_G_MOUNT_8       + OPTM_G_MOUNT_DRV   + OPTM_G_START,
                                             OPTM_G_LINE,
                                             OPTM_G_FLIP_JOYS     + OPTM_G_SINGLESEL,
                                             OPTM_G_LINE,
                                             OPTM_G_HEADLINE,
                                             OPTM_G_LINE,
                                             OPTM_G_SID           + OPTM_G_STDSEL,
                                             OPTM_G_SID,
                                             OPTM_G_LINE,
                                             OPTM_G_HEADLINE,
                                             OPTM_G_LINE,
                                             OPTM_G_CRT_EMULATION + OPTM_G_SINGLESEL + OPTM_G_STDSEL,
                                             OPTM_G_HDMI_ZOOM     + OPTM_G_SINGLESEL,
                                             OPTM_G_IMPROVE_AUDIO + OPTM_G_SINGLESEL + OPTM_G_STDSEL,
                                             OPTM_G_LINE,
                                             OPTM_G_HEADLINE,
                                             OPTM_G_LINE,
                                             OPTM_G_VGA_RETRO     + OPTM_G_SINGLESEL,
                                             OPTM_G_HDMI_60HZ     + OPTM_G_SINGLESEL,
                                             OPTM_G_HDMI_FF       + OPTM_G_SINGLESEL + OPTM_G_STDSEL,                                            
                                             OPTM_G_LINE,
                                             OPTM_G_INFO_HELP     + OPTM_G_HELP,
                                             OPTM_G_LINE,
                                             OPTM_G_CLOSE
                                           );

--------------------------------------------------------------------------------------------------------------------
-- !!! CAUTION: M2M FRAMEWORK CODE !!! DO NOT TOUCH ANYTHING BELOW THIS LINE !!!
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- Address Decoding
--------------------------------------------------------------------------------------------------------------------

begin

addr_decode : process(all)
   variable index : integer;
   variable whs_array_index : integer;
   variable whs_page_index : integer;
   
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
   
   -- return the dimensions of the Options menu
   function getDXDY(dx, dy, index: natural) return std_logic_vector is
   begin
      case index is
         when 0 => return std_logic_vector(to_unsigned(dx + 2, 16));
         when 1 => return std_logic_vector(to_unsigned(dy + 2, 16));
         when others => return (others => '0');
      end case;
   end;
   
   -- convert bool to std_logic_vector
   function bool2slv(b: boolean) return std_logic_vector is
   begin
      if b then
         return x"0001";
      else
         return x"0000";
      end if;
   end;
   
   -- return the General Configuration settings
   function getGenConf(index: natural) return std_logic_vector is
   begin
      case index is
         when 0      => return bool2slv(RESET_KEEP);
         when 1      => return std_logic_vector(to_unsigned(RESET_COUNTER, 16));
         when 2      => return bool2slv(OPTM_PAUSE);
         when 3      => return bool2slv(WELCOME_ACTIVE);
         when 4      => return bool2slv(WELCOME_AT_RESET);
         when 5      => return bool2slv(KEYBOARD_AT_RESET);
         when 6      => return bool2slv(JOY_1_AT_RESET);
         when 7      => return bool2slv(JOY_2_AT_RESET);
         when 8      => return bool2slv(KEYBOARD_AT_OSD);
         when 9      => return bool2slv(JOY_1_AT_OSD);
         when 10     => return bool2slv(JOY_2_AT_OSD);
         when 11     => return std_logic_vector(to_unsigned(ASCAL_USAGE, 16));
         when 12     => return std_logic_vector(to_unsigned(ASCAL_MODE, 16));
         when others => return x"0000";
      end case;
   end;
     
begin
   data_o <= x"EEEE";
   index := to_integer(unsigned(address_i(11 downto 0)));
   whs_array_index := to_integer(unsigned(address_i(23 downto 20)));
   whs_page_index  := to_integer(unsigned(address_i(19 downto 12)));   
   
   case address_i(27 downto 12) is   
      when SEL_GENERAL           => data_o <= getGenConf(index);
      when SEL_DIR_START         => data_o <= str2data(DIR_START);
      when SEL_OPTM_ITEMS        => data_o <= str2data(OPTM_ITEMS);
      when SEL_OPTM_MOUNT_STR    => data_o <= str2data(OPTM_S_MOUNT);
      when SEL_OPTM_GROUPS       => data_o <= std_logic(to_unsigned(OPTM_GROUPS(index), 16)(15)) & "00" & 
                                              std_logic(to_unsigned(OPTM_GROUPS(index), 16)(12)) & "0000" &
                                              std_logic_vector(to_unsigned(OPTM_GROUPS(index), 16)(7 downto 0));
      when SEL_OPTM_STDSEL       => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(8));
      when SEL_OPTM_LINES        => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(9));
      when SEL_OPTM_START        => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(10));
      when SEL_OPTM_MOUNT_DRV    => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(11));
      when SEL_OPTM_HELP         => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(13));
      when SEL_OPTM_SINGLESEL    => data_o <= x"000" & "000" & std_logic(to_unsigned(OPTM_GROUPS(index), 16)(15));      
      when SEL_OPTM_ICOUNT       => data_o <= x"00" & std_logic_vector(to_unsigned(OPTM_SIZE, 8));
      when SEL_OPTM_DIMENSIONS   => data_o <= getDXDY(OPTM_DX, OPTM_DY, index);
 
      when others =>
         -- Welcome and Help Screens
         if address_i(27 downto 24) = SEL_WHS(15 downto 12) then           
            if  whs_array_index < WHS_RECORDS then
               if index = 4095 then
                  data_o <= std_logic_vector(to_unsigned(WHS(whs_array_index).page_count, 16));
               else
                  data_o <= str2data(WHS(whs_array_index).page_data(whs_page_index));
               end if;
            end if;       
         end if; 
   end case;
end process;

end beh;
