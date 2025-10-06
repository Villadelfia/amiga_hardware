            IFND    PROLOGUE_I
PROLOGUE_I  SET     1
**
**  This file contains all the bare metal register names and descriptions one
**  might need for low-level amiga assembly programming.
**
**  Sections:
**    - CUSTOM: Contains all custom hardware registers and relevant bitfields.
**    - CIA: Contains all cia addresses and relevant bitfields.
**    - COPPER: Contains some useful copper instruction building blocks.
**    - EXEC: Common LVOs and utilities to call into exec.
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
CUSTOM                  = $00DFF000
*
********************************************************************************

*** DISK CONTROL REGISTERS *****************************************************

*** DSKBYTR ********************************************************************
*
*   Relative address: $001A
*   Read/write:       Read
*   Chip:             Paula
*   Function:         Disk data byte and status
*
*   This register is the disk-microprocessor data buffer. Data from the disk (in
*   read mode) is loaded into this register one byte at a time, and bit 15 
*   (DSKBYT) is set to true.
*
DSKBYTR                 = $001A
*
CUSTOM_DSKBYTR          = CUSTOM+DSKBYTR
*
*   BIT#  FLAG      DESCRIPTION
*   ----- --------- ------------------------------------------------------------
*   15    DSKBYT    Disk byte ready. (Reset on read.)
*   14    DMAON     AND of DMAEN of DSKLEN and DMACON.
*   13    DISKWRITE Mirror of WRITE in DSKLEN. 
*   12    WORDEQUAL True if and only DATA equals DSKSYNC.
*   07-00 DATA      Disk data byte.
*
DSKBYTRB_DSKBYT         = 15
DSKBYTRF_DSKBYT         = (1<<15)
*
DSKBYTRB_DMAON          = 14
DSKBYTRF_DMAON          = (1<<14)
*
DSKBYTRB_DISKWRITE      = 13
DSKBYTRF_DISKWRITE      = (1<<13)
*
DSKBYTRB_WORDEQUAL      = 12
DSKBYTRF_WORDEQUAL      = (1<<12)
*
DSKBYTRF_DATA           = $00FF
*
********************************************************************************

*** DSKPT (DSKPTH + DSKPTL) ****************************************************
*
*   Relative address: $0020 + $0022
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Disk pointer
*
*   This pair of registers contains the 18-bit address of disk DMA data. These 
*   address registers must be initialized by the processor or Copper before disk
*   DMA is enabled.
*
*   NOTE: Can be written to with a single MOVE.L instruction.
*
*   OCS: The low word's LSB is ignored and is assumed to be an even address.
*        Only the 3 least significant bits in the high word are considered.
*   ECS: As OCS, except the 5 least significant bits in the high word are
*        considered.
*   AGA: As ECS, except all bits in the high word are considered.
*
DSKPT                   = $0020
DSKPTH                  = DSKPT
DSKPTL                  = $0022
*
CUSTOM_DSKPT            = CUSTOM+DSKPT
CUSTOM_DSKPTH           = CUSTOM+DSKPTH
CUSTOM_DSKPTL           = CUSTOM+DSKPTL
*
********************************************************************************

*** DSKLEN *********************************************************************
*
*   Relative address: $0024
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk length
*
*   This register contains the length (number of words) of disk DMA data. It 
*   also contains two control bits, a DMA enable bit, and a DMA direction 
*   (read/write) bit.
*
DSKLEN                  = $0024
*
CUSTOM_DSKLEN           = CUSTOM+DSKLEN
*
*   BIT# FLAG  DESCRIPTION
*   ---- ----- -----------------------------------------------------------------
*   15   DMAEN Disk DMA enable.
*   14   WRITE Disk write (ram to disk) if 1.
*   13-0 LEN   Length (number of words) of DMA data.
*
DSKLENB_DMAEN           = 15
DSKLENF_DMAEN           = (1<<15)
*
DSKLENB_WRITE           = 14
DSKLENF_WRITE           = (1<<14)
*
DSKLENF_LEN             = $3FFF
*
********************************************************************************

*** DSKDAT *********************************************************************
*
*   Relative address: $0026
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk DMA data write
*
*   This register is the disk DMA data buffer. It contains two bytes of data 
*   that are either sent (written) to or received (read) from the disk. The 
*   write mode is enabled by bit 14 of the LENGTH register. The DMA controller 
*   automatically transfers data to or from this register and RAM, and when the
*   DMA data is finished (length=0) it causes a disk block interrupt.
*
*   DSKDATR does exist, but it cannot be accessed. See the dummy registers 
*   section.
*
DSKDAT                  = $0026
*
CUSTOM_DSKDAT           = CUSTOM+DSKDAT
*
********************************************************************************

*** DSKSYNC ********************************************************************
*
*   Relative address: $007E
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Disk sync register
*
*   Holds the match code for disk read synchronization. See ADKCON.
*
DSKSYNC                 = $007E
*
CUSTOM_DSKSYNC          = CUSTOM+DSKSYNC
*
********************************************************************************

*** BLITTER REGISTERS **********************************************************

