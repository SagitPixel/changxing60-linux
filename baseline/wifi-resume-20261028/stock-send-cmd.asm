
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000001c8e4 <sc2355_send_cmd_recv_rsp>:
   1c8e4:	f800865e 	str	x30, [x18], #8
   1c8e8:	a9ba7bfd 	stp	x29, x30, [sp, #-96]!
   1c8ec:	a9016ffc 	stp	x28, x27, [sp, #16]
   1c8f0:	a90267fa 	stp	x26, x25, [sp, #32]
   1c8f4:	a9035ff8 	stp	x24, x23, [sp, #48]
   1c8f8:	a90457f6 	stp	x22, x21, [sp, #64]
   1c8fc:	a9054ff4 	stp	x20, x19, [sp, #80]
   1c900:	910003fd 	mov	x29, sp
   1c904:	3940e008 	ldrb	w8, [x0, #56]
   1c908:	aa0003f3 	mov	x19, x0
   1c90c:	aa0103f5 	mov	x21, x1
   1c910:	7100051f 	cmp	w8, #0x1
   1c914:	54001280 	b.eq	1cb64 <sc2355_send_cmd_recv_rsp+0x280>  // b.none
   1c918:	52889c08 	mov	w8, #0x44e0                	// #17632
   1c91c:	8b08027c 	add	x28, x19, x8
   1c920:	f94012a8 	ldr	x8, [x21, #32]
   1c924:	b9800389 	ldrsw	x9, [x28]
   1c928:	2a0403f9 	mov	w25, w4
   1c92c:	aa0303f6 	mov	x22, x3
   1c930:	aa0203f7 	mov	x23, x2
   1c934:	8b090108 	add	x8, x8, x9
   1c938:	39400501 	ldrb	w1, [x8, #1]
   1c93c:	52891608 	mov	w8, #0x48b0                	// #18608
   1c940:	8b08027a 	add	x26, x19, x8
   1c944:	321f0029 	orr	w9, w1, #0x2
   1c948:	71002d3f 	cmp	w9, #0xb
   1c94c:	54000220 	b.eq	1c990 <sc2355_send_cmd_recv_rsp+0xac>  // b.none
   1c950:	2a0103e8 	mov	w8, w1
   1c954:	90000009 	adrp	x9, 15d0 <__cfi_check+0x15d0>
			1c954: R_AARCH64_ADR_PREL_PG_HI21	api_array
   1c958:	91000129 	add	x9, x9, #0x0
			1c958: R_AARCH64_ADD_ABS_LO12_NC	api_array
   1c95c:	8b214508 	add	x8, x8, w1, uxtw #1
   1c960:	8b080128 	add	x8, x9, x8
   1c964:	39400502 	ldrb	w2, [x8, #1]
   1c968:	39400903 	ldrb	w3, [x8, #2]
   1c96c:	6b03005f 	cmp	w2, w3
   1c970:	1a833048 	csel	w8, w2, w3, cc	// cc = lo, ul, last
   1c974:	34001488 	cbz	w8, 1cc04 <sc2355_send_cmd_recv_rsp+0x320>
   1c978:	54000089 	b.ls	1c988 <sc2355_send_cmd_recv_rsp+0xa4>  // b.plast
   1c97c:	b9443b44 	ldr	w4, [x26, #1080]
   1c980:	6b04011f 	cmp	w8, w4
   1c984:	54002121 	b.ne	1cda8 <sc2355_send_cmd_recv_rsp+0x4c4>  // b.any
   1c988:	52801fe8 	mov	w8, #0xff                  	// #255
   1c98c:	b9043b48 	str	w8, [x26, #1080]
   1c990:	52890d08 	mov	w8, #0x4868                	// #18536
   1c994:	8b080260 	add	x0, x19, x8
   1c998:	91002261 	add	x1, x19, #0x8
   1c99c:	94000000 	bl	0 <__cfi_check>
			1c99c: R_AARCH64_CALL26	.text+0x1d194
   1c9a0:	340002c0 	cbz	w0, 1c9f8 <sc2355_send_cmd_recv_rsp+0x114>
   1c9a4:	52800037 	mov	w23, #0x1                   	// #1
   1c9a8:	f9642668 	ldr	x8, [x19, #18504]
   1c9ac:	90000009 	adrp	x9, 0 <__cfi_check>
			1c9ac: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82034
   1c9b0:	91000129 	add	x9, x9, #0x0
			1c9b0: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82034
   1c9b4:	f9400514 	ldr	x20, [x8, #8]
   1c9b8:	52890808 	mov	w8, #0x4840                	// #18496
   1c9bc:	8b080273 	add	x19, x19, x8
   1c9c0:	cb090289 	sub	x9, x20, x9
   1c9c4:	93c90929 	ror	x9, x9, #2
   1c9c8:	f100113f 	cmp	x9, #0x4
   1c9cc:	54003502 	b.cs	1d06c <sc2355_send_cmd_recv_rsp+0x788>  // b.hs, b.nlast
   1c9d0:	aa1303e0 	mov	x0, x19
   1c9d4:	aa1503e1 	mov	x1, x21
   1c9d8:	d63f0280 	blr	x20
   1c9dc:	f94012a0 	ldr	x0, [x21, #32]
   1c9e0:	94000000 	bl	0 <kfree>
			1c9e0: R_AARCH64_CALL26	kfree
   1c9e4:	b4000056 	cbz	x22, 1c9ec <sc2355_send_cmd_recv_rsp+0x108>
   1c9e8:	790002df 	strh	wzr, [x22]
   1c9ec:	36000e97 	tbz	w23, #0, 1cbbc <sc2355_send_cmd_recv_rsp+0x2d8>
   1c9f0:	2a1f03f5 	mov	w21, wzr
   1c9f4:	14000171 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1c9f8:	f94012a8 	ldr	x8, [x21, #32]
   1c9fc:	b9800389 	ldrsw	x9, [x28]
   1ca00:	8b090108 	add	x8, x8, x9
   1ca04:	39400518 	ldrb	w24, [x8, #1]
   1ca08:	3940011b 	ldrb	w27, [x8]
   1ca0c:	b9435788 	ldr	w8, [x28, #852]
   1ca10:	7100131f 	cmp	w24, #0x4
   1ca14:	93401f14 	sxtb	x20, w24
   1ca18:	54000060 	b.eq	1ca24 <sc2355_send_cmd_recv_rsp+0x140>  // b.none
   1ca1c:	7100051f 	cmp	w8, #0x1
   1ca20:	54000d80 	b.eq	1cbd0 <sc2355_send_cmd_recv_rsp+0x2ec>  // b.none
   1ca24:	b9435b88 	ldr	w8, [x28, #856]
   1ca28:	51000e89 	sub	w9, w20, #0x3
   1ca2c:	12001d29 	and	w9, w9, #0xff
   1ca30:	7100093f 	cmp	w9, #0x2
   1ca34:	54000063 	b.cc	1ca40 <sc2355_send_cmd_recv_rsp+0x15c>  // b.lo, b.ul, b.last
   1ca38:	7100051f 	cmp	w8, #0x1
   1ca3c:	54000d60 	b.eq	1cbe8 <sc2355_send_cmd_recv_rsp+0x304>  // b.none
   1ca40:	aa1303e0 	mov	x0, x19
   1ca44:	aa1503e1 	mov	x1, x21
   1ca48:	b900035f 	str	wzr, [x26]
   1ca4c:	94000000 	bl	0 <__cfi_check>
			1ca4c: R_AARCH64_CALL26	.text+0x1d288
   1ca50:	34000340 	cbz	w0, 1cab8 <sc2355_send_cmd_recv_rsp+0x1d4>
   1ca54:	f9400e68 	ldr	x8, [x19, #24]
   1ca58:	52898089 	mov	w9, #0x4c04                	// #19460
   1ca5c:	b8696909 	ldr	w9, [x8, x9]
   1ca60:	350000c9 	cbnz	w9, 1ca78 <sc2355_send_cmd_recv_rsp+0x194>
   1ca64:	f9645660 	ldr	x0, [x19, #18600]
   1ca68:	94000000 	bl	0 <__pm_relax>
			1ca68: R_AARCH64_CALL26	__pm_relax
   1ca6c:	f9400e68 	ldr	x8, [x19, #24]
   1ca70:	52898089 	mov	w9, #0x4c04                	// #19460
   1ca74:	b8696909 	ldr	w9, [x8, x9]
   1ca78:	7100053f 	cmp	w9, #0x1
   1ca7c:	54000061 	b.ne	1ca88 <sc2355_send_cmd_recv_rsp+0x1a4>  // b.any
   1ca80:	52898089 	mov	w9, #0x4c04                	// #19460
   1ca84:	b829691f 	str	wzr, [x8, x9]
   1ca88:	52891108 	mov	w8, #0x4888                	// #18568
   1ca8c:	8b080260 	add	x0, x19, x8
   1ca90:	94000000 	bl	0 <mutex_unlock>
			1ca90: R_AARCH64_CALL26	mutex_unlock
   1ca94:	52891008 	mov	w8, #0x4880                	// #18560
   1ca98:	8b080268 	add	x8, x19, x8
   1ca9c:	14000197 	b	1d0f8 <sc2355_send_cmd_recv_rsp+0x814>
   1caa0:	14000196 	b	1d0f8 <sc2355_send_cmd_recv_rsp+0x814>
   1caa4:	52800029 	mov	w9, #0x1                   	// #1
   1caa8:	4b0903e9 	neg	w9, w9
   1caac:	b829011f 	stadd	w9, [x8]
   1cab0:	12800015 	mov	w21, #0xffffffff            	// #-1
   1cab4:	14000141 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1cab8:	90000008 	adrp	x8, 0 <console_printk>
			1cab8: R_AARCH64_ADR_PREL_PG_HI21	console_printk
   1cabc:	b9400108 	ldr	w8, [x8]
			1cabc: R_AARCH64_LDST32_ABS_LO12_NC	console_printk
   1cac0:	52817709 	mov	w9, #0xbb8                 	// #3000
   1cac4:	7100111f 	cmp	w8, #0x4
   1cac8:	7a49c320 	ccmp	w25, w9, #0x0, gt
   1cacc:	52827108 	mov	w8, #0x1388                	// #5000
   1cad0:	1a990100 	csel	w0, w8, w25, eq	// eq = none
   1cad4:	94000000 	bl	0 <__msecs_to_jiffies>
			1cad4: R_AARCH64_CALL26	__msecs_to_jiffies
   1cad8:	aa0003e1 	mov	x1, x0
   1cadc:	aa1a03e0 	mov	x0, x26
   1cae0:	94000000 	bl	0 <wait_for_completion_timeout>
			1cae0: R_AARCH64_CALL26	wait_for_completion_timeout
   1cae4:	340016c0 	cbz	w0, 1cdbc <sc2355_send_cmd_recv_rsp+0x4d8>
   1cae8:	f9642668 	ldr	x8, [x19, #18504]
   1caec:	90000009 	adrp	x9, 0 <__cfi_check>
			1caec: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82024
   1caf0:	91000129 	add	x9, x9, #0x0
			1caf0: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82024
   1caf4:	f9401515 	ldr	x21, [x8, #40]
   1caf8:	52890808 	mov	w8, #0x4840                	// #18496
   1cafc:	8b080279 	add	x25, x19, x8
   1cb00:	cb0902a9 	sub	x9, x21, x9
   1cb04:	93c90929 	ror	x9, x9, #2
   1cb08:	f100113f 	cmp	x9, #0x4
   1cb0c:	54002be2 	b.cs	1d088 <sc2355_send_cmd_recv_rsp+0x7a4>  // b.hs, b.nlast
   1cb10:	aa1903e0 	mov	x0, x25
   1cb14:	d63f02a0 	blr	x21
   1cb18:	350007e0 	cbnz	w0, 1cc14 <sc2355_send_cmd_recv_rsp+0x330>
   1cb1c:	b943a388 	ldr	w8, [x28, #928]
   1cb20:	7140211f 	cmp	w8, #0x8, lsl #12
   1cb24:	5400078a 	b.ge	1cc14 <sc2355_send_cmd_recv_rsp+0x330>  // b.tcont
   1cb28:	52891088 	mov	w8, #0x4884                	// #18564
   1cb2c:	8b080275 	add	x21, x19, x8
   1cb30:	aa1503e0 	mov	x0, x21
   1cb34:	94000000 	bl	0 <_raw_spin_lock_bh>
			1cb34: R_AARCH64_CALL26	_raw_spin_lock_bh
   1cb38:	f9643e79 	ldr	x25, [x19, #18552]
   1cb3c:	aa1503e0 	mov	x0, x21
   1cb40:	94000000 	bl	0 <_raw_spin_unlock_bh>
			1cb40: R_AARCH64_CALL26	_raw_spin_unlock_bh
   1cb44:	b4001559 	cbz	x25, 1cdec <sc2355_send_cmd_recv_rsp+0x508>
   1cb48:	2a1f03f5 	mov	w21, wzr
   1cb4c:	b4002097 	cbz	x23, 1cf5c <sc2355_send_cmd_recv_rsp+0x678>
   1cb50:	b4002076 	cbz	x22, 1cf5c <sc2355_send_cmd_recv_rsp+0x678>
   1cb54:	794002c8 	ldrh	w8, [x22]
   1cb58:	35002428 	cbnz	w8, 1cfdc <sc2355_send_cmd_recv_rsp+0x6f8>
   1cb5c:	2a1f03f5 	mov	w21, wzr
   1cb60:	140000ff 	b	1cf5c <sc2355_send_cmd_recv_rsp+0x678>
   1cb64:	90000000 	adrp	x0, 0 <__cfi_check>
			1cb64: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe038
   1cb68:	90000001 	adrp	x1, 0 <__cfi_check>
			1cb68: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x11316
   1cb6c:	91000000 	add	x0, x0, #0x0
			1cb6c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe038
   1cb70:	91000021 	add	x1, x1, #0x0
			1cb70: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x11316
   1cb74:	94000000 	bl	0 <printk>
			1cb74: R_AARCH64_CALL26	printk
   1cb78:	f9642668 	ldr	x8, [x19, #18504]
   1cb7c:	90000009 	adrp	x9, 0 <__cfi_check>
			1cb7c: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82034
   1cb80:	91000129 	add	x9, x9, #0x0
			1cb80: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82034
   1cb84:	f9400514 	ldr	x20, [x8, #8]
   1cb88:	52890808 	mov	w8, #0x4840                	// #18496
   1cb8c:	8b080273 	add	x19, x19, x8
   1cb90:	cb090289 	sub	x9, x20, x9
   1cb94:	93c90929 	ror	x9, x9, #2
   1cb98:	f100113f 	cmp	x9, #0x4
   1cb9c:	54002842 	b.cs	1d0a4 <sc2355_send_cmd_recv_rsp+0x7c0>  // b.hs, b.nlast
   1cba0:	aa1303e0 	mov	x0, x19
   1cba4:	aa1503e1 	mov	x1, x21
   1cba8:	d63f0280 	blr	x20
   1cbac:	f94012a0 	ldr	x0, [x21, #32]
   1cbb0:	94000000 	bl	0 <kfree>
			1cbb0: R_AARCH64_CALL26	kfree
   1cbb4:	12800095 	mov	w21, #0xfffffffb            	// #-5
   1cbb8:	14000100 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1cbbc:	90000000 	adrp	x0, 0 <__cfi_check>
			1cbbc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12f3b
   1cbc0:	91000000 	add	x0, x0, #0x0
			1cbc0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12f3b
   1cbc4:	94000000 	bl	0 <printk>
			1cbc4: R_AARCH64_CALL26	printk
   1cbc8:	12800015 	mov	w21, #0xffffffff            	// #-1
   1cbcc:	140000fb 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1cbd0:	7101671f 	cmp	w24, #0x59
   1cbd4:	540002e8 	b.hi	1cc30 <sc2355_send_cmd_recv_rsp+0x34c>  // b.pmore
   1cbd8:	90000008 	adrp	x8, 0 <__cfi_check>
			1cbd8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1cbdc:	91000108 	add	x8, x8, #0x0
			1cbdc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1cbe0:	f8747902 	ldr	x2, [x8, x20, lsl #3]
   1cbe4:	14000015 	b	1cc38 <sc2355_send_cmd_recv_rsp+0x354>
   1cbe8:	12001e88 	and	w8, w20, #0xff
   1cbec:	7101651f 	cmp	w8, #0x59
   1cbf0:	540007e8 	b.hi	1ccec <sc2355_send_cmd_recv_rsp+0x408>  // b.pmore
   1cbf4:	90000008 	adrp	x8, 0 <__cfi_check>
			1cbf4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1cbf8:	91000108 	add	x8, x8, #0x0
			1cbf8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1cbfc:	f8747902 	ldr	x2, [x8, x20, lsl #3]
   1cc00:	1400003d 	b	1ccf4 <sc2355_send_cmd_recv_rsp+0x410>
   1cc04:	90000000 	adrp	x0, 0 <__cfi_check>
			1cc04: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x7c3d
   1cc08:	91000000 	add	x0, x0, #0x0
			1cc08: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x7c3d
   1cc0c:	94000000 	bl	0 <printk>
			1cc0c: R_AARCH64_CALL26	printk
   1cc10:	14000069 	b	1cdb4 <sc2355_send_cmd_recv_rsp+0x4d0>
   1cc14:	b943a382 	ldr	w2, [x28, #928]
   1cc18:	90000000 	adrp	x0, 0 <__cfi_check>
			1cc18: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xec38
   1cc1c:	90000001 	adrp	x1, 0 <__cfi_check>
			1cc1c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x120c3
   1cc20:	91000000 	add	x0, x0, #0x0
			1cc20: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xec38
   1cc24:	91000021 	add	x1, x1, #0x0
			1cc24: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x120c3
   1cc28:	94000000 	bl	0 <printk>
			1cc28: R_AARCH64_CALL26	printk
   1cc2c:	14000070 	b	1cdec <sc2355_send_cmd_recv_rsp+0x508>
   1cc30:	90000002 	adrp	x2, 0 <__cfi_check>
			1cc30: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1cc34:	91000042 	add	x2, x2, #0x0
			1cc34: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1cc38:	90000000 	adrp	x0, 0 <__cfi_check>
			1cc38: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x527c
   1cc3c:	90000001 	adrp	x1, 0 <__cfi_check>
			1cc3c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x11316
   1cc40:	91000000 	add	x0, x0, #0x0
			1cc40: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x527c
   1cc44:	91000021 	add	x1, x1, #0x0
			1cc44: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x11316
   1cc48:	94000000 	bl	0 <printk>
			1cc48: R_AARCH64_CALL26	printk
   1cc4c:	f9642668 	ldr	x8, [x19, #18504]
   1cc50:	90000009 	adrp	x9, 0 <__cfi_check>
			1cc50: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82034
   1cc54:	91000129 	add	x9, x9, #0x0
			1cc54: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82034
   1cc58:	f9400514 	ldr	x20, [x8, #8]
   1cc5c:	52890808 	mov	w8, #0x4840                	// #18496
   1cc60:	8b080276 	add	x22, x19, x8
   1cc64:	cb090289 	sub	x9, x20, x9
   1cc68:	93c90929 	ror	x9, x9, #2
   1cc6c:	f100113f 	cmp	x9, #0x4
   1cc70:	54002282 	b.cs	1d0c0 <sc2355_send_cmd_recv_rsp+0x7dc>  // b.hs, b.nlast
   1cc74:	aa1603e0 	mov	x0, x22
   1cc78:	aa1503e1 	mov	x1, x21
   1cc7c:	d63f0280 	blr	x20
   1cc80:	f94012a0 	ldr	x0, [x21, #32]
   1cc84:	94000000 	bl	0 <kfree>
			1cc84: R_AARCH64_CALL26	kfree
   1cc88:	f9400e68 	ldr	x8, [x19, #24]
   1cc8c:	52898089 	mov	w9, #0x4c04                	// #19460
   1cc90:	b8696909 	ldr	w9, [x8, x9]
   1cc94:	350000c9 	cbnz	w9, 1ccac <sc2355_send_cmd_recv_rsp+0x3c8>
   1cc98:	f9645660 	ldr	x0, [x19, #18600]
   1cc9c:	94000000 	bl	0 <__pm_relax>
			1cc9c: R_AARCH64_CALL26	__pm_relax
   1cca0:	f9400e68 	ldr	x8, [x19, #24]
   1cca4:	52898089 	mov	w9, #0x4c04                	// #19460
   1cca8:	b8696909 	ldr	w9, [x8, x9]
   1ccac:	7100053f 	cmp	w9, #0x1
   1ccb0:	54000061 	b.ne	1ccbc <sc2355_send_cmd_recv_rsp+0x3d8>  // b.any
   1ccb4:	52898089 	mov	w9, #0x4c04                	// #19460
   1ccb8:	b829691f 	str	wzr, [x8, x9]
   1ccbc:	52891108 	mov	w8, #0x4888                	// #18568
   1ccc0:	8b080260 	add	x0, x19, x8
   1ccc4:	94000000 	bl	0 <mutex_unlock>
			1ccc4: R_AARCH64_CALL26	mutex_unlock
   1ccc8:	52891008 	mov	w8, #0x4880                	// #18560
   1cccc:	8b080268 	add	x8, x19, x8
   1ccd0:	14000119 	b	1d134 <sc2355_send_cmd_recv_rsp+0x850>
   1ccd4:	14000118 	b	1d134 <sc2355_send_cmd_recv_rsp+0x850>
   1ccd8:	52800029 	mov	w9, #0x1                   	// #1
   1ccdc:	4b0903e9 	neg	w9, w9
   1cce0:	b829011f 	stadd	w9, [x8]
   1cce4:	2a1f03f5 	mov	w21, wzr
   1cce8:	140000b4 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1ccec:	90000002 	adrp	x2, 0 <__cfi_check>
			1ccec: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1ccf0:	91000042 	add	x2, x2, #0x0
			1ccf0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1ccf4:	90000000 	adrp	x0, 0 <__cfi_check>
			1ccf4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1132f
   1ccf8:	90000001 	adrp	x1, 0 <__cfi_check>
			1ccf8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x11316
   1ccfc:	91000000 	add	x0, x0, #0x0
			1ccfc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1132f
   1cd00:	91000021 	add	x1, x1, #0x0
			1cd00: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x11316
   1cd04:	94000000 	bl	0 <printk>
			1cd04: R_AARCH64_CALL26	printk
   1cd08:	f9642668 	ldr	x8, [x19, #18504]
   1cd0c:	90000009 	adrp	x9, 0 <__cfi_check>
			1cd0c: R_AARCH64_ADR_PREL_PG_HI21	.text+0x82034
   1cd10:	91000129 	add	x9, x9, #0x0
			1cd10: R_AARCH64_ADD_ABS_LO12_NC	.text+0x82034
   1cd14:	f9400514 	ldr	x20, [x8, #8]
   1cd18:	52890808 	mov	w8, #0x4840                	// #18496
   1cd1c:	8b080276 	add	x22, x19, x8
   1cd20:	cb090289 	sub	x9, x20, x9
   1cd24:	93c90929 	ror	x9, x9, #2
   1cd28:	f100113f 	cmp	x9, #0x4
   1cd2c:	54001d82 	b.cs	1d0dc <sc2355_send_cmd_recv_rsp+0x7f8>  // b.hs, b.nlast
   1cd30:	aa1603e0 	mov	x0, x22
   1cd34:	aa1503e1 	mov	x1, x21
   1cd38:	d63f0280 	blr	x20
   1cd3c:	f94012a0 	ldr	x0, [x21, #32]
   1cd40:	94000000 	bl	0 <kfree>
			1cd40: R_AARCH64_CALL26	kfree
   1cd44:	f9400e68 	ldr	x8, [x19, #24]
   1cd48:	52898089 	mov	w9, #0x4c04                	// #19460
   1cd4c:	b8696909 	ldr	w9, [x8, x9]
   1cd50:	350000c9 	cbnz	w9, 1cd68 <sc2355_send_cmd_recv_rsp+0x484>
   1cd54:	f9645660 	ldr	x0, [x19, #18600]
   1cd58:	94000000 	bl	0 <__pm_relax>
			1cd58: R_AARCH64_CALL26	__pm_relax
   1cd5c:	f9400e68 	ldr	x8, [x19, #24]
   1cd60:	52898089 	mov	w9, #0x4c04                	// #19460
   1cd64:	b8696909 	ldr	w9, [x8, x9]
   1cd68:	7100053f 	cmp	w9, #0x1
   1cd6c:	54000061 	b.ne	1cd78 <sc2355_send_cmd_recv_rsp+0x494>  // b.any
   1cd70:	52898089 	mov	w9, #0x4c04                	// #19460
   1cd74:	b829691f 	str	wzr, [x8, x9]
   1cd78:	52891108 	mov	w8, #0x4888                	// #18568
   1cd7c:	8b080260 	add	x0, x19, x8
   1cd80:	94000000 	bl	0 <mutex_unlock>
			1cd80: R_AARCH64_CALL26	mutex_unlock
   1cd84:	52891008 	mov	w8, #0x4880                	// #18560
   1cd88:	8b080268 	add	x8, x19, x8
   1cd8c:	140000f2 	b	1d154 <sc2355_send_cmd_recv_rsp+0x870>
   1cd90:	140000f1 	b	1d154 <sc2355_send_cmd_recv_rsp+0x870>
   1cd94:	52800029 	mov	w9, #0x1                   	// #1
   1cd98:	4b0903e9 	neg	w9, w9
   1cd9c:	b829011f 	stadd	w9, [x8]
   1cda0:	2a1f03f5 	mov	w21, wzr
   1cda4:	14000085 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1cda8:	90000000 	adrp	x0, 0 <__cfi_check>
			1cda8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xb459
   1cdac:	91000000 	add	x0, x0, #0x0
			1cdac: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xb459
   1cdb0:	94000000 	bl	0 <printk>
			1cdb0: R_AARCH64_CALL26	printk
   1cdb4:	2a1f03f7 	mov	w23, wzr
   1cdb8:	17fffefc 	b	1c9a8 <sc2355_send_cmd_recv_rsp+0xc4>
   1cdbc:	398e2388 	ldrsb	x8, [x28, #904]
   1cdc0:	f101651f 	cmp	x8, #0x59
   1cdc4:	540000a8 	b.hi	1cdd8 <sc2355_send_cmd_recv_rsp+0x4f4>  // b.pmore
   1cdc8:	90000009 	adrp	x9, 0 <__cfi_check>
			1cdc8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1cdcc:	91000129 	add	x9, x9, #0x0
			1cdcc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1cdd0:	f8687921 	ldr	x1, [x9, x8, lsl #3]
   1cdd4:	14000003 	b	1cde0 <sc2355_send_cmd_recv_rsp+0x4fc>
   1cdd8:	90000001 	adrp	x1, 0 <__cfi_check>
			1cdd8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1cddc:	91000021 	add	x1, x1, #0x0
			1cddc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1cde0:	90000000 	adrp	x0, 0 <__cfi_check>
			1cde0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xd291
   1cde4:	91000000 	add	x0, x0, #0x0
			1cde4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xd291
   1cde8:	94000000 	bl	0 <printk>
			1cde8: R_AARCH64_CALL26	printk
   1cdec:	7101671f 	cmp	w24, #0x59
   1cdf0:	53057f61 	lsr	w1, w27, #5
   1cdf4:	540000a8 	b.hi	1ce08 <sc2355_send_cmd_recv_rsp+0x524>  // b.pmore
   1cdf8:	90000008 	adrp	x8, 0 <__cfi_check>
			1cdf8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1cdfc:	91000108 	add	x8, x8, #0x0
			1cdfc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1ce00:	f8747902 	ldr	x2, [x8, x20, lsl #3]
   1ce04:	14000003 	b	1ce10 <sc2355_send_cmd_recv_rsp+0x52c>
   1ce08:	90000002 	adrp	x2, 0 <__cfi_check>
			1ce08: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1ce0c:	91000042 	add	x2, x2, #0x0
			1ce0c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1ce10:	90000008 	adrp	x8, 0 <console_printk>
			1ce10: R_AARCH64_ADR_PREL_PG_HI21	console_printk
   1ce14:	b9400103 	ldr	w3, [x8]
			1ce14: R_AARCH64_LDST32_ABS_LO12_NC	console_printk
   1ce18:	90000000 	adrp	x0, 0 <__cfi_check>
			1ce18: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1628f
   1ce1c:	91000000 	add	x0, x0, #0x0
			1ce1c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1628f
   1ce20:	94000000 	bl	0 <printk>
			1ce20: R_AARCH64_CALL26	printk
   1ce24:	52890a08 	mov	w8, #0x4850                	// #18512
   1ce28:	8b080275 	add	x21, x19, x8
   1ce2c:	aa1503e0 	mov	x0, x21
   1ce30:	94000000 	bl	0 <_raw_spin_lock_bh>
			1ce30: R_AARCH64_CALL26	_raw_spin_lock_bh
   1ce34:	f9642e68 	ldr	x8, [x19, #18520]
   1ce38:	52890b09 	mov	w9, #0x4858                	// #18520
   1ce3c:	8b090269 	add	x9, x19, x9
   1ce40:	eb08013f 	cmp	x9, x8
   1ce44:	540000e0 	b.eq	1ce60 <sc2355_send_cmd_recv_rsp+0x57c>  // b.none
   1ce48:	385fc10a 	ldurb	w10, [x8, #-4]
   1ce4c:	6b5b155f 	cmp	w10, w27, lsr #5
   1ce50:	540000c0 	b.eq	1ce68 <sc2355_send_cmd_recv_rsp+0x584>  // b.none
   1ce54:	f9400108 	ldr	x8, [x8]
   1ce58:	eb08013f 	cmp	x9, x8
   1ce5c:	54ffff61 	b.ne	1ce48 <sc2355_send_cmd_recv_rsp+0x564>  // b.any
   1ce60:	aa1f03f6 	mov	x22, xzr
   1ce64:	14000005 	b	1ce78 <sc2355_send_cmd_recv_rsp+0x594>
   1ce68:	b9401109 	ldr	w9, [x8, #16]
   1ce6c:	d107e116 	sub	x22, x8, #0x1f8
   1ce70:	11000529 	add	w9, w9, #0x1
   1ce74:	b9001109 	str	w9, [x8, #16]
   1ce78:	aa1503e0 	mov	x0, x21
   1ce7c:	94000000 	bl	0 <_raw_spin_unlock_bh>
			1ce7c: R_AARCH64_CALL26	_raw_spin_unlock_bh
   1ce80:	7100129f 	cmp	w20, #0x4
   1ce84:	540003c1 	b.ne	1cefc <sc2355_send_cmd_recv_rsp+0x618>  // b.any
   1ce88:	52800082 	mov	w2, #0x4                   	// #4
   1ce8c:	52800063 	mov	w3, #0x3                   	// #3
   1ce90:	aa1303e0 	mov	x0, x19
   1ce94:	94000000 	bl	1c3b4 <sc2355_assert_cmd>
			1ce94: R_AARCH64_CALL26	sc2355_assert_cmd
   1ce98:	f9400e68 	ldr	x8, [x19, #24]
   1ce9c:	52898089 	mov	w9, #0x4c04                	// #19460
   1cea0:	b8696909 	ldr	w9, [x8, x9]
   1cea4:	350000c9 	cbnz	w9, 1cebc <sc2355_send_cmd_recv_rsp+0x5d8>
   1cea8:	f9645660 	ldr	x0, [x19, #18600]
   1ceac:	94000000 	bl	0 <__pm_relax>
			1ceac: R_AARCH64_CALL26	__pm_relax
   1ceb0:	f9400e68 	ldr	x8, [x19, #24]
   1ceb4:	52898089 	mov	w9, #0x4c04                	// #19460
   1ceb8:	b8696909 	ldr	w9, [x8, x9]
   1cebc:	7100053f 	cmp	w9, #0x1
   1cec0:	54000061 	b.ne	1cecc <sc2355_send_cmd_recv_rsp+0x5e8>  // b.any
   1cec4:	52898089 	mov	w9, #0x4c04                	// #19460
   1cec8:	b829691f 	str	wzr, [x8, x9]
   1cecc:	52891108 	mov	w8, #0x4888                	// #18568
   1ced0:	8b080260 	add	x0, x19, x8
   1ced4:	94000000 	bl	0 <mutex_unlock>
			1ced4: R_AARCH64_CALL26	mutex_unlock
   1ced8:	52891008 	mov	w8, #0x4880                	// #18560
   1cedc:	8b080268 	add	x8, x19, x8
   1cee0:	140000a5 	b	1d174 <sc2355_send_cmd_recv_rsp+0x890>
   1cee4:	140000a4 	b	1d174 <sc2355_send_cmd_recv_rsp+0x890>
   1cee8:	52800029 	mov	w9, #0x1                   	// #1
   1ceec:	4b0903e9 	neg	w9, w9
   1cef0:	b829011f 	stadd	w9, [x8]
   1cef4:	12800015 	mov	w21, #0xffffffff            	// #-1
   1cef8:	14000030 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1cefc:	b40002f6 	cbz	x22, 1cf58 <sc2355_send_cmd_recv_rsp+0x674>
   1cf00:	3940e268 	ldrb	w8, [x19, #56]
   1cf04:	35000168 	cbnz	w8, 1cf30 <sc2355_send_cmd_recv_rsp+0x64c>
   1cf08:	f9586668 	ldr	x8, [x19, #12488]
   1cf0c:	b940c908 	ldr	w8, [x8, #200]
   1cf10:	7100051f 	cmp	w8, #0x1
   1cf14:	540000e1 	b.ne	1cf30 <sc2355_send_cmd_recv_rsp+0x64c>  // b.any
   1cf18:	b9402a68 	ldr	w8, [x19, #40]
   1cf1c:	350000a8 	cbnz	w8, 1cf30 <sc2355_send_cmd_recv_rsp+0x64c>
   1cf20:	52800063 	mov	w3, #0x3                   	// #3
   1cf24:	aa1303e0 	mov	x0, x19
   1cf28:	2a1403e2 	mov	w2, w20
   1cf2c:	94000000 	bl	1c3b4 <sc2355_assert_cmd>
			1cf2c: R_AARCH64_CALL26	sc2355_assert_cmd
   1cf30:	f940eec8 	ldr	x8, [x22, #472]
   1cf34:	52890a14 	mov	w20, #0x4850                	// #18512
   1cf38:	8b140100 	add	x0, x8, x20
   1cf3c:	94000000 	bl	0 <_raw_spin_lock_bh>
			1cf3c: R_AARCH64_CALL26	_raw_spin_lock_bh
   1cf40:	b9420ac8 	ldr	w8, [x22, #520]
   1cf44:	f940eec9 	ldr	x9, [x22, #472]
   1cf48:	51000508 	sub	w8, w8, #0x1
   1cf4c:	8b140120 	add	x0, x9, x20
   1cf50:	b9020ac8 	str	w8, [x22, #520]
   1cf54:	94000000 	bl	0 <_raw_spin_unlock_bh>
			1cf54: R_AARCH64_CALL26	_raw_spin_unlock_bh
   1cf58:	12800015 	mov	w21, #0xffffffff            	// #-1
   1cf5c:	f9400e68 	ldr	x8, [x19, #24]
   1cf60:	52898089 	mov	w9, #0x4c04                	// #19460
   1cf64:	b8696909 	ldr	w9, [x8, x9]
   1cf68:	350000c9 	cbnz	w9, 1cf80 <sc2355_send_cmd_recv_rsp+0x69c>
   1cf6c:	f9645660 	ldr	x0, [x19, #18600]
   1cf70:	94000000 	bl	0 <__pm_relax>
			1cf70: R_AARCH64_CALL26	__pm_relax
   1cf74:	f9400e68 	ldr	x8, [x19, #24]
   1cf78:	52898089 	mov	w9, #0x4c04                	// #19460
   1cf7c:	b8696909 	ldr	w9, [x8, x9]
   1cf80:	7100053f 	cmp	w9, #0x1
   1cf84:	54000061 	b.ne	1cf90 <sc2355_send_cmd_recv_rsp+0x6ac>  // b.any
   1cf88:	52898089 	mov	w9, #0x4c04                	// #19460
   1cf8c:	b829691f 	str	wzr, [x8, x9]
   1cf90:	52891108 	mov	w8, #0x4888                	// #18568
   1cf94:	8b080260 	add	x0, x19, x8
   1cf98:	94000000 	bl	0 <mutex_unlock>
			1cf98: R_AARCH64_CALL26	mutex_unlock
   1cf9c:	52891008 	mov	w8, #0x4880                	// #18560
   1cfa0:	8b080268 	add	x8, x19, x8
   1cfa4:	1400005d 	b	1d118 <sc2355_send_cmd_recv_rsp+0x834>
   1cfa8:	1400005c 	b	1d118 <sc2355_send_cmd_recv_rsp+0x834>
   1cfac:	52800029 	mov	w9, #0x1                   	// #1
   1cfb0:	4b0903e9 	neg	w9, w9
   1cfb4:	b829011f 	stadd	w9, [x8]
   1cfb8:	2a1503e0 	mov	w0, w21
   1cfbc:	a9454ff4 	ldp	x20, x19, [sp, #80]
   1cfc0:	a94457f6 	ldp	x22, x21, [sp, #64]
   1cfc4:	a9435ff8 	ldp	x24, x23, [sp, #48]
   1cfc8:	a94267fa 	ldp	x26, x25, [sp, #32]
   1cfcc:	a9416ffc 	ldp	x28, x27, [sp, #16]
   1cfd0:	a8c67bfd 	ldp	x29, x30, [sp], #96
   1cfd4:	f85f8e5e 	ldr	x30, [x18, #-8]!
   1cfd8:	d65f03c0 	ret
   1cfdc:	f9643e69 	ldr	x9, [x19, #18552]
   1cfe0:	aa1703e0 	mov	x0, x23
   1cfe4:	12001e95 	and	w21, w20, #0xff
   1cfe8:	7940052a 	ldrh	w10, [x9, #2]
   1cfec:	91003121 	add	x1, x9, #0xc
   1cff0:	5100314a 	sub	w10, w10, #0xc
   1cff4:	6b2a211f 	cmp	w8, w10, uxth
   1cff8:	1a8a3108 	csel	w8, w8, w10, cc	// cc = lo, ul, last
   1cffc:	790002c8 	strh	w8, [x22]
   1d000:	3940012a 	ldrb	w10, [x9]
   1d004:	92403d02 	and	x2, x8, #0xffff
   1d008:	53057d56 	lsr	w22, w10, #5
   1d00c:	94000000 	bl	0 <memcpy>
			1d00c: R_AARCH64_CALL26	memcpy
   1d010:	71016abf 	cmp	w21, #0x5a
   1d014:	540001c2 	b.cs	1d04c <sc2355_send_cmd_recv_rsp+0x768>  // b.hs, b.nlast
   1d018:	90000008 	adrp	x8, 0 <__cfi_check>
			1d018: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x22598
   1d01c:	91000108 	add	x8, x8, #0x0
			1d01c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x22598
   1d020:	f8747903 	ldr	x3, [x8, x20, lsl #3]
   1d024:	90000000 	adrp	x0, 0 <__cfi_check>
			1d024: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2009
   1d028:	91000000 	add	x0, x0, #0x0
			1d028: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2009
   1d02c:	2a1603e1 	mov	w1, w22
   1d030:	2a1803e2 	mov	w2, w24
   1d034:	94000000 	bl	0 <printk>
			1d034: R_AARCH64_CALL26	printk
   1d038:	71000e9f 	cmp	w20, #0x3
   1d03c:	54ffd901 	b.ne	1cb5c <sc2355_send_cmd_recv_rsp+0x278>  // b.any
   1d040:	2a1f03f5 	mov	w21, wzr
   1d044:	390002f6 	strb	w22, [x23]
   1d048:	17ffffc5 	b	1cf5c <sc2355_send_cmd_recv_rsp+0x678>
   1d04c:	90000000 	adrp	x0, 0 <__cfi_check>
			1d04c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2009
   1d050:	90000003 	adrp	x3, 0 <__cfi_check>
			1d050: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x20a
   1d054:	91000000 	add	x0, x0, #0x0
			1d054: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2009
   1d058:	91000063 	add	x3, x3, #0x0
			1d058: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x20a
   1d05c:	2a1603e1 	mov	w1, w22
   1d060:	2a1803e2 	mov	w2, w24
   1d064:	94000000 	bl	0 <printk>
			1d064: R_AARCH64_CALL26	printk
   1d068:	17fffebd 	b	1cb5c <sc2355_send_cmd_recv_rsp+0x278>
   1d06c:	d2923fc0 	mov	x0, #0x91fe                	// #37374
   1d070:	f2ac4400 	movk	x0, #0x6220, lsl #16
   1d074:	f2c6e440 	movk	x0, #0x3722, lsl #32
   1d078:	f2fdc3e0 	movk	x0, #0xee1f, lsl #48
   1d07c:	aa1403e1 	mov	x1, x20
   1d080:	94000000 	bl	0 <__cfi_slowpath>
			1d080: R_AARCH64_CALL26	__cfi_slowpath
   1d084:	17fffe53 	b	1c9d0 <sc2355_send_cmd_recv_rsp+0xec>
   1d088:	d297f4c0 	mov	x0, #0xbfa6                	// #49062
   1d08c:	f2a789e0 	movk	x0, #0x3c4f, lsl #16
   1d090:	f2c0fb00 	movk	x0, #0x7d8, lsl #32
   1d094:	f2f2a8c0 	movk	x0, #0x9546, lsl #48
   1d098:	aa1503e1 	mov	x1, x21
   1d09c:	94000000 	bl	0 <__cfi_slowpath>
			1d09c: R_AARCH64_CALL26	__cfi_slowpath
   1d0a0:	17fffe9c 	b	1cb10 <sc2355_send_cmd_recv_rsp+0x22c>
   1d0a4:	d2923fc0 	mov	x0, #0x91fe                	// #37374
   1d0a8:	f2ac4400 	movk	x0, #0x6220, lsl #16
   1d0ac:	f2c6e440 	movk	x0, #0x3722, lsl #32
   1d0b0:	f2fdc3e0 	movk	x0, #0xee1f, lsl #48
   1d0b4:	aa1403e1 	mov	x1, x20
   1d0b8:	94000000 	bl	0 <__cfi_slowpath>
			1d0b8: R_AARCH64_CALL26	__cfi_slowpath
   1d0bc:	17fffeb9 	b	1cba0 <sc2355_send_cmd_recv_rsp+0x2bc>
   1d0c0:	d2923fc0 	mov	x0, #0x91fe                	// #37374
   1d0c4:	f2ac4400 	movk	x0, #0x6220, lsl #16
   1d0c8:	f2c6e440 	movk	x0, #0x3722, lsl #32
   1d0cc:	f2fdc3e0 	movk	x0, #0xee1f, lsl #48
   1d0d0:	aa1403e1 	mov	x1, x20
   1d0d4:	94000000 	bl	0 <__cfi_slowpath>
			1d0d4: R_AARCH64_CALL26	__cfi_slowpath
   1d0d8:	17fffee7 	b	1cc74 <sc2355_send_cmd_recv_rsp+0x390>
   1d0dc:	d2923fc0 	mov	x0, #0x91fe                	// #37374
   1d0e0:	f2ac4400 	movk	x0, #0x6220, lsl #16
   1d0e4:	f2c6e440 	movk	x0, #0x3722, lsl #32
   1d0e8:	f2fdc3e0 	movk	x0, #0xee1f, lsl #48
   1d0ec:	aa1403e1 	mov	x1, x20
   1d0f0:	94000000 	bl	0 <__cfi_slowpath>
			1d0f0: R_AARCH64_CALL26	__cfi_slowpath
   1d0f4:	17ffff0f 	b	1cd30 <sc2355_send_cmd_recv_rsp+0x44c>
   1d0f8:	52800029 	mov	w9, #0x1                   	// #1
   1d0fc:	f9800111 	prfm	pstl1strm, [x8]
   1d100:	885f7d0a 	ldxr	w10, [x8]
   1d104:	4b09014a 	sub	w10, w10, w9
   1d108:	880b7d0a 	stxr	w11, w10, [x8]
   1d10c:	35ffffab 	cbnz	w11, 1d100 <sc2355_send_cmd_recv_rsp+0x81c>
   1d110:	12800015 	mov	w21, #0xffffffff            	// #-1
   1d114:	17ffffa9 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1d118:	52800029 	mov	w9, #0x1                   	// #1
   1d11c:	f9800111 	prfm	pstl1strm, [x8]
   1d120:	885f7d0a 	ldxr	w10, [x8]
   1d124:	4b09014a 	sub	w10, w10, w9
   1d128:	880b7d0a 	stxr	w11, w10, [x8]
   1d12c:	35ffffab 	cbnz	w11, 1d120 <sc2355_send_cmd_recv_rsp+0x83c>
   1d130:	17ffffa2 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1d134:	52800029 	mov	w9, #0x1                   	// #1
   1d138:	f9800111 	prfm	pstl1strm, [x8]
   1d13c:	885f7d0a 	ldxr	w10, [x8]
   1d140:	4b09014a 	sub	w10, w10, w9
   1d144:	880b7d0a 	stxr	w11, w10, [x8]
   1d148:	35ffffab 	cbnz	w11, 1d13c <sc2355_send_cmd_recv_rsp+0x858>
   1d14c:	2a1f03f5 	mov	w21, wzr
   1d150:	17ffff9a 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1d154:	52800029 	mov	w9, #0x1                   	// #1
   1d158:	f9800111 	prfm	pstl1strm, [x8]
   1d15c:	885f7d0a 	ldxr	w10, [x8]
   1d160:	4b09014a 	sub	w10, w10, w9
   1d164:	880b7d0a 	stxr	w11, w10, [x8]
   1d168:	35ffffab 	cbnz	w11, 1d15c <sc2355_send_cmd_recv_rsp+0x878>
   1d16c:	2a1f03f5 	mov	w21, wzr
   1d170:	17ffff92 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>
   1d174:	52800029 	mov	w9, #0x1                   	// #1
   1d178:	f9800111 	prfm	pstl1strm, [x8]
   1d17c:	885f7d0a 	ldxr	w10, [x8]
   1d180:	4b09014a 	sub	w10, w10, w9
   1d184:	880b7d0a 	stxr	w11, w10, [x8]
   1d188:	35ffffab 	cbnz	w11, 1d17c <sc2355_send_cmd_recv_rsp+0x898>
   1d18c:	12800015 	mov	w21, #0xffffffff            	// #-1
   1d190:	17ffff8a 	b	1cfb8 <sc2355_send_cmd_recv_rsp+0x6d4>

Disassembly of section .init.text:

Disassembly of section .exit.text:
