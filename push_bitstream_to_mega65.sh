#!/bin/bash

# Requirement for this below is a JTAG USB adaptor!!! If you don't know if you have it... then you don't ;-)

# I have probably a special setup, where I from Ubuntu is utilizing the Windows (JTAG) USB devices, so I am calling a Windows batch script.
# My JTAG USB has "COM4" and I am pushing this directly to the MEGA65 computer:
#	- Connect the USB cable and power-on the MEGA65

# Push the bitstream directly to the MEGA65
cmd.exe /C D:\\Data\\Development\\m65tools\\push-bitstream-to-mega65.cmd

# Content of my D:\Data\Development\m65tools\push-bitstream-to-mega65.cmd (executed from Windows)
# m65.exe --device COM4 --bitonly \\wsl$\Ubuntu-22.04\root\C64MEGA65\CORE\CORE-R3.runs\impl_1\CORE_R3.bit