*** BLTCONx ********************************************************************
*
*   Relative address: $0040 & $0042
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter control registers
*
*   These two control registers are used together to control blitter operations.
*   There are two basic modes, area and line, which are selected by bit 0 of 
*   BLTCON1, as shown below.
*
*   ECS: Flag DOFF in BLTCON1 is only available on ECS.
*
BLTCON0                 = $0040
BLTCON1                 = $0042
*
CUSTOM_BLTCON0          = CUSTOM+BLTCON0
CUSTOM_BLTCON1          = CUSTOM+BLTCON1
*
*   AREA                  LINE
*   --------------------  ----------------
*   BIT# BLTCON0 BLTCON1  BLTCON0 BLTCON1
*   ---- ------- -------  ------- --------
*   15   ASH3    BSH3     START3  TEXTURE3
*   14   ASH2    BSH2     START2  TEXTURE2
*   13   ASH1    BSH1     START1  TEXTURE1
*   12   ASH0    BSH0     START0  TEXTURE0
*   11   USEA    0        1       0
*   10   USEB    0        0       0
*   09   USEC    0        1       0
*   08   USED    0        1       0
*   07   LF7     DOFF     LF7     DOFF
*   06   LF6     0        LF6     SIGN
*   05   LF5     0        LF5     OVF
*   04   LF4     EFE      LF4     SUD
*   03   LF3     IFE      LF3     SUL
*   02   LF2     FCI      LF2     AUL
*   01   LF1     DESC     LF1     SING
*   00   LF0     LINE(0)  LF0     LINE(1)
*
BLTCON0B_ASH3           = 15
BLTCON0B_ASH2           = 14
BLTCON0B_ASH1           = 13
BLTCON0B_ASH0           = 12
BLTCON0F_ASH            = $F000
BLTCON0F_ASH3           = (1<<15)
BLTCON0F_ASH2           = (1<<14)
BLTCON0F_ASH1           = (1<<13)
BLTCON0F_ASH0           = (1<<12)
*
BLTCON0B_START3         = 15
BLTCON0B_START2         = 14
BLTCON0B_START1         = 13
BLTCON0B_START0         = 12
BLTCON0F_START          = $F000
BLTCON0F_START3         = (1<<15)
BLTCON0F_START2         = (1<<14)
BLTCON0F_START1         = (1<<13)
BLTCON0F_START0         = (1<<12)
*
BLTCON1B_BSH3           = 15
BLTCON1B_BSH2           = 14
BLTCON1B_BSH1           = 13
BLTCON1B_BSH0           = 12
BLTCON1F_BSH            = $F000
BLTCON1F_BSH3           = (1<<15)
BLTCON1F_BSH2           = (1<<14)
BLTCON1F_BSH1           = (1<<13)
BLTCON1F_BSH0           = (1<<12)
*
BLTCON1B_TEXTURE3       = 15
BLTCON1B_TEXTURE2       = 14
BLTCON1B_TEXTURE1       = 13
BLTCON1B_TEXTURE0       = 12
BLTCON1F_TEXTURE        = $F000
BLTCON1F_TEXTURE3       = (1<<15)
BLTCON1F_TEXTURE2       = (1<<14)
BLTCON1F_TEXTURE1       = (1<<13)
BLTCON1F_TEXTURE0       = (1<<12)
*
BLTCON0B_USEA           = 11
BLTCON0B_USEB           = 10
BLTCON0B_USEC           = 9
BLTCON0B_USED           = 8
BLTCON0F_USE            = $0F00
BLTCON0F_USEA           = (1<<11)
BLTCON0F_USEB           = (1<<10)
BLTCON0F_USEC           = (1<<9)
BLTCON0F_USED           = (1<<8)
BLTCON0F_USE_LINE       = $0B00
*
BLTCON0B_LF7            = 7
BLTCON0B_LF6            = 6
BLTCON0B_LF5            = 5
BLTCON0B_LF4            = 4
BLTCON0B_LF3            = 3
BLTCON0B_LF2            = 2
BLTCON0B_LF1            = 1
BLTCON0B_LF0            = 0
BLTCON0F_LF             = $00FF
BLTCON0F_LF7            = (1<<7)
BLTCON0F_LF6            = (1<<6)
BLTCON0F_LF5            = (1<<5)
BLTCON0F_LF4            = (1<<4)
BLTCON0F_LF3            = (1<<3)
BLTCON0F_LF2            = (1<<2)
BLTCON0F_LF1            = (1<<1)
BLTCON0F_LF0            = (1<<0)
*
BLTCON1B_DOFF           = 7
BLTCON1F_DOFF           = (1<<7)
*
BLTCON1B_SIGN           = 6
BLTCON1F_SIGN           = (1<<6)
*
BLTCON1B_OVF            = 5
BLTCON1F_OVF            = (1<<5)
*
BLTCON1B_EFE            = 4
BLTCON1B_SUD            = 4
BLTCON1F_EFE            = (1<<4)
BLTCON1F_SUD            = (1<<4)
*
BLTCON1B_IFE            = 3
BLTCON1B_SUL            = 3
BLTCON1F_IFE            = (1<<3)
BLTCON1F_SUL            = (1<<3)
*
BLTCON1B_FCI            = 2
BLTCON1B_AUL            = 2
BLTCON1F_FCI            = (1<<2)
BLTCON1F_AUL            = (1<<2)
*
BLTCON1B_DESC           = 1
BLTCON1B_SING           = 1
BLTCON1B_ONEDOT         = 1
BLTCON1F_DESC           = (1<<1)
BLTCON1F_SING           = (1<<1)
BLTCON1F_ONEDOT         = (1<<1)
*
BLTCON1B_LINE           = 0
BLTCON1F_LINE           = (1<<0)
*
*   Conveniences for the octant in line mode.
*
BLTCON1F_OCTANT0        = $18
BLTCON1F_OCTANT1        = $04
BLTCON1F_OCTANT2        = $0C
BLTCON1F_OCTANT3        = $1C
BLTCON1F_OCTANT4        = $14
BLTCON1F_OCTANT5        = $08
BLTCON1F_OCTANT6        = $00
BLTCON1F_OCTANT7        = $10
*
*   Logic function helpers.
*
*   These are all the possible basic building blocks for the logic function.
*   Every building block has one of three values for A, B, and C:
*     - Set: A, B, or C.
*     - Not set: a, b, or c.
*     - Don't care: x.
*
*   Examples: 
*     - Axx: A, because we don't care about B and C.
*     - ABx: A and B, because we don't care about C.
*     - AbC: A, not B, and C.
*
*   You can binary or several of these building blocks together to represent the
*   logical or of these functions. So (ABx | Axc) represents (A and B) or (A and
*   not C.)
*
BLTCON0F_LF_NOP         = $00
BLTCON0F_LF_xxx         = $FF
BLTCON0F_LF_Axx         = $F0
BLTCON0F_LF_axx         = $0F
BLTCON0F_LF_xBx         = $CC
BLTCON0F_LF_ABx         = $C0
BLTCON0F_LF_aBx         = $0C
BLTCON0F_LF_xbx         = $33
BLTCON0F_LF_Abx         = $30
BLTCON0F_LF_abx         = $03
BLTCON0F_LF_xxC         = $AA
BLTCON0F_LF_AxC         = $A0
BLTCON0F_LF_axC         = $0A
BLTCON0F_LF_xBC         = $88
BLTCON0F_LF_ABC         = $80
BLTCON0F_LF_aBC         = $08
BLTCON0F_LF_xbC         = $22
BLTCON0F_LF_AbC         = $20
BLTCON0F_LF_abC         = $02
BLTCON0F_LF_xxc         = $55
BLTCON0F_LF_Axc         = $50
BLTCON0F_LF_axc         = $05
BLTCON0F_LF_xBc         = $44
BLTCON0F_LF_ABc         = $40
BLTCON0F_LF_aBc         = $04
BLTCON0F_LF_xbc         = $11
BLTCON0F_LF_Abc         = $10
BLTCON0F_LF_abc         = $01
*
*   Redefinitions of some of the above in minterm terms.
*
BLTCON0F_MINTERM_ABC    = $80
BLTCON0F_MINTERM_ABc    = $40
BLTCON0F_MINTERM_AbC    = $20
BLTCON0F_MINTERM_Abc    = $10
BLTCON0F_MINTERM_aBC    = $08
BLTCON0F_MINTERM_aBc    = $04
BLTCON0F_MINTERM_abC    = $02
BLTCON0F_MINTERM_abc    = $01
*   
*   Convience logic functions for line mode.
*
*   OVER = ABx + axx
*   XOR  = ABc + Axc
*
BLTCON0F_LF_LINE_OVER   = $CF
BLTCON0F_LF_LINE_XOR    = $4A
*
********************************************************************************

*** BLTAFWM & BLTALWM **********************************************************
*
*   Relative address: $0044 & $0046
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter first/last-word mask for source A
*
*   The patterns in these two registers are ANDed with the first and last words
*   of each line of data from source A into the blitter. A zero in any bit 
*   overrides data from source A. These registers should be set to all 1s for 
*   fill mode or for line-drawing mode.
*
BLTAFWM                 = $0044
BLTALWM                 = $0046
*
CUSTOM_BLTAFWM          = CUSTOM+BLTAFWM
CUSTOM_BLTALWM          = CUSTOM+BLTALWM
*
********************************************************************************

*** BLTxPT (BLTxPTH + BLTxPTL) *************************************************
*
*   Relative address: $0048 + $004A & $004C + $004E & 
*                     $0050 + $0052 & $0054 + $0056
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter pointer to A/B/C/D
*
*   This pair of registers contains the 18-bit address of blitter source 
*   (x=A,B,C) or destination (x=D) DMA data. This pointer must be preloaded with
*   the starting address of the data to be processed by the blitter. After the 
*   blitter is finished, it will contain the last data address (plus increment
*   and modulo).
*
*   Line mode: BLTAPTL is used as an accumulator register and must be preloaded
*              with the starting value of (2Y-X) where Y/X is the line slope. 
*              BLTCPT and BLTDPT (both H and L) must be preloaded with the 
*              starting address of the line.
*
*   NOTE: Can be written to with a single MOVE.L instruction.
*
*   OCS: The low word's LSB is ignored and is assumed to be an even address.
*        Only the 3 least significant bits in the high word are considered.
*   ECS: As OCS, except the 5 least significant bits in the high word are
*        considered.
*   AGA: As ECS, except all bits in the high word are considered.
*
BLTCPT                  = $0048          
BLTCPTH                 = BLTCPT
BLTCPTL                 = $004A
BLTBPT                  = $004C          
BLTBPTH                 = BLTBPT
BLTBPTL                 = $004E
BLTAPT                  = $0050          
BLTAPTH                 = BLTAPT
BLTAPTL                 = $0052
BLTDPT                  = $0054          
BLTDPTH                 = BLTDPT
BLTDPTL                 = $0054
*
CUSTOM_BLTCPT           = CUSTOM+BLTCPT 
CUSTOM_BLTCPTH          = CUSTOM+BLTCPTH
CUSTOM_BLTCPTL          = CUSTOM+BLTCPTL
CUSTOM_BLTBPT           = CUSTOM+BLTBPT         
CUSTOM_BLTBPTH          = CUSTOM+BLTBPTH
CUSTOM_BLTBPTL          = CUSTOM+BLTBPTL
CUSTOM_BLTAPT           = CUSTOM+BLTAPT         
CUSTOM_BLTAPTH          = CUSTOM+BLTAPTH
CUSTOM_BLTAPTL          = CUSTOM+BLTAPTL
CUSTOM_BLTDPT           = CUSTOM+BLTDPT         
CUSTOM_BLTDPTH          = CUSTOM+BLTDPTH
CUSTOM_BLTDPTL          = CUSTOM+BLTDPTL
*
********************************************************************************

