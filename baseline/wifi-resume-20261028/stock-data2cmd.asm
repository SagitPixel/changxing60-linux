
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

0000000000021680 <sprd_xmit_data2cmd_wq>:
   21680:	f800865e 	str	x30, [x18], #8
   21684:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   21688:	f9000bf7 	str	x23, [sp, #16]
   2168c:	a90257f6 	stp	x22, x21, [sp, #32]
   21690:	a9034ff4 	stp	x20, x19, [sp, #48]
   21694:	910003fd 	mov	x29, sp
   21698:	f945ac36 	ldr	x22, [x1, #2904]
   2169c:	aa0003f3 	mov	x19, x0
   216a0:	91260035 	add	x21, x1, #0x980
   216a4:	aa0103f4 	mov	x20, x1
   216a8:	b9403ec8 	ldr	w8, [x22, #60]
   216ac:	aa1503e0 	mov	x0, x21
   216b0:	aa1303e1 	mov	x1, x19
   216b4:	2a1f03e2 	mov	w2, wzr
   216b8:	71000d1f 	cmp	w8, #0x3
   216bc:	2a1f03e3 	mov	w3, wzr
   216c0:	54000081 	b.ne	216d0 <sprd_xmit_data2cmd_wq+0x50>  // b.any
   216c4:	94000000 	bl	7e6ac <sc2355_pcie_hif_fill_msdu_dscr>
			216c4: R_AARCH64_CALL26	sc2355_pcie_hif_fill_msdu_dscr
   216c8:	35000080 	cbnz	w0, 216d8 <sprd_xmit_data2cmd_wq+0x58>
   216cc:	14000007 	b	216e8 <sprd_xmit_data2cmd_wq+0x68>
   216d0:	94000000 	bl	3f584 <sc2355_hif_fill_msdu_dscr>
			216d0: R_AARCH64_CALL26	sc2355_hif_fill_msdu_dscr
   216d4:	340000a0 	cbz	w0, 216e8 <sprd_xmit_data2cmd_wq+0x68>
   216d8:	aa1303e0 	mov	x0, x19
   216dc:	94000000 	bl	0 <consume_skb>
			216dc: R_AARCH64_CALL26	consume_skb
   216e0:	12800000 	mov	w0, #0xffffffff            	// #-1
   216e4:	14000042 	b	217ec <sprd_xmit_data2cmd_wq+0x16c>
   216e8:	b9403ec8 	ldr	w8, [x22, #60]
   216ec:	71000d1f 	cmp	w8, #0x3
   216f0:	54000140 	b.eq	21718 <sprd_xmit_data2cmd_wq+0x98>  // b.none
   216f4:	528000a1 	mov	w1, #0x5                   	// #5
   216f8:	aa1303e0 	mov	x0, x19
   216fc:	94000000 	bl	0 <skb_push>
			216fc: R_AARCH64_CALL26	skb_push
   21700:	f9406e68 	ldr	x8, [x19, #216]
   21704:	52862609 	mov	w9, #0x3130                	// #12592
   21708:	72a66649 	movk	w9, #0x3332, lsl #16
   2170c:	5280068a 	mov	w10, #0x34                  	// #52
   21710:	b9000109 	str	w9, [x8]
   21714:	3900110a 	strb	w10, [x8, #4]
   21718:	b94b7288 	ldr	w8, [x20, #2928]
   2171c:	321e0108 	orr	w8, w8, #0x4
   21720:	7100191f 	cmp	w8, #0x6
   21724:	540000a1 	b.ne	21738 <sprd_xmit_data2cmd_wq+0xb8>  // b.any
   21728:	f9406e68 	ldr	x8, [x19, #216]
   2172c:	39401909 	ldrb	w9, [x8, #6]
   21730:	7100153f 	cmp	w9, #0x5
   21734:	54000749 	b.ls	2181c <sprd_xmit_data2cmd_wq+0x19c>  // b.plast
   21738:	b9407277 	ldr	w23, [x19, #112]
   2173c:	52816401 	mov	w1, #0xb20                 	// #2848
   21740:	1100a2e8 	add	w8, w23, #0x28
   21744:	93407d00 	sxtw	x0, w8
   21748:	94000000 	bl	0 <__kmalloc>
			21748: R_AARCH64_CALL26	__kmalloc
   2174c:	b40005c0 	cbz	x0, 21804 <sprd_xmit_data2cmd_wq+0x184>
   21750:	f9000000 	str	x0, [x0]
   21754:	f9000400 	str	x0, [x0, #8]
   21758:	b9002017 	str	w23, [x0, #32]
   2175c:	f9406e61 	ldr	x1, [x19, #216]
   21760:	b9407262 	ldr	w2, [x19, #112]
   21764:	aa0003f6 	mov	x22, x0
   21768:	91009000 	add	x0, x0, #0x24
   2176c:	94000000 	bl	0 <memcpy>
			2176c: R_AARCH64_CALL26	memcpy
   21770:	aa1303e0 	mov	x0, x19
   21774:	94000000 	bl	0 <consume_skb>
			21774: R_AARCH64_CALL26	consume_skb
   21778:	52800208 	mov	w8, #0x10                  	// #16
   2177c:	f9000ad5 	str	x21, [x22, #16]
   21780:	390072c8 	strb	w8, [x22, #28]
   21784:	f945ae97 	ldr	x23, [x20, #2904]
   21788:	52893808 	mov	w8, #0x49c0                	// #18880
   2178c:	8b0802f3 	add	x19, x23, x8
   21790:	aa1303e0 	mov	x0, x19
   21794:	94000000 	bl	0 <_raw_spin_lock_bh>
			21794: R_AARCH64_CALL26	_raw_spin_lock_bh
   21798:	f96502f4 	ldr	x20, [x23, #18944]
   2179c:	52893f08 	mov	w8, #0x49f8                	// #18936
   217a0:	8b0802f5 	add	x21, x23, x8
   217a4:	aa1603e0 	mov	x0, x22
   217a8:	aa1403e1 	mov	x1, x20
   217ac:	aa1503e2 	mov	x2, x21
   217b0:	94000000 	bl	0 <__list_add_valid>
			217b0: R_AARCH64_CALL26	__list_add_valid
   217b4:	36000080 	tbz	w0, #0, 217c4 <sprd_xmit_data2cmd_wq+0x144>
   217b8:	f92502f6 	str	x22, [x23, #18944]
   217bc:	a90052d5 	stp	x21, x20, [x22]
   217c0:	f9000296 	str	x22, [x20]
   217c4:	aa1303e0 	mov	x0, x19
   217c8:	94000000 	bl	0 <_raw_spin_unlock_bh>
			217c8: R_AARCH64_CALL26	_raw_spin_unlock_bh
   217cc:	f964e6e8 	ldr	x8, [x23, #18888]
   217d0:	370000c8 	tbnz	w8, #0, 217e8 <sprd_xmit_data2cmd_wq+0x168>
   217d4:	f96506e1 	ldr	x1, [x23, #18952]
   217d8:	52893908 	mov	w8, #0x49c8                	// #18888
   217dc:	8b0802e2 	add	x2, x23, x8
   217e0:	52800400 	mov	w0, #0x20                  	// #32
   217e4:	94000000 	bl	0 <queue_work_on>
			217e4: R_AARCH64_CALL26	queue_work_on
   217e8:	2a1f03e0 	mov	w0, wzr
   217ec:	a9434ff4 	ldp	x20, x19, [sp, #48]
   217f0:	a94257f6 	ldp	x22, x21, [sp, #32]
   217f4:	f9400bf7 	ldr	x23, [sp, #16]
   217f8:	a8c47bfd 	ldp	x29, x30, [sp], #64
   217fc:	f85f8e5e 	ldr	x30, [x18, #-8]!
   21800:	d65f03c0 	ret
   21804:	90000000 	adrp	x0, 0 <__cfi_check>
			21804: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x14ac9
   21808:	90000001 	adrp	x1, 0 <__cfi_check>
			21808: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6eac
   2180c:	91000000 	add	x0, x0, #0x0
			2180c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x14ac9
   21810:	91000021 	add	x1, x1, #0x0
			21810: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6eac
   21814:	94000000 	bl	0 <printk>
			21814: R_AARCH64_CALL26	printk
   21818:	17ffffb0 	b	216d8 <sprd_xmit_data2cmd_wq+0x58>
   2181c:	39401509 	ldrb	w9, [x8, #5]
   21820:	90000000 	adrp	x0, 0 <__cfi_check>
			21820: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x11376
   21824:	90000001 	adrp	x1, 0 <__cfi_check>
			21824: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6eac
   21828:	91000000 	add	x0, x0, #0x0
			21828: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x11376
   2182c:	121c0d29 	and	w9, w9, #0xf0
   21830:	32000129 	orr	w9, w9, #0x1
   21834:	91000021 	add	x1, x1, #0x0
			21834: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6eac
   21838:	52814d62 	mov	w2, #0xa6b                 	// #2667
   2183c:	39001509 	strb	w9, [x8, #5]
   21840:	94000000 	bl	0 <printk>
			21840: R_AARCH64_CALL26	printk
   21844:	17ffffbd 	b	21738 <sprd_xmit_data2cmd_wq+0xb8>

Disassembly of section .init.text:

Disassembly of section .exit.text:
