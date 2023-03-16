#!/bin/bash

cd M2M/font

# Convert text font into PSF
psftools-1.1.1/tools/txt2psf Anikki-16x16-MegaBeauvais.txt Anikki-16x16-MegaBeauvais.psf

# Build H-include file from PSF font
psftools-1.1.1/tools/txt2psf Anikki-16x16-MegaBeauvais.txt Anikki-16x16-MegaBeauvais.psf

# Set a constant/variable
echo "#define FONT_SIZE (256*32)" >> Anikki-16x16-MegaBeauvais.h.TMP1
echo "const unsigned char FONT[FONT_SIZE] =" >> Anikki-16x16-MegaBeauvais.h.TMP1
echo "{" >> Anikki-16x16-MegaBeauvais.h.TMP1

# Build the C-include file (.h)
psftools-1.1.1/tools/psf2inc Anikki-16x16-MegaBeauvais.psf Anikki-16x16-MegaBeauvais.h

# Remove the first 10 lines and outout the rest to temporary file
tail -n +10 Anikki-16x16-MegaBeauvais.h >> Anikki-16x16-MegaBeauvais.h.TMP1

# Remove the last two lines and delete from the last comma of the last line
cat Anikki-16x16-MegaBeauvais.h.TMP1 | head --lines=-2 | sed '$s/,\s*$//' > Anikki-16x16-MegaBeauvais.h.TMP2

# Close the array
echo "};" >> Anikki-16x16-MegaBeauvais.h.TMP2

# Move and delete files
mv Anikki-16x16-MegaBeauvais.h.TMP2 Anikki-16x16-MegaBeauvais.h
rm Anikki-16x16-MegaBeauvais.h.TMP1

# Compile the C-source and make an executable
gcc Anikki-16x16-MegaBeauvais.c -o Anikki-16x16-MegaBeauvais

# Run the executable and get the ".rom" file
./Anikki-16x16-MegaBeauvais

# Just in case - CLEAN-UP
rm Anikki-16x16-MegaBeauvais
rm Anikki-16x16-MegaBeauvais.h
rm Anikki-16x16-MegaBeauvais.psf

cd ../..