*** BLTxDAT ********************************************************************
*
*   Relative address: $0070 & $0072 & $0074
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter source A/B/C data register
*
*   This register holds source x (x=A,B,C) data for use by the blitter. It is 
*   normally loaded by the blitter DMA channel; however, it may also be 
*   preloaded by the microprocessor.
*
*   Line mode: BLTADAT is used as an index register and must be preloaded with 
*              8000. BLTBDAT is used for texture; it must be preloaded with FF 
*              if no texture (solid line) is desired.
*
BLTCDAT                 = $0070
BLTBDAT                 = $0072
BLTADAT                 = $0074
*
CUSTOM_BLTCDAT          = CUSTOM+BLTCDAT
CUSTOM_BLTBDAT          = CUSTOM+BLTBDAT
CUSTOM_BLTADAT          = CUSTOM+BLTADAT
*
********************************************************************************

*** BLTxMOD ********************************************************************
*
*   Relative address: $0060 & $0062 & $0064 & $0066
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter modulo A/B/C/D
*
*   This register contains the modulo for blitter source (x=A,B,C) or 
*   destination (x=D). A modulo is a number that is automatically added to the
*   address at the end of each line, to make the address point to the start of 
*   the next line. Each source or destination has its own modulo, allowing each
*   to be a different size, while an identical area of each is used in the 
*   blitter operation.
*
*   Line mode: BLTAMOD and BLTBMOD are used as slope storage registers and must 
*              be preloaded with the values (4Y-4X) and (4Y) respectively. 
*              Y/X= line slope. BLTCMOD and BLTDMOD must both be preloaded with
*              the width (in bytes) of the image into which the line is being 
*              drawn (normally two times the screen width in words).
*
BLTCMOD                 = $0060
BLTBMOD                 = $0062
BLTAMOD                 = $0064
BLTDMOD                 = $0066
*
CUSTOM_BLTCMOD          = CUSTOM+BLTCMOD
CUSTOM_BLTBMOD          = CUSTOM+BLTBMOD
CUSTOM_BLTAMOD          = CUSTOM+BLTAMOD
CUSTOM_BLTDMOD          = CUSTOM+BLTDMOD
*
********************************************************************************

*** BLTSIZE ********************************************************************
*
*   Relative address: $0058
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter start and size (window width, height)
*
*   This register contains the width and height of the blitter operation (in 
*   line mode, width must = 2, height = line length). Writing to this register 
*   will start the blitter, and should be done last, after all pointers and 
*   control registers have been initialized.
*
*   Line draw: BLTSIZE controls the line length and starts the line draw when 
*              written to. The h field controls the line length (10 bits gives
*              lines up to 1024 dots long). The w field must be set to 02 for 
*              all line drawing.
*
BLTSIZE                 = $0058
*
CUSTOM_BLTSIZE          = CUSTOM+BLTSIZE
*
*   BIT#  15,14,13,12,11,10,09,08,07,06,05,04,03,02,01,00
*         -----------------------------------------------
*         h9 h8 h7 h6 h5 h4 h3 h2 h1 h0,w5 w4 w3 w2 w1 w0
*
*   h = height = vertical lines (10 bits = 1024 lines max)
*   w = width = horizontal pixels (6 bits = 64 words = 1024 pixels max)
*
BLTSIZEB_HEIGHT9        = 15
BLTSIZEB_HEIGHT8        = 14
BLTSIZEB_HEIGHT7        = 13
BLTSIZEB_HEIGHT6        = 12
BLTSIZEB_HEIGHT5        = 11
BLTSIZEB_HEIGHT4        = 10
BLTSIZEB_HEIGHT3        = 9
BLTSIZEB_HEIGHT2        = 8
BLTSIZEB_HEIGHT1        = 7
BLTSIZEB_HEIGHT0        = 6
BLTSIZEF_HEIGHT         = $FFC0
BLTSIZEF_HEIGHT9        = (1<<15)
BLTSIZEF_HEIGHT8        = (1<<14)
BLTSIZEF_HEIGHT7        = (1<<13)
BLTSIZEF_HEIGHT6        = (1<<12)
BLTSIZEF_HEIGHT5        = (1<<11)
BLTSIZEF_HEIGHT4        = (1<<10)
BLTSIZEF_HEIGHT3        = (1<<9)
BLTSIZEF_HEIGHT2        = (1<<8)
BLTSIZEF_HEIGHT1        = (1<<7)
BLTSIZEF_HEIGHT0        = (1<<6)
*
BLTSIZEB_WIDTH5         = 5
BLTSIZEB_WIDTH4         = 4
BLTSIZEB_WIDTH3         = 3
BLTSIZEB_WIDTH2         = 2
BLTSIZEB_WIDTH1         = 1
BLTSIZEB_WIDTH0         = 0
BLTSIZEF_WIDTH          = $3F
BLTSIZEF_WIDTH5         = (1<<5)
BLTSIZEF_WIDTH4         = (1<<4)
BLTSIZEF_WIDTH3         = (1<<3)
BLTSIZEF_WIDTH2         = (1<<2)
BLTSIZEF_WIDTH1         = (1<<1)
BLTSIZEF_WIDTH0         = (1<<0)
*
********************************************************************************

