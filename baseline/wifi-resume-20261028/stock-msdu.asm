
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000003f584 <sc2355_hif_fill_msdu_dscr>:
   3f584:	d10183ff 	sub	sp, sp, #0x60
   3f588:	f800865e 	str	x30, [x18], #8
   3f58c:	a9017bfd 	stp	x29, x30, [sp, #16]
   3f590:	f90013f9 	str	x25, [sp, #32]
   3f594:	a9035ff8 	stp	x24, x23, [sp, #48]
   3f598:	a90457f6 	stp	x22, x21, [sp, #64]
   3f59c:	a9054ff4 	stp	x20, x19, [sp, #80]
   3f5a0:	910043fd 	add	x29, sp, #0x10
   3f5a4:	90000008 	adrp	x8, 0 <__stack_chk_guard>
			3f5a4: R_AARCH64_ADR_PREL_PG_HI21	__stack_chk_guard
   3f5a8:	f9400108 	ldr	x8, [x8]
			3f5a8: R_AARCH64_LDST64_ABS_LO12_NC	__stack_chk_guard
   3f5ac:	2a0303f6 	mov	w22, w3
   3f5b0:	2a0203f5 	mov	w21, w2
   3f5b4:	aa0103f3 	mov	x19, x1
   3f5b8:	f90007e8 	str	x8, [sp, #8]
   3f5bc:	f9406c38 	ldr	x24, [x1, #216]
   3f5c0:	390013ff 	strb	wzr, [sp, #4]
   3f5c4:	aa0003f4 	mov	x20, x0
   3f5c8:	79401b09 	ldrh	w9, [x24, #12]
   3f5cc:	aa1803e8 	mov	x8, x24
   3f5d0:	7118213f 	cmp	w9, #0x608
   3f5d4:	540001a0 	b.eq	3f608 <sc2355_hif_fill_msdu_dscr+0x84>  // b.none
   3f5d8:	7136253f 	cmp	w9, #0xd89
   3f5dc:	54000160 	b.eq	3f608 <sc2355_hif_fill_msdu_dscr+0x84>  // b.none
   3f5e0:	5298f10a 	mov	w10, #0xc788                	// #51080
   3f5e4:	6b0a013f 	cmp	w9, w10
   3f5e8:	54000100 	b.eq	3f608 <sc2355_hif_fill_msdu_dscr+0x84>  // b.none
   3f5ec:	72001ebf 	tst	w21, #0xff
   3f5f0:	aa1803e8 	mov	x8, x24
   3f5f4:	540000a1 	b.ne	3f608 <sc2355_hif_fill_msdu_dscr+0x84>  // b.any
   3f5f8:	910013e1 	add	x1, sp, #0x4
   3f5fc:	aa1303e0 	mov	x0, x19
   3f600:	94000000 	bl	33f40 <sc2355_is_vowifi_pkt>
			3f600: R_AARCH64_CALL26	sc2355_is_vowifi_pkt
   3f604:	f9406e68 	ldr	x8, [x19, #216]
   3f608:	f940ee99 	ldr	x25, [x20, #472]
   3f60c:	52889c0a 	mov	w10, #0x44e0                	// #17632
   3f610:	b940d269 	ldr	w9, [x19, #208]
   3f614:	b8aa6b2a 	ldrsw	x10, [x25, x10]
   3f618:	4b090109 	sub	w9, w8, w9
   3f61c:	91004d41 	add	x1, x10, #0x13
   3f620:	eb09003f 	cmp	x1, x9
   3f624:	54000129 	b.ls	3f648 <sc2355_hif_fill_msdu_dscr+0xc4>  // b.plast
   3f628:	aa1303e0 	mov	x0, x19
   3f62c:	94000000 	bl	0 <skb_realloc_headroom>
			3f62c: R_AARCH64_CALL26	skb_realloc_headroom
   3f630:	aa0003f7 	mov	x23, x0
   3f634:	aa1303e0 	mov	x0, x19
   3f638:	94000000 	bl	0 <kfree_skb>
			3f638: R_AARCH64_CALL26	kfree_skb
   3f63c:	b4000a37 	cbz	x23, 3f780 <sc2355_hif_fill_msdu_dscr+0x1fc>
   3f640:	f9406ee8 	ldr	x8, [x23, #216]
   3f644:	aa1703f3 	mov	x19, x23
   3f648:	91002320 	add	x0, x25, #0x8
   3f64c:	b40000e8 	cbz	x8, 3f668 <sc2355_hif_fill_msdu_dscr+0xe4>
   3f650:	79400909 	ldrh	w9, [x8, #4]
   3f654:	b9400108 	ldr	w8, [x8]
   3f658:	52889b0a 	mov	w10, #0x44d8                	// #17624
   3f65c:	8b0a032a 	add	x10, x25, x10
   3f660:	79000949 	strh	w9, [x10, #4]
   3f664:	b9000148 	str	w8, [x10]
   3f668:	aa1403e1 	mov	x1, x20
   3f66c:	94000000 	bl	3f29c <sc2355_find_lut_index>
			3f66c: R_AARCH64_CALL26	sc2355_find_lut_index
   3f670:	12001c08 	and	w8, w0, #0xff
   3f674:	2a0003f7 	mov	w23, w0
   3f678:	7100151f 	cmp	w8, #0x5
   3f67c:	540000a8 	b.hi	3f690 <sc2355_hif_fill_msdu_dscr+0x10c>  // b.pmore
   3f680:	52889b08 	mov	w8, #0x44d8                	// #17624
   3f684:	8b080328 	add	x8, x25, x8
   3f688:	39400108 	ldrb	w8, [x8]
   3f68c:	36000868 	tbz	w8, #0, 3f798 <sc2355_hif_fill_msdu_dscr+0x214>
   3f690:	12001ec8 	and	w8, w22, #0xff
   3f694:	11002d01 	add	w1, w8, #0xb
   3f698:	aa1303e0 	mov	x0, x19
   3f69c:	94000000 	bl	0 <skb_push>
			3f69c: R_AARCH64_CALL26	skb_push
   3f6a0:	f9406e68 	ldr	x8, [x19, #216]
   3f6a4:	72001ebf 	tst	w21, #0xff
   3f6a8:	1a9f07e9 	cset	w9, ne	// ne = any
   3f6ac:	531f7929 	lsl	w9, w9, #1
   3f6b0:	f800111f 	stur	xzr, [x8, #1]
   3f6b4:	7800911f 	sturh	wzr, [x8, #9]
   3f6b8:	39000109 	strb	w9, [x8]
   3f6bc:	3947d28a 	ldrb	w10, [x20, #500]
   3f6c0:	2a1f03e0 	mov	w0, wzr
   3f6c4:	331b6949 	bfi	w9, w10, #5, #27
   3f6c8:	39000109 	strb	w9, [x8]
   3f6cc:	7940e269 	ldrh	w9, [x19, #112]
   3f6d0:	5280016a 	mov	w10, #0xb                   	// #11
   3f6d4:	3900050a 	strb	w10, [x8, #1]
   3f6d8:	39001917 	strb	w23, [x8, #6]
   3f6dc:	51002d29 	sub	w9, w9, #0xb
   3f6e0:	78003109 	sturh	w9, [x8, #3]
   3f6e4:	79410269 	ldrh	w9, [x19, #128]
   3f6e8:	2a2903e9 	mvn	w9, w9
   3f6ec:	721b053f 	tst	w9, #0x60
   3f6f0:	540002e1 	b.ne	3f74c <sc2355_hif_fill_msdu_dscr+0x1c8>  // b.any
   3f6f4:	52800029 	mov	w9, #0x1                   	// #1
   3f6f8:	39000909 	strb	w9, [x8, #2]
   3f6fc:	79401b09 	ldrh	w9, [x24, #12]
   3f700:	f9406a6a 	ldr	x10, [x19, #208]
   3f704:	79416a6b 	ldrh	w11, [x19, #180]
   3f708:	529bb0cc 	mov	w12, #0xdd86                	// #56710
   3f70c:	6b0c013f 	cmp	w9, w12
   3f710:	52800129 	mov	w9, #0x9                   	// #9
   3f714:	8b0b014a 	add	x10, x10, x11
   3f718:	528000cb 	mov	w11, #0x6                   	// #6
   3f71c:	9a890169 	csel	x9, x11, x9, eq	// eq = none
   3f720:	38696944 	ldrb	w4, [x10, x9]
   3f724:	52800069 	mov	w9, #0x3                   	// #3
   3f728:	7100189f 	cmp	w4, #0x6
   3f72c:	1a9f0529 	csinc	w9, w9, wzr, eq	// eq = none
   3f730:	39000909 	strb	w9, [x8, #2]
   3f734:	79416669 	ldrh	w9, [x19, #178]
   3f738:	79416e6a 	ldrh	w10, [x19, #182]
   3f73c:	4b0a0129 	sub	w9, w9, w10
   3f740:	78009109 	sturh	w9, [x8, #9]
   3f744:	d503201f 	nop
   3f748:	2a1f03e0 	mov	w0, wzr
   3f74c:	90000009 	adrp	x9, 0 <__stack_chk_guard>
			3f74c: R_AARCH64_ADR_PREL_PG_HI21	__stack_chk_guard
   3f750:	f94007e8 	ldr	x8, [sp, #8]
   3f754:	f9400129 	ldr	x9, [x9]
			3f754: R_AARCH64_LDST64_ABS_LO12_NC	__stack_chk_guard
   3f758:	eb08013f 	cmp	x9, x8
   3f75c:	540002e1 	b.ne	3f7b8 <sc2355_hif_fill_msdu_dscr+0x234>  // b.any
   3f760:	a9417bfd 	ldp	x29, x30, [sp, #16]
   3f764:	a9454ff4 	ldp	x20, x19, [sp, #80]
   3f768:	a94457f6 	ldp	x22, x21, [sp, #64]
   3f76c:	a9435ff8 	ldp	x24, x23, [sp, #48]
   3f770:	f94013f9 	ldr	x25, [sp, #32]
   3f774:	f85f8e5e 	ldr	x30, [x18, #-8]!
   3f778:	910183ff 	add	sp, sp, #0x60
   3f77c:	d65f03c0 	ret
   3f780:	90000000 	adrp	x0, 0 <__cfi_check>
			3f780: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x9628
   3f784:	90000001 	adrp	x1, 0 <__cfi_check>
			3f784: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x65e5
   3f788:	91000000 	add	x0, x0, #0x0
			3f788: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x9628
   3f78c:	91000021 	add	x1, x1, #0x0
			3f78c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x65e5
   3f790:	52806482 	mov	w2, #0x324                 	// #804
   3f794:	14000006 	b	3f7ac <sc2355_hif_fill_msdu_dscr+0x228>
   3f798:	90000000 	adrp	x0, 0 <__cfi_check>
			3f798: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x13b13
   3f79c:	90000001 	adrp	x1, 0 <__cfi_check>
			3f79c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x65e5
   3f7a0:	91000000 	add	x0, x0, #0x0
			3f7a0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x13b13
   3f7a4:	91000021 	add	x1, x1, #0x0
			3f7a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x65e5
   3f7a8:	52806642 	mov	w2, #0x332                 	// #818
   3f7ac:	94000000 	bl	0 <printk>
			3f7ac: R_AARCH64_CALL26	printk
   3f7b0:	12800000 	mov	w0, #0xffffffff            	// #-1
   3f7b4:	17ffffe6 	b	3f74c <sc2355_hif_fill_msdu_dscr+0x1c8>
   3f7b8:	94000000 	bl	0 <__stack_chk_fail>
			3f7b8: R_AARCH64_CALL26	__stack_chk_fail
   3f7bc:	90000000 	adrp	x0, 0 <__cfi_check>
			3f7bc: R_AARCH64_ADR_PREL_PG_HI21	__verbose+0x1180
   3f7c0:	90000001 	adrp	x1, 0 <__cfi_check>
			3f7c0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x885f
   3f7c4:	90000002 	adrp	x2, 0 <__cfi_check>
			3f7c4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x65e5
   3f7c8:	12003d23 	and	w3, w9, #0xffff
   3f7cc:	91000000 	add	x0, x0, #0x0
			3f7cc: R_AARCH64_ADD_ABS_LO12_NC	__verbose+0x1180
   3f7d0:	91000021 	add	x1, x1, #0x0
			3f7d0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x885f
   3f7d4:	91000042 	add	x2, x2, #0x0
			3f7d4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x65e5
   3f7d8:	94000000 	bl	0 <__dynamic_pr_debug>
			3f7d8: R_AARCH64_CALL26	__dynamic_pr_debug
   3f7dc:	17ffffdb 	b	3f748 <sc2355_hif_fill_msdu_dscr+0x1c4>

Disassembly of section .init.text:

Disassembly of section .exit.text:
