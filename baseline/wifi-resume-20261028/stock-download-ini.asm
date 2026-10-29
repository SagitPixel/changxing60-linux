
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000001e5f0 <sc2355_download_hw_param>:
   1e5f0:	f800865e 	str	x30, [x18], #8
   1e5f4:	a9bd7bfd 	stp	x29, x30, [sp, #-48]!
   1e5f8:	f9000bf5 	str	x21, [sp, #16]
   1e5fc:	a9024ff4 	stp	x20, x19, [sp, #32]
   1e600:	910003fd 	mov	x29, sp
   1e604:	b9403c08 	ldr	w8, [x0, #60]
   1e608:	aa0003f3 	mov	x19, x0
   1e60c:	71000d1f 	cmp	w8, #0x3
   1e610:	54000100 	b.eq	1e630 <sc2355_download_hw_param+0x40>  // b.none
   1e614:	52800040 	mov	w0, #0x2                   	// #2
   1e618:	94000000 	bl	0 <cali_ini_need_download>
			1e618: R_AARCH64_CALL26	cali_ini_need_download
   1e61c:	350000a0 	cbnz	w0, 1e630 <sc2355_download_hw_param+0x40>
   1e620:	90000000 	adrp	x0, 0 <__cfi_check>
			1e620: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x14a9c
   1e624:	91000000 	add	x0, x0, #0x0
			1e624: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x14a9c
   1e628:	94000000 	bl	0 <printk>
			1e628: R_AARCH64_CALL26	printk
   1e62c:	1400005a 	b	1e794 <sc2355_download_hw_param+0x1a4>
   1e630:	90000008 	adrp	x8, 0 <kmalloc_caches>
			1e630: R_AARCH64_ADR_PREL_PG_HI21	kmalloc_caches+0x60
   1e634:	f9400100 	ldr	x0, [x8]
			1e634: R_AARCH64_LDST64_ABS_LO12_NC	kmalloc_caches+0x60
   1e638:	5281b801 	mov	w1, #0xdc0                 	// #3520
   1e63c:	52819c82 	mov	w2, #0xce4                 	// #3300
   1e640:	94000000 	bl	0 <kmem_cache_alloc_trace>
			1e640: R_AARCH64_CALL26	kmem_cache_alloc_trace
   1e644:	aa0003f4 	mov	x20, x0
   1e648:	aa1303e0 	mov	x0, x19
   1e64c:	aa1403e1 	mov	x1, x20
   1e650:	94000000 	bl	2535c <sc2355_get_nvm_table>
			1e650: R_AARCH64_CALL26	sc2355_get_nvm_table
   1e654:	35000780 	cbnz	w0, 1e744 <sc2355_download_hw_param+0x154>
   1e658:	90000000 	adrp	x0, 0 <__cfi_check>
			1e658: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x17e8e
   1e65c:	91000000 	add	x0, x0, #0x0
			1e65c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x17e8e
   1e660:	52800101 	mov	w1, #0x8                   	// #8
   1e664:	52802902 	mov	w2, #0x148                 	// #328
   1e668:	5280b703 	mov	w3, #0x5b8                 	// #1464
   1e66c:	94000000 	bl	0 <printk>
			1e66c: R_AARCH64_CALL26	printk
   1e670:	90000000 	adrp	x0, 0 <__cfi_check>
			1e670: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1a9b0
   1e674:	91000000 	add	x0, x0, #0x0
			1e674: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1a9b0
   1e678:	94000000 	bl	0 <printk>
			1e678: R_AARCH64_CALL26	printk
   1e67c:	52802902 	mov	w2, #0x148                 	// #328
   1e680:	52800023 	mov	w3, #0x1                   	// #1
   1e684:	aa1303e0 	mov	x0, x19
   1e688:	aa1403e1 	mov	x1, x20
   1e68c:	94000000 	bl	0 <__cfi_check>
			1e68c: R_AARCH64_CALL26	.text+0x1e7c0
   1e690:	350006a0 	cbnz	w0, 1e764 <sc2355_download_hw_param+0x174>
   1e694:	90000000 	adrp	x0, 0 <__cfi_check>
			1e694: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10537
   1e698:	91000000 	add	x0, x0, #0x0
			1e698: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10537
   1e69c:	91052295 	add	x21, x20, #0x148
   1e6a0:	94000000 	bl	0 <printk>
			1e6a0: R_AARCH64_CALL26	printk
   1e6a4:	5280b702 	mov	w2, #0x5b8                 	// #1464
   1e6a8:	52800043 	mov	w3, #0x2                   	// #2
   1e6ac:	aa1303e0 	mov	x0, x19
   1e6b0:	aa1503e1 	mov	x1, x21
   1e6b4:	94000000 	bl	0 <__cfi_check>
			1e6b4: R_AARCH64_CALL26	.text+0x1e7c0
   1e6b8:	350005c0 	cbnz	w0, 1e770 <sc2355_download_hw_param+0x180>
   1e6bc:	b9470288 	ldr	w8, [x20, #1792]
   1e6c0:	340001c8 	cbz	w8, 1e6f8 <sc2355_download_hw_param+0x108>
   1e6c4:	90000000 	adrp	x0, 0 <__cfi_check>
			1e6c4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6e61
   1e6c8:	91000000 	add	x0, x0, #0x0
			1e6c8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6e61
   1e6cc:	94000000 	bl	0 <printk>
			1e6cc: R_AARCH64_CALL26	printk
   1e6d0:	b9470281 	ldr	w1, [x20, #1792]
   1e6d4:	90000000 	adrp	x0, 0 <__cfi_check>
			1e6d4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x13ec2
   1e6d8:	91000000 	add	x0, x0, #0x0
			1e6d8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x13ec2
   1e6dc:	94000000 	bl	0 <printk>
			1e6dc: R_AARCH64_CALL26	printk
   1e6e0:	b9470282 	ldr	w2, [x20, #1792]
   1e6e4:	911c1281 	add	x1, x20, #0x704
   1e6e8:	52800063 	mov	w3, #0x3                   	// #3
   1e6ec:	aa1303e0 	mov	x0, x19
   1e6f0:	94000000 	bl	0 <__cfi_check>
			1e6f0: R_AARCH64_CALL26	.text+0x1e7c0
   1e6f4:	350005a0 	cbnz	w0, 1e7a8 <sc2355_download_hw_param+0x1b8>
   1e6f8:	90000000 	adrp	x0, 0 <__cfi_check>
			1e6f8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x52f7
   1e6fc:	91000000 	add	x0, x0, #0x0
			1e6fc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x52f7
   1e700:	91338295 	add	x21, x20, #0xce0
   1e704:	94000000 	bl	0 <printk>
			1e704: R_AARCH64_CALL26	printk
   1e708:	39738281 	ldrb	w1, [x20, #3296]
   1e70c:	39738682 	ldrb	w2, [x20, #3297]
   1e710:	39738a83 	ldrb	w3, [x20, #3298]
   1e714:	90000000 	adrp	x0, 0 <__cfi_check>
			1e714: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12feb
   1e718:	91000000 	add	x0, x0, #0x0
			1e718: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12feb
   1e71c:	94000000 	bl	0 <printk>
			1e71c: R_AARCH64_CALL26	printk
   1e720:	52800062 	mov	w2, #0x3                   	// #3
   1e724:	52800083 	mov	w3, #0x4                   	// #4
   1e728:	aa1303e0 	mov	x0, x19
   1e72c:	aa1503e1 	mov	x1, x21
   1e730:	94000000 	bl	0 <__cfi_check>
			1e730: R_AARCH64_CALL26	.text+0x1e7c0
   1e734:	35000400 	cbnz	w0, 1e7b4 <sc2355_download_hw_param+0x1c4>
   1e738:	aa1403e0 	mov	x0, x20
   1e73c:	94000000 	bl	0 <kfree>
			1e73c: R_AARCH64_CALL26	kfree
   1e740:	14000015 	b	1e794 <sc2355_download_hw_param+0x1a4>
   1e744:	90000000 	adrp	x0, 0 <__cfi_check>
			1e744: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x13e97
   1e748:	91000000 	add	x0, x0, #0x0
			1e748: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x13e97
   1e74c:	94000000 	bl	0 <printk>
			1e74c: R_AARCH64_CALL26	printk
   1e750:	aa1403e0 	mov	x0, x20
   1e754:	94000000 	bl	0 <kfree>
			1e754: R_AARCH64_CALL26	kfree
   1e758:	52800982 	mov	w2, #0x4c                  	// #76
   1e75c:	52800083 	mov	w3, #0x4                   	// #4
   1e760:	1400000b 	b	1e78c <sc2355_download_hw_param+0x19c>
   1e764:	90000000 	adrp	x0, 0 <__cfi_check>
			1e764: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x3b63
   1e768:	91000000 	add	x0, x0, #0x0
			1e768: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x3b63
   1e76c:	14000003 	b	1e778 <sc2355_download_hw_param+0x188>
   1e770:	90000000 	adrp	x0, 0 <__cfi_check>
			1e770: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x19a81
   1e774:	91000000 	add	x0, x0, #0x0
			1e774: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x19a81
   1e778:	94000000 	bl	0 <printk>
			1e778: R_AARCH64_CALL26	printk
   1e77c:	aa1403e0 	mov	x0, x20
   1e780:	94000000 	bl	0 <kfree>
			1e780: R_AARCH64_CALL26	kfree
   1e784:	52800982 	mov	w2, #0x4c                  	// #76
   1e788:	528000a3 	mov	w3, #0x5                   	// #5
   1e78c:	aa1303e0 	mov	x0, x19
   1e790:	94000000 	bl	1c3b4 <sc2355_assert_cmd>
			1e790: R_AARCH64_CALL26	sc2355_assert_cmd
   1e794:	a9424ff4 	ldp	x20, x19, [sp, #32]
   1e798:	f9400bf5 	ldr	x21, [sp, #16]
   1e79c:	a8c37bfd 	ldp	x29, x30, [sp], #48
   1e7a0:	f85f8e5e 	ldr	x30, [x18, #-8]!
   1e7a4:	d65f03c0 	ret
   1e7a8:	90000000 	adrp	x0, 0 <__cfi_check>
			1e7a8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12faf
   1e7ac:	91000000 	add	x0, x0, #0x0
			1e7ac: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12faf
   1e7b0:	17fffff2 	b	1e778 <sc2355_download_hw_param+0x188>
   1e7b4:	90000000 	adrp	x0, 0 <__cfi_check>
			1e7b4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x97bd
   1e7b8:	91000000 	add	x0, x0, #0x0
			1e7b8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x97bd
   1e7bc:	17ffffef 	b	1e778 <sc2355_download_hw_param+0x188>

Disassembly of section .init.text:

Disassembly of section .exit.text:
