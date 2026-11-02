# paddle_control.s
# Readable source for the program hard-coded in rtl/instr_rom.v.
# The ROM holds the hand-assembled machine code; this file is the listing.
#
# Memory-mapped I/O:
#   0x8000_0000  input register   bit 0 = UP, bit 1 = DOWN (one event per frame, cleared on read)
#   0x8000_0004  paddle register  bits 9:0 = paddle Y position
#
# Uses only the instructions the core implements: LUI, ADDI, ANDI, LW, SW, BEQ, JAL.

        .text
start:                              # addr  machine code
        lui   x1, 0x80000           # 0x00  800000B7   x1 = 0x8000_0000 (input register)
        addi  x2, x1, 4             # 0x04  00408113   x2 = 0x8000_0004 (paddle register)
        addi  x3, x0, 200           # 0x08  0C800193   x3 = paddle Y, start near the middle
        sw    x3, 0(x2)             # 0x0C  00312023   show the paddle at its start position

loop:
        lw    x4, 0(x1)             # 0x10  0000A203   read button events
        andi  x5, x4, 1             # 0x14  00127293   UP pressed?
        beq   x5, x0, check_down    # 0x18  00028463
        addi  x3, x3, -4            # 0x1C  FFC18193   move up 4 px

check_down:
        andi  x5, x4, 2             # 0x20  00227293   DOWN pressed?
        beq   x5, x0, store         # 0x24  00028463
        addi  x3, x3, 4             # 0x28  00418193   move down 4 px

store:
        sw    x3, 0(x2)             # 0x2C  00312023   send new position to the game engine
        jal   x0, loop              # 0x30  FE1FF06F   repeat forever
