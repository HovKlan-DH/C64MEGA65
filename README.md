Commodore 64 for MEGA65 version 4
=================================

This project is copied directly from the [Commodore 64 for MEGA65 project](https://github.com/MJoergen/C64MEGA65) and is fully done by [sy2002](https://github.com/sy2002) and [MJoergen](https://github.com/MJoergen).

My purpose here is solely to **tweak the help menu**, to reflect my wishes for an improvement - that means different **colors**, **layout** and **font** - that's it. The core itself is not touched at all, and I have even no idea how this is working :-)

    ------------------------------------------
    ALL THE CREDIT GOES TO SY2002 AND MJOERGEN
    ------------------------------------------

This is how the **original** menu looks like:

![Original menu](http://howto.dk/MiSTer2MEGA65-Color-Schema/org1.jpg)

This is how my **tweaked** menu looks like:

![Tweaked menu](http://howto.dk/MiSTer2MEGA65-Color-Schema/tweaked1.jpg)

If you would like to tweak this yourself, then you could find inspiration in my below documented steps. You are also welcome to reach out to me on [Discord MEGA65](https://discord.com/channels/719326990221574164/), where I have the strange handle as **MegaBeauvais#9623**

You could also just head to the [RELEASES](https://github.com/HovKlan-DH/C64MEGA65/releases) and do a quick download - ready to go for your MEGA65 :-)


REQUIREMENTS BEFORE YOU START YOUR OWN TWEAKING
===============================================

**Familiarize yourself with the MiSTer2MEGA65 project**

  - It is highly recommended that you first follow the steps in this excellent guide, [MiSTer2MEGA65 First Steps](https://github.com/sy2002/MiSTer2MEGA65/wiki/2.-First-Steps), for how to use the MiSTer2MEGA65 framework

**Xilinx Vivado ML Standard 2022.2 proper setup** (the Standard version is free to use)

  - For me it took some effort in getting this to work proper, but sadly I did not document everything I did - maybe it is working better for you.
  - I have my Vivado installed in Ubuntu 22.04 in Subsystem for Linux on my Windows 10.
  - `m65tools` which can be fetched from https://github.com/MEGA65/mega65-tools
  - You optionally need to use these two tools:
    - `bit2core` needed for converting a BIT file to a COR file
    - `m65` is optional and for a direct transfer of a BIT file to the MEGA65


STEPS I HAVE DONE TO REBUILD A NEW TWEAKED CORE
===============================================

**Step 1**

Fork the C64MEGA65 project from https://github.com/MJoergen/C64MEGA65/ to your own GitHub repository.
  - Make sure to uncheck the `Copy the master branch only`, as we need the `M2M-V0.9` tag also from the source repository.


**Step 2**

Clone the GitHub repository to local computer - it will create the parent folder.
(replace with your GitHub repository)
  - `git clone https://github.com/HovKlan-DH/C64MEGA65`
  - `cd C64MEGA65`


**Step 3**

The current default forked repository from the C64MEGA65 project currently does not support Vivado 2022.2, but the `M2M-V0.9` tag does.
(this is why we need to fork the entire repository and not only the master branch)
  - `git checkout M2M-V0.9`


**Step 4**

Update with the required sub-modules (will fetch from their sources).
  - `git submodule update --init --recursive`


**Step 5**

Build the toolchains (quote from @sy2002):
  - `cd M2M/QNICE/tools`
  - `./make-toolchain.sh`
    - Answer all questions by pressing ENTER
    - After it finishes you should see "*QNICE: Toolchain successfully made, if you do not see any error messages above.*"
  - `cd ../../../CORE/m2m-rom`
  - `./make_rom.sh`
  - `ls -l m2m-rom.out`
    - You should see something like (filesize needs to be 237594):
    - `-rw-r--r--  1 sy2002  staff  237594 16 Mär 12:30 m2m-rom.out`


**Step 6**

Do a trial-build in Vivado - just to validate that everything is working from real source.
  - `cd ..`
  - `/root/Xilinx/Vivado/2022.2/bin/vivado`
    - Open Project and choose the `CORE-R3.xpr` file.
    - Find the button for `Generate Bitstream` and embrace yourself with patience, as it takes ~20 minutes to compile a bitstream (on my computer).
    - When clicking this button, and you experience it states "*Bitstream generation has already completed and is up-to-date. Re-run anyway?*" then you should CANCEL it. Then go to the `Tcl Console` and click the `synth_1` and choose the `Reset Runs` - and then you can again run the `Generate Bitstream`.
    - When it finishes compiling and it states "*Bitstream Generation successfully completed*" then just CANCEL
    - The BIT file will now be available here:
      - `CORE/CORE-R3.runs/impl_1/CORE_R3.bit`


**Step 7**

Adapt my previous modified files and learnings from my [MyFirstM2M](https://github.com/HovKlan-DH/MyFirstM2M) project:
  - Copy my modified raw text font to `M2M\font\Anikki-16x16-MegaBeauvais.txt`
  - Copy Anikki C-file and replace text inside to new font name
    - `cd ../M2M/font`
    - `cp Anikki-16x16-m2m.c Anikki-16x16-MegaBeauvais.c`
    - `sed -i 's/Anikki-16x16-m2m.h/Anikki-16x16-MegaBeauvais.h/g' Anikki-16x16-MegaBeauvais.c`
    - `sed -i 's/Anikki-16x16-m2m.rom/Anikki-16x16-MegaBeauvais.rom/g' Anikki-16x16-MegaBeauvais.c`
  - Adapt my modified `sysdef.asm` to to `M2M\rom\sysdef.asm`
    - Change the colors used in menu.
    - Change the characters used in menu.
  - Adapt my modified `globals.vhd` to to `CORE\vhdl\mega65.vhd`
    - Change the font ROM file.
  - Adapt my modified `config.vhd` to to `CORE\vhdl\config.vhd`
    - I changed these:
      - `constant OPTM_SIZE`
      - `constant OPTM_DX`
      - `constant OPTM_ITEMS`
      - `constant OPTM_GROUPS`
  - Adapt my modified `mega65.vhd` to to `CORE\vhdl\mega65.vhd`
    - I changed these:
      - `constant C_MENU_FLIP_JOYS`
      - `constant C_MENU_8580`
      - `constant C_MENU_REU`
      - `constant C_MENU_CRT_EMULATION`
      - `constant C_MENU_HDMI_ZOOM`
      - `constant C_MENU_HDMI_16_9_50`
      - `constant C_MENU_HDMI_16_9_60`
      - `constant C_MENU_HDMI_4_3_50`
      - `constant C_MENU_HDMI_5_4_50`
      - `constant C_MENU_HDMI_FF`
      - `constant C_MENU_HDMI_DVI`
      - `constant C_MENU_VGA_RETRO`
      - `constant C_MENU_8521`
      - `constant C_MENU_IMPROVE_AUDIO`


**Step 8**

Unpack PSFTools that will be used for font handling:
  - `cd ../M2M/font`
  - `tar -zxvf psftools-1.1.1.tar.gz`


**Step 9**

Fix bug in `txt2psf.c` and replace line 180 (read `M2M\font\README.md`) and then compile it:
  - `cd psftools-1.1.1`
  - `sed -i 's/strcpy(linebuf, c);/memmove(linebuf, c, 1 + strlen(c));/g' tools/txt2psf.c`
  - `./configure`
  - `make`


**Step 10**

Compile a new font with script:
  - `cd ../../..`
  - `./build_font.sh`


**Step 11**

Compile a new configuration save-file for your SD card.
This file must be placed in the `\c64` folder in the root of the SD card.
You must get the size of `OPTM_SIZE` in the file `CORE/vhdl/config.vhd`, and in the below then `27` is the value I have in the `OPTM_SIZE`
  - `cd M2M/tools`
  - `./make_config.sh c64mega65-mb 27`

**Step 12**

Compile a new bitstream (requires `bit2core`).
Make sure to EXIT Vivado once it has completed a successful bitstream.
  - `./build_bitstream.sh`
    - After successful build, you will have the BIT and COR files here:
      - `CORE/CORE-R3.runs/impl_1/CORE_R3.bit`
      - `CORE/C64V4MB.COR`
Note - I have disabled the push to the MEGA65, as this setup is so special on my setup (+ requires a JTAG adaptor), that you need to do your own setup.
View in `push_bitstream_to_mega65.sh` what happens in there.


**That's it**

Now repeat from step 12, until you are happy with the result :-)


**Push your local changes to GitHub**

Due to the `git checkout M2M-V0.9` in one of the first steps, then it is not possible to do a normal `git commit` and `git push`, but you will need to use Google to figure this out, as this was too weird for me to understand. I finally did manage to get my branch merged with the `master` branch, and then suddenly life is easy again ;-)
