/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20251212 (64-bit version)
 * Copyright (c) 2000 - 2025 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of ssdt1.dat
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000466 (1126)
 *     Revision         0x01
 *     Checksum         0x46
 *     OEM ID           "HPQOEM"
 *     OEM Table ID     "SataAhci"
 *     OEM Revision     0x00001000 (4096)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20110112 (537985298)
 */
DefinitionBlock ("", "SSDT", 1, "HPQOEM", "SataAhci", 0x00001000)
{
    External (_SB_.PCI0.SATA, DeviceObj)
    External (_SB_.PEPD, UnknownObj)
    External (DAMS, UnknownObj)
    External (DVS0, UnknownObj)
    External (DVS1, UnknownObj)
    External (DVS2, UnknownObj)
    External (DVS3, UnknownObj)
    External (GPIE, UnknownObj)
    External (GPIS, UnknownObj)
    External (ODDI, UnknownObj)
    External (ODDL, IntObj)
    External (ODDS, UnknownObj)
    External (ODPL, UnknownObj)
    External (OSYS, UnknownObj)
    External (PEPC, UnknownObj)
    External (S0ID, UnknownObj)

    Scope (\_SB.PCI0.SATA)
    {
        Method (_DEP, 0, NotSerialized)  // _DEP: Dependencies
        {
            If ((OSYS >= 0x07DD))
            {
                If (((S0ID == 0x01) && ((PEPC & 0x03) != 0x00)))
                {
                    Return (Package (0x01)
                    {
                        \_SB.PEPD
                    })
                }
            }

            Return (Package (0x00){})
        }

        Device (PRT0)
        {
            Name (_ADR, 0xFFFF)  // _ADR: Address
            Name (FDEV, Zero)
            Name (FDRP, Zero)
            Method (_SDD, 1, Serialized)  // _SDD: Set Device Data
            {
                CreateByteField (Arg0, 0x9D, BFDS)
                ToInteger (BFDS, FDEV) /* \_SB_.PCI0.SATA.PRT0.FDEV */
                CreateByteField (Arg0, 0x9A, BFRP)
                ToInteger (BFRP, FDRP) /* \_SB_.PCI0.SATA.PRT0.FDRP */
            }

            Method (_GTF, 0, Serialized)  // _GTF: Get Task File
            {
                If ((((DVS0 == 0x01) && ((FDEV & 0x01) == 0x01)) && 
                    ((FDRP & 0x80) == 0x80)))
                {
                    Name (PIB1, Buffer (0x07)
                    {
                         0x10, 0x09, 0x00, 0x00, 0x00, 0xB0, 0xEF         // .......
                    })
                    Return (PIB1) /* \_SB_.PCI0.SATA.PRT0._GTF.PIB1 */
                }

                Name (PIB2, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                })
                Return (PIB2) /* \_SB_.PCI0.SATA.PRT0._GTF.PIB2 */
            }
        }

        Device (PRT1)
        {
            Name (_ADR, 0x0001FFFF)  // _ADR: Address
            Name (FDEV, Zero)
            Name (FDRP, Zero)
            Method (_SDD, 1, Serialized)  // _SDD: Set Device Data
            {
                CreateByteField (Arg0, 0x9D, BFDS)
                ToInteger (BFDS, FDEV) /* \_SB_.PCI0.SATA.PRT1.FDEV */
                CreateByteField (Arg0, 0x9A, BFRP)
                ToInteger (BFRP, FDRP) /* \_SB_.PCI0.SATA.PRT1.FDRP */
            }

            Method (_GTF, 0, Serialized)  // _GTF: Get Task File
            {
                If ((((DVS1 == 0x01) && ((FDEV & 0x01) == 0x01)) && 
                    ((FDRP & 0x80) == 0x80)))
                {
                    Name (PIB1, Buffer (0x07)
                    {
                         0x10, 0x09, 0x00, 0x00, 0x00, 0xB0, 0xEF         // .......
                    })
                    Return (PIB1) /* \_SB_.PCI0.SATA.PRT1._GTF.PIB1 */
                }

                Name (PIB2, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                })
                Return (PIB2) /* \_SB_.PCI0.SATA.PRT1._GTF.PIB2 */
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((DAMS == 0x01))
                {
                    Return (HDSM (Arg0, Arg1, Arg2, Arg3))
                }
            }
        }

        Device (PRT2)
        {
            Name (_ADR, 0x0002FFFF)  // _ADR: Address
            Name (FDEV, Zero)
            Name (FDRP, Zero)
            Method (_SDD, 1, Serialized)  // _SDD: Set Device Data
            {
                CreateByteField (Arg0, 0x9D, BFDS)
                ToInteger (BFDS, FDEV) /* \_SB_.PCI0.SATA.PRT2.FDEV */
                CreateByteField (Arg0, 0x9A, BFRP)
                ToInteger (BFRP, FDRP) /* \_SB_.PCI0.SATA.PRT2.FDRP */
            }

            Method (_GTF, 0, Serialized)  // _GTF: Get Task File
            {
                If ((((DVS2 == 0x01) && ((FDEV & 0x01) == 0x01)) && 
                    ((FDRP & 0x80) == 0x80)))
                {
                    Name (PIB1, Buffer (0x07)
                    {
                         0x10, 0x09, 0x00, 0x00, 0x00, 0xB0, 0xEF         // .......
                    })
                    Return (PIB1) /* \_SB_.PCI0.SATA.PRT2._GTF.PIB1 */
                }

                Name (PIB2, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                })
                Return (PIB2) /* \_SB_.PCI0.SATA.PRT2._GTF.PIB2 */
            }
        }

        Device (PRT3)
        {
            Name (_ADR, 0x0003FFFF)  // _ADR: Address
            Name (FDEV, Zero)
            Name (FDRP, Zero)
            Method (_SDD, 1, Serialized)  // _SDD: Set Device Data
            {
                CreateByteField (Arg0, 0x9D, BFDS)
                ToInteger (BFDS, FDEV) /* \_SB_.PCI0.SATA.PRT3.FDEV */
                CreateByteField (Arg0, 0x9A, BFRP)
                ToInteger (BFRP, FDRP) /* \_SB_.PCI0.SATA.PRT3.FDRP */
            }

            Method (_GTF, 0, Serialized)  // _GTF: Get Task File
            {
                If ((((DVS3 == 0x01) && ((FDEV & 0x01) == 0x01)) && 
                    ((FDRP & 0x80) == 0x80)))
                {
                    Name (PIB1, Buffer (0x07)
                    {
                         0x10, 0x09, 0x00, 0x00, 0x00, 0xB0, 0xEF         // .......
                    })
                    Return (PIB1) /* \_SB_.PCI0.SATA.PRT3._GTF.PIB1 */
                }

                Name (PIB2, Buffer (0x07)
                {
                     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00         // .......
                })
                Return (PIB2) /* \_SB_.PCI0.SATA.PRT3._GTF.PIB2 */
            }
        }

        Device (PRT4)
        {
            Name (_ADR, 0x0004FFFF)  // _ADR: Address
            Name (GTF4, Buffer (0x07)
            {
                 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         // .......
            })
            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                GTF4 = Buffer (0x07)
                    {
                         0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         // .......
                    }
                Return (GTF4) /* \_SB_.PCI0.SATA.PRT4.GTF4 */
            }
        }

        Device (PRT5)
        {
            Name (_ADR, 0x0005FFFF)  // _ADR: Address
            Name (GTF5, Buffer (0x07)
            {
                 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         // .......
            })
            Method (_GTF, 0, NotSerialized)  // _GTF: Get Task File
            {
                GTF5 = Buffer (0x07)
                    {
                         0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00         // .......
                    }
                Return (GTF5) /* \_SB_.PCI0.SATA.PRT5.GTF5 */
            }
        }
    }

    Method (HDSM, 4, Serialized)
    {
        If ((Arg0 == ToUUID ("bdfaef30-aebb-11de-8a39-0800200c9a66") /* Unknown UUID */))
        {
            If ((ToInteger (Arg2) == 0x00))
            {
                If ((ToInteger (Arg1) == 0x01))
                {
                    Return (Buffer (0x01)
                    {
                         0x0F                                             // .
                    })
                }
                Else
                {
                    Return (Buffer (0x01)
                    {
                         0x00                                             // .
                    })
                }
            }
            ElseIf ((ToInteger (Arg2) == 0x01))
            {
                Return (0x01)
            }
            ElseIf ((ToInteger (Arg2) == 0x02))
            {
                ODDS = 0x00
                If (ODDL)
                {
                    ODDI = 0x01
                }
                Else
                {
                    ODDI = 0x00
                }

                ODPL = 0x00
                Sleep (0xC8)
                GPIS |= 0x08
                Local1 = (GPIE & 0x08)
                If ((Local1 != 0x08))
                {
                    Local0 = (GPIE | 0x08)
                    GPIE = Local0
                }

                ODDS = 0x01
                Return (0x01)
            }
            ElseIf ((ToInteger (Arg2) == 0x03))
            {
                GPIE &= ~0x08
                GPIS |= 0x08
                ODDS = 0x00
                ODPL = 0x01
                Sleep (0x02BC)
                ODDS = 0x01
                Return (0x01)
            }
            Else
            {
                Return (0x00)
            }
        }
        Else
        {
            Return (0x00)
        }
    }
}

