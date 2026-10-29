00146776 push.w    {r4, r5, r6, r7, r8, sb, sl, lr}
0014677a sub       sp, #0x18
0014677c mov       r4, r1
0014677e mov       sl, r0
00146780 bl        #0x163f1c
00146784 add.w     r8, r0, #0x1000
00146788 ldrb      r1, [r4, #1]
0014678a ldrb.w    r0, [r8, #0xab2]
0014678e and       r6, r0, #1
00146792 orr.w     r0, r1, sl, lsl #8
00146796 uxth      r1, r0
00146798 ldr       r0, [pc, #0x2a8]
0014679a ldr       r2, [r0, #0x40]
0014679c movw      r0, #0xdaf4
001467a0 blx       r2
0014685c ldrb      r0, [r0, #7]
0014685e adr       r1, #0x268
00146860 ubfx      r7, r0, #5, #2
00146864 movw      r0, #0xe090
00146868 stm.w     sp, {r0, r6, r7}
0014686c ldr       r0, [pc, #0x268]
0014686e bl        #0x109272
00146872 ldr.w     r0, [r8, #0xab2]
00146876 lsls      r0, r0, #0xf
00146878 bpl       #0x1468a0
0014687a cbz       r6, #0x146880
0014687c cbz       r7, #0x146886
0014687e b         #0x1468a0
00146880 cbnz      r6, #0x1468a0
00146882 cmp       r7, #1
001aad10 strh      r3, [r2, #0x1c]
001aad12 pop       {r2, r3, r4, r5, r7, pc}
001aad14 subs      r2, r2, #1
001aad16 add       r6, sp, #0x3ac
001aad18 bvs       #0x1aacb4
001aad1a lsrs      r5, r6, #0x20
001aad1c ldrh      r0, [r1, #0x16]
001aad1e b         #0x1ab28a
001aad20 iteet     gt
001aad22 bgt       #0x1aacd8
001aad24 ldrle     r0, [r2, r5]
001aad26 ldrle     r5, [pc, #0xfc]
001aad28 addgt     r4, #0x62
001aad2a ldr       r0, [pc, #0x28]
001aad2c push      {r3, r7, lr}