*** (ECS) BLTCON0L *************************************************************
*
*   Relative address: $005B
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         BLTCON0 lower 8 bits
*
*   Note: Byte access only. See also BLTCON0.
*
BLTCON0L                = $005B
*
CUSTOM_BLTCON0L         = CUSTOM+BLTCON0L
*
********************************************************************************

*** (ECS) BLTSIZV & BLTSIZH ****************************************************
*
*   Relative address: $005C & $005E
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Blitter 15 bit height & blitter 11 bit width (+start)
*
*   These are the blitter size registers for blits larger than OCS could accept.
*   The original BLTSIZE register is retained for compatibility. BLTSIZV should
*   be written first, followed by BLTSIZH, which starts the blitter. BLTSIZV 
*   need not be rewritten for subsequent blits if the vertical size is the same.
*
BLTSIZV                 = $005C
BLTSIZH                 = $005E
*
CUSTOM_BLTSIZV          = CUSTOM+BLTSIZV
CUSTOM_BLTSIZH          = CUSTOM+BLTSIZH
*
********************************************************************************

*** COPPER CONTROL REGISTERS ***************************************************

*** COPCON *********************************************************************
*
*   Relative address: $002E
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Copper control register
*
*   This is a 1-bit register that when set true, allows the Copper to access the 
*   blitter hardware. This bit is cleared by power-on reset, so that the Copper
*   cannot access the blitter hardware.
*
*   OCS: With the CDANG bit cleared, the copper can access: $DFF080 - $DFF1FE
*        With the CDANG bit set, the copper can access:     $DFF03E - $DFF1FE
*   ECS: With the CDANG bit cleared, the copper can access: $DFF03E - $DFF1FE
*        With the CDANG bit set, the copper can access:     $DFF000 - $DFF1FE
*
COPCON                  = $002E
*
CUSTOM_COPCON           = CUSTOM+COPCON
*
COPCONB_CDANG           = 1
COPCONF_CDANG           = (1<<1)
*
********************************************************************************

*** COPxLC (COPxLCH + COPxLCL) *************************************************
*
*   Relative address: $0080 + $0082 & $0084 + $0086
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Copper list 1/2 pointer registers
*
*   These registers contain the jump addresses for the first and second copper
*   lists.
*
*   NOTE: Can be written to with a single MOVE.L instruction.
*
*   OCS: The low word's LSB is ignored and is assumed to be an even address.
*        Only the 3 least significant bits in the high word are considered.
*   ECS: As OCS, except the 5 least significant bits in the high word are
*        considered.
*   AGA: As ECS, except all bits in the high word are considered.
*
COP1LC                  = $0080
COP1LCH                 = COP1LC
COP1LCL                 = $0082
COP2LC                  = $0084
COP2LCH                 = COP2LC
COP2LCL                 = $0086
*
CUSTOM_COP1LC           = CUSTOM+COP1LC 
CUSTOM_COP1LCH          = CUSTOM+COP1LCH
CUSTOM_COP1LCL          = CUSTOM+COP1LCL
CUSTOM_COP2LC           = CUSTOM+COP2LC 
CUSTOM_COP2LCH          = CUSTOM+COP2LCH
CUSTOM_COP2LCL          = CUSTOM+COP2LCL
*
********************************************************************************

*** COPJMPx ********************************************************************
*
*   Relative address: $0088 & $008A
*   Read/write:       Strobe
*   Chip:             Agnus
*   Function:         Copper list 1/2 restart strobe
*
COPJMP1                 = $0088
COPJMP2                 = $008A
*
CUSTOM_COPJMP1          = CUSTOM+COPJMP1
CUSTOM_COPJMP2          = CUSTOM+COPJMP2
*
COPJMP1F_STROBE         = $FFFF
COPJMP2F_STROBE         = $FFFF
*
********************************************************************************

*** AUDIO CHANNEL REGISTERS ****************************************************

