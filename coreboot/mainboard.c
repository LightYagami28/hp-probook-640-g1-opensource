/* SPDX-License-Identifier: GPL-2.0-only */

#include <device/device.h>
#include <ec/acpi/ec.h>
#include <console/console.h>
#include <pc80/keyboard.h>

#define EC_REGISTER_COUNT 256

static void mainboard_init(struct device *dev)
{
	int i;

	/* Replay the EC dump captured on the original firmware (all zeros). */
	printk(BIOS_DEBUG, "Replaying EC dump ...");
	for (i = 0; i < EC_REGISTER_COUNT; i++)
		ec_write(i, 0x00);
	printk(BIOS_DEBUG, "done\n");

	pc_keyboard_init(NO_AUX_DEVICE);
}

static void mainboard_enable(struct device *dev)
{
	dev->ops->init = mainboard_init;
}

struct chip_operations mainboard_ops = {
	.enable_dev = mainboard_enable,
};
