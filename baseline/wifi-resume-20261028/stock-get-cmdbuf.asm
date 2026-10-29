
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000001c594 <sc2355_get_cmdbuf>:
   1c594:	f800865e 	str	x30, [x18], #8
   1c598:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   1c59c:	a9016ffc 	stp	x28, x27, [sp, #16]
   1c5a0:	a90267fa 	stp	x26, x25, [sp, #32]
   1c5a4:	a9035ff8 	stp	x24, x23, [sp, #48]
   1c5a8:	a90457f6 	stp	x22, x21, [sp, #64]
   1c5ac:	a9054ff4 	stp	x20, x19, [sp, #80]
   1c5b0:	910003fd 	mov	x29, sp
   1c5b4:	b9402c08 	ldr	w8, [x0, #44]
   1c5b8:	2a0303f3 	mov	w19, w3
   1c5bc:	34000e88 	cbz	w8, 1c78c <sc2355_get_cmdbuf+0x1f8>
   1c5c0:	52889c08 	mov	w8, #0x44e0                	// #17632
   1c5c4:	2a0503f6 	mov	w22, w5
   1c5c8:	2a0403f4 	mov	w20, w4
   1c5cc:	2a0203f7 	mov	w23, w2
   1c5d0:	aa0003f5 	mov	x21, x0
   1c5d4:	aa0103f9 	mov	x25, x1
   1c5d8:	8b08001b 	add	x27, x0, x8
   1c5dc:	b4000221 	cbz	x1, 1c620 <sc2355_get_cmdbuf+0x8c>
   1c5e0:	b941f338 	ldr	w24, [x25, #496]
   1c5e4:	12001e68 	and	w8, w19, #0xff
   1c5e8:	7101491f 	cmp	w8, #0x52
   1c5ec:	54000261 	b.ne	1c638 <sc2355_get_cmdbuf+0xa4>  // b.any
   1c5f0:	f940ef28 	ldr	x8, [x25, #472]
   1c5f4:	52890a1a 	mov	w26, #0x4850                	// #18512
   1c5f8:	8b1a0100 	add	x0, x8, x26
   1c5fc:	94000000 	bl	0 <_raw_spin_lock_bh>
			1c5fc: R_AARCH64_CALL26	_raw_spin_lock_bh
   1c600:	b9420b28 	ldr	w8, [x25, #520]
   1c604:	f940ef29 	ldr	x9, [x25, #472]
   1c608:	51000508 	sub	w8, w8, #0x1
   1c60c:	8b1a0120 	add	x0, x9, x26
   1c610:	b9020b28 	str	w8, [x25, #520]
   1c614:	94000000 	bl	0 <_raw_spin_unlock_bh>
			1c614: R_AARCH64_CALL26	_raw_spin_unlock_bh
   1c618:	2a1803fc 	mov	w28, w24
   1c61c:	1400001c 	b	1c68c <sc2355_get_cmdbuf+0xf8>
   1c620:	12001e68 	and	w8, w19, #0xff
   1c624:	2a1f03f8 	mov	w24, wzr
   1c628:	7100091f 	cmp	w8, #0x2
   1c62c:	2a1f03fc 	mov	w28, wzr
   1c630:	540001e8 	b.hi	1c66c <sc2355_get_cmdbuf+0xd8>  // b.pmore
   1c634:	1400002b 	b	1c6e0 <sc2355_get_cmdbuf+0x14c>
   1c638:	3947d33c 	ldrb	w28, [x25, #500]
   1c63c:	7100091f 	cmp	w8, #0x2
   1c640:	54000509 	b.ls	1c6e0 <sc2355_get_cmdbuf+0x14c>  // b.plast
   1c644:	f940ef28 	ldr	x8, [x25, #472]
   1c648:	52890a1a 	mov	w26, #0x4850                	// #18512
   1c64c:	8b1a0100 	add	x0, x8, x26
   1c650:	94000000 	bl	0 <_raw_spin_lock_bh>
			1c650: R_AARCH64_CALL26	_raw_spin_lock_bh
   1c654:	b9420b28 	ldr	w8, [x25, #520]
   1c658:	f940ef29 	ldr	x9, [x25, #472]
   1c65c:	51000508 	sub	w8, w8, #0x1
   1c660:	8b1a0120 	add	x0, x9, x26
   1c664:	b9020b28 	str	w8, [x25, #520]
   1c668:	94000000 	bl	0 <_raw_spin_unlock_bh>
			1c668: R_AARCH64_CALL26	_raw_spin_unlock_bh
   1c66c:	12001e68 	and	w8, w19, #0xff
   1c670:	7100151f 	cmp	w8, #0x5
   1c674:	540000c1 	b.ne	1c68c <sc2355_get_cmdbuf+0xf8>  // b.any
   1c678:	b95d8368 	ldr	w8, [x27, #7552]
   1c67c:	35000088 	cbnz	w8, 1c68c <sc2355_get_cmdbuf+0xf8>
   1c680:	b4000db9 	cbz	x25, 1c834 <sc2355_get_cmdbuf+0x2a0>
   1c684:	39486328 	ldrb	w8, [x25, #536]
   1c688:	36000d68 	tbz	w8, #0, 1c834 <sc2355_get_cmdbuf+0x2a0>
   1c68c:	b9403ea8 	ldr	w8, [x21, #60]
   1c690:	71000d1f 	cmp	w8, #0x3
   1c694:	54000261 	b.ne	1c6e0 <sc2355_get_cmdbuf+0x14c>  // b.any
   1c698:	12001e68 	and	w8, w19, #0xff
   1c69c:	7100151f 	cmp	w8, #0x5
   1c6a0:	54000200 	b.eq	1c6e0 <sc2355_get_cmdbuf+0x14c>  // b.none
   1c6a4:	7101391f 	cmp	w8, #0x4e
   1c6a8:	540001c0 	b.eq	1c6e0 <sc2355_get_cmdbuf+0x14c>  // b.none
   1c6ac:	94000000 	bl	0 <get_wcn_bus_ops>
			1c6ac: R_AARCH64_CALL26	get_wcn_bus_ops
   1c6b0:	b4000ee0 	cbz	x0, 1c88c <sc2355_get_cmdbuf+0x2f8>
   1c6b4:	f9400408 	ldr	x8, [x0, #8]
   1c6b8:	b4000ea8 	cbz	x8, 1c88c <sc2355_get_cmdbuf+0x2f8>
   1c6bc:	f9401419 	ldr	x25, [x0, #40]
   1c6c0:	90000008 	adrp	x8, 0 <__cfi_check>
			1c6c0: R_AARCH64_ADR_PREL_PG_HI21	.text+0x822b0
   1c6c4:	91000108 	add	x8, x8, #0x0
			1c6c4: R_AARCH64_ADD_ABS_LO12_NC	.text+0x822b0
   1c6c8:	cb080328 	sub	x8, x25, x8
   1c6cc:	93c80908 	ror	x8, x8, #2
   1c6d0:	f100311f 	cmp	x8, #0xc
   1c6d4:	54000cc2 	b.cs	1c86c <sc2355_get_cmdbuf+0x2d8>  // b.hs, b.nlast
   1c6d8:	d63f0320 	blr	x25
   1c6dc:	34000d80 	cbz	w0, 1c88c <sc2355_get_cmdbuf+0x2f8>
   1c6e0:	f96426a8 	ldr	x8, [x21, #18504]
   1c6e4:	90000009 	adrp	x9, 0 <__cfi_check>
			1c6e4: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82010
   1c6e8:	91000129 	add	x9, x9, #0x0
			1c6e8: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82010
   1c6ec:	f9400119 	ldr	x25, [x8]
   1c6f0:	52890808 	mov	w8, #0x4840                	// #18496
   1c6f4:	8b0802ba 	add	x26, x21, x8
   1c6f8:	cb090329 	sub	x9, x25, x9
   1c6fc:	93c90929 	ror	x9, x9, #2
   1c700:	f100093f 	cmp	x9, #0x2
   1c704:	54000a62 	b.cs	1c850 <sc2355_get_cmdbuf+0x2bc>  // b.hs, b.nlast
   1c708:	aa1a03e0 	mov	x0, x26
   1c70c:	2a1f03e1 	mov	w1, wzr
   1c710:	2a1803e2 	mov	w2, w24
   1c714:	d63f0320 	blr	x25
   1c718:	aa0003f9 	mov	x25, x0
   1c71c:	b4000480 	cbz	x0, 1c7ac <sc2355_get_cmdbuf+0x218>
   1c720:	b9400368 	ldr	w8, [x27]
   1c724:	110032f7 	add	w23, w23, #0xc
   1c728:	321802c1 	orr	w1, w22, #0x100
   1c72c:	0b372108 	add	w8, w8, w23, uxth
   1c730:	93407d00 	sxtw	x0, w8
   1c734:	94000000 	bl	0 <__kmalloc>
			1c734: R_AARCH64_CALL26	__kmalloc
   1c738:	b40004a0 	cbz	x0, 1c7cc <sc2355_get_cmdbuf+0x238>
   1c73c:	b9800368 	ldrsw	x8, [x27]
   1c740:	531c0289 	ubfiz	w9, w20, #4, #1
   1c744:	331b6b89 	bfi	w9, w28, #5, #27
   1c748:	8b080008 	add	x8, x0, x8
   1c74c:	39000109 	strb	w9, [x8]
   1c750:	79000517 	strh	w23, [x8, #2]
   1c754:	39000513 	strb	w19, [x8, #1]
   1c758:	91003108 	add	x8, x8, #0xc
   1c75c:	79007737 	strh	w23, [x25, #58]
   1c760:	f9000b3f 	str	xzr, [x25, #16]
   1c764:	a9018328 	stp	x8, x0, [x25, #24]
   1c768:	aa1903e0 	mov	x0, x25
   1c76c:	a9454ff4 	ldp	x20, x19, [sp, #80]
   1c770:	a94457f6 	ldp	x22, x21, [sp, #64]
   1c774:	a9435ff8 	ldp	x24, x23, [sp, #48]
   1c778:	a94267fa 	ldp	x26, x25, [sp, #32]
   1c77c:	a9416ffc 	ldp	x28, x27, [sp, #16]
   1c780:	a8c67bfd 	ldp	x29, x30, [sp], #96
   1c784:	f85f8e5e 	ldr	x30, [x18, #-8]!
   1c788:	d65f03c0 	ret
   1c78c:	12001e68 	and	w8, w19, #0xff
   1c790:	7101651f 	cmp	w8, #0x59
   1c794:	540003e8 	b.hi	1c810 <sc2355_get_cmdbuf+0x27c>  // b.pmore
   1c798:	90000009 	adrp	x9, 0 <__cfi_check>
			1c798: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1c79c:	93401e68 	sxtb	x8, w19
   1c7a0:	91000129 	add	x9, x9, #0x0
			1c7a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1c7a4:	f8687922 	ldr	x2, [x9, x8, lsl #3]
   1c7a8:	1400001c 	b	1c818 <sc2355_get_cmdbuf+0x284>
   1c7ac:	90000000 	adrp	x0, 0 <__cfi_check>
			1c7ac: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12f0c
   1c7b0:	90000001 	adrp	x1, 0 <__cfi_check>
			1c7b0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12efa
   1c7b4:	91000000 	add	x0, x0, #0x0
			1c7b4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12f0c
   1c7b8:	91000021 	add	x1, x1, #0x0
			1c7b8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12efa
   1c7bc:	52804e82 	mov	w2, #0x274                 	// #628
   1c7c0:	2a1803e3 	mov	w3, w24
   1c7c4:	94000000 	bl	0 <printk>
			1c7c4: R_AARCH64_CALL26	printk
   1c7c8:	17ffffe8 	b	1c768 <sc2355_get_cmdbuf+0x1d4>
   1c7cc:	90000000 	adrp	x0, 0 <__cfi_check>
			1c7cc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x13e53
   1c7d0:	90000001 	adrp	x1, 0 <__cfi_check>
			1c7d0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12efa
   1c7d4:	91000000 	add	x0, x0, #0x0
			1c7d4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x13e53
   1c7d8:	91000021 	add	x1, x1, #0x0
			1c7d8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12efa
   1c7dc:	94000000 	bl	0 <printk>
			1c7dc: R_AARCH64_CALL26	printk
   1c7e0:	f96426a8 	ldr	x8, [x21, #18504]
   1c7e4:	f9400513 	ldr	x19, [x8, #8]
   1c7e8:	90000008 	adrp	x8, 0 <__cfi_check>
			1c7e8: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82034
   1c7ec:	91000108 	add	x8, x8, #0x0
			1c7ec: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82034
   1c7f0:	cb080268 	sub	x8, x19, x8
   1c7f4:	93c80908 	ror	x8, x8, #2
   1c7f8:	f100111f 	cmp	x8, #0x4
   1c7fc:	54000662 	b.cs	1c8c8 <sc2355_get_cmdbuf+0x334>  // b.hs, b.nlast
   1c800:	aa1a03e0 	mov	x0, x26
   1c804:	aa1903e1 	mov	x1, x25
   1c808:	d63f0260 	blr	x19
   1c80c:	14000008 	b	1c82c <sc2355_get_cmdbuf+0x298>
   1c810:	90000002 	adrp	x2, 0 <__cfi_check>
			1c810: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1c814:	91000042 	add	x2, x2, #0x0
			1c814: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1c818:	90000000 	adrp	x0, 0 <__cfi_check>
			1c818: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xd25b
   1c81c:	91000000 	add	x0, x0, #0x0
			1c81c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xd25b
   1c820:	90000001 	adrp	x1, 0 <__cfi_check>
			1c820: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12efa
   1c824:	91000021 	add	x1, x1, #0x0
			1c824: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12efa
   1c828:	94000000 	bl	0 <printk>
			1c828: R_AARCH64_CALL26	printk
   1c82c:	aa1f03f9 	mov	x25, xzr
   1c830:	17ffffce 	b	1c768 <sc2355_get_cmdbuf+0x1d4>
   1c834:	90000000 	adrp	x0, 0 <__cfi_check>
			1c834: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xb4ac
   1c838:	90000001 	adrp	x1, 0 <__cfi_check>
			1c838: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12efa
   1c83c:	90000002 	adrp	x2, 0 <__cfi_check>
			1c83c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xec11
   1c840:	91000000 	add	x0, x0, #0x0
			1c840: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xb4ac
   1c844:	91000021 	add	x1, x1, #0x0
			1c844: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12efa
   1c848:	91000042 	add	x2, x2, #0x0
			1c848: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xec11
   1c84c:	17fffff7 	b	1c828 <sc2355_get_cmdbuf+0x294>
   1c850:	d299ddc0 	mov	x0, #0xceee                	// #52974
   1c854:	f2af5a20 	movk	x0, #0x7ad1, lsl #16
   1c858:	f2d27d80 	movk	x0, #0x93ec, lsl #32
   1c85c:	f2febd20 	movk	x0, #0xf5e9, lsl #48
   1c860:	aa1903e1 	mov	x1, x25
   1c864:	94000000 	bl	0 <__cfi_slowpath>
			1c864: R_AARCH64_CALL26	__cfi_slowpath
   1c868:	17ffffa8 	b	1c708 <sc2355_get_cmdbuf+0x174>
   1c86c:	d28488a0 	mov	x0, #0x2445                	// #9285
   1c870:	f2a52480 	movk	x0, #0x2924, lsl #16
   1c874:	f2d487c0 	movk	x0, #0xa43e, lsl #32
   1c878:	f2e05660 	movk	x0, #0x2b3, lsl #48
   1c87c:	aa1903e1 	mov	x1, x25
   1c880:	94000000 	bl	0 <__cfi_slowpath>
			1c880: R_AARCH64_CALL26	__cfi_slowpath
   1c884:	d63f0320 	blr	x25
   1c888:	35fff2c0 	cbnz	w0, 1c6e0 <sc2355_get_cmdbuf+0x14c>
   1c88c:	12001e68 	and	w8, w19, #0xff
   1c890:	7101651f 	cmp	w8, #0x59
   1c894:	54000108 	b.hi	1c8b4 <sc2355_get_cmdbuf+0x320>  // b.pmore
   1c898:	90000009 	adrp	x9, 0 <__cfi_check>
			1c898: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1c89c:	93401e68 	sxtb	x8, w19
   1c8a0:	91000129 	add	x9, x9, #0x0
			1c8a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1c8a4:	f8687922 	ldr	x2, [x9, x8, lsl #3]
   1c8a8:	90000000 	adrp	x0, 0 <__cfi_check>
			1c8a8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xb4de
   1c8ac:	91000000 	add	x0, x0, #0x0
			1c8ac: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xb4de
   1c8b0:	17ffffdc 	b	1c820 <sc2355_get_cmdbuf+0x28c>
   1c8b4:	90000002 	adrp	x2, 0 <__cfi_check>
			1c8b4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1c8b8:	90000000 	adrp	x0, 0 <__cfi_check>
			1c8b8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xb4de
   1c8bc:	91000042 	add	x2, x2, #0x0
			1c8bc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1c8c0:	91000000 	add	x0, x0, #0x0
			1c8c0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xb4de
   1c8c4:	17ffffd7 	b	1c820 <sc2355_get_cmdbuf+0x28c>
   1c8c8:	d2923fc0 	mov	x0, #0x91fe                	// #37374
   1c8cc:	f2ac4400 	movk	x0, #0x6220, lsl #16
   1c8d0:	f2c6e440 	movk	x0, #0x3722, lsl #32
   1c8d4:	f2fdc3e0 	movk	x0, #0xee1f, lsl #48
   1c8d8:	aa1303e1 	mov	x1, x19
   1c8dc:	94000000 	bl	0 <__cfi_slowpath>
			1c8dc: R_AARCH64_CALL26	__cfi_slowpath
   1c8e0:	17ffffc8 	b	1c800 <sc2355_get_cmdbuf+0x26c>

Disassembly of section .init.text:

Disassembly of section .exit.text:
