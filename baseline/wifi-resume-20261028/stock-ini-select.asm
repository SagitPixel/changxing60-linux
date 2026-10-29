
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000002535c <sc2355_get_nvm_table>:
   2535c:	f800865e 	str	x30, [x18], #8
   25360:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   25364:	a90157f6 	stp	x22, x21, [sp, #16]
   25368:	a9024ff4 	stp	x20, x19, [sp, #32]
   2536c:	910003fd 	mov	x29, sp
   25370:	aa0103f3 	mov	x19, x1
   25374:	aa0003f4 	mov	x20, x0
   25378:	94000000 	bl	0 <wcn_get_chip_type>
			25378: R_AARCH64_CALL26	wcn_get_chip_type
   2537c:	35000100 	cbnz	w0, 2539c <sc2355_get_nvm_table+0x40>
   25380:	90000000 	adrp	x0, 0 <__cfi_check>
			25380: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x5452
   25384:	90000001 	adrp	x1, 0 <__cfi_check>
			25384: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xecef
   25388:	91000000 	add	x0, x0, #0x0
			25388: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x5452
   2538c:	91000021 	add	x1, x1, #0x0
			2538c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xecef
   25390:	94000000 	bl	0 <printk>
			25390: R_AARCH64_CALL26	printk
   25394:	12800000 	mov	w0, #0xffffffff            	// #-1
   25398:	14000030 	b	25458 <sc2355_get_nvm_table+0xfc>
   2539c:	94000000 	bl	0 <wcn_get_chip_type>
			2539c: R_AARCH64_CALL26	wcn_get_chip_type
   253a0:	7100041f 	cmp	w0, #0x1
   253a4:	540001c1 	b.ne	253dc <sc2355_get_nvm_table+0x80>  // b.any
   253a8:	94000000 	bl	0 <wcn_get_chip_type>
			253a8: R_AARCH64_CALL26	wcn_get_chip_type
   253ac:	90000015 	adrp	x21, 0 <__cfi_check>
			253ac: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x8c21
   253b0:	2a0003e2 	mov	w2, w0
   253b4:	90000000 	adrp	x0, 0 <__cfi_check>
			253b4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x217d
   253b8:	90000001 	adrp	x1, 0 <__cfi_check>
			253b8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xecef
   253bc:	910002b5 	add	x21, x21, #0x0
			253bc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x8c21
   253c0:	91000000 	add	x0, x0, #0x0
			253c0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x217d
   253c4:	91000021 	add	x1, x1, #0x0
			253c4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xecef
   253c8:	aa1503e3 	mov	x3, x21
   253cc:	94000000 	bl	0 <printk>
			253cc: R_AARCH64_CALL26	printk
   253d0:	aa1403e0 	mov	x0, x20
   253d4:	aa1503e1 	mov	x1, x21
   253d8:	1400001e 	b	25450 <sc2355_get_nvm_table+0xf4>
   253dc:	94000000 	bl	0 <marlin_get_wcn_xpe_efuse_data>
			253dc: R_AARCH64_CALL26	marlin_get_wcn_xpe_efuse_data
   253e0:	2a0003f5 	mov	w21, w0
   253e4:	94000000 	bl	0 <wcn_get_chip_type>
			253e4: R_AARCH64_CALL26	wcn_get_chip_type
   253e8:	710006bf 	cmp	w21, #0x1
   253ec:	2a0003f5 	mov	w21, w0
   253f0:	540001a1 	b.ne	25424 <sc2355_get_nvm_table+0xc8>  // b.any
   253f4:	94000000 	bl	0 <marlin_get_wcn_xpe_efuse_data>
			253f4: R_AARCH64_CALL26	marlin_get_wcn_xpe_efuse_data
   253f8:	90000016 	adrp	x22, 0 <__cfi_check>
			253f8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x9886
   253fc:	2a0003e3 	mov	w3, w0
   25400:	90000000 	adrp	x0, 0 <__cfi_check>
			25400: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x9845
   25404:	90000001 	adrp	x1, 0 <__cfi_check>
			25404: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xecef
   25408:	910002d6 	add	x22, x22, #0x0
			25408: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x9886
   2540c:	91000000 	add	x0, x0, #0x0
			2540c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x9845
   25410:	91000021 	add	x1, x1, #0x0
			25410: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xecef
   25414:	2a1503e2 	mov	w2, w21
   25418:	aa1603e4 	mov	x4, x22
   2541c:	94000000 	bl	0 <printk>
			2541c: R_AARCH64_CALL26	printk
   25420:	1400000a 	b	25448 <sc2355_get_nvm_table+0xec>
   25424:	90000016 	adrp	x22, 0 <__cfi_check>
			25424: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x153ca
   25428:	90000000 	adrp	x0, 0 <__cfi_check>
			25428: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x217d
   2542c:	90000001 	adrp	x1, 0 <__cfi_check>
			2542c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xecef
   25430:	910002d6 	add	x22, x22, #0x0
			25430: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x153ca
   25434:	91000000 	add	x0, x0, #0x0
			25434: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x217d
   25438:	91000021 	add	x1, x1, #0x0
			25438: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xecef
   2543c:	2a1503e2 	mov	w2, w21
   25440:	aa1603e3 	mov	x3, x22
   25444:	94000000 	bl	0 <printk>
			25444: R_AARCH64_CALL26	printk
   25448:	aa1403e0 	mov	x0, x20
   2544c:	aa1603e1 	mov	x1, x22
   25450:	aa1303e2 	mov	x2, x19
   25454:	94000000 	bl	0 <__cfi_check>
			25454: R_AARCH64_CALL26	.text+0x2546c
   25458:	a9424ff4 	ldp	x20, x19, [sp, #32]
   2545c:	a94157f6 	ldp	x22, x21, [sp, #16]
   25460:	a8c37bfd 	ldp	x29, x30, [sp], #48
   25464:	f85f8e5e 	ldr	x30, [x18, #-8]!
   25468:	d65f03c0 	ret

Disassembly of section .init.text:

Disassembly of section .exit.text:
