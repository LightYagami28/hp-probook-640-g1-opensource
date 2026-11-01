                Device (EC0)
                {
                    Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
                    Name (_UID, 0x01)  // _UID: Unique ID
                    Name (_GPE, 0x16)  // _GPE: General Purpose Events
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0062,             // Range Minimum
                            0x0062,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                        IO (Decode16,
                            0x0066,             // Range Minimum
                            0x0066,             // Range Maximum
                            0x01,               // Alignment
                            0x01,               // Length
                            )
                    })
                    Mutex (ECMX, 0x00)
                    Name (ECRG, 0x00)
                    Name (HSWK, 0x00)
                    Method (ECRI, 0, Serialized)
                    {
                        OST = \WCOS ()
                        PWUP (0x07, 0xFF)
                        Local0 = GBAP ()
                        ITLB ()
                        SBTN (Local0, 0x81)
                        PRIT ()
                    }

                    Method (_REG, 2, NotSerialized)  // _REG: Region Availability
                    {
                        If ((Arg0 == 0x03))
                        {
                            ECRG = Arg1
                            Local1 = ((\WCOS () == 0x01) || (\WCOS () == 0x02))
                            If ((Arg1 && !Local1))
                            {
                                ECRI ()
                            }
                        }
                    }

                    OperationRegion (ECRM, EmbeddedControl, 0x00, 0xFF)
                    Field (ECRM, ByteAcc, NoLock, Preserve)
                    {
                        PMCD,   32, 
                        S0FL,   8, 
                        SXF0,   8, 
                        SXF1,   8, 
                        CPWR,   16, 
                        CVLT,   16, 
                        CCUR,   16, 
                        DIDX,   8, 
                        CIDX,   8, 
                        PMCC,   8, 
                        PMEP,   8, 
                        Offset (0x22), 
                        CRZN,   8, 
                        THTA,   8, 
                        HYST,   8, 
                        CRIT,   8, 
                        TEMP,   8, 
                        TENA,   8, 
                        Offset (0x29), 
                        TOAD,   8, 
                        PHTP,   8, 
                        THEM,   8, 
                        TMPO,   8, 
                        Offset (0x2E), 
                        FRDC,   8, 
                        FTGC,   8, 
                        PLTP,   8, 
                        Offset (0x32), 
                        DTMP,   8, 
                        Offset (0x35), 
                        PL1,    8, 
                        PL2,    8, 
                        BCVD,   8, 
                        Offset (0x40), 
                        ABDI,   8, 
                        ABAD,   8, 
                        ABIX,   8, 
                        ABDA,   8, 
                        ABST,   8, 
                        PORI,   8, 
                        Offset (0x4C), 
                        PSSB,   8, 
                        Offset (0x50), 
                        FBCM,   8, 
                        FBGI,   8, 
                        FBAE,   8, 
                        FBCB,   8, 
                        FBW1,   8, 
                        FBW2,   8, 
                        Offset (0x57), 
                        FBID,   8, 
                        FUAE,   8, 
                        FRPS,   8, 
                        Offset (0x60), 
                        SCCB,   8, 
                        SCCS,   8, 
                        SCWT,   16, 
                        SCWD,   16, 
                        Offset (0x80), 
                        Offset (0x81), 
                            ,   4, 
                        SLPT,   4, 
                        FNSW,   1, 
                        SFNC,   1, 
                        ACPI,   1, 
                            ,   1, 
                            ,   1, 
                            ,   1, 
                            ,   1, 
                        DETF,   1, 
                        LIDS,   1, 
                        TBLT,   1, 
                            ,   1, 
                            ,   1, 
                            ,   1, 
                        COMM,   1, 
                        PME,    1, 
                        SBVD,   1, 
                        ADP,    1, 
                        ADID,   2, 
                        LCTV,   1, 
                        BATP,   4, 
                        BPU,    1, 
                        Offset (0x86), 
                        BSEL,   4, 
                        Offset (0x87), 
                        LB1,    8, 
                        LB2,    8, 
                        BDC,    16, 
                        Offset (0x8D), 
                        BFC,    16, 
                        BRTE,   16, 
                        BTC,    1, 
                        Offset (0x92), 
                        BME,    16, 
                        BDN,    8, 
                        BDV,    16, 
                        BCV1,   16, 
                        BST,    4, 
                        Offset (0x9B), 
                        BATE,   16, 
                        BPR,    16, 
                        BCR,    16, 
                        BRC,    16, 
                        BCC,    16, 
                        BPV,    16, 
                        BCV2,   16, 
                        BCV3,   16, 
                        BCV4,   16, 
                        BCW,    16, 
                        BATF,   16, 
                        BCL,    16, 
                        MAXC,   16, 
                        BCG1,   8, 
                        BT1I,   1, 
                        BT2I,   1, 
                            ,   2, 
                        BATN,   4, 
                        BSTS,   16, 
                        BCG2,   8, 
                        Offset (0xBD), 
                        BMO,    8, 
                        Offset (0xBF), 
                        BRCV,   8, 
                        Offset (0xC1), 
                        BIF,    8, 
                        BRCC,   8, 
                        Offset (0xC9), 
                        BSN,    16, 
                        BDAT,   16, 
                        BMF,    8, 
                        Offset (0xCF), 
                        CTLB,   8, 
                        Offset (0xD1), 
                        BTY,    8, 
                        Offset (0xD5), 
                        MFAC,   8, 
                        CFAN,   8, 
                        PFAN,   8, 
                        OCPS,   8, 
                        OCPR,   8, 
                        OCPE,   8, 
                        TMP1,   8, 
                        TMP2,   8, 
                        NABT,   4, 
                        BCM,    4, 
                        CCBQ,   16, 
                        CBT,    16, 
                        Offset (0xE3), 
                        OST,    4, 
                        Offset (0xE4), 
                        Offset (0xE5), 
                        TPTE,   1, 
                        TBBN,   1, 
                            ,   3, 
                        TP,     1, 
                        Offset (0xE6), 
                        SHK,    8, 
                        AUDS,   1, 
                        SPKR,   1, 
                        Offset (0xE8), 
                        HSEN,   4, 
                        HSST,   4, 
                        Offset (0xEA), 
                            ,   2, 
                        WWP,    1, 
                        WLP,    1, 
                            ,   1, 
                        WWS3,   1, 
                        WLS3,   1, 
                        Offset (0xEF), 
                        INCH,   2, 
                        IDIS,   2, 
                        INAC,   1
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        If (((\WCOS () == 0x01) || (\WCOS () == 0x02)))
                        {
                            ECRI ()
                        }
                    }

                    OperationRegion (MAIO, SystemIO, 0x0200, 0x02)
                    Field (MAIO, ByteAcc, NoLock, Preserve)
                    {
                        MAIN,   8, 
                        MADT,   8
                    }

                    IndexField (MAIN, MADT, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x8C), 
                            ,   7, 
                        CLID,   1, 
                        Offset (0x95), 
                        PWM0,   8, 
                        Offset (0x9D), 
                        PWMC,   8
                    }

                    Method (KFCL, 2, NotSerialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            MFAC = Arg1
                            If (((Arg0 >= 0x00) && (Arg0 <= 0x64)))
                            {
                                CFAN = Arg0
                            }
                        }

                        Release (ECMX)
                    }

                    Method (KSFS, 1, NotSerialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            CFAN = Arg0
                        }

                        Release (ECMX)
                    }

                    Method (KGFS, 0, NotSerialized)
                    {
                        Local0 = 0x14
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = CFAN /* \_SB_.PCI0.LPCB.EC0_.CFAN */
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (KRFS, 0, NotSerialized)
                    {
                        Local0 = 0x1E
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = PFAN /* \_SB_.PCI0.LPCB.EC0_.PFAN */
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (SFSD, 1, Serialized)
                    {
                        Local1 = (Arg0 * 0x40)
                        Divide (Local1, 0x64, Local2, Local0)
                        Local0 = (0x40 - Local0)
                        Local1 = (PWM0 & 0x80)
                        If ((Local0 == 0x40))
                        {
                            Local1 |= 0x01
                        }
                        Else
                        {
                            Local0 <<= 0x01
                            Local1 |= Local0
                        }

                        PWM0 = Local1
                    }

                    Method (GFSD, 0, Serialized)
                    {
                        Local0 = (PWM0 & 0x7F)
                        If ((Local0 & 0x01))
                        {
                            Local1 = 0x00
                        }
                        Else
                        {
                            Local0 >>= 0x01
                            Local0 = (0x40 - Local0)
                            Local0 *= 0x64
                            Divide ((Local0 + 0x20), 0x40, Local2, Local1)
                            Local1++
                        }

                        Return (Local1)
                    }

                    Method (GSHK, 0, Serialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = SHK /* \_SB_.PCI0.LPCB.EC0_.SHK_ */
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (SSHK, 1, Serialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Debug = Arg0
                            SHK = Arg0
                        }

                        Release (ECMX)
                    }

                    Method (SAST, 1, Serialized)
                    {
                        Local0 = 0x00
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            AUDS = Arg0
                            Local0 = 0x01
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (HSPW, 2, Serialized)
                    {
                        If (HSED)
                        {
                            Local0 = HSWK /* \_SB_.PCI0.LPCB.EC0_.HSWK */
                            If (Arg0)
                            {
                                HSWK = (Local0 | Arg1)
                            }
                            Else
                            {
                                HSWK = (Local0 & ~Arg1)
                            }
                        }
                        Else
                        {
                            HSWK = 0x00
                        }
                    }

                    Method (UHSW, 0, Serialized)
                    {
                    }

                    Method (CHSW, 1, Serialized)
                    {
                        Local1 = 0x00
                        Return (Local1)
                    }

                    Method (SHSW, 2, Serialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            If (Arg1)
                            {
                                HSEN |= Arg0
                            }
                            Else
                            {
                                HSEN &= ~Arg0
                            }
                        }

                        Release (ECMX)
                    }

                    Method (HWLP, 1, NotSerialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            WLP = (Arg0 ^ 0x00)
                        }

                        Release (ECMX)
                    }

                    Method (HWWP, 1, Serialized)
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            If (((WWIX & 0x80) && (Arg0 == 0x00)))
                            {
                                Sleep (0x1388)
                            }

                            WWP = ((Arg0 & 0x01) ^ 0x01)
                        }

                        Release (ECMX)
                    }

                    Method (ECAB, 4, Serialized)
                    {
                        Local0 = 0xECAB
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = 0xFF00
                            ABDI = Arg0
                            ABAD = Arg1
                            ABIX = Arg2
                            If (((Arg1 & 0x01) == 0x00))
                            {
                                ABDA = Arg3
                            }

                            ABST = 0xFF
                            Sleep (0x5A)
                            Local0 = 0x80
                            Local1 = 0x0B
                            While (((Local0 & 0x80) && (Local1 > 0x00)))
                            {
                                Sleep (0x0A)
                                Local0 = ABST /* \_SB_.PCI0.LPCB.EC0_.ABST */
                                Local1--
                            }

                            Local0 <<= 0x08
                            If (((Local0 == 0x00) && (Arg1 & 0x01)))
                            {
                                Local1 = (ABDA & 0xFF)
                                Local0 |= Local1
                            }
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Name (NGBF, 0xFF)
                    Name (NGBT, 0xFF)
                    Name (GACP, 0x07)
                    Name (ACST, 0x01)
                    Name (SMAR, 0x00)
                    Name (NBAP, 0x00)
                    Name (NNBO, 0x01)
                    Name (NDCB, 0x00)
                    Name (NLB1, 0xC8)
                    Name (NLB2, 0x64)
                    Mutex (BTMX, 0x00)
                    Method (UPAD, 0, Serialized)
                    {
                        Acquire (BTMX, 0xFFFF)
                        If ((GACP & 0x01))
                        {
                            GACP &= 0x06
                            Release (BTMX)
                            Local0 = 0x01
                            Local1 = 0x00
                            Acquire (ECMX, 0xFFFF)
                            If (ECRG)
                            {
                                Local0 = ADP /* \_SB_.PCI0.LPCB.EC0_.ADP_ */
                                Local1 = ADID /* \_SB_.PCI0.LPCB.EC0_.ADID */
                            }

                            Release (ECMX)
                            ACST = Local0
                            If ((DTCD & 0x0800))
                            {
                                If ((DTCD & 0x1000))
                                {
                                    ACST = 0x00
                                }
                                Else
                                {
                                    ACST = 0x01
                                }
                            }

                            SMAR = Local1
                        }
                        Else
                        {
                            Release (BTMX)
                        }
                    }

                    Method (GACS, 0, Serialized)
                    {
                        UPAD ()
                        Return (ACST) /* \_SB_.PCI0.LPCB.EC0_.ACST */
                    }

                    Method (GPID, 0, Serialized)
                    {
                        UPAD ()
                        Return (SMAR) /* \_SB_.PCI0.LPCB.EC0_.SMAR */
                    }

                    Method (GBAP, 0, Serialized)
                    {
                        Acquire (BTMX, 0xFFFF)
                        If ((GACP & 0x02))
                        {
                            GACP &= 0x05
                            Release (BTMX)
                            Acquire (ECMX, 0xFFFF)
                            If (ECRG)
                            {
                                NBAP = BATP /* \_SB_.PCI0.LPCB.EC0_.BATP */
                            }

                            Release (ECMX)
                        }
                        Else
                        {
                            Release (BTMX)
                        }

                        Return (NBAP) /* \_SB_.PCI0.LPCB.EC0_.NBAP */
                    }

                    Method (PWUP, 2, Serialized)
                    {
                        Local0 = 0x00
                        Acquire (BTMX, 0xFFFF)
                        Local1 = (Arg0 | GACP) /* \_SB_.PCI0.LPCB.EC0_.GACP */
                        GACP = (Local1 & 0x07)
                        If ((GACP & 0x02))
                        {
                            NGBF |= Arg1
                        }

                        If ((GACP & 0x04))
                        {
                            If ((NGBT != 0xFF))
                            {
                                Local0 = 0x01
                            }

                            NGBT |= Arg1
                        }

                        Release (BTMX)
                        Return (Local0)
                    }

                    Method (BTDR, 1, Serialized)
                    {
                        If ((Arg0 == 0x01))
                        {
                            NNBO = 0x01
                        }
                        ElseIf ((Arg0 == 0x00))
                        {
                            NNBO = 0x00
                        }

                        Return (NNBO) /* \_SB_.PCI0.LPCB.EC0_.NNBO */
                    }

                    Method (BSTA, 1, Serialized)
                    {
                        BTDR (0x01)
                        Local0 = GBAP ()
                        Local1 = 0x0F
                        If ((Local0 & Arg0))
                        {
                            Local1 = 0x1F
                        }

                        Return (Local1)
                    }

                    Method (GBSS, 2, Serialized)
                    {
                        ToBCD (Arg0, Local0)
                        Local3 = \ISTR (Local0, 0x05)
                        Concatenate (Local3, " ", Local4)
                        Local0 = (Arg1 >> 0x09)
                        Local1 = (Local0 + 0x07BC)
                        ToBCD (Local1, Local0)
                        Local2 = \ISTR (Local0, 0x04)
                        Concatenate (Local4, Local2, Local3)
                        Concatenate (Local3, "/", Local4)
                        Local0 = (Arg1 >> 0x05)
                        Local1 = (Local0 & 0x0F)
                        ToBCD (Local1, Local0)
                        Local2 = \ISTR (Local0, 0x02)
                        Concatenate (Local4, Local2, Local3)
                        Concatenate (Local3, "/", Local4)
                        Local1 = (Arg1 & 0x1F)
                        ToBCD (Local1, Local0)
                        Local2 = \ISTR (Local0, 0x02)
                        Concatenate (Local4, Local2, Local3)
                        Return (Local3)
                    }

                    Method (GBMF, 0, Serialized)
                    {
                        Local0 = Buffer (0x12){}
                        Local3 = 0x00
                        Local1 = BMF /* \_SB_.PCI0.LPCB.EC0_.BMF_ */
                        While (((Local3 < 0x10) && (Local1 != 0x00)))
                        {
                            Local0 [Local3] = Local1
                            Local3++
                            Local1 = BMF /* \_SB_.PCI0.LPCB.EC0_.BMF_ */
                        }

                        Return (Local0)
                    }

                    Method (GCTL, 1, Serialized)
                    {
                        Name (CTBF, Buffer (0x10){})
                        Local3 = 0x00
                        Local2 = 0x00
                        While ((Local3 != 0x10))
                        {
                            CTBF [Local2] = CTLB /* \_SB_.PCI0.LPCB.EC0_.CTLB */
                            Local2++
                            Local3++
                        }

                        Return (CTBF) /* \_SB_.PCI0.LPCB.EC0_.GCTL.CTBF */
                    }

                    Method (GDNM, 1, Serialized)
                    {
                        Name (DNBF, Buffer (0x07){})
                        Local3 = 0x00
                        Local2 = 0x00
                        While ((Local3 != 0x07))
                        {
                            DNBF [Local2] = BDN /* \_SB_.PCI0.LPCB.EC0_.BDN_ */
                            Local2++
                            Local3++
                        }

                        Return (DNBF) /* \_SB_.PCI0.LPCB.EC0_.GDNM.DNBF */
                    }

                    Method (GDCH, 1, Serialized)
                    {
                        Name (DCBF, Buffer (0x04){})
                        Local3 = 0x00
                        Local2 = 0x00
                        While ((Local3 != 0x04))
                        {
                            DCBF [Local2] = BTY /* \_SB_.PCI0.LPCB.EC0_.BTY_ */
                            Local2++
                            Local3++
                        }

                        Return (DCBF) /* \_SB_.PCI0.LPCB.EC0_.GDCH.DCBF */
                    }

                    Method (BTIF, 1, Serialized)
                    {
                        Local7 = (0x01 << Arg0)
                        BTDR (0x01)
                        If ((BSTA (Local7) == 0x0F))
                        {
                            Return (0xFF)
                        }

                        Acquire (BTMX, 0xFFFF)
                        Local0 = NGBF /* \_SB_.PCI0.LPCB.EC0_.NGBF */
                        Release (BTMX)
                        If (((Local0 & Local7) == 0x00))
                        {
                            Return (0x00)
                        }

                        NBST [Arg0] = NDBS /* \_SB_.NDBS */
                        Acquire (BTMX, 0xFFFF)
                        NGBT |= Local7
                        Release (BTMX)
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            BSEL = Arg0
                            Local0 = BFC /* \_SB_.PCI0.LPCB.EC0_.BFC_ */
                            DerefOf (NBTI [Arg0]) [0x01] = Local0
                            DerefOf (NBTI [Arg0]) [0x02] = Local0
                            DerefOf (NBTI [Arg0]) [0x04] = BDV /* \_SB_.PCI0.LPCB.EC0_.BDV_ */
                            DerefOf (NBTI [Arg0]) [0x05] = NLB1 /* \_SB_.PCI0.LPCB.EC0_.NLB1 */
                            DerefOf (NBTI [Arg0]) [0x06] = NLB2 /* \_SB_.PCI0.LPCB.EC0_.NLB2 */
                            Local0 = BSN /* \_SB_.PCI0.LPCB.EC0_.BSN_ */
                            Local1 = BDAT /* \_SB_.PCI0.LPCB.EC0_.BDAT */
                        }

                        Release (ECMX)
                        Local2 = GBSS (Local0, Local1)
                        DerefOf (NBTI [Arg0]) [0x0A] = Local2
                        Acquire (BTMX, 0xFFFF)
                        NGBF &= ~Local7
                        Release (BTMX)
                        Return (0x00)
                    }

                    Method (BTST, 2, Serialized)
                    {
                        Local7 = (0x01 << Arg0)
                        BTDR (0x01)
                        If ((BSTA (Local7) == 0x0F))
                        {
                            NBST [Arg0] = Package (0x04)
                                {
                                    0x00, 
                                    0xFFFFFFFF, 
                                    0xFFFFFFFF, 
                                    0xFFFFFFFF
                                }
                            Return (0xFF)
                        }

                        Acquire (BTMX, 0xFFFF)
                        If (Arg1)
                        {
                            NGBT = 0xFF
                        }

                        Local0 = NGBT /* \_SB_.PCI0.LPCB.EC0_.NGBT */
                        Release (BTMX)
                        If (((Local0 & Local7) == 0x00))
                        {
                            Return (0x00)
                        }

                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            BSEL = Arg0
                            Local0 = BST /* \_SB_.PCI0.LPCB.EC0_.BST_ */
                            Local3 = BPR /* \_SB_.PCI0.LPCB.EC0_.BPR_ */
                            DerefOf (NBST [Arg0]) [0x02] = BRC /* \_SB_.PCI0.LPCB.EC0_.BRC_ */
                            DerefOf (NBST [Arg0]) [0x03] = BPV /* \_SB_.PCI0.LPCB.EC0_.BPV_ */
                        }

                        Release (ECMX)
                        If ((GACS () == 0x01))
                        {
                            Local0 &= ~0x01
                        }
                        Else
                        {
                            Local0 &= ~0x02
                        }

                        If ((Local0 & 0x01))
                        {
                            Acquire (BTMX, 0xFFFF)
                            NDCB = Local7
                            Release (BTMX)
                        }

                        DerefOf (NBST [Arg0]) [0x00] = Local0
                        If ((Local0 & 0x01))
                        {
                            If (((Local3 < 0x0190) || (Local3 > 0x1964)))
                            {
                                Local5 = DerefOf (DerefOf (NBST [Arg0]) [0x01])
                                If (((Local5 < 0x0190) || (Local5 > 0x1964)))
                                {
                                    Local3 = (0x1AF4 / 0x02)
                                }
                                Else
                                {
                                    Local3 = Local5
                                }
                            }
                        }
                        ElseIf (((Local0 & 0x02) == 0x00))
                        {
                            Local3 = 0x00
                        }

                        DerefOf (NBST [Arg0]) [0x01] = Local3
                        Acquire (BTMX, 0xFFFF)
                        NGBT &= ~Local7
                        Release (BTMX)
                        Return (0x00)
                    }

                    Method (ITLB, 0, NotSerialized)
                    {
                        Divide ((NLB1 + 0x09), 0x0A, Local0, Local1)
                        Divide ((0x96 + 0x09), 0x0A, Local0, Local2)
                        If (ECRG)
                        {
                            LB1 = Local1
                            LB2 = Local2
                        }
                    }

                    Method (GBTI, 1, NotSerialized)
                    {
                        Debug = "Enter getbattinfo"
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            If ((BATP & (0x01 << Arg0)))
                            {
                                BSEL = Arg0
                                Local0 = Package (0x03)
                                    {
                                        0x00, 
                                        0x6B, 
                                        Buffer (0x6B){}
                                    }
                                DerefOf (Local0 [0x02]) [0x00] = BDC /* \_SB_.PCI0.LPCB.EC0_.BDC_ */
                                DerefOf (Local0 [0x02]) [0x01] = (BDC >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x02] = BFC /* \_SB_.PCI0.LPCB.EC0_.BFC_ */
                                DerefOf (Local0 [0x02]) [0x03] = (BFC >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x04] = BRC /* \_SB_.PCI0.LPCB.EC0_.BRC_ */
                                DerefOf (Local0 [0x02]) [0x05] = (BRC >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x06] = BME /* \_SB_.PCI0.LPCB.EC0_.BME_ */
                                DerefOf (Local0 [0x02]) [0x07] = (BME >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x08] = BCC /* \_SB_.PCI0.LPCB.EC0_.BCC_ */
                                DerefOf (Local0 [0x02]) [0x09] = (BCC >> 0x08
                                    )
                                Local1 = CBT /* \_SB_.PCI0.LPCB.EC0_.CBT_ */
                                Local1 -= 0x0AAC
                                Divide (Local1, 0x0A, Local2, Local3)
                                DerefOf (Local0 [0x02]) [0x0A] = Local3
                                DerefOf (Local0 [0x02]) [0x0B] = (Local3 >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x0C] = BPV /* \_SB_.PCI0.LPCB.EC0_.BPV_ */
                                DerefOf (Local0 [0x02]) [0x0D] = (BPV >> 0x08
                                    )
                                Local1 = BPR /* \_SB_.PCI0.LPCB.EC0_.BPR_ */
                                If (Local1)
                                {
                                    If ((BSTS & 0x40))
                                    {
                                        Local1 = (~Local1 + 0x01)
                                        Local1 &= 0xFFFF
                                    }
                                }

                                DerefOf (Local0 [0x02]) [0x0E] = Local1
                                DerefOf (Local0 [0x02]) [0x0F] = (Local1 >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x10] = BDV /* \_SB_.PCI0.LPCB.EC0_.BDV_ */
                                DerefOf (Local0 [0x02]) [0x11] = (BDV >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x12] = BSTS /* \_SB_.PCI0.LPCB.EC0_.BSTS */
                                DerefOf (Local0 [0x02]) [0x13] = (BSTS >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x14] = BCV1 /* \_SB_.PCI0.LPCB.EC0_.BCV1 */
                                DerefOf (Local0 [0x02]) [0x15] = (BCV1 >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x16] = BCV2 /* \_SB_.PCI0.LPCB.EC0_.BCV2 */
                                DerefOf (Local0 [0x02]) [0x17] = (BCV2 >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x18] = BCV3 /* \_SB_.PCI0.LPCB.EC0_.BCV3 */
                                DerefOf (Local0 [0x02]) [0x19] = (BCV3 >> 0x08
                                    )
                                DerefOf (Local0 [0x02]) [0x1A] = BCV4 /* \_SB_.PCI0.LPCB.EC0_.BCV4 */
                                DerefOf (Local0 [0x02]) [0x1B] = (BCV4 >> 0x08
                                    )
                                CreateField (DerefOf (Local0 [0x02]), (0x1C * 0x08), (0x10 * 
                                    0x08), BTSN)
                                BTSN = GBSS (BSN, BDAT)
                                Local1 = GBMF ()
                                Local2 = SizeOf (Local1)
                                CreateField (DerefOf (Local0 [0x02]), (0x2C * 0x08), (Local2 * 
                                    0x08), BMAN)
                                BMAN = Local1
                                Local2 += 0x2C
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x10 * 
                                    0x08), CLBL)
                                CLBL = GCTL (0x00)
                                Local2 += 0x11
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x07 * 
                                    0x08), DNAM)
                                DNAM = GDNM (0x00)
                                Local2 += 0x07
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x04 * 
                                    0x08), DCHE)
                                DCHE = GDCH (0x00)
                                Local2 += 0x04
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), BMAC)
                                BMAC = 0x00
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), BMAD)
                                BMAD = BDAT /* \_SB_.PCI0.LPCB.EC0_.BDAT */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), BCCU)
                                BCCU = BRCC /* \_SB_.PCI0.LPCB.EC0_.BRCC */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), BCVO)
                                BCVO = BRCV /* \_SB_.PCI0.LPCB.EC0_.BRCV */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), BAVC)
                                Local1 = BCR /* \_SB_.PCI0.LPCB.EC0_.BCR_ */
                                If (Local1)
                                {
                                    If ((BSTS & 0x40))
                                    {
                                        Local1 = (~Local1 + 0x01)
                                        Local1 &= 0xFFFF
                                    }
                                }

                                BAVC = Local1
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), RTTE)
                                RTTE = BRTE /* \_SB_.PCI0.LPCB.EC0_.BRTE */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), ATTE)
                                RTTE = BATE /* \_SB_.PCI0.LPCB.EC0_.BATE */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x02 * 
                                    0x08), ATTF)
                                RTTE = BATF /* \_SB_.PCI0.LPCB.EC0_.BATF */
                                Local2 += 0x02
                                CreateField (DerefOf (Local0 [0x02]), (Local2 * 0x08), (0x01 * 
                                    0x08), NOBS)
                                NOBS = BATN /* \_SB_.PCI0.LPCB.EC0_.BATN */
                            }
                            Else
                            {
                                Local0 = Package (0x02)
                                    {
                                        0x34, 
                                        0x00
                                    }
                            }
                        }
                        Else
                        {
                            Local0 = Package (0x02)
                                {
                                    0x0D, 
                                    0x00
                                }
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (GBTC, 0, NotSerialized)
                    {
                        Debug = "Enter GetBatteryControl"
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = Package (0x03)
                                {
                                    0x00, 
                                    0x04, 
                                    Buffer (0x04){}
                                }
                            If ((BATP & 0x01))
                            {
                                BSEL = 0x00
                                DerefOf (Local0 [0x02]) [0x00] = 0x00
                                If ((((INAC == 0x00) && (INCH == 0x00)) && (IDIS == 0x00)))
                                {
                                    DerefOf (Local0 [0x02]) [0x00] = 0x00
                                }
                                ElseIf (((((INAC == 0x00) && (INCH == 0x02)) && (
                                    IDIS == 0x01)) && (MAXC == 0x00)))
                                {
                                    DerefOf (Local0 [0x02]) [0x00] = 0x01
                                }
                                ElseIf (((INAC == 0x01) && (IDIS == 0x02)))
                                {
                                    DerefOf (Local0 [0x02]) [0x00] = 0x02
                                }
                                ElseIf (((((INAC == 0x00) && (INCH == 0x02)) && (
                                    IDIS == 0x01)) && (MAXC == 0xFA)))
                                {
                                    DerefOf (Local0 [0x02]) [0x00] = 0x03
                                }
                                ElseIf (((INAC == 0x00) && (INCH == 0x03)))
                                {
                                    DerefOf (Local0 [0x02]) [0x00] = 0x04
                                }
                            }
                            Else
                            {
                                DerefOf (Local0 [0x02]) [0x00] = 0xFF
                            }

                            If ((BATP & 0x02))
                            {
                                BSEL = 0x01
                                DerefOf (Local0 [0x02]) [0x01] = 0x00
                                If ((((INAC == 0x00) && (INCH == 0x00)) && (IDIS == 0x00)))
                                {
                                    DerefOf (Local0 [0x02]) [0x01] = 0x00
                                }
                                ElseIf (((((INAC == 0x00) && (INCH == 0x01)) && (
                                    IDIS == 0x02)) && (MAXC == 0x00)))
                                {
                                    DerefOf (Local0 [0x02]) [0x01] = 0x01
                                }
                                ElseIf (((INAC == 0x01) && (IDIS == 0x01)))
                                {
                                    DerefOf (Local0 [0x02]) [0x01] = 0x02
                                }
                                ElseIf (((((INAC == 0x00) && (INCH == 0x01)) && (
                                    IDIS == 0x02)) && (MAXC == 0xFA)))
                                {
                                    DerefOf (Local0 [0x02]) [0x01] = 0x03
                                }
                                ElseIf (((INAC == 0x00) && (INCH == 0x03)))
                                {
                                    DerefOf (Local0 [0x02]) [0x01] = 0x04
                                }
                            }
                            Else
                            {
                                DerefOf (Local0 [0x02]) [0x01] = 0xFF
                            }
                        }
                        Else
                        {
                            Local0 = Package (0x02)
                                {
                                    0x35, 
                                    0x00
                                }
                        }

                        Release (ECMX)
                        Return (Local0)
                    }

                    Method (SBTC, 3, NotSerialized)
                    {
                        Debug = "Enter SetBatteryControl"
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = Arg2
                            Debug = Local0
                            Local4 = Package (0x02)
                                {
                                    0x06, 
                                    0x00
                                }
                            Local1 = 0x00
                            Local2 = 0x00
                            Local1 = DerefOf (Local0 [0x10])
                            If ((Local1 == 0x00))
                            {
                                Debug = "battery 0"
                                If ((BATP & 0x01))
                                {
                                    Local2 = DerefOf (Local0 [0x11])
                                    If ((Local2 == 0x00))
                                    {
                                        INCH = 0x00
                                        IDIS = 0x00
                                        INAC = 0x00
                                        MAXC = 0x00
                                        PSSB = 0x01
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x01))
                                    {
                                        INAC = 0x00
                                        INCH = 0x02
                                        IDIS = 0x01
                                        MAXC = 0x00
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x02))
                                    {
                                        INAC = 0x01
                                        INCH = 0x01
                                        IDIS = 0x02
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x03))
                                    {
                                        INCH = 0x02
                                        IDIS = 0x01
                                        INAC = 0x00
                                        MAXC = 0xFA
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x04))
                                    {
                                        MAXC = 0xFA
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x05))
                                    {
                                        INAC = 0x00
                                        INCH = 0x03
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }
                                }
                                Else
                                {
                                    Local4 = Package (0x02)
                                        {
                                            0x34, 
                                            0x00
                                        }
                                }
                            }

                            If ((Local1 == 0x01))
                            {
                                If ((BATP & 0x02))
                                {
                                    Debug = "battery 1"
                                    Local2 = DerefOf (Local0 [0x11])
                                    If ((Local2 == 0x00))
                                    {
                                        INCH = 0x00
                                        IDIS = 0x00
                                        INAC = 0x00
                                        MAXC = 0x00
                                        PSSB = 0x01
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x01))
                                    {
                                        INAC = 0x00
                                        INCH = 0x01
                                        IDIS = 0x02
                                        MAXC = 0x00
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x02))
                                    {
                                        INAC = 0x01
                                        INCH = 0x02
                                        IDIS = 0x01
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x03))
                                    {
                                        INCH = 0x01
                                        IDIS = 0x02
                                        INAC = 0x00
                                        MAXC = 0xFA
                                        PSSB = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x04))
                                    {
                                        INCH = 0x00
                                        IDIS = 0x00
                                        INAC = 0x00
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }

                                    If ((Local2 == 0x05))
                                    {
                                        INAC = 0x00
                                        INCH = 0x03
                                        Local4 = Package (0x02)
                                            {
                                                0x00, 
                                                0x00
                                            }
                                    }
                                }
                                Else
                                {
                                    Local4 = Package (0x02)
                                        {
                                            0x34, 
                                            0x00
                                        }
                                }
                            }
                        }

                        Release (ECMX)
                        Return (Local4)
                    }

                    Mutex (OTMT, 0x00)
                    Name (OTLL, 0x01)
                    Name (OTSI, 0x01)
                    Name (OTRT, 0x00)
                    Name (OTEN, 0x00)
                    Name (LRPC, 0x00)
                    Name (MXCP, 0x00)
                    Name (DCCP, 0x00)
                    Method (_Q03, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Acquire (BTMX, 0xFFFF)
                        Local0 = NDCB /* \_SB_.PCI0.LPCB.EC0_.NDCB */
                        Release (BTMX)
                        PWUP (0x04, Local0)
                        SBTN (Local0, 0x80)
                    }

                    Method (_Q04, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Acquire (OTMT, 0xFFFF)
                        OTLL = GTST ()
                        OTSI = 0x01
                        Release (OTMT)
                        If ((RPPC (0x00) != 0x00))
                        {
                            PPNT ()
                        }
                    }

                    Method (_Q05, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local0 = THEM /* \_SB_.PCI0.LPCB.EC0_.THEM */
                        \_TZ.ECTE (Local0)
                    }

                    Method (_Q06, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        PWUP (0x05, (0x02 | 0x01))
                        If (BTDR (0x02))
                        {
                            Notify (\_SB.AC, 0x80) // Status Change
                        }

                        \_GPE.VBRE (0x00)
                    }

                    Method (_Q08, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        PWUP (0x06, 0x01)
                        Local0 = GBAP ()
                        If ((Local0 != 0x02))
                        {
                            PWUP (0x04, 0x02)
                            If (BTDR (0x02))
                            {
                                Notify (\_SB.BAT1, 0x80) // Status Change
                            }
                        }

                        If (BTDR (0x02))
                        {
                            Notify (\_SB.BAT0, 0x81) // Information Change
                        }
                    }

                    Method (_Q0A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local4 = \_GPE.VLET ()
                        Notify (\_SB.LID, 0x80) // Status Change
                        \_SB.PCI0.ACEL.AJAL ()
                        \_SB.WMID.WGWE (0x08, (\_SB.LID._LID () + 0x01))
                    }

                    Method (_Q09, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        PWUP (0x04, 0x01)
                        If (BTDR (0x02))
                        {
                            Notify (\_SB.BAT0, 0x80) // Status Change
                        }
                    }

                    Method (_Q0B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        \_SB.WMID.WGWE (0x00020000, 0x00)
                    }

                    Method (_Q0C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Local0 = THEM /* \_SB_.PCI0.LPCB.EC0_.THEM */
                        \_TZ.ECTE (Local0)
                    }

                    Method (_Q18, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        PWUP (0x06, 0x02)
                        Local0 = GBAP ()
                        If ((Local0 != 0x01))
                        {
                            PWUP (0x04, 0x01)
                            If (BTDR (0x02))
                            {
                                Notify (\_SB.BAT0, 0x80) // Status Change
                            }
                        }

                        If (BTDR (0x02))
                        {
                            Notify (\_SB.BAT1, 0x81) // Information Change
                        }
                    }

                    Method (_Q19, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        PWUP (0x04, 0x02)
                        If (BTDR (0x02))
                        {
                            Notify (\_SB.BAT1, 0x80) // Status Change
                        }
                    }

                    Method (_Q20, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        Acquire (ECMX, 0xFFFF)
                        If (ECRG)
                        {
                            Local0 = (PSSA & 0x01)
                            Local1 = (PSSB & 0x01)
                            Local2 = (PSSA & 0x02)
                            Local3 = (PSSB & 0x02)
                            Local4 = (PSSA & 0x10)
                            Local5 = (PSSB & 0x10)
                            If (((Local0 != Local1) && (Local0 == 0x00)))
                            {
                                \_SB.WMID.WGWE (0x0F, 0x00)
                                PSSA = PSSB /* \_SB_.PCI0.LPCB.EC0_.PSSB */
                            }
                            ElseIf (((Local4 != Local5) && (Local4 == 0x00)))
                            {
                                \_SB.WMID.WGWE (0x0F, 0x03)
                                PSSA = PSSB /* \_SB_.PCI0.LPCB.EC0_.PSSB */
                            }
                            ElseIf (((Local0 != Local1) && (Local0 == 0x01)))
                            {
                                \_SB.WMID.WGWE (0x0F, 0x01)
                                PSSA = PSSB /* \_SB_.PCI0.LPCB.EC0_.PSSB */
                            }
                            ElseIf (((Local2 != Local3) && (Local2 == 0x02)))
                            {
                                If (!BCIE)
                                {
                                    \_SB.WMID.WGWE (0x10, 0x00)
                                }

                                BCIE = 0x00
                                PSSA = PSSB /* \_SB_.PCI0.LPCB.EC0_.PSSB */
                            }
                            ElseIf (((Local2 != Local3) && (Local2 == 0x00)))
                            {
                                If (!BCIE)
                                {
                                    \_SB.WMID.WGWE (0x10, 0x01)
                                }

                                BCIE = 0x00
                                PSSA = PSSB /* \_SB_.PCI0.LPCB.EC0_.PSSB */
                            }
                        }

                        Release (ECMX)
                    }

                    Method (_Q21, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
                    {
                        If (CondRefOf (\_SB.ISCT))
                        {
                            Notify (\_SB.ISCT, 0x80) // Status Change
                            Stall (0x0A)
                            If ((SCCB & 0x01))
                            {
                                \_SB.ISCT.SAOS (0x00)
                            }
                        }
                    }

