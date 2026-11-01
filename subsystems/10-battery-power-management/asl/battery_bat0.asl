        Device (BAT0)
        {
            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, 0x01)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = \_SB.PCI0.LPCB.EC0.BSTA (0x01)
                If ((BT0P ^ Local0))
                {
                    BT0P = Local0
                    Local1 = Local0
                    If ((Local1 != 0x1F))
                    {
                        Local1 = 0x00
                    }

                    If ((\_SB.GLVR (0x3B) == 0x01))
                    {
                        \_SB.SSMI (0xEA3A, 0x00, Local1, 0x00, 0x00)
                        Local1 = ECX /* \ECX_ */
                        \_GPE.HWWP (0x01)
                        \_SB.PCI0.LPCB.EC0.HWWP (Local1)
                    }

                    \_SB.WMID.WGWE (0x05, 0x00)
                }

                Return (Local0)
            }

            Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
            {
                Return (BTIF (0x00))
            }

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                Return (BTST (0x00))
            }

            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                \_SB
            })
        }

        Device (BAT1)
        {
            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x00)
            }

            Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
            {
                Return (BTIF (0x01))
            }

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                Return (BTST (0x01))
            }

            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                \_SB
            })
        }

        Device (AC)
        {
            Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                \_SB
            })
            Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
            {
                Local0 = \_SB.PCI0.LPCB.EC0.GACS ()
                PWRS = Local0
                Local1 = \_SB.PCI0.LPCB.EC0.GPID ()
                If ((Local0 ^ ACST))
                {
                    \_GPE.HNLP (0x00)
                    \_SB.PCI0.ACEL.AJAL ()
                    \_GPE.VPUP (Local0, Local1)
                    \_SB.PCI0.LPCB.EC0.SMCP (Local0)
                }

                If (((Local0 && !ACST) || (Local1 && !SMAR)))
                {
                    \_SB.WMID.WGWE (0x03, 0x00)
                }

                ACST = Local0
                SMAR = Local1
                Return (Local0)
            }
        }

        Device (SLPB)
        {
            Name (_HID, EisaId ("PNP0C0E") /* Sleep Button Device */)  // _HID: Hardware ID
        }

        Device (LID)
        {
            Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
            Method (_LID, 0, NotSerialized)  // _LID: Lid Status
            {
                Local0 = \_SB.PCI0.LPCB.EC0.CLID
                Return (Local0)
            }
        }

        Device (HST1)
        {
            Name (_HID, EisaId ("PNP0C32") /* Direct App Launch Button */)  // _HID: Hardware ID
            Name (_UID, 0x01)  // _UID: Unique ID
            Name (HS1S, 0xFF)
            Method (_STA, 0, Serialized)  // _STA: Status
            {
                If ((HS1S == 0xFF))
                {
                    Local0 = 0x00
                    If ((\WCOS () >= 0x06))
                    {
                        If (ISUD ())
                        {
                            Local0 = 0x0F
                        }
