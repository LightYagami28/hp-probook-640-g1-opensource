/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt2.dat
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000048A (1162)
 *     Revision         0x01
 *     Checksum         0xAA
 *     OEM ID           "HPQOEM"
 *     OEM Table ID     "PtidDevc"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20110112 (537985298)
 */
DefinitionBlock ("", "SSDT", 1, "HPQOEM", "PtidDevc", 0x00001000)
{
    External (_SB_.PCI0.LPCB.EC0_.BCVD, IntObj)
    External (_SB_.PCI0.LPCB.EC0_.ECMX, UnknownObj)
    External (_SB_.PCI0.LPCB.EC0_.ECRG, IntObj)
    External (_SB_.PCI0.LPCB.EC0_.PL1_, IntObj)
    External (_SB_.PCI0.LPCB.EC0_.PL2_, IntObj)
    External (_TZ_.BATZ._TMP, IntObj)
    External (_TZ_.CPUZ._TMP, IntObj)
    External (_TZ_.EXTZ._TMP, IntObj)
    External (_TZ_.GDTP, IntObj)
    External (_TZ_.GFRM, IntObj)
    External (_TZ_.GFSD, IntObj)
    External (_TZ_.GFXZ._TMP, IntObj)
    External (_TZ_.GTRM, IntObj)
    External (_TZ_.LOCZ._TMP, IntObj)
    External (_TZ_.PCHZ._TMP, IntObj)

    Device (PTID)
    {
        Name (_HID, EisaId ("INT340E") /* Motherboard Resources */)  // _HID: Hardware ID
        Name (_CID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _CID: Compatible ID
        Name (IVER, 0x00020001)
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            Return (0x0F)
        }

        Name (TMPV, Package (0x24)
        {
            0x00, 
            "0-CPUZ-CPU reading via EC", 
            0x80000000, 
            0x01, 
            "1-GFXZ-Graphics via EC", 
            0x80000000, 
            0x03, 
            "2-EXTZ-External/Remote 1", 
            0x80000000, 
            0x03, 
            "3-LOCZ-Local/Internal", 
            0x80000000, 
            0x03, 
            "5-BATZ-Battery", 
            0x80000000, 
            0x05, 
            "6-PCHZ-PCH DTS from PCH", 
            0x80000000, 
            0x02, 
            "Dummy", 
            0x80000000, 
            0x02, 
            "Dummy", 
            0x80000000, 
            0x02, 
            "Dummy", 
            0x80000000, 
            0x02, 
            "Dummy", 
            0x80000000, 
            0x02, 
            "V0", 
            0x80000000, 
            0x02, 
            "V1", 
            0x80000000
        })
        Name (PWRV, Package (0x09)
        {
            0x00, 
            "PL1", 
            0x80000000, 
            0x00, 
            "PL2", 
            0x80000000, 
            0x00, 
            "Boost Converter", 
            0x80000000
        })
        Name (OSDV, Package (0x0C)
        {
            0x00, 
            "Fan Speed RPM", 
            "RPM", 
            0x80000000, 
            0x00, 
            "Target Fan RPM", 
            "RPM", 
            0x80000000, 
            0x00, 
            "Fan Speed %", 
            "RAW", 
            0x80000000
        })
        OperationRegion (MCHP, SystemMemory, 0xFED158A4, 0x02)
        Field (MCHP, ByteAcc, NoLock, Preserve)
        {
            VTS0,   8, 
            VTS1,   8
        }

        Method (TSDD, 0, NotSerialized)
        {
            TMPV [0x02] = \_TZ.CPUZ._TMP /* External reference */
            TMPV [0x05] = \_TZ.GFXZ._TMP /* External reference */
            TMPV [0x08] = \_TZ.EXTZ._TMP /* External reference */
            TMPV [0x0B] = \_TZ.LOCZ._TMP /* External reference */
            TMPV [0x0E] = \_TZ.BATZ._TMP /* External reference */
            TMPV [0x11] = \_TZ.PCHZ._TMP /* External reference */
            Local0 = 0x11
            Local0 += 0x02
            TMPV [Local0] = "DM1Z-Memory DIMM 1"
            Local0++
            0x30 = \_TZ.GDTP /* External reference */
            0x01
            TMPV [Local0]
            Local0 += 0x02
            TMPV [Local0] = "DM2Z-Memory DIMM 2"
            Local0++
            0x34 = \_TZ.GDTP /* External reference */
            0x01
            TMPV [Local0]
            While ((Local0 < 0x1D))
            {
                Local0 += 0x03
                TMPV [Local0] = 0x0AAC
            }

            TMPV [0x20] = ((VTS0 * 0x0A) + 0x0AAC)
            TMPV [0x23] = ((VTS1 * 0x0A) + 0x0AAC)
            Return (TMPV) /* \PTID.TMPV */
        }

        Method (PSDD, 0, NotSerialized)
        {
            Local0 = 0x00
            Local1 = 0x00
            If (\_SB.PCI0.LPCB.EC0.ECRG)
            {
                Acquire (\_SB.PCI0.LPCB.EC0.ECMX, 0xFFFF)
                Local0 = \_SB.PCI0.LPCB.EC0.PL1 /* External reference */
                Local1 = \_SB.PCI0.LPCB.EC0.PL2 /* External reference */
                Local2 = \_SB.PCI0.LPCB.EC0.BCVD /* External reference */
                Release (\_SB.PCI0.LPCB.EC0.ECMX)
            }

            PWRV [0x02] = (Local0 * 0x03E8)
            PWRV [0x05] = (Local1 * 0x03E8)
            PWRV [0x08] = Local2
            Return (PWRV) /* \PTID.PWRV */
        }

        Method (OSDD, 0, NotSerialized)
        {
            OSDV [0x03] = \_TZ.GFRM /* External reference */
            OSDV [0x07] = \_TZ.GTRM /* External reference */
            OSDV [0x0B] = \_TZ.GFSD /* External reference */
            Return (OSDV) /* \PTID.OSDV */
        }

        Method (SDSP, 0, NotSerialized)
        {
            Return (0x0A)
        }
    }
}

