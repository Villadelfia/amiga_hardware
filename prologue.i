                      IFND PROLOGUE_I
PROLOGUE_I            SET 1
**
**  This file contains all the bare metal register names and descriptions one
**  might need for low-level amiga assembly programming.
**
**  Sections:
**    - CUSTOM: Contains all custom hardware registers and relevant bitfields.
**    - CIA: Contains all cia addresses and relevant bitfields.
**    - COPPER: Contains some useful copper instruction building blocks.
**    - EXEC: Common LVOs and utilities to call into exec.
**    - LVO: Other common LVOs.
**
********************************************************************************

*** CUSTOM SECTION START *******************************************************
*
*   Every register is defined in two ways:
*     - COPCONW: As an offset relative to CUSTOM.
*     - CUSTOM_COPCONW: As an absolute address.
*
*   Flags relevant to one register are defined in two ways:
*     - INTENAWB_DSKSYN: The bit number. 12 in this case.
*     - INTENAWF_DSKSYN: The flag. (1 << 12) or $1000 in this case.
*
*   Flags that define a set of bits will only define the F variant, and it will
*   be set to a literal with only those bits set.
*
*   Flags relevant to multiple registers are defined in the same ways as flags
*   relevant to just one register, except the number in the register name is
*   replaced with X. For example SPR0CTLN_ATT to SPR7CTLN_ATT will instead be
*   defined as SPRXCTLN_ATT.
*
*   Strobe registers will have a "flag" named REGISTERF_STROBE, with a value of
*   $FFFF.
*
*   Registers will be sorted by general functionality. Within each section, OCS
*   registers will come first, then the ECS registers, then the AGA registers.
*   Within each of these sections, registers will be listed in a logical order.
*
*   In the cases of OCS registers having special functionality in ECS, this will
*   be noted. The register will still be in the OCS section.
*
*   Generally, any register with an R suffix is read-only, and any register that
*   does not have an R suffix is write-only. There are a few exceptions in both
*   directions:
*     - Read-only: JOY0DAT, JOY1DAT, CLXDAT, DENISEID
*     - Write-only: REFPTR, SERPER, AUD0PER, AUD1PER, AUD2PER, AUD3PER, HCENTER
*     - Strobe: STRHOR
*
*   Registers that have a PT(H/L) suffix are chip memory pointers that address
*   DMA data. Must be reloaded by a processor before use (vertical blank for
*   bitplane and sprite pointers, and prior to starting the blitter for blitter
*   pointers).
*
*   Registers that have an LC(H/L) suffix are chip memory locations (starting
*   addresses) of DMA data. Used to automatically restart pointers, such as the
*   Copper program counter (during vertical blank) and the audio sample counter
*   (whenever the audio length count is finished).
*
********************************************************************************

*** BASE ADDRESS ***************************************************************
*
*   This is the memory location at which the custom chips are located.
*
CUSTOM                = $DFF000
*
********************************************************************************

*** DISK CONTROL REGISTERS *****************************************************

*** DSKBYTR ********************************************************************
*
*   Relative address: $01A
*   Read/write:       Read
*   Chip:             Paula
*   Function:         Disk data byte and status
*
DSKBYTR               = $01A
*
CUSTOM_DSKBYTR        = CUSTOM+DSKBYTR
*
DSKBYTRB_DSKBYT       = 15
DSKBYTRB_DMAON        = 14
DSKBYTRB_DISKWRITE    = 13
DSKBYTRB_WORDEQUAL    = 12
*
DSKBYTRF_DSKBYT       = (1<<15)
DSKBYTRF_DMAON        = (1<<14)
DSKBYTRF_DISKWRITE    = (1<<13)
DSKBYTRF_WORDEQUAL    = (1<<12)
*
DSKBYTRF_DATA         = $00FF
*
********************************************************************************

*** DSKPT (DSKPTH + DSKPTL) ****************************************************
*
*   Relative address: $020 + $022
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Disk pointer
*
DSKPT                 = $020
DSKPTH                = DSKPT
DSKPTL                = $022
*
CUSTOM_DSKPT          = CUSTOM+DSKPT
CUSTOM_DSKPTH         = CUSTOM+DSKPTH
CUSTOM_DSKPTL         = CUSTOM+DSKPTL
*
********************************************************************************

*** DSKLEN *********************************************************************
*
*   Relative address: $024
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk length
*
DSKLEN                = $024
*
CUSTOM_DSKLEN         = CUSTOM+DSKLEN
*
DSKLENB_DMAEN         = 15
DSKLENB_WRITE         = 14
*
DSKLENF_DMAEN         = (1<<15)
DSKLENF_WRITE         = (1<<14)
DSKLENF_LEN           = $3FFF
*
********************************************************************************

*** DSKDAT *********************************************************************
*
*   Relative address: $026
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk DMA data write
*
DSKDAT                = $026
*
CUSTOM_DSKDAT         = CUSTOM+DSKDAT
*
********************************************************************************

*** DSKSYNC ********************************************************************
*
*   Relative address: $07E
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk sync register
*
DSKSYNC               = $07E
*
CUSTOM_DSKSYNC        = CUSTOM+DSKSYNC
*
********************************************************************************

*** BLITTER REGISTERS **********************************************************

