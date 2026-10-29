
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000003f29c <sc2355_find_lut_index>:
   3f29c:	d10103ff 	sub	sp, sp, #0x40
   3f2a0:	f800865e 	str	x30, [x18], #8
   3f2a4:	a9027bfd 	stp	x29, x30, [sp, #32]
   3f2a8:	f9001bf3 	str	x19, [sp, #48]
   3f2ac:	910083fd 	add	x29, sp, #0x20
   3f2b0:	52889a08 	mov	w8, #0x44d0                	// #17616
   3f2b4:	8b080008 	add	x8, x0, x8
   3f2b8:	b9400109 	ldr	w9, [x8]
   3f2bc:	7940090a 	ldrh	w10, [x8, #4]
   3f2c0:	2a0a012b 	orr	w11, w9, w10
   3f2c4:	3500050b 	cbnz	w11, 3f364 <sc2355_find_lut_index+0xc8>
   3f2c8:	b941f028 	ldr	w8, [x1, #496]
   3f2cc:	51000508 	sub	w8, w8, #0x1
   3f2d0:	7100251f 	cmp	w8, #0x9
   3f2d4:	2a1f03e0 	mov	w0, wzr
   3f2d8:	540003c8 	b.hi	3f350 <sc2355_find_lut_index+0xb4>  // b.pmore
   3f2dc:	90000009 	adrp	x9, 0 <__cfi_check>
			3f2dc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1c03c
   3f2e0:	91000129 	add	x9, x9, #0x0
			3f2e0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1c03c
   3f2e4:	1000000a 	adr	x10, 3f2e4 <sc2355_find_lut_index+0x48>
   3f2e8:	b8a8792b 	ldrsw	x11, [x9, x8, lsl #2]
   3f2ec:	8b0b014a 	add	x10, x10, x11
   3f2f0:	d61f0140 	br	x10
   3f2f4:	3947d022 	ldrb	w2, [x1, #500]
   3f2f8:	90000000 	adrp	x0, 0 <__cfi_check>
			3f2f8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10ee3
   3f2fc:	90000001 	adrp	x1, 0 <__cfi_check>
			3f2fc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f300:	91000000 	add	x0, x0, #0x0
			3f300: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10ee3
   3f304:	91000021 	add	x1, x1, #0x0
			3f304: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f308:	94000000 	bl	0 <printk>
			3f308: R_AARCH64_CALL26	printk
   3f30c:	2a1f03e0 	mov	w0, wzr
   3f310:	14000010 	b	3f350 <sc2355_find_lut_index+0xb4>
   3f314:	3947d022 	ldrb	w2, [x1, #500]
   3f318:	90000000 	adrp	x0, 0 <__cfi_check>
			3f318: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12cde
   3f31c:	91000000 	add	x0, x0, #0x0
			3f31c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12cde
   3f320:	90000001 	adrp	x1, 0 <__cfi_check>
			3f320: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f324:	91000021 	add	x1, x1, #0x0
			3f324: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f328:	94000000 	bl	0 <printk>
			3f328: R_AARCH64_CALL26	printk
   3f32c:	52800080 	mov	w0, #0x4                   	// #4
   3f330:	14000008 	b	3f350 <sc2355_find_lut_index+0xb4>
   3f334:	3947d022 	ldrb	w2, [x1, #500]
   3f338:	90000000 	adrp	x0, 0 <__cfi_check>
			3f338: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xd03b
   3f33c:	91000000 	add	x0, x0, #0x0
			3f33c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xd03b
   3f340:	90000001 	adrp	x1, 0 <__cfi_check>
			3f340: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f344:	91000021 	add	x1, x1, #0x0
			3f344: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f348:	94000000 	bl	0 <printk>
			3f348: R_AARCH64_CALL26	printk
   3f34c:	528000a0 	mov	w0, #0x5                   	// #5
   3f350:	a9427bfd 	ldp	x29, x30, [sp, #32]
   3f354:	f9401bf3 	ldr	x19, [sp, #48]
   3f358:	f85f8e5e 	ldr	x30, [x18, #-8]!
   3f35c:	910103ff 	add	sp, sp, #0x40
   3f360:	d65f03c0 	ret
   3f364:	d503201f 	nop
   3f368:	36000409 	tbz	w9, #0, 3f3e8 <sc2355_find_lut_index+0x14c>
   3f36c:	b941f029 	ldr	w9, [x1, #496]
   3f370:	321e012a 	orr	w10, w9, #0x4
   3f374:	7100195f 	cmp	w10, #0x6
   3f378:	54000381 	b.ne	3f3e8 <sc2355_find_lut_index+0x14c>  // b.any
   3f37c:	52861b8a 	mov	w10, #0x30dc                	// #12508
   3f380:	8b0a000a 	add	x10, x0, x10
   3f384:	5280040b 	mov	w11, #0x20                  	// #32
   3f388:	14000004 	b	3f398 <sc2355_find_lut_index+0xfc>
   3f38c:	f100056b 	subs	x11, x11, #0x1
   3f390:	9102614a 	add	x10, x10, #0x98
   3f394:	54000220 	b.eq	3f3d8 <sc2355_find_lut_index+0x13c>  // b.none
   3f398:	385f414c 	ldurb	w12, [x10, #-12]
   3f39c:	3607ff8c 	tbz	w12, #0, 3f38c <sc2355_find_lut_index+0xf0>
   3f3a0:	3940054c 	ldrb	w12, [x10, #1]
   3f3a4:	3947d02d 	ldrb	w13, [x1, #500]
   3f3a8:	6b0d019f 	cmp	w12, w13
   3f3ac:	54ffff01 	b.ne	3f38c <sc2355_find_lut_index+0xf0>  // b.any
   3f3b0:	39400143 	ldrb	w3, [x10]
   3f3b4:	90000000 	adrp	x0, 0 <__cfi_check>
			3f3b4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xf6e8
   3f3b8:	90000001 	adrp	x1, 0 <__cfi_check>
			3f3b8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f3bc:	91000000 	add	x0, x0, #0x0
			3f3bc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xf6e8
   3f3c0:	91000021 	add	x1, x1, #0x0
			3f3c0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f3c4:	528058a2 	mov	w2, #0x2c5                 	// #709
   3f3c8:	aa0a03f3 	mov	x19, x10
   3f3cc:	94000000 	bl	0 <printk>
			3f3cc: R_AARCH64_CALL26	printk
   3f3d0:	39400260 	ldrb	w0, [x19]
   3f3d4:	17ffffdf 	b	3f350 <sc2355_find_lut_index+0xb4>
   3f3d8:	7100193f 	cmp	w9, #0x6
   3f3dc:	540006e0 	b.eq	3f4b8 <sc2355_find_lut_index+0x21c>  // b.none
   3f3e0:	7100093f 	cmp	w9, #0x2
   3f3e4:	54000620 	b.eq	3f4a8 <sc2355_find_lut_index+0x20c>  // b.none
   3f3e8:	52861a09 	mov	w9, #0x30d0                	// #12496
   3f3ec:	8b090009 	add	x9, x0, x9
   3f3f0:	5280040a 	mov	w10, #0x20                  	// #32
   3f3f4:	14000004 	b	3f404 <sc2355_find_lut_index+0x168>
   3f3f8:	f100054a 	subs	x10, x10, #0x1
   3f3fc:	91026129 	add	x9, x9, #0x98
   3f400:	54000240 	b.eq	3f448 <sc2355_find_lut_index+0x1ac>  // b.none
   3f404:	b940012b 	ldr	w11, [x9]
   3f408:	b940010c 	ldr	w12, [x8]
   3f40c:	7940092d 	ldrh	w13, [x9, #4]
   3f410:	7940090e 	ldrh	w14, [x8, #4]
   3f414:	4a0c016b 	eor	w11, w11, w12
   3f418:	4a0e01ac 	eor	w12, w13, w14
   3f41c:	2a0c016b 	orr	w11, w11, w12
   3f420:	35fffecb 	cbnz	w11, 3f3f8 <sc2355_find_lut_index+0x15c>
   3f424:	3940352b 	ldrb	w11, [x9, #13]
   3f428:	3947d02c 	ldrb	w12, [x1, #500]
   3f42c:	6b0c017f 	cmp	w11, w12
   3f430:	54fffe41 	b.ne	3f3f8 <sc2355_find_lut_index+0x15c>  // b.any
   3f434:	f9000fa9 	str	x9, [x29, #24]
   3f438:	d503201f 	nop
   3f43c:	f9400fa8 	ldr	x8, [x29, #24]
   3f440:	39403100 	ldrb	w0, [x8, #12]
   3f444:	17ffffc3 	b	3f350 <sc2355_find_lut_index+0xb4>
   3f448:	b941f028 	ldr	w8, [x1, #496]
   3f44c:	52861b89 	mov	w9, #0x30dc                	// #12508
   3f450:	8b090009 	add	x9, x0, x9
   3f454:	5280040a 	mov	w10, #0x20                  	// #32
   3f458:	5280002b 	mov	w11, #0x1                   	// #1
   3f45c:	5280844c 	mov	w12, #0x422                 	// #1058
   3f460:	14000004 	b	3f470 <sc2355_find_lut_index+0x1d4>
   3f464:	f100054a 	subs	x10, x10, #0x1
   3f468:	91026129 	add	x9, x9, #0x98
   3f46c:	54fff300 	b.eq	3f2cc <sc2355_find_lut_index+0x30>  // b.none
   3f470:	7100291f 	cmp	w8, #0xa
   3f474:	54ffff88 	b.hi	3f464 <sc2355_find_lut_index+0x1c8>  // b.pmore
   3f478:	1ac8216d 	lsl	w13, w11, w8
   3f47c:	6a0c01bf 	tst	w13, w12
   3f480:	54ffff20 	b.eq	3f464 <sc2355_find_lut_index+0x1c8>  // b.none
   3f484:	3940052d 	ldrb	w13, [x9, #1]
   3f488:	3947d02e 	ldrb	w14, [x1, #500]
   3f48c:	6b0e01bf 	cmp	w13, w14
   3f490:	54fffea1 	b.ne	3f464 <sc2355_find_lut_index+0x1c8>  // b.any
   3f494:	f9000fa9 	str	x9, [x29, #24]
   3f498:	d503201f 	nop
   3f49c:	f9400fa8 	ldr	x8, [x29, #24]
   3f4a0:	39400100 	ldrb	w0, [x8]
   3f4a4:	17ffffab 	b	3f350 <sc2355_find_lut_index+0xb4>
   3f4a8:	3947d022 	ldrb	w2, [x1, #500]
   3f4ac:	90000000 	adrp	x0, 0 <__cfi_check>
			3f4ac: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2a4a
   3f4b0:	91000000 	add	x0, x0, #0x0
			3f4b0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2a4a
   3f4b4:	17ffff9b 	b	3f320 <sc2355_find_lut_index+0x84>
   3f4b8:	3947d022 	ldrb	w2, [x1, #500]
   3f4bc:	90000000 	adrp	x0, 0 <__cfi_check>
			3f4bc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x17b27
   3f4c0:	91000000 	add	x0, x0, #0x0
			3f4c0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x17b27
   3f4c4:	17ffff9f 	b	3f340 <sc2355_find_lut_index+0xa4>
   3f4c8:	39400504 	ldrb	w4, [x8, #1]
   3f4cc:	39400905 	ldrb	w5, [x8, #2]
   3f4d0:	39400d06 	ldrb	w6, [x8, #3]
   3f4d4:	3940150b 	ldrb	w11, [x8, #5]
   3f4d8:	12001d23 	and	w3, w9, #0xff
   3f4dc:	f9000fa8 	str	x8, [x29, #24]
   3f4e0:	90000008 	adrp	x8, 0 <__cfi_check>
			3f4e0: R_AARCH64_ADR_PREL_PG_HI21	__verbose+0x10d8
   3f4e4:	90000009 	adrp	x9, 0 <__cfi_check>
			3f4e4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1a709
   3f4e8:	91000108 	add	x8, x8, #0x0
			3f4e8: R_AARCH64_ADD_ABS_LO12_NC	__verbose+0x10d8
   3f4ec:	91000129 	add	x9, x9, #0x0
			3f4ec: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1a709
   3f4f0:	90000002 	adrp	x2, 0 <__cfi_check>
			3f4f0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f4f4:	12001d47 	and	w7, w10, #0xff
   3f4f8:	91000042 	add	x2, x2, #0x0
			3f4f8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f4fc:	f81f83a0 	stur	x0, [x29, #-8]
   3f500:	aa0803e0 	mov	x0, x8
   3f504:	f9000be1 	str	x1, [sp, #16]
   3f508:	aa0903e1 	mov	x1, x9
   3f50c:	b90003eb 	str	w11, [sp]
   3f510:	94000000 	bl	0 <__dynamic_pr_debug>
			3f510: R_AARCH64_CALL26	__dynamic_pr_debug
   3f514:	f9400fa8 	ldr	x8, [x29, #24]
   3f518:	f85f83a0 	ldur	x0, [x29, #-8]
   3f51c:	f9400be1 	ldr	x1, [sp, #16]
   3f520:	39400109 	ldrb	w9, [x8]
   3f524:	3707f249 	tbnz	w9, #0, 3f36c <sc2355_find_lut_index+0xd0>
   3f528:	17ffffb0 	b	3f3e8 <sc2355_find_lut_index+0x14c>
   3f52c:	f9400fa8 	ldr	x8, [x29, #24]
   3f530:	90000000 	adrp	x0, 0 <__cfi_check>
			3f530: R_AARCH64_ADR_PREL_PG_HI21	__verbose+0x1148
   3f534:	90000001 	adrp	x1, 0 <__cfi_check>
			3f534: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1c44
   3f538:	90000002 	adrp	x2, 0 <__cfi_check>
			3f538: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f53c:	39400104 	ldrb	w4, [x8]
   3f540:	91000000 	add	x0, x0, #0x0
			3f540: R_AARCH64_ADD_ABS_LO12_NC	__verbose+0x1148
   3f544:	91000021 	add	x1, x1, #0x0
			3f544: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1c44
   3f548:	91000042 	add	x2, x2, #0x0
			3f548: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f54c:	52805d03 	mov	w3, #0x2e8                 	// #744
   3f550:	94000000 	bl	0 <__dynamic_pr_debug>
			3f550: R_AARCH64_CALL26	__dynamic_pr_debug
   3f554:	17ffffd2 	b	3f49c <sc2355_find_lut_index+0x200>
   3f558:	f9400fa8 	ldr	x8, [x29, #24]
   3f55c:	90000000 	adrp	x0, 0 <__cfi_check>
			3f55c: R_AARCH64_ADR_PREL_PG_HI21	__verbose+0x1110
   3f560:	90000001 	adrp	x1, 0 <__cfi_check>
			3f560: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1c44
   3f564:	90000002 	adrp	x2, 0 <__cfi_check>
			3f564: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15ab9
   3f568:	39403104 	ldrb	w4, [x8, #12]
   3f56c:	91000000 	add	x0, x0, #0x0
			3f56c: R_AARCH64_ADD_ABS_LO12_NC	__verbose+0x1110
   3f570:	91000021 	add	x1, x1, #0x0
			3f570: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1c44
   3f574:	91000042 	add	x2, x2, #0x0
			3f574: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15ab9
   3f578:	52805b83 	mov	w3, #0x2dc                 	// #732
   3f57c:	94000000 	bl	0 <__dynamic_pr_debug>
			3f57c: R_AARCH64_CALL26	__dynamic_pr_debug
   3f580:	17ffffaf 	b	3f43c <sc2355_find_lut_index+0x1a0>

Disassembly of section .init.text:

Disassembly of section .exit.text:
