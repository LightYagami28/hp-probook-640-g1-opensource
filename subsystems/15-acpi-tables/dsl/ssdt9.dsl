/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt9.dat
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000119 (281)
 *     Revision         0x01
 *     Checksum         0xF5
 *     OEM ID           "PmRef"
 *     OEM Table ID     "ApCst"
 *     OEM Revision     0x00003000 (12288)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20110112 (537985298)
 */
DefinitionBlock ("", "SSDT", 1, "PmRef", "ApCst", 0x00003000)
{
    External (_PR_.CPU0._CST, MethodObj)    // 0 Arguments
    External (_PR_.CPU1, DeviceObj)
    External (_PR_.CPU2, DeviceObj)
    External (_PR_.CPU3, DeviceObj)
    External (_PR_.CPU4, DeviceObj)
    External (_PR_.CPU5, DeviceObj)
    External (_PR_.CPU6, DeviceObj)
    External (_PR_.CPU7, DeviceObj)

    Scope (\_PR.CPU1)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU2)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU3)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU4)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU5)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU6)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }

    Scope (\_PR.CPU7)
    {
        Method (_CST, 0, NotSerialized)  // _CST: C-States
        {
            Return (\_PR.CPU0._CST ())
        }
    }
}