*** BLTCONx ********************************************************************
*
*   Relative address: $040 & $042
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter control registers
*
BLTCON0               = $040
BLTCON1               = $042
*
CUSTOM_BLTCON0        = CUSTOM+BLTCON0
CUSTOM_BLTCON1        = CUSTOM+BLTCON1
*
BLTCON0B_ASH3         = 15
BLTCON0B_ASH2         = 14
BLTCON0B_ASH1         = 13
BLTCON0B_ASH0         = 12
BLTCON0F_ASH          = $F000
BLTCON0F_ASH3         = (1<<15)
BLTCON0F_ASH2         = (1<<14)
BLTCON0F_ASH1         = (1<<13)
BLTCON0F_ASH0         = (1<<12)
*
BLTCON0B_START3       = 15
BLTCON0B_START2       = 14
BLTCON0B_START1       = 13
BLTCON0B_START0       = 12
BLTCON0F_START        = $F000
BLTCON0F_START3       = (1<<15)
BLTCON0F_START2       = (1<<14)
BLTCON0F_START1       = (1<<13)
BLTCON0F_START0       = (1<<12)
*
BLTCON1B_BSH3         = 15
BLTCON1B_BSH2         = 14
BLTCON1B_BSH1         = 13
BLTCON1B_BSH0         = 12
BLTCON1F_BSH          = $F000
BLTCON1F_BSH3         = (1<<15)
BLTCON1F_BSH2         = (1<<14)
BLTCON1F_BSH1         = (1<<13)
BLTCON1F_BSH0         = (1<<12)
*
BLTCON1B_TEXTURE3     = 15
BLTCON1B_TEXTURE2     = 14
BLTCON1B_TEXTURE1     = 13
BLTCON1B_TEXTURE0     = 12
BLTCON1F_TEXTURE      = $F000
BLTCON1F_TEXTURE3     = (1<<15)
BLTCON1F_TEXTURE2     = (1<<14)
BLTCON1F_TEXTURE1     = (1<<13)
BLTCON1F_TEXTURE0     = (1<<12)
*
BLTCON0B_USEA         = 11
BLTCON0B_USEB         = 10
BLTCON0B_USEC         = 9
BLTCON0B_USED         = 8
BLTCON0F_USE          = $F00
BLTCON0F_USEA         = (1<<11)
BLTCON0F_USEB         = (1<<10)
BLTCON0F_USEC         = (1<<9)
BLTCON0F_USED         = (1<<8)
BLTCON0F_USE_LINE     = $B00
*
BLTCON0B_LF7          = 7
BLTCON0B_LF6          = 6
BLTCON0B_LF5          = 5
BLTCON0B_LF4          = 4
BLTCON0B_LF3          = 3
BLTCON0B_LF2          = 2
BLTCON0B_LF1          = 1
BLTCON0B_LF0          = 0
BLTCON0F_LF           = $00FF
BLTCON0F_LF7          = (1<<7)
BLTCON0F_LF6          = (1<<6)
BLTCON0F_LF5          = (1<<5)
BLTCON0F_LF4          = (1<<4)
BLTCON0F_LF3          = (1<<3)
BLTCON0F_LF2          = (1<<2)
BLTCON0F_LF1          = (1<<1)
BLTCON0F_LF0          = (1<<0)
*
BLTCON1B_DOFF         = 7
BLTCON1F_DOFF         = (1<<7)
*
BLTCON1B_SIGN         = 6
BLTCON1F_SIGN         = (1<<6)
*
BLTCON1B_OVF          = 5
BLTCON1F_OVF          = (1<<5)
*
BLTCON1B_EFE          = 4
BLTCON1B_SUD          = 4
BLTCON1F_EFE          = (1<<4)
BLTCON1F_SUD          = (1<<4)
*
BLTCON1B_IFE          = 3
BLTCON1B_SUL          = 3
BLTCON1F_IFE          = (1<<3)
BLTCON1F_SUL          = (1<<3)
*
BLTCON1B_FCI          = 2
BLTCON1B_AUL          = 2
BLTCON1F_FCI          = (1<<2)
BLTCON1F_AUL          = (1<<2)
*
BLTCON1B_DESC         = 1
BLTCON1B_SING         = 1
BLTCON1B_ONEDOT       = 1
BLTCON1F_DESC         = (1<<1)
BLTCON1F_SING         = (1<<1)
BLTCON1F_ONEDOT       = (1<<1)
*
BLTCON1B_LINE         = 0
BLTCON1F_LINE         = (1<<0)
*
BLTCON1F_OCTANT0      = $18
BLTCON1F_OCTANT1      = $04
BLTCON1F_OCTANT2      = $0C
BLTCON1F_OCTANT3      = $1C
BLTCON1F_OCTANT4      = $14
BLTCON1F_OCTANT5      = $08
BLTCON1F_OCTANT6      = $00
BLTCON1F_OCTANT7      = $10
*
BLTCON0F_LF_NOP       = $00
BLTCON0F_LF_xxx       = $FF
BLTCON0F_LF_Axx       = $F0
BLTCON0F_LF_axx       = $0F
BLTCON0F_LF_xBx       = $CC
BLTCON0F_LF_ABx       = $C0
BLTCON0F_LF_aBx       = $0C
BLTCON0F_LF_xbx       = $33
BLTCON0F_LF_Abx       = $30
BLTCON0F_LF_abx       = $03
BLTCON0F_LF_xxC       = $AA
BLTCON0F_LF_AxC       = $A0
BLTCON0F_LF_axC       = $0A
BLTCON0F_LF_xBC       = $88
BLTCON0F_LF_ABC       = $80
BLTCON0F_LF_aBC       = $08
BLTCON0F_LF_xbC       = $22
BLTCON0F_LF_AbC       = $20
BLTCON0F_LF_abC       = $02
BLTCON0F_LF_xxc       = $55
BLTCON0F_LF_Axc       = $50
BLTCON0F_LF_axc       = $05
BLTCON0F_LF_xBc       = $44
BLTCON0F_LF_ABc       = $40
BLTCON0F_LF_aBc       = $04
BLTCON0F_LF_xbc       = $11
BLTCON0F_LF_Abc       = $10
BLTCON0F_LF_abc       = $01
*
BLTCON0F_MINTERM_ABC  = $80
BLTCON0F_MINTERM_ABc  = $40
BLTCON0F_MINTERM_AbC  = $20
BLTCON0F_MINTERM_Abc  = $10
BLTCON0F_MINTERM_aBC  = $08
BLTCON0F_MINTERM_aBc  = $04
BLTCON0F_MINTERM_abC  = $02
BLTCON0F_MINTERM_abc  = $01
*
BLTCON0F_LF_LINE_OVER = $CF
BLTCON0F_LF_LINE_XOR  = $4A
*
********************************************************************************

*** BLTAFWM & BLTALWM **********************************************************
*
*   Relative address: $044 & $046
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter first/last-word mask for source A
*
BLTAFWM               = $044
BLTALWM               = $046
*
CUSTOM_BLTAFWM        = CUSTOM+BLTAFWM
CUSTOM_BLTALWM        = CUSTOM+BLTALWM
*
********************************************************************************

*** BLTxPT (BLTxPTH + BLTxPTL) *************************************************
*
*   Relative address: $048 + $04A & $04C + $04E &
*                     $050 + $052 & $054 + $056
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter pointer to A/B/C/D
*
BLTCPT                = $048
BLTCPTH               = BLTCPT
BLTCPTL               = $04A
BLTBPT                = $04C
BLTBPTH               = BLTBPT
BLTBPTL               = $04E
BLTAPT                = $050
BLTAPTH               = BLTAPT
BLTAPTL               = $052
BLTDPT                = $054
BLTDPTH               = BLTDPT
BLTDPTL               = $056
*
CUSTOM_BLTCPT         = CUSTOM+BLTCPT
CUSTOM_BLTCPTH        = CUSTOM+BLTCPTH
CUSTOM_BLTCPTL        = CUSTOM+BLTCPTL
CUSTOM_BLTBPT         = CUSTOM+BLTBPT
CUSTOM_BLTBPTH        = CUSTOM+BLTBPTH
CUSTOM_BLTBPTL        = CUSTOM+BLTBPTL
CUSTOM_BLTAPT         = CUSTOM+BLTAPT
CUSTOM_BLTAPTH        = CUSTOM+BLTAPTH
CUSTOM_BLTAPTL        = CUSTOM+BLTAPTL
CUSTOM_BLTDPT         = CUSTOM+BLTDPT
CUSTOM_BLTDPTH        = CUSTOM+BLTDPTH
CUSTOM_BLTDPTL        = CUSTOM+BLTDPTL
*
********************************************************************************

*** BLTxDAT ********************************************************************
*
*   Relative address: $070 & $072 & $074
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter source A/B/C data register
*
BLTCDAT               = $070
BLTBDAT               = $072
BLTADAT               = $074
*
CUSTOM_BLTCDAT        = CUSTOM+BLTCDAT
CUSTOM_BLTBDAT        = CUSTOM+BLTBDAT
CUSTOM_BLTADAT        = CUSTOM+BLTADAT
*
********************************************************************************

*** BLTxMOD ********************************************************************
*
*   Relative address: $060 & $062 & $064 & $066
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter modulo A/B/C/D
*
BLTCMOD               = $060
BLTBMOD               = $062
BLTAMOD               = $064
BLTDMOD               = $066
*
CUSTOM_BLTCMOD        = CUSTOM+BLTCMOD
CUSTOM_BLTBMOD        = CUSTOM+BLTBMOD
CUSTOM_BLTAMOD        = CUSTOM+BLTAMOD
CUSTOM_BLTDMOD        = CUSTOM+BLTDMOD
*
********************************************************************************

*** BLTSIZE ********************************************************************
*
*   Relative address: $058
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter start and size (window width, height)
*
BLTSIZE               = $058
*
CUSTOM_BLTSIZE        = CUSTOM+BLTSIZE
*
BLTSIZEB_HEIGHT9      = 15
BLTSIZEB_HEIGHT8      = 14
BLTSIZEB_HEIGHT7      = 13
BLTSIZEB_HEIGHT6      = 12
BLTSIZEB_HEIGHT5      = 11
BLTSIZEB_HEIGHT4      = 10
BLTSIZEB_HEIGHT3      = 9
BLTSIZEB_HEIGHT2      = 8
BLTSIZEB_HEIGHT1      = 7
BLTSIZEB_HEIGHT0      = 6
BLTSIZEF_HEIGHT       = $FFC0
BLTSIZEF_HEIGHT9      = (1<<15)
BLTSIZEF_HEIGHT8      = (1<<14)
BLTSIZEF_HEIGHT7      = (1<<13)
BLTSIZEF_HEIGHT6      = (1<<12)
BLTSIZEF_HEIGHT5      = (1<<11)
BLTSIZEF_HEIGHT4      = (1<<10)
BLTSIZEF_HEIGHT3      = (1<<9)
BLTSIZEF_HEIGHT2      = (1<<8)
BLTSIZEF_HEIGHT1      = (1<<7)
BLTSIZEF_HEIGHT0      = (1<<6)
*
BLTSIZEB_WIDTH5       = 5
BLTSIZEB_WIDTH4       = 4
BLTSIZEB_WIDTH3       = 3
BLTSIZEB_WIDTH2       = 2
BLTSIZEB_WIDTH1       = 1
BLTSIZEB_WIDTH0       = 0
BLTSIZEF_WIDTH        = $3F
BLTSIZEF_WIDTH5       = (1<<5)
BLTSIZEF_WIDTH4       = (1<<4)
BLTSIZEF_WIDTH3       = (1<<3)
BLTSIZEF_WIDTH2       = (1<<2)
BLTSIZEF_WIDTH1       = (1<<1)
BLTSIZEF_WIDTH0       = (1<<0)
*
********************************************************************************

*** (ECS) BLTCON0L *************************************************************
*
*   Relative address: $05B
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         BLTCON0 lower 8 bits
*   Note: Byte access only. See also BLTCON0.
*
BLTCON0L              = $05B
*
CUSTOM_BLTCON0L       = CUSTOM+BLTCON0L
*
********************************************************************************

*** BLTSIZV & BLTSIZH **********************************************************
*
*   Relative address: $05C & $05E
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter 15 bit height & blitter 11 bit width (+start)
*
BLTSIZV               = $05C
BLTSIZH               = $05E
*
CUSTOM_BLTSIZV        = CUSTOM+BLTSIZV
CUSTOM_BLTSIZH        = CUSTOM+BLTSIZH
*
********************************************************************************

*** COPPER CONTROL REGISTERS ***************************************************

*** COPCON *********************************************************************
*
*   Relative address: $02E
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Copper control register
*
COPCON                = $02E
*
CUSTOM_COPCON         = CUSTOM+COPCON
*
COPCONB_CDANG         = 1
COPCONF_CDANG         = (1<<1)
*
********************************************************************************

*** COPxLC (COPxLCH + COPxLCL) *************************************************
*
*   Relative address: $080 + $082 & $084 + $086
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Copper list 1/2 pointer registers
*
COP1LC                = $080
COP1LCH               = COP1LC
COP1LCL               = $082
COP2LC                = $084
COP2LCH               = COP2LC
COP2LCL               = $086
*
CUSTOM_COP1LC         = CUSTOM+COP1LC
CUSTOM_COP1LCH        = CUSTOM+COP1LCH
CUSTOM_COP1LCL        = CUSTOM+COP1LCL
CUSTOM_COP2LC         = CUSTOM+COP2LC
CUSTOM_COP2LCH        = CUSTOM+COP2LCH
CUSTOM_COP2LCL        = CUSTOM+COP2LCL
*
********************************************************************************

*** COPJMPx ********************************************************************
*
*   Relative address: $088 & $08A
*   Read/write:       Strobe
*   Chip:             Agnus
*   Function:         Copper list 1/2 restart strobe
*
COPJMP1               = $088
COPJMP2               = $08A
*
CUSTOM_COPJMP1        = CUSTOM+COPJMP1
CUSTOM_COPJMP2        = CUSTOM+COPJMP2
*
COPJMP1F_STROBE       = $FFFF
COPJMP2F_STROBE       = $FFFF
*
********************************************************************************

*** AUDIO CHANNEL REGISTERS ****************************************************

*** ADKCON & ADKCONR ***********************************************************
*
*   Relative address: $09E & $010
*   Read/write:       Write & Read
*   Chip:             Agnus
*   Function:         Audio+disk control
*
ADKCON                = $09E
ADKCONR               = $010
*
CUSTOM_ADKCON         = CUSTOM+ADKCON
CUSTOM_ADKCONR        = CUSTOM+ADKCONR
*
ADKCONB_SETCLR        = 15
ADKCONB_PRECOMP1      = 14
ADKCONB_PRECOMP0      = 13
ADKCONB_MFMPREC       = 12
ADKCONB_UARTBRK       = 11
ADKCONB_WORDSYNC      = 10
ADKCONB_MSBSYNC       = 9
ADKCONB_FAST          = 8
ADKCONF_SETCLR        = (1<<15)
ADKCONF_PRECOMP1      = (1<<14)
ADKCONF_PRECOMP0      = (1<<13)
ADKCONF_MFMPREC       = (1<<12)
ADKCONF_UARTBRK       = (1<<11)
ADKCONF_WORDSYNC      = (1<<10)
ADKCONF_MSBSYNC       = (1<<9)
ADKCONF_FAST          = (1<<8)
*
ADKCONB_USE3PN        = 7
ADKCONB_USE2P3        = 6
ADKCONB_USE1P2        = 5
ADKCONB_USE0P1        = 4
ADKCONF_USE3PN        = (1<<7)
ADKCONF_USE2P3        = (1<<6)
ADKCONF_USE1P2        = (1<<5)
ADKCONF_USE0P1        = (1<<4)
*
ADKCONB_USE3VN        = 3
ADKCONB_USE2V3        = 2
ADKCONB_USE1V2        = 1
ADKCONB_USE0V1        = 0
ADKCONF_USE3VN        = (1<<3)
ADKCONF_USE2V3        = (1<<2)
ADKCONF_USE1V2        = (1<<1)
ADKCONF_USE0V1        = (1<<0)
*
ADKCONF_PRE000NS      = $0000
ADKCONF_PRE140NS      = $2000
ADKCONF_PRE280NS      = $4000
ADKCONF_PRE560NS      = $6000
*
********************************************************************************

