/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt5.dat
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x000001D5 (469)
 *     Revision         0x01
 *     Checksum         0x88
 *     OEM ID           "PmRef"
 *     OEM Table ID     "LakeTiny"
 *     OEM Revision     0x00003000 (12288)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20110112 (537985298)
 */
DefinitionBlock ("", "SSDT", 1, "PmRef", "LakeTiny", 0x00003000)
{
    /*
     * iASL Warning: There was 1 external control method found during
     * disassembly, but only 0 were resolved (1 unresolved). Additional
     * ACPI tables may be required to properly disassemble the code. This
     * resulting disassembler output file may not compile because the
     * disassembler did not know how many arguments to assign to the
     * unresolved methods. Note: SSDTs can be dynamically loaded at
     * runtime and may or may not be available via the host OS.
     *
     * To specify the tables needed to resolve external control method
     * references, the -e option can be used to specify the filenames.
     * Example iASL invocations:
     *     iasl -e ssdt1.aml ssdt2.aml ssdt3.aml -d dsdt.aml
     *     iasl -e dsdt.aml ssdt2.aml -d ssdt1.aml
     *     iasl -e ssdt*.aml -d dsdt.aml
     *
     * In addition, the -fe option can be used to specify a file containing
     * control method external declarations with the associated method
     * argument counts. Each line of the file must be of the form:
     *     External (<method pathname>, MethodObj, <argument count>)
     * Invocation:
     *     iasl -fe refs.txt -d dsdt.aml
     *
     * The following methods were unresolved and many not compile properly
     * because the disassembler had to guess at the number of arguments
     * required for each:
     */
    External (_PR_.CPU0.GEAR, IntObj)
    External (_SB_.PCI0.SAT1, DeviceObj)
    External (_SB_.PCI0.SATA, DeviceObj)
    External (MPMF, UnknownObj)
    External (PNOT, MethodObj)    // Warning: Unknown method, guessing 0 arguments

    Scope (\_SB.PCI0.SATA)
    {
        Method (SLT1, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x00
                \PNOT ()
            }

            Return (0x00)
        }

        Method (SLT2, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x01
                \PNOT ()
            }

            Return (0x00)
        }

        Method (SLT3, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x02
                \PNOT ()
            }

            Return (0x00)
        }

        Method (GLTS, 0, Serialized)
        {
            Local0 = \_PR.CPU0.GEAR /* External reference */
            Local0 <<= 0x01
            Local0 |= 0x01
            Return (Local0)
        }
    }

    Scope (\_SB.PCI0.SAT1)
    {
        Method (SLT1, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x00
                \PNOT ()
            }

            Return (0x00)
        }

        Method (SLT2, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x01
                \PNOT ()
            }

            Return (0x00)
        }

        Method (SLT3, 0, Serialized)
        {
            If (CondRefOf (\_PR.CPU0.GEAR))
            {
                \_PR.CPU0.GEAR = 0x02
                \PNOT ()
            }

            Return (0x00)
        }

        Method (GLTS, 0, Serialized)
        {
            Local0 = \_PR.CPU0.GEAR /* External reference */
            Local0 <<= 0x01
            Local1 = (MPMF & 0x01)
            Local0 |= Local1
            Return (Local0)
        }
    }
}