*** ADKCON & ADKCONR ***********************************************************
*
*   Relative address: $009E & $0010
*   Read/write:       Write & Read
*   Chip:             Agnus
*   Function:         Audio+disk control
*
ADKCON                  = $009E
ADKCONR                 = $0010
*
CUSTOM_ADKCON           = CUSTOM+ADKCON 
CUSTOM_ADKCONR          = CUSTOM+ADKCONR
*
*   BIT#  FLAG      DESCRIPTION
*   ---- --------- ------------------------------------------------------------
*   15    SETCLR    Determines if set bits get set or cleared
*   14    PRECOMP1  Precompensation amount
*   13    PRECOMP0  00=0ns, 01=140ns, 10=280ns, 11=560ns
*   12    MFMPREC   MFM or GCR precompensation
*   11    UARTBRK   Assert a UART break if set
*   10    WORDSYNC  Enables disk read sync on word in DSKSYNC
*   09    MSBSYNC   Enables sync on MSB for Apple GCR
*   08    FAST      Set for 1-2us/bit, clear for 2-4us/bit
*   07    USE3PN    Use audio channel 3 to modulate nothing
*   06    USE2P3    Use audio channel 2 to modulate period of channel 3
*   05    USE1P2    Use audio channel 1 to modulate period of channel 2
*   04    USE0P1    Use audio channel 0 to modulate period of channel 1
*   03    USE3VN    Use audio channel 3 to modulate nothing
*   02    USE2V3    Use audio channel 2 to modulate volume of channel 3
*   01    USE1V2    Use audio channel 1 to modulate volume of channel 2
*   00    USE0V1    Use audio channel 0 to modulate volume of channel 1
*
ADKCONB_SETCLR          = 15
ADKCONB_PRECOMP1        = 14
ADKCONB_PRECOMP0        = 13
ADKCONB_MFMPREC         = 12
ADKCONB_UARTBRK         = 11
ADKCONB_WORDSYNC        = 10
ADKCONB_MSBSYNC         = 9
ADKCONB_FAST            = 8
ADKCONF_SETCLR          = (1<<15)
ADKCONF_PRECOMP1        = (1<<14)
ADKCONF_PRECOMP0        = (1<<13)
ADKCONF_MFMPREC         = (1<<12)
ADKCONF_UARTBRK         = (1<<11)
ADKCONF_WORDSYNC        = (1<<10)
ADKCONF_MSBSYNC         = (1<<9)
ADKCONF_FAST            = (1<<8)
*
ADKCONB_USE3PN          = 7
ADKCONB_USE2P3          = 6
ADKCONB_USE1P2          = 5
ADKCONB_USE0P1          = 4
ADKCONF_USE3PN          = (1<<7)
ADKCONF_USE2P3          = (1<<6)
ADKCONF_USE1P2          = (1<<5)
ADKCONF_USE0P1          = (1<<4)
*
ADKCONB_USE3VN          = 3
ADKCONB_USE2V3          = 2
ADKCONB_USE1V2          = 1
ADKCONB_USE0V1          = 0
ADKCONF_USE3VN          = (1<<3)
ADKCONF_USE2V3          = (1<<2)
ADKCONF_USE1V2          = (1<<1)
ADKCONF_USE0V1          = (1<<0)
*
ADKCONF_PRE000NS        = $0000
ADKCONF_PRE140NS        = $2000
ADKCONF_PRE280NS        = $4000
ADKCONF_PRE560NS        = $6000
*
********************************************************************************

*** AUDxLC (AUDxLCH + AUDxLCL) *************************************************
*
*   Relative address: $00A0 + $00A2 & $00B0 + $00B2 &
*                     $00C0 + $00C2 & $00D0 + $00D2
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Audio channel x location
*
*   This pair of registers contains the 18 bit starting address (location) of 
*   audio channel x (x=0,1,2,3) DMA data. This is not a pointer register and 
*   therefore needs to be reloaded only if a different memory location is to be
*   output. See the DMACON register for information on how to begin the DMA.
*
*   NOTE: Can be written to with a single MOVE.L instruction.
*
*   OCS: The low word's LSB is ignored and is assumed to be an even address.
*        Only the 3 least significant bits in the high word are considered.
*   ECS: As OCS, except the 5 least significant bits in the high word are
*        considered.
*   AGA: As ECS, except all bits in the high word are considered.
*
AUD0LC                  = $00A0
AUD0LCH                 = AUD0LC
AUD0LCL                 = $00A2
AUD1LC                  = $00B0
AUD1LCH                 = AUD1LC
AUD1LCL                 = $00B2
AUD2LC                  = $00C0
AUD2LCH                 = AUD2LC
AUD2LCL                 = $00C2
AUD3LC                  = $00D0
AUD3LCH                 = AUD3LC
AUD3LCL                 = $00D2
*
CUSTOM_AUD0LC           = CUSTOM+AUD0LC 
CUSTOM_AUD0LCH          = CUSTOM+AUD0LCH
CUSTOM_AUD0LCL          = CUSTOM+AUD0LCL
CUSTOM_AUD1LC           = CUSTOM+AUD1LC 
CUSTOM_AUD1LCH          = CUSTOM+AUD1LCH
CUSTOM_AUD1LCL          = CUSTOM+AUD1LCL
CUSTOM_AUD2LC           = CUSTOM+AUD2LC 
CUSTOM_AUD2LCH          = CUSTOM+AUD2LCH
CUSTOM_AUD2LCL          = CUSTOM+AUD2LCL
CUSTOM_AUD3LC           = CUSTOM+AUD3LC 
CUSTOM_AUD3LCH          = CUSTOM+AUD3LCH
CUSTOM_AUD3LCL          = CUSTOM+AUD3LCL
*
********************************************************************************

*** AUDxLEN ********************************************************************
*
*   Relative address: $00A4 & $00B4 & $00C4 & $00D4 
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x length
*
*   This register contains the length (number of words) of audio channel x DMA 
*   data.
*
AUD0LEN                 = $00A4
AUD1LEN                 = $00B4
AUD2LEN                 = $00C4
AUD3LEN                 = $00D4
*
CUSTOM_AUD0LEN          = CUSTOM+AUD0LEN
CUSTOM_AUD1LEN          = CUSTOM+AUD1LEN
CUSTOM_AUD2LEN          = CUSTOM+AUD2LEN
CUSTOM_AUD3LEN          = CUSTOM+AUD3LEN
*
********************************************************************************