*** AUDxLC (AUDxLCH + AUDxLCL) *************************************************
*
*   Relative address: $0A0 + $0A2 & $0B0 + $0B2 &
*                     $0C0 + $0C2 & $0D0 + $0D2
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Audio channel x location
*
AUD0LC                = $0A0
AUD0LCH               = AUD0LC
AUD0LCL               = $0A2
AUD1LC                = $0B0
AUD1LCH               = AUD1LC
AUD1LCL               = $0B2
AUD2LC                = $0C0
AUD2LCH               = AUD2LC
AUD2LCL               = $0C2
AUD3LC                = $0D0
AUD3LCH               = AUD3LC
AUD3LCL               = $0D2
*
CUSTOM_AUD0LC         = CUSTOM+AUD0LC
CUSTOM_AUD0LCH        = CUSTOM+AUD0LCH
CUSTOM_AUD0LCL        = CUSTOM+AUD0LCL
CUSTOM_AUD1LC         = CUSTOM+AUD1LC
CUSTOM_AUD1LCH        = CUSTOM+AUD1LCH
CUSTOM_AUD1LCL        = CUSTOM+AUD1LCL
CUSTOM_AUD2LC         = CUSTOM+AUD2LC
CUSTOM_AUD2LCH        = CUSTOM+AUD2LCH
CUSTOM_AUD2LCL        = CUSTOM+AUD2LCL
CUSTOM_AUD3LC         = CUSTOM+AUD3LC
CUSTOM_AUD3LCH        = CUSTOM+AUD3LCH
CUSTOM_AUD3LCL        = CUSTOM+AUD3LCL
*
********************************************************************************

*** AUDxLEN ********************************************************************
*
*   Relative address: $0A4 & $0B4 & $0C4 & $0D4
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x length
*
AUD0LEN               = $0A4
AUD1LEN               = $0B4
AUD2LEN               = $0C4
AUD3LEN               = $0D4
*
CUSTOM_AUD0LEN        = CUSTOM+AUD0LEN
CUSTOM_AUD1LEN        = CUSTOM+AUD1LEN
CUSTOM_AUD2LEN        = CUSTOM+AUD2LEN
CUSTOM_AUD3LEN        = CUSTOM+AUD3LEN
*
********************************************************************************

*** AUDxPER ********************************************************************
*
*   Relative address: $0A6 & $0B6 & $0C6 & $0D6
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x period
*
AUD0PER               = $0A6
AUD1PER               = $0B6
AUD2PER               = $0C6
AUD3PER               = $0D6
*
CUSTOM_AUD0PER        = CUSTOM+AUD0PER
CUSTOM_AUD1PER        = CUSTOM+AUD1PER
CUSTOM_AUD2PER        = CUSTOM+AUD2PER
CUSTOM_AUD3PER        = CUSTOM+AUD3PER
*
********************************************************************************

*** AUDxVOL ********************************************************************
*
*   Relative address: $0A8 & $0B8 & $0C8 & $0D8
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x volume
*
AUD0VOL               = $0A8
AUD1VOL               = $0B8
AUD2VOL               = $0C8
AUD3VOL               = $0D8
*
CUSTOM_AUD0VOL        = CUSTOM+AUD0VOL
CUSTOM_AUD1VOL        = CUSTOM+AUD1VOL
CUSTOM_AUD2VOL        = CUSTOM+AUD2VOL
CUSTOM_AUD3VOL        = CUSTOM+AUD3VOL
*
********************************************************************************

*** AUDxDAT ********************************************************************
*
*   Relative address: $0AA & $0BA & $0CA & $0DA
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x data
*
AUD0DAT               = $0AA
AUD1DAT               = $0BA
AUD2DAT               = $0CA
AUD3DAT               = $0DA
*
CUSTOM_AUD0DAT        = CUSTOM+AUD0DAT
CUSTOM_AUD1DAT        = CUSTOM+AUD1DAT
CUSTOM_AUD2DAT        = CUSTOM+AUD2DAT
CUSTOM_AUD3DAT        = CUSTOM+AUD3DAT
*
********************************************************************************

*** BITPLANE REGISTERS *********************************************************

*** BPLxPT (BPLxPTH + BPLxPTL) *************************************************
*
*   Relative address: $0E0 + $0E2 & $0E4 + $0E6 &
*                     $0E8 + $0EA & $0EC + $0EE &
*                     $0F0 + $0F2 & $0F4 + $0F6 &
*                     $0F8 + $0FA & $0FC + $0FE
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Bitplane x pointer
*
BPL1PT                = $0E0
BPL1PTH               = BPL1PT
BPL1PTL               = $0E2
BPL2PT                = $0E4
BPL2PTH               = BPL2PT
BPL2PTL               = $0E6
BPL3PT                = $0E8
BPL3PTH               = BPL3PT
BPL3PTL               = $0EA
BPL4PT                = $0EC
BPL4PTH               = BPL4PT
BPL4PTL               = $0EE
BPL5PT                = $0F0
BPL5PTH               = BPL5PT
BPL5PTL               = $0F2
BPL6PT                = $0F4
BPL6PTH               = BPL6PT
BPL6PTL               = $0F6
BPL7PT                = $0F8
BPL7PTH               = BPL7PT
BPL7PTL               = $0FA
BPL8PT                = $0FC
BPL8PTH               = BPL8PT
BPL8PTL               = $0FE
*
CUSTOM_BPL1PT         = CUSTOM+BPL1PT
CUSTOM_BPL1PTH        = CUSTOM+BPL1PTH
CUSTOM_BPL1PTL        = CUSTOM+BPL1PTL
CUSTOM_BPL2PT         = CUSTOM+BPL2PT
CUSTOM_BPL2PTH        = CUSTOM+BPL2PTH
CUSTOM_BPL2PTL        = CUSTOM+BPL2PTL
CUSTOM_BPL3PT         = CUSTOM+BPL3PT
CUSTOM_BPL3PTH        = CUSTOM+BPL3PTH
CUSTOM_BPL3PTL        = CUSTOM+BPL3PTL
CUSTOM_BPL4PT         = CUSTOM+BPL4PT
CUSTOM_BPL4PTH        = CUSTOM+BPL4PTH
CUSTOM_BPL4PTL        = CUSTOM+BPL4PTL
CUSTOM_BPL5PT         = CUSTOM+BPL5PT
CUSTOM_BPL5PTH        = CUSTOM+BPL5PTH
CUSTOM_BPL5PTL        = CUSTOM+BPL5PTL
CUSTOM_BPL6PT         = CUSTOM+BPL6PT
CUSTOM_BPL6PTH        = CUSTOM+BPL6PTH
CUSTOM_BPL6PTL        = CUSTOM+BPL6PTL
CUSTOM_BPL7PT         = CUSTOM+BPL7PT
CUSTOM_BPL7PTH        = CUSTOM+BPL7PTH
CUSTOM_BPL7PTL        = CUSTOM+BPL7PTL
CUSTOM_BPL8PT         = CUSTOM+BPL8PT
CUSTOM_BPL8PTH        = CUSTOM+BPL8PTH
CUSTOM_BPL8PTL        = CUSTOM+BPL8PTL
*
********************************************************************************

*** BPLCONx ********************************************************************
*
*   Relative address: $100 & $102 & $104 & $106 & $10C
*   Read/write:       Write
*   Chip:             Agnus & Denise
*   Function:         Bitplane control registers
*
BPLCON0               = $100
BPLCON1               = $102
BPLCON2               = $104
BPLCON3               = $106
BPLCON4               = $10C
*
CUSTOM_BPLCON0        = CUSTOM+BPLCON0
CUSTOM_BPLCON1        = CUSTOM+BPLCON1
CUSTOM_BPLCON2        = CUSTOM+BPLCON2
CUSTOM_BPLCON3        = CUSTOM+BPLCON3
CUSTOM_BPLCON4        = CUSTOM+BPLCON4
*
BPLCON0B_HIRES        = 15
BPLCON0B_BPU2         = 14
BPLCON0B_BPU1         = 13
BPLCON0B_BPU0         = 12
BPLCON0B_HAM          = 11
BPLCON0B_HOMOD        = 11
BPLCON0B_DPF          = 10
BPLCON0B_DBLPF        = 10
BPLCON0B_COLOR        = 9
BPLCON0B_GAUD         = 8
BPLCON0B_UHRES        = 7
BPLCON0B_SHRES        = 6
BPLCON0B_BYPASS       = 5
BPLCON0B_BPU3         = 4
BPLCON0B_LPEN         = 3
BPLCON0B_LACE         = 2
BPLCON0B_ERSY         = 1
BPLCON0B_ECSENA       = 0
BPLCON0F_HIRES        = (1<<15)
BPLCON0F_BPU2         = (1<<14)
BPLCON0F_BPU1         = (1<<13)
BPLCON0F_BPU0         = (1<<12)
BPLCON0F_HAM          = (1<<11)
BPLCON0F_HOMOD        = (1<<11)
BPLCON0F_DPF          = (1<<10)
BPLCON0F_DBLPF        = (1<<10)
BPLCON0F_COLOR        = (1<<9)
BPLCON0F_GAUD         = (1<<8)
BPLCON0F_UHRES        = (1<<7)
BPLCON0F_SHRES        = (1<<6)
BPLCON0F_BYPASS       = (1<<5)
BPLCON0F_BPU3         = (1<<4)
BPLCON0F_LPEN         = (1<<3)
BPLCON0F_LACE         = (1<<2)
BPLCON0F_ERSY         = (1<<1)
BPLCON0F_ECSENA       = (1<<0)
*
BPLCON1B_PF2H7        = 15
BPLCON1B_PF2H6        = 14
BPLCON1B_PF2H1        = 13
BPLCON1B_PF2H0        = 12
BPLCON1B_PF1H7        = 11
BPLCON1B_PF1H6        = 10
BPLCON1B_PF1H1        = 9
BPLCON1B_PF1H0        = 8
BPLCON1B_PF2H5        = 7
BPLCON1B_PF2H4        = 6
BPLCON1B_PF2H3        = 5
BPLCON1B_PF2H2        = 4
BPLCON1B_PF1H5        = 3
BPLCON1B_PF1H4        = 2
BPLCON1B_PF1H3        = 1
BPLCON1B_PF1H2        = 0
BPLCON1F_PF2H7        = (1<<15)
BPLCON1F_PF2H6        = (1<<14)
BPLCON1F_PF2H1        = (1<<13)
BPLCON1F_PF2H0        = (1<<12)
BPLCON1F_PF1H7        = (1<<11)
BPLCON1F_PF1H6        = (1<<10)
BPLCON1F_PF1H1        = (1<<9)
BPLCON1F_PF1H0        = (1<<8)
BPLCON1F_PF2H5        = (1<<7)
BPLCON1F_PF2H4        = (1<<6)
BPLCON1F_PF2H3        = (1<<5)
BPLCON1F_PF2H2        = (1<<4)
BPLCON1F_PF1H5        = (1<<3)
BPLCON1F_PF1H4        = (1<<2)
BPLCON1F_PF1H3        = (1<<1)
BPLCON1F_PF1H2        = (1<<0)
*
BPLCON2B_ZDBPSEL2     = 14
BPLCON2B_ZDBPSEL1     = 13
BPLCON2B_ZDBPSEL0     = 12
BPLCON2B_ZDBPEN       = 11
BPLCON2B_ZDCTEN       = 10
BPLCON2B_KILLEHB      = 9
BPLCON2B_RDRAM        = 8
BPLCON2B_SOGEN        = 7
BPLCON2B_PF2PRI       = 6
BPLCON2B_PF2P2        = 5
BPLCON2B_PF2P1        = 4
BPLCON2B_PF2P0        = 3
BPLCON2B_PF1P2        = 2
BPLCON2B_PF1P1        = 1
BPLCON2B_PF1P0        = 0
BPLCON2F_ZDBPSEL2     = (1<<14)
BPLCON2F_ZDBPSEL1     = (1<<13)
BPLCON2F_ZDBPSEL0     = (1<<12)
BPLCON2F_ZDBPEN       = (1<<11)
BPLCON2F_ZDCTEN       = (1<<10)
BPLCON2F_KILLEHB      = (1<<9)
BPLCON2F_RDRAM        = (1<<8)
BPLCON2F_SOGEN        = (1<<7)
BPLCON2F_PF2PRI       = (1<<6)
BPLCON2F_PF2P2        = (1<<5)
BPLCON2F_PF2P1        = (1<<4)
BPLCON2F_PF2P0        = (1<<3)
BPLCON2F_PF1P2        = (1<<2)
BPLCON2F_PF1P1        = (1<<1)
BPLCON2F_PF1P0        = (1<<0)
*
BPLCON3B_BANK2        = 15
BPLCON3B_BANK1        = 14
BPLCON3B_BANK0        = 13
BPLCON3B_PF2OF2       = 12
BPLCON3B_PF2OF1       = 11
BPLCON3B_PF2OF0       = 10
BPLCON3B_LOCT         = 9
BPLCON3B_SPRES1       = 7
BPLCON3B_SPRES0       = 6
BPLCON3B_BRDRBLNK     = 5
BPLCON3B_BRDNTRAN     = 4
BPLCON3B_ZDCLKEN      = 2
BPLCON3B_BRDSPRT      = 1
BPLCON3B_EXTBLKEN     = 0
BPLCON3F_BANK2        = (1<<15)
BPLCON3F_BANK1        = (1<<14)
BPLCON3F_BANK0        = (1<<13)
BPLCON3F_PF2OF2       = (1<<12)
BPLCON3F_PF2OF1       = (1<<11)
BPLCON3F_PF2OF0       = (1<<10)
BPLCON3F_LOCT         = (1<<9)
BPLCON3F_SPRES1       = (1<<7)
BPLCON3F_SPRES0       = (1<<6)
BPLCON3F_BRDRBLNK     = (1<<5)
BPLCON3F_BRDNTRAN     = (1<<4)
BPLCON3F_ZDCLKEN      = (1<<2)
BPLCON3F_BRDSPRT      = (1<<1)
BPLCON3F_EXTBLKEN     = (1<<0)
*
BPLCON4B_BPLAM7       = 15
BPLCON4B_BPLAM6       = 14
BPLCON4B_BPLAM5       = 13
BPLCON4B_BPLAM4       = 12
BPLCON4B_BPLAM3       = 11
BPLCON4B_BPLAM2       = 10
BPLCON4B_BPLAM1       = 9
BPLCON4B_BPLAM0       = 8
BPLCON4B_ESPRM3       = 7
BPLCON4B_ESPRM2       = 6
BPLCON4B_ESPRM1       = 5
BPLCON4B_ESPRM0       = 4
BPLCON4B_OSPRM3       = 3
BPLCON4B_OSPRM2       = 2
BPLCON4B_OSPRM1       = 1
BPLCON4B_OSPRM0       = 0
BPLCON4F_BPLAM7       = (1<<15)
BPLCON4F_BPLAM6       = (1<<14)
BPLCON4F_BPLAM5       = (1<<13)
BPLCON4F_BPLAM4       = (1<<12)
BPLCON4F_BPLAM3       = (1<<11)
BPLCON4F_BPLAM2       = (1<<10)
BPLCON4F_BPLAM1       = (1<<9)
BPLCON4F_BPLAM0       = (1<<8)
BPLCON4F_ESPRM3       = (1<<7)
BPLCON4F_ESPRM2       = (1<<6)
BPLCON4F_ESPRM1       = (1<<5)
BPLCON4F_ESPRM0       = (1<<4)
BPLCON4F_OSPRM3       = (1<<3)
BPLCON4F_OSPRM2       = (1<<2)
BPLCON4F_OSPRM1       = (1<<1)
BPLCON4F_OSPRM0       = (1<<0)
*
********************************************************************************

*** BPLxMOD ********************************************************************
*
*   Relative address: $108 & $10A
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Bitplane modulo (odd/even)
*
BPL1MOD               = $108
BPL2MOD               = $10A
*
CUSTOM_BPL1MOD        = CUSTOM+BPL1MOD
CUSTOM_BPL2MOD        = CUSTOM+BPL2MOD
*
********************************************************************************

*** BPLxDAT ********************************************************************
*
*   Relative address: $110 & $112 & $114 & $116 & 
*                     $118 & $11A & $11C & $11E
*   Read/write:       Write
*   Chip:             Denise
*   Function:         Bitplane x data (par-to-ser)
*
BPL1DAT               = $110
BPL2DAT               = $112
BPL3DAT               = $114
BPL4DAT               = $116
BPL5DAT               = $118
BPL6DAT               = $11A
BPL7DAT               = $11C
BPL8DAT               = $11E
*
CUSTOM_BPL1DAT        = CUSTOM+BPL1DAT
CUSTOM_BPL2DAT        = CUSTOM+BPL2DAT
CUSTOM_BPL3DAT        = CUSTOM+BPL3DAT
CUSTOM_BPL4DAT        = CUSTOM+BPL4DAT
CUSTOM_BPL5DAT        = CUSTOM+BPL5DAT
CUSTOM_BPL6DAT        = CUSTOM+BPL6DAT
CUSTOM_BPL7DAT        = CUSTOM+BPL7DAT
CUSTOM_BPL8DAT        = CUSTOM+BPL8DAT
*
********************************************************************************

*** SPRITE CONTROL REGISTERS ***************************************************

*** SPRxPT (SPRxPTH + SPRxPTL) *************************************************
*
*   Relative address: $120 + $122 & $124 + $126 &
*                     $128 + $12A & $12C + $12E &
*                     $130 + $132 & $134 + $136 &
*                     $138 + $13A & $13C + $13E &                               
*       
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Sprite x pointer
*
SPR0PT                = $120
SPR0PTH               = SPR0PT
SPR0PTL               = $122
SPR1PT                = $124
SPR1PTH               = SPR1PT
SPR1PTL               = $126
SPR2PT                = $128
SPR2PTH               = SPR2PT
SPR2PTL               = $12A
SPR3PT                = $12C
SPR3PTH               = SPR3PT
SPR3PTL               = $12E
SPR4PT                = $130
SPR4PTH               = SPR4PT
SPR4PTL               = $132
SPR5PT                = $134
SPR5PTH               = SPR5PT
SPR5PTL               = $136
SPR6PT                = $138
SPR6PTH               = SPR6PT
SPR6PTL               = $13A
SPR7PT                = $13C
SPR7PTH               = SPR7PT
SPR7PTL               = $13E
*
CUSTOM_SPR0PT         = CUSTOM+SPR0PT
CUSTOM_SPR0PTH        = CUSTOM+SPR0PTH
CUSTOM_SPR0PTL        = CUSTOM+SPR0PTL
CUSTOM_SPR1PT         = CUSTOM+SPR1PT
CUSTOM_SPR1PTH        = CUSTOM+SPR1PTH
CUSTOM_SPR1PTL        = CUSTOM+SPR1PTL
CUSTOM_SPR2PT         = CUSTOM+SPR2PT
CUSTOM_SPR2PTH        = CUSTOM+SPR2PTH
CUSTOM_SPR2PTL        = CUSTOM+SPR2PTL
CUSTOM_SPR3PT         = CUSTOM+SPR3PT
CUSTOM_SPR3PTH        = CUSTOM+SPR3PTH
CUSTOM_SPR3PTL        = CUSTOM+SPR3PTL
CUSTOM_SPR4PT         = CUSTOM+SPR4PT
CUSTOM_SPR4PTH        = CUSTOM+SPR4PTH
CUSTOM_SPR4PTL        = CUSTOM+SPR4PTL
CUSTOM_SPR5PT         = CUSTOM+SPR5PT
CUSTOM_SPR5PTH        = CUSTOM+SPR5PTH
CUSTOM_SPR5PTL        = CUSTOM+SPR5PTL
CUSTOM_SPR6PT         = CUSTOM+SPR6PT
CUSTOM_SPR6PTH        = CUSTOM+SPR6PTH
CUSTOM_SPR6PTL        = CUSTOM+SPR6PTL
CUSTOM_SPR7PT         = CUSTOM+SPR7PT
CUSTOM_SPR7PTH        = CUSTOM+SPR7PTH
CUSTOM_SPR7PTL        = CUSTOM+SPR7PTL
*
********************************************************************************

*** SPRxPOS ********************************************************************
*
*   Relative address: $140 & $148 & $150 & $158 &                               
*       
*                     $160 & $168 & $170 & $178
*   Read/write:       Write
*   Chip:             Agnus & Denise
*   Function:         Sprite x start position
*
SPR0POS               = $140
SPR1POS               = $148
SPR2POS               = $150
SPR3POS               = $158
SPR4POS               = $160
SPR5POS               = $168
SPR6POS               = $170
SPR7POS               = $178
*
CUSTOM_SPR0POS        = CUSTOM+SPR0POS
CUSTOM_SPR1POS        = CUSTOM+SPR1POS
CUSTOM_SPR2POS        = CUSTOM+SPR2POS
CUSTOM_SPR3POS        = CUSTOM+SPR3POS
CUSTOM_SPR4POS        = CUSTOM+SPR4POS
CUSTOM_SPR5POS        = CUSTOM+SPR5POS
CUSTOM_SPR6POS        = CUSTOM+SPR6POS
CUSTOM_SPR7POS        = CUSTOM+SPR7POS
*
SPRxPOSB_SV7          = 15
SPRxPOSB_SV6          = 14
SPRxPOSB_SV5          = 13
SPRxPOSB_SV4          = 12
SPRxPOSB_SV3          = 11
SPRxPOSB_SV2          = 10
SPRxPOSB_SV1          = 9
SPRxPOSB_SV0          = 8
SPRxPOSB_SH8          = 7
SPRxPOSB_SH7          = 6
SPRxPOSB_SH6          = 5
SPRxPOSB_SH5          = 4
SPRxPOSB_SH4          = 3
SPRxPOSB_SH3          = 2
SPRxPOSB_SH2          = 1
SPRxPOSB_SH1          = 0
SPRxPOSF_SV7          = (1<<15)
SPRxPOSF_SV6          = (1<<14)
SPRxPOSF_SV5          = (1<<13)
SPRxPOSF_SV4          = (1<<12)
SPRxPOSF_SV3          = (1<<11)
SPRxPOSF_SV2          = (1<<10)
SPRxPOSF_SV1          = (1<<9)
SPRxPOSF_SV0          = (1<<8)
SPRxPOSF_SH8          = (1<<7)
SPRxPOSF_SH7          = (1<<6)
SPRxPOSF_SH6          = (1<<5)
SPRxPOSF_SH5          = (1<<4)
SPRxPOSF_SH4          = (1<<3)
SPRxPOSF_SH3          = (1<<2)
SPRxPOSF_SH2          = (1<<1)
SPRxPOSF_SH1          = (1<<0)
*
********************************************************************************

*** SPRxCTL ********************************************************************
*
*   Relative address: $142 & $14A & $152 & $15A &                               
*       
*                     $162 & $16A & $172 & $17A
*   Read/write:       Write
*   Chip:             Agnus & Denise
*   Function:         Sprite x control
*
SPR0CTL               = $142
SPR1CTL               = $14A
SPR2CTL               = $152
SPR3CTL               = $15A
SPR4CTL               = $162
SPR5CTL               = $16A
SPR6CTL               = $172
SPR7CTL               = $17A
*
CUSTOM_SPR0CTL        = CUSTOM+SPR0CTL
CUSTOM_SPR1CTL        = CUSTOM+SPR1CTL
CUSTOM_SPR2CTL        = CUSTOM+SPR2CTL
CUSTOM_SPR3CTL        = CUSTOM+SPR3CTL
CUSTOM_SPR4CTL        = CUSTOM+SPR4CTL
CUSTOM_SPR5CTL        = CUSTOM+SPR5CTL
CUSTOM_SPR6CTL        = CUSTOM+SPR6CTL
CUSTOM_SPR7CTL        = CUSTOM+SPR7CTL
*
SPRxCTLB_EV7          = 15
SPRxCTLB_EV6          = 14
SPRxCTLB_EV5          = 13
SPRxCTLB_EV4          = 12
SPRxCTLB_EV3          = 11
SPRxCTLB_EV2          = 10
SPRxCTLB_EV1          = 9
SPRxCTLB_EV0          = 8
SPRxCTLB_ATT          = 7
SPRxCTLB_SV9          = 6
SPRxCTLB_EV9          = 5
SPRxCTLB_SHSH1        = 4
SPRxCTLB_SHSH0        = 3
SPRxCTLB_SV8          = 2
SPRxCTLB_EV8          = 1
SPRxCTLB_SH0          = 0
SPRxCTLF_EV7          = (1<<15)
SPRxCTLF_EV6          = (1<<14)
SPRxCTLF_EV5          = (1<<13)
SPRxCTLF_EV4          = (1<<12)
SPRxCTLF_EV3          = (1<<11)
SPRxCTLF_EV2          = (1<<10)
SPRxCTLF_EV1          = (1<<9)
SPRxCTLF_EV0          = (1<<8)
SPRxCTLF_ATT          = (1<<7)
SPRxCTLF_SV9          = (1<<6)
SPRxCTLF_EV9          = (1<<5)
SPRxCTLF_SHSH1        = (1<<4)
SPRxCTLF_SHSH0        = (1<<3)
SPRxCTLF_SV8          = (1<<2)
SPRxCTLF_EV8          = (1<<1)
SPRxCTLF_SH0          = (1<<0)
*
********************************************************************************

*** SPRxDATA + SPRxDATB ********************************************************
*
*   Relative address: $144 + $146 & $14C + $14E &
*                     $154 + $156 & $15C + $15E &
*                     $164 + $166 & $16C + $16E &
*                     $174 + $176 & $17C + $17E
*   Read/write:       Write
*   Chip:             Denise
*   Function:         Sprite x data
*
SPR0DATA              = $144
SPR0DATB              = $146
SPR1DATA              = $14C
SPR1DATB              = $14E
SPR2DATA              = $154
SPR2DATB              = $156
SPR3DATA              = $15C
SPR3DATB              = $15E
SPR4DATA              = $164
SPR4DATB              = $166
SPR5DATA              = $16C
SPR5DATB              = $16E
SPR6DATA              = $174
SPR6DATB              = $176
SPR7DATA              = $17C
SPR7DATB              = $17E
*
CUSTOM_SPR0DATA       = CUSTOM+SPR0DATA
CUSTOM_SPR0DATB       = CUSTOM+SPR0DATB
CUSTOM_SPR1DATA       = CUSTOM+SPR1DATA
CUSTOM_SPR1DATB       = CUSTOM+SPR1DATB
CUSTOM_SPR2DATA       = CUSTOM+SPR2DATA
CUSTOM_SPR2DATB       = CUSTOM+SPR2DATB
CUSTOM_SPR3DATA       = CUSTOM+SPR3DATA
CUSTOM_SPR3DATB       = CUSTOM+SPR3DATB
CUSTOM_SPR4DATA       = CUSTOM+SPR4DATA
CUSTOM_SPR4DATB       = CUSTOM+SPR4DATB
CUSTOM_SPR5DATA       = CUSTOM+SPR5DATA
CUSTOM_SPR5DATB       = CUSTOM+SPR5DATB
CUSTOM_SPR6DATA       = CUSTOM+SPR6DATA
CUSTOM_SPR6DATB       = CUSTOM+SPR6DATB
CUSTOM_SPR7DATA       = CUSTOM+SPR7DATA
CUSTOM_SPR7DATB       = CUSTOM+SPR7DATB
*
********************************************************************************

