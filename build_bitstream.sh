#!/bin/bash

# Launch Vivado and push the "Generate Bitstream" button.
# Exit Vivado once it has completed a successful bitstream.
cd CORE
#/root/Xilinx/Vivado/2022.2/bin/vivado

# Convert the bitstream to a COR file, which can be used to manually flash a MEGA65 slot
/root/m65tools/bit2core mega65r3 CORE-R3.runs/impl_1/CORE_R3.bit 'C64 for MEGA65' v4 C64MEGA65V4.COR

# Copy COR and BIT to local Windows, so it can be uploaded
cp C64V4MB.COR /mnt/d/Data/Development/m65tools/
cp CORE-R3.runs/impl_1/CORE_R3.bit /mnt/d/Data/Development/m65tools/C64V4MB.BIT

# Upload the COR and push the bitstream directly to the MEGA65 (I have my USB setup on the Windows side)
cd ..
./push_bitstream_to_mega65.sh

