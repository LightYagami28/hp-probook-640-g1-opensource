
            Return (Local0)
        }

        ThermalZone (CPUZ)
        {
            Method (_HOT, 0, Serialized)  // _HOT: Hot Temperature
            {
                Return (CHOT (0x00))
            }

            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (GETP (0x00, 0x03))
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                \_TZ.OSIT ()
                Local0 = 0x00
                Local0 = GTTP (0x00, 0x01, 0x10, 0x00, 0x7F)
                If (SETM (0x00, 0x01, Local0))
                {
                    Notify (\_TZ.CPUZ, 0x81) // Thermal Trip Point Change
                }

                Return (GETK (Local0))
            }
        }

        ThermalZone (GFXZ)
        {
            Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
            {
                Return (GETP (0x01, 0x01))
            }

            Method (_PSL, 0, NotSerialized)  // _PSL: Passive List
            {
                Return (PSL ())
            }

            Name (_TSP, 0x012C)  // _TSP: Thermal Sampling Period
            Name (_TC1, 0x01)  // _TC1: Thermal Constant 1
            Name (_TC2, 0x02)  // _TC2: Thermal Constant 2
            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (GETP (0x01, 0x03))
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Local0 = 0x00
                Local0 = GTTP (0x01, 0x02, 0x10, 0x00, 0x7F)
                If (SETM (0x01, 0x02, Local0))
                {
                    Notify (\_TZ.GFXZ, 0x81) // Thermal Trip Point Change
                }

                Return (GETK (Local0))
            }
        }

        ThermalZone (EXTZ)
        {
            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (GETP (0x02, 0x03))
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Local0 = 0x00
                Local0 = GTTP (0x02, 0x03, 0x10, 0x00, 0x7F)
                Return (GETK (Local0))
            }
        }

        ThermalZone (LOCZ)
        {
            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (GETP (0x03, 0x03))
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Local0 = 0x00
                Local0 = GTTP (0x03, 0x04, 0x10, 0x00, 0x7F)
                Return (GETK (Local0))
            }
        }

        ThermalZone (BATZ)
        {
            Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
            {
                Return (GETP (0x04, 0x01))
            }

            Method (_PSL, 0, NotSerialized)  // _PSL: Passive List
            {
                Return (PSL ())
            }

            Name (_TSP, 0x012C)  // _TSP: Thermal Sampling Period
            Name (_TC1, 0x32)  // _TC1: Thermal Constant 1
            Name (_TC2, 0x00)  // _TC2: Thermal Constant 2
            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (GETP (0x04, 0x03))
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Local0 = 0x00
                Local0 = GTTP (0x04, 0x05, 0x00, 0x00, 0x7F)
                If (SETM (0x04, 0x05, Local0))
                {
                    Notify (\_TZ.BATZ, 0x81) // Thermal Trip Point Change
                }

                Return (GETK (Local0))
            }
        }

        Method (NTHS, 1, Serialized)
        {
            If ((Arg0 & 0x01))
            {
                Notify (CPUZ, 0x80) // Thermal Status Change
            }

            If ((Arg0 & 0x02))
            {
                Notify (GFXZ, 0x80) // Thermal Status Change
            }

            If ((Arg0 & 0x04))
            {
                Notify (EXTZ, 0x80) // Thermal Status Change
            }

            If ((Arg0 & 0x08))
            {
                Notify (LOCZ, 0x80) // Thermal Status Change
            }

            If ((Arg0 & 0x10))
            {
                Notify (BATZ, 0x80) // Thermal Status Change
            }
        }

        Method (ECTE, 1, Serialized)
        {
            Local1 = 0x00
            If (Arg0)
            {
                If ((Arg0 & 0x01))
                {
                    Local1 |= 0x01
                }

                If ((Arg0 & 0x02))
                {
                    Local1 |= 0x02
                }

                If ((Arg0 & 0x04))
                {
                    Local1 |= 0x04
                }

                If ((Arg0 & 0x08))
                {
                    Local1 |= 0x08
                }

                If ((Arg0 & 0x10))
                {
                    Local1 |= 0x10
                }
            }
            Else
            {
                Local1 |= 0x10
            }

            Acquire (THER, 0xFFFF)
            THSC |= Local1
            Release (THER)
            NTHS (Local1)
        }

        Method (GFRM, 0, Serialized)
        {
            Local0 = 0x00
            If (\_SB.PCI0.LPCB.EC0.ECRG)
            {
                Acquire (\_SB.PCI0.LPCB.EC0.ECMX, 0xFFFF)
                Local0 = \_SB.PCI0.LPCB.EC0.FRDC
                Release (\_SB.PCI0.LPCB.EC0.ECMX)
                If (Local0)
                {
                    Local1 = (Local0 >> 0x01)
                    Local2 = (0x0003C000 + Local1)
                    Divide (Local2, Local0, Local1, Local0)
                }
            }

            Return (Local0)
        }

        Method (GTRM, 0, Serialized)
        {
            Local0 = 0x00
            If (\_SB.PCI0.LPCB.EC0.ECRG)
            {
                Acquire (\_SB.PCI0.LPCB.EC0.ECMX, 0xFFFF)
                Local0 = \_SB.PCI0.LPCB.EC0.FTGC
                Release (\_SB.PCI0.LPCB.EC0.ECMX)
                If (Local0)
                {
                    Local1 = (Local0 >> 0x01)
                    Local2 = (0x0003C000 + Local1)
                    Divide (Local2, Local0, Local1, Local0)
                }
            }

            Return (Local0)
        }

        Method (GFSD, 0, Serialized)
        {
            Local0 = GFRM ()
            Local1 = (Local0 * 0x64)
            Divide (Local1, MRPM, Local1, Local2)
            Return (Local2)
        }

        Method (CTCT, 1, Serialized)
        {
            Local1 = (Arg0 * MRPM) /* \_TZ_.MRPM */
            Divide (Local1, 0x64, Local2, Local0)
            If (Local0)
            {
                Local1 = (Local0 >> 0x01)
                Local2 = (0x0003C000 + Local1)
                Divide (Local2, Local0, Local1, Local0)
            }

            If ((Local0 > 0xF4))
            {
                Local0 = 0xF4
            }

            Return (Local0)
        }

        Method (PSL, 0, Serialized)
        {
            If ((\_PR.CFGD & 0x01000000))
            {
                If ((TCNT == 0x08))
                {
                    Return (Package (0x08)
                    {
                        \_PR.CPU0, 
                        \_PR.CPU1, 
                        \_PR.CPU2, 
                        \_PR.CPU3, 
                        \_PR.CPU4, 
                        \_PR.CPU5, 
                        \_PR.CPU6, 
                        \_PR.CPU7
                    })
                }

                If ((TCNT == 0x04))
                {
                    Return (Package (0x04)
                    {
                        \_PR.CPU0, 
                        \_PR.CPU1, 
                        \_PR.CPU2, 
                        \_PR.CPU3
                    })
                }

                Return (Package (0x02)
                {
                    \_PR.CPU0, 
                    \_PR.CPU1
                })
            }
            Else
            {
                Return (Package (0x01)
                {
                    \_PR.CPU0
                })
            }
        }

        ThermalZone (PCHZ)
        {
            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (0x0FAC)
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Local0 = 0x00
                Local0 = GTTP (0x05, 0x00, PCHT, 0x00, 0x7F)
                Local1 = DerefOf (DerefOf (\_SB.WMID.TSTV [0x02]) [0x02])
                If ((Local1 != 0xFF))
                {
                    Local0 = Local1
                }

                Return (GETK (Local0))
            }
        }

        Method (GDTP, 2, Serialized)
        {
            If ((Arg1 || DTZS ()))
            {
                Local0 = \_SB.PCI0.SBUS.SRDW (Arg0, 0x05)
                If ((Local0 == 0xFFFFFFFF))
                {
                    Local0 = 0x00
                }
                ElseIf ((Local0 & 0x1000))
                {
                    Local0 = 0x00
                }
                Else
                {
                    Local0 >>= 0x04
                    Local0 &= 0xFF
                }

                Return (\_TZ.GETK (Local0))
            }
            Else
            {
                Return (0x0AAC)
            }
        }

        Method (DTZS, 0, NotSerialized)
        {
            If ((DTCD & 0x00010000))
            {
                Return (0x0F)
            }

            Return (0x00)
        }

        ThermalZone (DM1Z)
        {
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (DTZS ())
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Return (GDTP (0x30, 0x00))
            }

            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (0x0FAC)
            }
        }

        ThermalZone (DM2Z)
        {
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (DTZS ())
            }

            Method (_TMP, 0, Serialized)  // _TMP: Temperature
            {
                Return (GDTP (0x34, 0x00))
            }

            Method (_CRT, 0, Serialized)  // _CRT: Critical Temperature
            {
                Return (0x0FAC)
            }
        }

        Name (SEN1, Package (0x06)
        {
