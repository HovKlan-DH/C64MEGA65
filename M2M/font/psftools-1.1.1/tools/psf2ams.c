/*
    psftools: Manipulate console fonts in the .PSF format
    Copyright (C) 2005, 2008, 2020  John Elliott

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
#include <stdio.h>
#include "cnvshell.h"
#include "psflib.h"

/* Convert a PSF file to an Amstrad PCW font */

char *cnv_progname = "PSF2AMS";

static char helpbuf[5120];
static char emsfile[4096];
		   /* 1...5...10...15...20...25...30 */
static char identity[91]=" Screen matrices generated by "
                         "   PSFTOOLS                   "
                         "                              ";
int ems = 0;
int scrchar = 0;

char *cnv_set_option(int ddash, char *variable, char *value)
{
	if (!stricmp(variable, "ems"))
	{
		ems = 1;
		strcpy(emsfile, value);
		return NULL;
	} 
	if (!stricmp(variable, "scrchar"))
	{
		scrchar = 1;
		if (value != NULL && value[0] != 0)
		{
			sprintf(identity, "%-90.90s", value);
		}
		return NULL;
	}
	sprintf(helpbuf, "Unknown option: %s", variable);
	return helpbuf;
}

char *cnv_help(void)
    {
    sprintf(helpbuf, "Syntax: %s { options } psf_file amstrad_file\n\n"
		     "Options:\n"
		     "   --emsfile=template  Output an EMS file based on the\n"
                     "                       provided template\n"
		     "   --scrchar=identity  Output a SCRCHAR.JOY file with\n"
		     "                       the specified identity text\n"
		     "If neither --emsfile or --scrchar is present a .COM "
		     "file is output.\n"
		    ,cnv_progname);
    return helpbuf;
    }

/* Offsets in PSFCOM: 
 * 0000-000E  Initial code
 * 000F-002D  Signature
 * 002E-002F  Length of font, bytes (2k or 4k)
 * 0030-0031  Address of font */
static const unsigned char com8_header[] =
{
#include "psfcom8.inc"
};

static const unsigned char com16_header[] =
{
#include "psfcom16.inc"
};


static unsigned char filebuf[0xC800];

char *cnv_execute(FILE *fpin, FILE *fpout)
{	
	int rv;
	PSF_FILE psf;
	psf_dword ch;
	psf_dword y, wb;
	FILE *fpems;
	int file_len = 0;
	int found = 0;
	int maxchar = 512;
	int cell_h = 8;
	unsigned offset;
	/* The first 8 bytes of the standard Amstrad font */
	static unsigned char font_magic[] = 
		{ 0x00, 0x00, 0x66, 0xDB, 0xDB, 0xDB, 0x66, 0x00 };
	/* And of the +3 narrow font */
	static unsigned char font3_magic[] = 
		{ 0x00, 0x00, 0x50, 0xA8, 0xA8, 0xA8, 0x50, 0x00 };

	psf_file_new(&psf);
	rv = psf_file_read(&psf, fpin);	
	if (rv != PSF_E_OK) return psf_error_string(rv);
	if (maxchar > psf.psf_length) maxchar = psf.psf_length;

	if (scrchar)
	{
		file_len = 0xF80;
		memset(filebuf, 0, file_len + 0x100);
		sprintf((char *)filebuf,"SCR%c%c%-90.90s", 1, 1, identity);
		offset = 128;	
		cell_h = 8;
	}

	else if (ems)
	{
		fpems = fopen(emsfile, "rb");
		if (!fpems)
		{
			sprintf(helpbuf, "Cannot open template EMS file %s\n",
				emsfile);
			return helpbuf;
		}
		file_len = fread(filebuf, 1, sizeof(filebuf), fpems);
		fclose(fpems);
		if (file_len < 0x800)
		{
			sprintf(helpbuf, "Template EMS file %s is smaller than 2k\n", emsfile);
			return helpbuf;
		}
		/* Look for font signature */
		for (offset = 0; offset < file_len - 0x800; offset++)
		{
			if (!memcmp(filebuf + offset, font_magic, 8)) 
			{
				found = 1;
				break;
			}
		}
		if (!found) 
		{
			sprintf(helpbuf, "Cannot find Amstrad CP/M font in %s\n",
				emsfile);
			return helpbuf;
		}
		/* If there is no 'small' +3 font, limit to 256 chars */
		if (memcmp(filebuf + offset + 0x800, font3_magic, 8))
		{
			maxchar = 256;
			fprintf(stderr, "Found 256-character font at 0x%04x in %s\n", offset, emsfile);
		}
		else
		{
			fprintf(stderr, "Found 512-character font at 0x%04x in %s\n", offset, emsfile);
		}
		cell_h = 8;
	}
	else
	{
		if (psf.psf_height >= 16)
		{
			cell_h = 16;
			memcpy(filebuf, com16_header, sizeof(com16_header));
			offset = sizeof(com16_header);
			filebuf[0x30] = (offset & 0xFF);
			filebuf[0x31] = (offset >> 8) + 1;
			found = 1;
		}
		else
		{
			cell_h = 8;
			memcpy(filebuf, com8_header, sizeof(com8_header));
			offset = sizeof(com8_header);
			filebuf[0x30] = (offset & 0xFF);
			filebuf[0x31] = (offset >> 8) + 1;
			found = 1;
		}
	}


	if (!ems && !scrchar)
	{
		file_len = (maxchar * cell_h) + offset;
		filebuf[0x2E] = (maxchar * cell_h) & 0xFF; 
		filebuf[0x2F] = (maxchar * cell_h) >> 8;
	}

	if (psf.psf_width > 8)
	{
		fprintf(stderr, "Warning: Input file is wider than 8 pixels. Truncating at 8.\n");
	}
	if (psf.psf_height >= 16 && !ems && !scrchar)
	{
		if (psf.psf_height > 16)
		{
			fprintf(stderr, "Warning: Input file is higher than 16 pixels. Truncating at 16.\n");
		}
	}
	else	/* Smaller than 16px high */
	{
		if (psf.psf_height > 8)
		{
			fprintf(stderr, "Warning: Input file is higher than 8 pixels. Truncating at 8.\n");
		}
	}
	/* wb = number of bytes per line */	
	wb = psf.psf_charlen / psf.psf_height;	
	for (ch = 0; ch < maxchar; ch++)
	{
		/* Populate character buffer */
		for (y = 0; y < psf.psf_height; y++)
		{
			if (y >= cell_h) break;
			filebuf[y + cell_h * ch + offset ] =
				psf.psf_data[ch * psf.psf_charlen + y * wb];	
		}
	}
	psf_file_delete(&psf);
	if (scrchar)
	{
		unsigned long cksum = 0;

		/* Drop the first 32 characters */
		memmove(filebuf + 0x80, filebuf + 0x180, file_len - 0x80);
		/* Checksum the data */
		for (y = 0x80; y < file_len; y++)
		{
			cksum += filebuf[y];
		}
		filebuf[0x61] = cksum & 0xFF;
		filebuf[0x62] = (cksum >> 8);
		filebuf[0x63] = 0x1E;	/* File length / 128 
					 * (excluding header) */
		/* Now checksum the header */
		cksum = 0;
		for (y = 0; y < 0x7F; y++) 
		{
			cksum += filebuf[y];
		}
		filebuf[0x7f] = cksum & 0xFF;	
	}
	if (fwrite(filebuf, 1, file_len, fpout) < file_len)
	{
		return "Could not write to output.";
	}

	return 0;
}