*** COLOR REGISTERS ************************************************************

*** COLORxx ********************************************************************
*
*   Relative address: $180 & $182 & $184 & $186 &
*                     $188 & $18A & $18C & $18E &
*                     $190 & $192 & $194 & $196 &
*                     $198 & $19A & $19C & $19E &
*                     $1A0 & $1A2 & $1A4 & $1A6 &
*                     $1A8 & $1AA & $1AC & $1AE &
*                     $1B0 & $1B2 & $1B4 & $1B6 &
*                     $1B8 & $1BA & $1BC & $1BE
*   Read/write:       Write
*   Chip:             Denise
*   Function:         Color table
*
COLOR00               = $180
COLOR01               = $182
COLOR02               = $184
COLOR03               = $186
COLOR04               = $188
COLOR05               = $18A
COLOR06               = $18C
COLOR07               = $18E
COLOR08               = $190
COLOR09               = $192
COLOR10               = $194
COLOR11               = $196
COLOR12               = $198
COLOR13               = $19A
COLOR14               = $19C
COLOR15               = $19E
COLOR16               = $1A0
COLOR17               = $1A2
COLOR18               = $1A4
COLOR19               = $1A6
COLOR20               = $1A8
COLOR21               = $1AA
COLOR22               = $1AC
COLOR23               = $1AE
COLOR24               = $1B0
COLOR25               = $1B2
COLOR26               = $1B4
COLOR27               = $1B6
COLOR28               = $1B8
COLOR29               = $1BA
COLOR30               = $1BC
COLOR31               = $1BE
*
CUSTOM_COLOR00        = CUSTOM+COLOR00
CUSTOM_COLOR01        = CUSTOM+COLOR01
CUSTOM_COLOR02        = CUSTOM+COLOR02
CUSTOM_COLOR03        = CUSTOM+COLOR03
CUSTOM_COLOR04        = CUSTOM+COLOR04
CUSTOM_COLOR05        = CUSTOM+COLOR05
CUSTOM_COLOR06        = CUSTOM+COLOR06
CUSTOM_COLOR07        = CUSTOM+COLOR07
CUSTOM_COLOR08        = CUSTOM+COLOR08
CUSTOM_COLOR09        = CUSTOM+COLOR09
CUSTOM_COLOR10        = CUSTOM+COLOR10
CUSTOM_COLOR11        = CUSTOM+COLOR11
CUSTOM_COLOR12        = CUSTOM+COLOR12
CUSTOM_COLOR13        = CUSTOM+COLOR13
CUSTOM_COLOR14        = CUSTOM+COLOR14
CUSTOM_COLOR15        = CUSTOM+COLOR15
CUSTOM_COLOR16        = CUSTOM+COLOR16
CUSTOM_COLOR17        = CUSTOM+COLOR17
CUSTOM_COLOR18        = CUSTOM+COLOR18
CUSTOM_COLOR19        = CUSTOM+COLOR19
CUSTOM_COLOR20        = CUSTOM+COLOR20
CUSTOM_COLOR21        = CUSTOM+COLOR21
CUSTOM_COLOR22        = CUSTOM+COLOR22
CUSTOM_COLOR23        = CUSTOM+COLOR23
CUSTOM_COLOR24        = CUSTOM+COLOR24
CUSTOM_COLOR25        = CUSTOM+COLOR25
CUSTOM_COLOR26        = CUSTOM+COLOR26
CUSTOM_COLOR27        = CUSTOM+COLOR27
CUSTOM_COLOR28        = CUSTOM+COLOR28
CUSTOM_COLOR29        = CUSTOM+COLOR29
CUSTOM_COLOR30        = CUSTOM+COLOR30
CUSTOM_COLOR31        = CUSTOM+COLOR31
*
********************************************************************************

*** MISC REGISTERS *************************************************************

*** TODO ***********************************************************************
*
*   $002 = DMACONR
*   $004 = VPOSR
*   $006 = VHPOSR
*   $02A = VPOSW
*   $02C = VHPOSW
*   $00A = JOY0DAT
*   $00C = JOY1DAT
*   $00E = CLXDAT
*   $012 = POT0DAT
*   $014 = POT1DAT
*   $016 = POTINP
*   $018 = SERDATR
*   $01C = INTENAR
*   $01E = INTREQR
*   $028 = REFPTR
*   $030 = SERDAT
*   $032 = SERPER
*   $034 = POTGO
*   $036 = JOYTEST
*   $038 = STREQU
*   $03A = STRVBL
*   $03C = STRHOR
*   $03E = STRLONG
*   $078 = SPRHDAT 
*   $07A = BPLHDAT 
*   $07C = DENISEID
*   $08E = DIWSTRT
*   $090 = DIWSTOP
*   $092 = DDFSTRT
*   $094 = DDFSTOP
*   $096 = DMACON
*   $098 = CLXCON
*   $10E = CLXCON2
*   $09A = INTENA
*   $09C = INTREQ
*   $1C0 = HTOTAL  
*   $1C2 = HSSTOP  
*   $1C4 = HBSTRT  
*   $1C6 = HBSTOP  
*   $1C8 = VTOTAL  
*   $1CA = VSSTOP  
*   $1CC = VBSTRT  
*   $1CE = VBSTOP  
*   $1D0 = SPRHSTRT
*   $1D2 = SPRHSTOP
*   $1D4 = BPLHSTRT
*   $1D6 = BPLHSTOP
*   $1D8 = HHPOSW  
*   $1DA = HHPOSR  
*   $1DC = BEAMCON0
*   $1DE = HSSTRT  
*   $1E0 = VSSTRT  
*   $1E2 = HCENTER 
*   $1E4 = DIWHIGH 
*   $1E6 = BPLHMOD 
*   $1E8 = SPRHPTH 
*   $1EA = SPRHPTL 
*   $1EC = BPLHPTH 
*   $1EE = BPLHPTL 
*   $1FC = FMODE   
*   $1FE = NOOP
*
********************************************************************************

*** DUMMY REGISTERS ************************************************************

*** BLTDDAT ********************************************************************
*
*   Relative address: $000
*   Read/write:       -
*   Chip:             Agnus
*   Function:         Blitter destination data register
*
BLTDDAT               = $000
*
CUSTOM_BLTDDAT        = CUSTOM+BLTDDAT
*
********************************************************************************

*** DSKDATR ********************************************************************
*
*   Relative address: $008
*   Read/write:       -
*   Chip:             Paula
*   Function:         Disk DMA data read
*
DSKDATR               = $008
*
CUSTOM_DSKDATR        = CUSTOM+DSKDATR
*
********************************************************************************

*** COPINS *********************************************************************
*
*   Relative address: $08C
*   Read/write:       -
*   Chip:             Agnus
*   Function:         Copper instruction fetch identify
*
COPINS                = $08C
*
CUSTOM_COPINS         = CUSTOM+COPINS
*
********************************************************************************

*** CUSTOM SECTION END *********************************************************
                      ENDC
