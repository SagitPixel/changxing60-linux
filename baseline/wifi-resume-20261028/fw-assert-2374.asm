0014685a adr      r2, #0x258
0014685c ldrb     r0, [r0, #7]
0014685e adr      r1, #0x268
00146860 ubfx     r7, r0, #5, #2
00146864 movw     r0, #0xe090
00146868 stm.w    sp, {r0, r6, r7}
0014686c ldr      r0, [pc, #0x268]
0014686e bl       #0x109272
00146872 ldr.w    r0, [r8, #0xab2]
00146876 lsls     r0, r0, #0xf
00146878 bpl      #0x1468a0
0014687a cbz      r6, #0x146880
0014687c cbz      r7, #0x146886
0014687e b        #0x1468a0
00146880 cbnz     r6, #0x1468a0
00146882 cmp      r7, #1
00146884 bne      #0x1468a0
00146886 ldr      r0, [pc, #0x250]
00146888 adds     r0, r0, #1
0014688a bl       #0x10923a
0014688e movw     r2, #0x946
00146892 subw     r1, pc, #0x790
00146896 subw     r0, pc, #0x788
0014689a ldr.w    r3, [sb, #0x24c]
0014689e blx      r3
001468a0 ldr      r0, [pc, #0x1fc]
001468a2 mov      r1, r4
001468a4 adds     r0, #0xc
001468a6 ldr.w    r2, [r0, r5, lsl #2]
001468aa add      sp, #0x18
001468ac mov      r0, sl
001468ae pop.w    {r4, r5, r6, r7, r8, sb, sl, lr}
001468b2 bx       r2
001468b4 push     {r2, r3, r4, r5, r6, lr}
001468b6 mov      r4, r3
002c685a adr      r2, #0x258
002c685c ldrb     r0, [r0, #7]
002c685e adr      r1, #0x268
002c6860 ubfx     r7, r0, #5, #2
002c6864 movw     r0, #0xe090
002c6868 stm.w    sp, {r0, r6, r7}
002c686c ldr      r0, [pc, #0x268]
002c686e bl       #0x289272
002c6872 ldr.w    r0, [r8, #0xab2]
002c6876 lsls     r0, r0, #0xf
002c6878 bpl      #0x2c68a0
002c687a cbz      r6, #0x2c6880
002c687c cbz      r7, #0x2c6886
002c687e b        #0x2c68a0
002c6880 cbnz     r6, #0x2c68a0
002c6882 cmp      r7, #1
002c6884 bne      #0x2c68a0
002c6886 ldr      r0, [pc, #0x250]
002c6888 adds     r0, r0, #1
002c688a bl       #0x28923a
002c688e movw     r2, #0x946
002c6892 subw     r1, pc, #0x790
002c6896 subw     r0, pc, #0x788
002c689a ldr.w    r3, [sb, #0x24c]
002c689e blx      r3
002c68a0 ldr      r0, [pc, #0x1fc]
002c68a2 mov      r1, r4
002c68a4 adds     r0, #0xc
002c68a6 ldr.w    r2, [r0, r5, lsl #2]
002c68aa add      sp, #0x18
002c68ac mov      r0, sl
002c68ae pop.w    {r4, r5, r6, r7, r8, sb, sl, lr}
002c68b2 bx       r2
002c68b4 push     {r2, r3, r4, r5, r6, lr}
002c68b6 mov      r4, r3