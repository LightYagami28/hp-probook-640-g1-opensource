/* SPDX-License-Identifier: GPL-2.0-only */

#include <southbridge/intel/lynxpoint/pch.h>

/* Hook required by the Lynx Point bootblock; nothing to configure. */
void mainboard_config_superio(void)
{
	/* This board has no Super I/O settings to apply at bootblock time. */
}