*** AUDxPER ********************************************************************
*
*   Relative address: $00A6 & $00B6 & $00C6 & $00D6 
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x period
*
*   This register contains the period (rate) of audio channel x DMA data 
*   transfer. The minimum period is 124 color clocks. This means that the 
*   smallest number that should be placed in this register is 123 (PAL)/124
*   (NTSC) decimal. This corresponds to a maximum sample frequency of 28867 
*   samples/second.
*
*   To avoid aliasing distortion, values should be restricted to the range of
*   124-256, which corresponds to a sample rate of 14-28 kHz.
*
*   The formula that governs the audio system is: PERIOD = CONSTANT/SAMPLE_RATE
*
*   The constant in the above function is 3579545 for NTSC and 3546895 for PAL.
*
*   ECS: With programmable scan rates, the maximum value read from this register
*        will differ. Generally, the faster the scan rate, the smaller the 
*        maximum period becomes. Adjustments to the scan rate are reflected in 
*        this maximum value.
*
AUD0PER                 = $00A6
AUD1PER                 = $00B6
AUD2PER                 = $00C6
AUD3PER                 = $00D6
*
CUSTOM_AUD0PER          = CUSTOM+AUD0PER
CUSTOM_AUD1PER          = CUSTOM+AUD1PER
CUSTOM_AUD2PER          = CUSTOM+AUD2PER
CUSTOM_AUD3PER          = CUSTOM+AUD3PER
*
********************************************************************************

*** AUDxVOL ********************************************************************
*
*   Relative address: $00A8 & $00B8 & $00C8 & $00D8
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x volume
*
*   This register contains the volume setting for audio channel x. Bits 6-0 
*   specify 65 linear volume levels from 0 (silent) to 64 (maximum).
*
AUD0VOL                 = $00A8
AUD1VOL                 = $00B8
AUD2VOL                 = $00C8
AUD3VOL                 = $00D8
*
CUSTOM_AUD0VOL          = CUSTOM+AUD0VOL
CUSTOM_AUD1VOL          = CUSTOM+AUD1VOL
CUSTOM_AUD2VOL          = CUSTOM+AUD2VOL
CUSTOM_AUD3VOL          = CUSTOM+AUD3VOL
*
********************************************************************************

*** AUDxDAT ********************************************************************
*
*   Relative address: $00AA & $00BA & $00CA & $00DA
*   Read/write:       Write
*   Chip:             Paula
*   Function:         Audio channel x data
*
*   This register is the audio channel x (x=0,1,2,3) DMA data buffer. It 
*   contains 2 bytes of data that are each 2's complement and are output 
*   sequentially (with digital-to-analog conversion) to the audio output pins. 
*   (LSB = 3 MV) The DMA controller automatically transfers data to this
*   register from RAM. The processor can also write directly to this register.
*   When the DMA data is finished (words output=length) and the data in this 
*   register has been used, an audio channel interrupt request is set.
*
AUD0DAT                 = $00AA
AUD1DAT                 = $00BA
AUD2DAT                 = $00CA
AUD3DAT                 = $00DA
*
CUSTOM_AUD0DAT          = CUSTOM+AUD0DAT
CUSTOM_AUD1DAT          = CUSTOM+AUD1DAT
CUSTOM_AUD2DAT          = CUSTOM+AUD2DAT
CUSTOM_AUD3DAT          = CUSTOM+AUD3DAT
*
********************************************************************************

*** BITPLANE REGISTERS *********************************************************

*** BPLxPT (BPLxPTH + BPLxPTL) *************************************************
*
*   Relative address: $00E0 + $00E2 & $00E4 + $00E6 &
*                     $00E8 + $00EA & $00EC + $00EE &
*                     $00F0 + $00F2 & $00F4 + $00F6 &
*                     $00F8 + $00FA & $00FC + $00FE
*   Read/write:       Write
*   Chip:             Agnus
*   Function:         Bitplane x pointer
*
*   This pair of registers contains the 18-bit pointer to the address of 
*   bitplane x (x=1,2,3,4,5,6) DMA data. This pointer must be reinitialized by 
*   the processor or copper to point to the beginning of bitplane data every 
*   vertical blank time.
*
*   NOTE: Can be written to with a single MOVE.L instruction.
*
*   OCS: The low word's LSB is ignored and is assumed to be an even address.
*        Only the 3 least significant bits in the high word are considered.
*   ECS: As OCS, except the 5 least significant bits in the high word are
*        considered.
*   AGA: As ECS, except all bits in the high word are considered. AGA also adds
*        bitplanes 7 and 8.
*
BPL1PT                  = $00E0
BPL1PTH                 = BPL1PT
BPL1PTL                 = $00E2
BPL2PT                  = $00E4
BPL2PTH                 = BPL2PT
BPL2PTL                 = $00E6
BPL3PT                  = $00E8
BPL3PTH                 = BPL3PT
BPL3PTL                 = $00EA
BPL4PT                  = $00EC
BPL4PTH                 = BPL4PT
BPL4PTL                 = $00EE
BPL5PT                  = $00F0
BPL5PTH                 = BPL5PT
BPL5PTL                 = $00F2
BPL6PT                  = $00F4
BPL6PTH                 = BPL6PT
BPL6PTL                 = $00F6
BPL7PT                  = $00F8
BPL7PTH                 = BPL7PT
BPL7PTL                 = $00FA
BPL8PT                  = $00FC
BPL8PTH                 = BPL8PT
BPL8PTL                 = $00FE
*
CUSTOM_BPL1PT           = CUSTOM+BPL1PT 
CUSTOM_BPL1PTH          = CUSTOM+BPL1PTH 
CUSTOM_BPL1PTL          = CUSTOM+BPL1PTL
CUSTOM_BPL2PT           = CUSTOM+BPL2PT 
CUSTOM_BPL2PTH          = CUSTOM+BPL2PTH 
CUSTOM_BPL2PTL          = CUSTOM+BPL2PTL
CUSTOM_BPL3PT           = CUSTOM+BPL3PT 
CUSTOM_BPL3PTH          = CUSTOM+BPL3PTH 
CUSTOM_BPL3PTL          = CUSTOM+BPL3PTL
CUSTOM_BPL4PT           = CUSTOM+BPL4PT 
CUSTOM_BPL4PTH          = CUSTOM+BPL4PTH 
CUSTOM_BPL4PTL          = CUSTOM+BPL4PTL
CUSTOM_BPL5PT           = CUSTOM+BPL5PT 
CUSTOM_BPL5PTH          = CUSTOM+BPL5PTH 
CUSTOM_BPL5PTL          = CUSTOM+BPL5PTL
CUSTOM_BPL6PT           = CUSTOM+BPL6PT 
CUSTOM_BPL6PTH          = CUSTOM+BPL6PTH 
CUSTOM_BPL6PTL          = CUSTOM+BPL6PTL
CUSTOM_BPL7PT           = CUSTOM+BPL7PT 
CUSTOM_BPL7PTH          = CUSTOM+BPL7PTH 
CUSTOM_BPL7PTL          = CUSTOM+BPL7PTL
CUSTOM_BPL8PT           = CUSTOM+BPL8PT 
CUSTOM_BPL8PTH          = CUSTOM+BPL8PTH 
CUSTOM_BPL8PTL          = CUSTOM+BPL8PTL
*
********************************************************************************

;BPLCON0               equ bplcon0        
;BPLCON1               equ bplcon1        
;BPLCON2               equ bplcon2        
;BPLCON3               equ bplcon3
;BPLCON4               equ bplcon4
;BPL1MOD               equ bpl1mod        
;BPL2MOD               equ bpl2mod       
;
;BPL1DAT               equ bpldat
;BPL2DAT               equ bpldat+$02
;BPL3DAT               equ bpldat+$04
;BPL4DAT               equ bpldat+$06
;BPL5DAT               equ bpldat+$08
;BPL6DAT               equ bpldat+$0a
;BPL7DAT               equ bpldat+$0c
;BPL8DAT               equ bpldat+$0e

*** DUMMY REGISTERS ************************************************************

*** BLTDDAT ********************************************************************
*
*   Relative address: $0000
*   Read/write:       -
*   Chip:             Agnus
*   Function:         Blitter destination data register
*
*   This register holds the data resulting from each word of blitter operation 
*   until it is sent to a RAM destination. This is a dummy address and cannot be
*   read by the micro. The transfer is automatic during blitter operation.
*
BLTDDAT                 = $0000
*
CUSTOM_BLTDDAT          = CUSTOM+BLTDDAT
*
********************************************************************************

*** DSKDATR ********************************************************************
*
*   Relative address: $0008
*   Read/write:       -
*   Chip:             Paula
*   Function:         Disk DMA data read
*
*   See DSKDAT in the disk control registers section.
*
DSKDATR                 = $0008
*
CUSTOM_DSKDATR          = CUSTOM+DSKDATR
*
********************************************************************************

*** COPINS *********************************************************************
*
*   Relative address: $008C
*   Read/write:       -
*   Chip:             Agnus
*   Function:         Copper instruction fetch identify
*
*   This is a dummy address used by the copper to identify its instructions
*
COPINS                  = $008C
*
CUSTOM_COPINS           = CUSTOM+COPINS
*
********************************************************************************



; Checklist
; $0002
; $0004
; $0006
; $000A
; $000C
; $000E
; $0012
; $0014
; $0016
; $0018
; $001C
; $001E
; $0028
; $002A
; $002C
; $0030
; $0032
; $0034
; $0036
; $0038
; $003A
; $003C
; $003E
; $0044
; $0046
; $0056
; $0078
; $007A
; $007C
; $007E
; $008E
; $0090
; $0092
; $0094
; $0096
; $0098
; $009A
; $009C
; $009E
; $0100
; $0102
; $0104
; $0106
; $0108
; $010A
; $010C
; $010E
; $0110
; $0112
; $0114
; $0116
; $0118
; $011A
; $011C
; $011E
; $0120
; $0122
; $0124
; $0126
; $0128
; $012A
; $012C
; $012E
; $0130
; $0132
; $0134
; $0136
; $0138
; $013A
; $013C
; $013E
; $0140
; $0142
; $0144
; $0146
; $0148
; $014A
; $014C
; $014E
; $0150
; $0152
; $0154
; $0156
; $0158
; $015A
; $015C
; $015E
; $0160
; $0162
; $0164
; $0166
; $0168
; $016A
; $016C
; $016E
; $0170
; $0172
; $0174
; $0176
; $0178
; $017A
; $017C
; $017E
; $0180
; $0182
; $0184
; $0186
; $0188
; $018A
; $018C
; $018E
; $0190
; $0192
; $0194
; $0196
; $0198
; $019A
; $019C
; $019E
; $01A0
; $01A2
; $01A4
; $01A6
; $01A8
; $01AA
; $01AC
; $01AE
; $01B0
; $01B2
; $01B4
; $01B6
; $01B8
; $01BA
; $01BC
; $01BE
; $01C0
; $01C2
; $01C4
; $01C6
; $01C8
; $01CA
; $01CC
; $01CE
; $01D0
; $01D2
; $01D4
; $01D6
; $01D8
; $01DA
; $01DC
; $01DE
; $01E0
; $01E2
; $01E4
; $01E6
; $01E8
; $01EA
; $01EC
; $01EE
; $01FC
; $01FE

*** CUSTOM SECTION END *********************************************************
            ENDC