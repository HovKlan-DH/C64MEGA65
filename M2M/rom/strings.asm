; ****************************************************************************
; MiSTer2MEGA65 (M2M) QNICE ROM
;
; Hardcoded Shell strings that cannot be changed by config.vhd
;
; done by sy2002 in 2021 and licensed under GPL v3
; ****************************************************************************

; ----------------------------------------------------------------------------
; Debug Mode
; (Hold "Run/Stop" + "Cursor Up" and then while holding these, press "Help")
; ----------------------------------------------------------------------------

DBG_START1		.ASCII_P "Entering MiSTer2MEGA65 debug mode.\nPress H for "
				.ASCII_W "help and press C R "
DBG_START2 		.ASCII_W " to return to the Shell.\n"

; ----------------------------------------------------------------------------
; Error Messages
; ----------------------------------------------------------------------------

ERR_FATAL		.ASCII_W "FATAL ERROR:\n"
ERR_F_MENUSIZE	.ASCII_P "config.vhd: Illegal menu size (OPTM_SIZE): Must be "
				.ASCII_W "between 1 and 254\n"
ERR_F_MENUSTART .ASCII_P "config.vhd: No start menu item tag (OPTM_G_START) "
				.ASCII_W "found in OPTM_GROUPS\n"

ERR_MOUNT       .ASCII_W "Error: Cannot mount SD card!\nError code: "
ERR_MOUNT_RET   .ASCII_W "\n\nPress Return to retry"