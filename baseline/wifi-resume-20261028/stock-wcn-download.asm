
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/wcn_bsp.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

0000000000014ae8 <pre_btwifi_download_sdio>:
   14ae8:	d10243ff 	sub	sp, sp, #0x90
   14aec:	f800865e 	str	x30, [x18], #8
   14af0:	a9037bfd 	stp	x29, x30, [sp, #48]
   14af4:	a9046ffc 	stp	x28, x27, [sp, #64]
   14af8:	a90567fa 	stp	x26, x25, [sp, #80]
   14afc:	a9065ff8 	stp	x24, x23, [sp, #96]
   14b00:	a90757f6 	stp	x22, x21, [sp, #112]
   14b04:	a9084ff4 	stp	x20, x19, [sp, #128]
   14b08:	9100c3fd 	add	x29, sp, #0x30
   14b0c:	90000008 	adrp	x8, 0 <__stack_chk_guard>
			14b0c: R_AARCH64_ADR_PREL_PG_HI21	__stack_chk_guard
   14b10:	f9400108 	ldr	x8, [x8]
			14b10: R_AARCH64_LDST64_ABS_LO12_NC	__stack_chk_guard
   14b14:	90000014 	adrp	x20, 0 <__cfi_check>
			14b14: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   14b18:	f81f83a8 	stur	x8, [x29, #-8]
   14b1c:	f9400297 	ldr	x23, [x20]
			14b1c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14b20:	b50000d7 	cbnz	x23, 14b38 <pre_btwifi_download_sdio+0x50>
   14b24:	90000000 	adrp	x0, 0 <__cfi_check>
			14b24: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14b28:	91000000 	add	x0, x0, #0x0
			14b28: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14b2c:	94000000 	bl	0 <printk>
			14b2c: R_AARCH64_CALL26	printk
   14b30:	94000000 	bl	0 <dump_stack>
			14b30: R_AARCH64_CALL26	dump_stack
   14b34:	f9400297 	ldr	x23, [x20]
			14b34: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14b38:	90000016 	adrp	x22, 0 <__cfi_check>
			14b38: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   14b3c:	f94002c8 	ldr	x8, [x22]
			14b3c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   14b40:	90000009 	adrp	x9, 380c <at_cmd_prepare_buf+0xbc>
			14b40: R_AARCH64_ADR_PREL_PG_HI21	flag_download_done
   14b44:	3900013f 	strb	wzr, [x9]
			14b44: R_AARCH64_LDST8_ABS_LO12_NC	flag_download_done
   14b48:	f81f03bf 	stur	xzr, [x29, #-16]
   14b4c:	394a4909 	ldrb	w9, [x8, #658]
   14b50:	9000001c 	adrp	x28, 0 <__cfi_check>
			14b50: R_AARCH64_ADR_PREL_PG_HI21	.bss
   14b54:	35000309 	cbnz	w9, 14bb4 <pre_btwifi_download_sdio+0xcc>
   14b58:	90000000 	adrp	x0, 0 <__cfi_check>
			14b58: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xc39c
   14b5c:	90000001 	adrp	x1, 0 <__cfi_check>
			14b5c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14b60:	91000000 	add	x0, x0, #0x0
			14b60: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xc39c
   14b64:	91000021 	add	x1, x1, #0x0
			14b64: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14b68:	94000000 	bl	0 <printk>
			14b68: R_AARCH64_CALL26	printk
   14b6c:	f94002c8 	ldr	x8, [x22]
			14b6c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   14b70:	90000001 	adrp	x1, 0 <__cfi_check>
			14b70: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12e28
   14b74:	91000021 	add	x1, x1, #0x0
			14b74: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12e28
   14b78:	d10043a0 	sub	x0, x29, #0x10
   14b7c:	f940d113 	ldr	x19, [x8, #416]
   14b80:	aa1f03e2 	mov	x2, xzr
   14b84:	94000000 	bl	0 <request_firmware>
			14b84: R_AARCH64_CALL26	request_firmware
   14b88:	36f807e0 	tbz	w0, #31, 14c84 <pre_btwifi_download_sdio+0x19c>
   14b8c:	2a0003e1 	mov	w1, w0
   14b90:	90000000 	adrp	x0, 0 <__cfi_check>
			14b90: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6517
   14b94:	91000000 	add	x0, x0, #0x0
			14b94: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6517
   14b98:	94000000 	bl	0 <printk>
			14b98: R_AARCH64_CALL26	printk
   14b9c:	f94002c8 	ldr	x8, [x22]
			14b9c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   14ba0:	52800029 	mov	w9, #0x1                   	// #1
   14ba4:	390a4909 	strb	w9, [x8, #658]
   14ba8:	f9400289 	ldr	x9, [x20]
			14ba8: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14bac:	b4000069 	cbz	x9, 14bb8 <pre_btwifi_download_sdio+0xd0>
   14bb0:	14000012 	b	14bf8 <pre_btwifi_download_sdio+0x110>
   14bb4:	b5000237 	cbnz	x23, 14bf8 <pre_btwifi_download_sdio+0x110>
   14bb8:	b942e913 	ldr	w19, [x8, #744]
   14bbc:	90000000 	adrp	x0, 0 <__cfi_check>
			14bbc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14bc0:	91000000 	add	x0, x0, #0x0
			14bc0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14bc4:	94000000 	bl	0 <printk>
			14bc4: R_AARCH64_CALL26	printk
   14bc8:	94000000 	bl	0 <dump_stack>
			14bc8: R_AARCH64_CALL26	dump_stack
   14bcc:	f9400288 	ldr	x8, [x20]
			14bcc: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14bd0:	b5000148 	cbnz	x8, 14bf8 <pre_btwifi_download_sdio+0x110>
   14bd4:	52818008 	mov	w8, #0xc00                 	// #3072
   14bd8:	72a001e8 	movk	w8, #0xf, lsl #16
   14bdc:	6b08027f 	cmp	w19, w8
   14be0:	540000c8 	b.hi	14bf8 <pre_btwifi_download_sdio+0x110>  // b.pmore
   14be4:	350000bf 	cbnz	wzr, 14bf8 <pre_btwifi_download_sdio+0x110>
   14be8:	90000000 	adrp	x0, 0 <__cfi_check>
			14be8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14bec:	91000000 	add	x0, x0, #0x0
			14bec: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14bf0:	94000000 	bl	0 <printk>
			14bf0: R_AARCH64_CALL26	printk
   14bf4:	94000000 	bl	0 <dump_stack>
			14bf4: R_AARCH64_CALL26	dump_stack
   14bf8:	90000013 	adrp	x19, 0 <__cfi_check>
			14bf8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12454
   14bfc:	90000000 	adrp	x0, 0 <__cfi_check>
			14bfc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1198f
   14c00:	91000273 	add	x19, x19, #0x0
			14c00: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12454
   14c04:	91000000 	add	x0, x0, #0x0
			14c04: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1198f
   14c08:	aa1303e1 	mov	x1, x19
   14c0c:	94000000 	bl	0 <printk>
			14c0c: R_AARCH64_CALL26	printk
   14c10:	90000000 	adrp	x0, 0 <__cfi_check>
			14c10: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x9503
   14c14:	91000000 	add	x0, x0, #0x0
			14c14: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x9503
   14c18:	aa1303e1 	mov	x1, x19
   14c1c:	94000000 	bl	0 <printk>
			14c1c: R_AARCH64_CALL26	printk
   14c20:	f9400388 	ldr	x8, [x28]
			14c20: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   14c24:	b4000148 	cbz	x8, 14c4c <pre_btwifi_download_sdio+0x164>
   14c28:	f9406913 	ldr	x19, [x8, #208]
   14c2c:	b4000113 	cbz	x19, 14c4c <pre_btwifi_download_sdio+0x164>
   14c30:	90000008 	adrp	x8, 0 <__cfi_check>
			14c30: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4e114
   14c34:	91000108 	add	x8, x8, #0x0
			14c34: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4e114
   14c38:	cb080268 	sub	x8, x19, x8
   14c3c:	93c80908 	ror	x8, x8, #2
   14c40:	f100591f 	cmp	x8, #0x16
   14c44:	54005c82 	b.cs	157d4 <pre_btwifi_download_sdio+0xcec>  // b.hs, b.nlast
   14c48:	d63f0260 	blr	x19
   14c4c:	90000009 	adrp	x9, 0 <__stack_chk_guard>
			14c4c: R_AARCH64_ADR_PREL_PG_HI21	__stack_chk_guard
   14c50:	f85f83a8 	ldur	x8, [x29, #-8]
   14c54:	f9400129 	ldr	x9, [x9]
			14c54: R_AARCH64_LDST64_ABS_LO12_NC	__stack_chk_guard
   14c58:	eb08013f 	cmp	x9, x8
   14c5c:	54005ba1 	b.ne	157d0 <pre_btwifi_download_sdio+0xce8>  // b.any
   14c60:	a9437bfd 	ldp	x29, x30, [sp, #48]
   14c64:	a9484ff4 	ldp	x20, x19, [sp, #128]
   14c68:	a94757f6 	ldp	x22, x21, [sp, #112]
   14c6c:	a9465ff8 	ldp	x24, x23, [sp, #96]
   14c70:	a94567fa 	ldp	x26, x25, [sp, #80]
   14c74:	a9446ffc 	ldp	x28, x27, [sp, #64]
   14c78:	f85f8e5e 	ldr	x30, [x18, #-8]!
   14c7c:	910243ff 	add	sp, sp, #0x90
   14c80:	d65f03c0 	ret
   14c84:	f85f03a0 	ldur	x0, [x29, #-16]
   14c88:	52890888 	mov	w8, #0x4844                	// #18500
   14c8c:	72a84a88 	movk	w8, #0x4254, lsl #16
   14c90:	f9400415 	ldr	x21, [x0, #8]
   14c94:	b94002b4 	ldr	w20, [x21]
   14c98:	6b08029f 	cmp	w20, w8
   14c9c:	54000201 	b.ne	14cdc <pre_btwifi_download_sdio+0x1f4>  // b.any
   14ca0:	b9404ea8 	ldr	w8, [x21, #76]
   14ca4:	34000108 	cbz	w8, 14cc4 <pre_btwifi_download_sdio+0x1dc>
   14ca8:	b94052a2 	ldr	w2, [x21, #80]
   14cac:	91080108 	add	x8, x8, #0x200
   14cb0:	eb02011f 	cmp	x8, x2
   14cb4:	54000082 	b.cs	14cc4 <pre_btwifi_download_sdio+0x1dc>  // b.hs, b.nlast
   14cb8:	f9400008 	ldr	x8, [x0]
   14cbc:	eb02011f 	cmp	x8, x2
   14cc0:	54003062 	b.cs	152cc <pre_btwifi_download_sdio+0x7e4>  // b.hs, b.nlast
   14cc4:	94000000 	bl	0 <release_firmware>
			14cc4: R_AARCH64_CALL26	release_firmware
   14cc8:	90000000 	adrp	x0, 0 <__cfi_check>
			14cc8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1196a
   14ccc:	91000000 	add	x0, x0, #0x0
			14ccc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1196a
   14cd0:	90000001 	adrp	x1, 0 <__cfi_check>
			14cd0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14cd4:	91000021 	add	x1, x1, #0x0
			14cd4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14cd8:	17ffffd1 	b	14c1c <pre_btwifi_download_sdio+0x134>
   14cdc:	90000000 	adrp	x0, 0 <__cfi_check>
			14cdc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1421a
   14ce0:	90000001 	adrp	x1, 0 <__cfi_check>
			14ce0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14ce4:	52890883 	mov	w3, #0x4844                	// #18500
   14ce8:	91000000 	add	x0, x0, #0x0
			14ce8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1421a
   14cec:	91000021 	add	x1, x1, #0x0
			14cec: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14cf0:	72a84a83 	movk	w3, #0x4254, lsl #16
   14cf4:	2a1403e2 	mov	w2, w20
   14cf8:	f9000bf7 	str	x23, [sp, #16]
   14cfc:	b81ec3b4 	stur	w20, [x29, #-20]
   14d00:	94000000 	bl	0 <printk>
			14d00: R_AARCH64_CALL26	printk
   14d04:	f85f03a8 	ldur	x8, [x29, #-16]
   14d08:	b9400116 	ldr	w22, [x8]
   14d0c:	f9400515 	ldr	x21, [x8, #8]
   14d10:	90000017 	adrp	x23, 0 <__cfi_check>
			14d10: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14d14:	90000000 	adrp	x0, 0 <__cfi_check>
			14d14: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10ea4
   14d18:	910002f7 	add	x23, x23, #0x0
			14d18: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14d1c:	528e7614 	mov	w20, #0x73b0                	// #29616
   14d20:	91000000 	add	x0, x0, #0x0
			14d20: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10ea4
   14d24:	aa1703e1 	mov	x1, x23
   14d28:	2a1603e2 	mov	w2, w22
   14d2c:	72a001d4 	movk	w20, #0xe, lsl #16
   14d30:	94000000 	bl	0 <printk>
			14d30: R_AARCH64_CALL26	printk
   14d34:	90000000 	adrp	x0, 0 <__cfi_check>
			14d34: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x24cb
   14d38:	91000000 	add	x0, x0, #0x0
			14d38: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x24cb
   14d3c:	aa1703e1 	mov	x1, x23
   14d40:	aa1503e2 	mov	x2, x21
   14d44:	94000000 	bl	0 <printk>
			14d44: R_AARCH64_CALL26	printk
   14d48:	f85f03a8 	ldur	x8, [x29, #-16]
   14d4c:	90000000 	adrp	x0, 0 <__cfi_check>
			14d4c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x4db8
   14d50:	91000000 	add	x0, x0, #0x0
			14d50: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x4db8
   14d54:	aa1703e1 	mov	x1, x23
   14d58:	f9400102 	ldr	x2, [x8]
   14d5c:	94000000 	bl	0 <printk>
			14d5c: R_AARCH64_CALL26	printk
   14d60:	11014288 	add	w8, w20, #0x50
   14d64:	6b0802df 	cmp	w22, w8
   14d68:	540001e9 	b.ls	14da4 <pre_btwifi_download_sdio+0x2bc>  // b.plast
   14d6c:	94000000 	bl	125e8 <marlin_get_wcn_xpe_efuse_data>
			14d6c: R_AARCH64_CALL26	marlin_get_wcn_xpe_efuse_data
   14d70:	7100041f 	cmp	w0, #0x1
   14d74:	540000e1 	b.ne	14d90 <pre_btwifi_download_sdio+0x2a8>  // b.any
   14d78:	90000000 	adrp	x0, 0 <__cfi_check>
			14d78: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xccc
   14d7c:	91000000 	add	x0, x0, #0x0
			14d7c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xccc
   14d80:	914602b5 	add	x21, x21, #0x180, lsl #12
   14d84:	94000000 	bl	0 <printk>
			14d84: R_AARCH64_CALL26	printk
   14d88:	528e7616 	mov	w22, #0x73b0                	// #29616
   14d8c:	72a001d6 	movk	w22, #0xe, lsl #16
   14d90:	90000000 	adrp	x0, 0 <__cfi_check>
			14d90: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xda87
   14d94:	90000001 	adrp	x1, 0 <__cfi_check>
			14d94: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14d98:	91000000 	add	x0, x0, #0x0
			14d98: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xda87
   14d9c:	91000021 	add	x1, x1, #0x0
			14d9c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14da0:	94000000 	bl	0 <printk>
			14da0: R_AARCH64_CALL26	printk
   14da4:	528fffe8 	mov	w8, #0x7fff                	// #32767
   14da8:	0b0802c8 	add	w8, w22, w8
   14dac:	530f7d1a 	lsr	w26, w8, #15
   14db0:	35000a7a 	cbnz	w26, 14efc <pre_btwifi_download_sdio+0x414>
   14db4:	f85f03a0 	ldur	x0, [x29, #-16]
   14db8:	94000000 	bl	0 <release_firmware>
			14db8: R_AARCH64_CALL26	release_firmware
   14dbc:	90000000 	adrp	x0, 0 <__cfi_check>
			14dbc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x14cb5
   14dc0:	90000001 	adrp	x1, 0 <__cfi_check>
			14dc0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   14dc4:	91000000 	add	x0, x0, #0x0
			14dc4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x14cb5
   14dc8:	91000021 	add	x1, x1, #0x0
			14dc8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   14dcc:	94000000 	bl	0 <printk>
			14dcc: R_AARCH64_CALL26	printk
   14dd0:	b85ec3a8 	ldur	w8, [x29, #-20]
   14dd4:	52890889 	mov	w9, #0x4844                	// #18500
   14dd8:	72a84a89 	movk	w9, #0x4254, lsl #16
   14ddc:	6b09011f 	cmp	w8, w9
   14de0:	54000081 	b.ne	14df0 <pre_btwifi_download_sdio+0x308>  // b.any
   14de4:	b4000075 	cbz	x21, 14df0 <pre_btwifi_download_sdio+0x308>
   14de8:	aa1503e0 	mov	x0, x21
   14dec:	94000000 	bl	0 <vfree>
			14dec: R_AARCH64_CALL26	vfree
   14df0:	9000001b 	adrp	x27, 0 <__cfi_check>
			14df0: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   14df4:	f9400373 	ldr	x19, [x27]
			14df4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14df8:	9000001c 	adrp	x28, 0 <__cfi_check>
			14df8: R_AARCH64_ADR_PREL_PG_HI21	.bss
   14dfc:	90000015 	adrp	x21, 0 <__cfi_check>
			14dfc: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   14e00:	b81f03bf 	stur	wzr, [x29, #-16]
   14e04:	b50000d3 	cbnz	x19, 14e1c <pre_btwifi_download_sdio+0x334>
   14e08:	90000000 	adrp	x0, 0 <__cfi_check>
			14e08: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14e0c:	91000000 	add	x0, x0, #0x0
			14e0c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14e10:	94000000 	bl	0 <printk>
			14e10: R_AARCH64_CALL26	printk
   14e14:	94000000 	bl	0 <dump_stack>
			14e14: R_AARCH64_CALL26	dump_stack
   14e18:	f9400373 	ldr	x19, [x27]
			14e18: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14e1c:	90000000 	adrp	x0, 0 <__cfi_check>
			14e1c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1040b
   14e20:	90000001 	adrp	x1, 0 <__cfi_check>
			14e20: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe621
   14e24:	52824254 	mov	w20, #0x1212                	// #4626
   14e28:	91000000 	add	x0, x0, #0x0
			14e28: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1040b
   14e2c:	91000021 	add	x1, x1, #0x0
			14e2c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe621
   14e30:	72a24254 	movk	w20, #0x1212, lsl #16
   14e34:	94000000 	bl	0 <printk>
			14e34: R_AARCH64_CALL26	printk
   14e38:	f94002a8 	ldr	x8, [x21]
			14e38: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   14e3c:	90000000 	adrp	x0, 0 <__cfi_check>
			14e3c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xa0e0
   14e40:	91000000 	add	x0, x0, #0x0
			14e40: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xa0e0
   14e44:	b942c501 	ldr	w1, [x8, #708]
   14e48:	94000000 	bl	0 <printk>
			14e48: R_AARCH64_CALL26	printk
   14e4c:	f94002a8 	ldr	x8, [x21]
			14e4c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   14e50:	b942c509 	ldr	w9, [x8, #708]
   14e54:	6b14013f 	cmp	w9, w20
   14e58:	540000e0 	b.eq	14e74 <pre_btwifi_download_sdio+0x38c>  // b.none
   14e5c:	90000000 	adrp	x0, 0 <__cfi_check>
			14e5c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xc3d3
   14e60:	529fffe9 	mov	w9, #0xffff                	// #65535
   14e64:	91000000 	add	x0, x0, #0x0
			14e64: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xc3d3
   14e68:	b902c514 	str	w20, [x8, #708]
   14e6c:	79059909 	strh	w9, [x8, #716]
   14e70:	94000000 	bl	0 <printk>
			14e70: R_AARCH64_CALL26	printk
   14e74:	b4000133 	cbz	x19, 14e98 <pre_btwifi_download_sdio+0x3b0>
   14e78:	39401668 	ldrb	w8, [x19, #5]
   14e7c:	340000e8 	cbz	w8, 14e98 <pre_btwifi_download_sdio+0x3b0>
   14e80:	94000000 	bl	25910 <sdio_pub_int_btwf_en0>
			14e80: R_AARCH64_CALL26	sdio_pub_int_btwf_en0
   14e84:	90000008 	adrp	x8, 0 <__cfi_check>
			14e84: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x4c28
   14e88:	91000108 	add	x8, x8, #0x0
			14e88: R_AARCH64_ADD_ABS_LO12_NC	.bss+0x4c28
   14e8c:	52800029 	mov	w9, #0x1                   	// #1
   14e90:	b9002509 	str	w9, [x8, #36]
   14e94:	b900011f 	str	wzr, [x8]
   14e98:	f9400368 	ldr	x8, [x27]
			14e98: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14e9c:	52905113 	mov	w19, #0x8288                	// #33416
   14ea0:	72a80113 	movk	w19, #0x4008, lsl #16
   14ea4:	b50000e8 	cbnz	x8, 14ec0 <pre_btwifi_download_sdio+0x3d8>
   14ea8:	90000000 	adrp	x0, 0 <__cfi_check>
			14ea8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14eac:	91000000 	add	x0, x0, #0x0
			14eac: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14eb0:	94000000 	bl	0 <printk>
			14eb0: R_AARCH64_CALL26	printk
   14eb4:	94000000 	bl	0 <dump_stack>
			14eb4: R_AARCH64_CALL26	dump_stack
   14eb8:	f9400368 	ldr	x8, [x27]
			14eb8: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14ebc:	b4000168 	cbz	x8, 14ee8 <pre_btwifi_download_sdio+0x400>
   14ec0:	39400109 	ldrb	w9, [x8]
   14ec4:	35000989 	cbnz	w9, 14ff4 <pre_btwifi_download_sdio+0x50c>
   14ec8:	39401d09 	ldrb	w9, [x8, #7]
   14ecc:	52905114 	mov	w20, #0x8288                	// #33416
   14ed0:	72a80114 	movk	w20, #0x4008, lsl #16
   14ed4:	350000e9 	cbnz	w9, 14ef0 <pre_btwifi_download_sdio+0x408>
   14ed8:	39401908 	ldrb	w8, [x8, #6]
   14edc:	52905114 	mov	w20, #0x8288                	// #33416
   14ee0:	72a80114 	movk	w20, #0x4008, lsl #16
   14ee4:	35000068 	cbnz	w8, 14ef0 <pre_btwifi_download_sdio+0x408>
   14ee8:	52800094 	mov	w20, #0x4                   	// #4
   14eec:	72a81274 	movk	w20, #0x4093, lsl #16
   14ef0:	f9400388 	ldr	x8, [x28]
			14ef0: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   14ef4:	b5000868 	cbnz	x8, 15000 <pre_btwifi_download_sdio+0x518>
   14ef8:	14000052 	b	15040 <pre_btwifi_download_sdio+0x558>
   14efc:	90000019 	adrp	x25, 0 <__cfi_check>
			14efc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x8a25
   14f00:	2a1f03f8 	mov	w24, wzr
   14f04:	52900014 	mov	w20, #0x8000                	// #32768
   14f08:	91000339 	add	x25, x25, #0x0
			14f08: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x8a25
   14f0c:	2a1a03f7 	mov	w23, w26
   14f10:	14000004 	b	14f20 <pre_btwifi_download_sdio+0x438>
   14f14:	710006f7 	subs	w23, w23, #0x1
   14f18:	0b180378 	add	w24, w27, w24
   14f1c:	54fff4c0 	b.eq	14db4 <pre_btwifi_download_sdio+0x2cc>  // b.none
   14f20:	4b1802c8 	sub	w8, w22, w24
   14f24:	7140211f 	cmp	w8, #0x8, lsl #12
   14f28:	1a94311b 	csel	w27, w8, w20, cc	// cc = lo, ul, last
   14f2c:	8b38c2a1 	add	x1, x21, w24, sxtw
   14f30:	aa1303e0 	mov	x0, x19
   14f34:	aa1b03e2 	mov	x2, x27
   14f38:	94000000 	bl	0 <memcpy>
			14f38: R_AARCH64_CALL26	memcpy
   14f3c:	aa1903e0 	mov	x0, x25
   14f40:	2a1a03e1 	mov	w1, w26
   14f44:	2a1803e2 	mov	w2, w24
   14f48:	2a1b03e3 	mov	w3, w27
   14f4c:	94000000 	bl	0 <printk>
			14f4c: R_AARCH64_CALL26	printk
   14f50:	90000008 	adrp	x8, 0 <__cfi_check>
			14f50: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   14f54:	f9400108 	ldr	x8, [x8]
			14f54: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14f58:	b5000108 	cbnz	x8, 14f78 <pre_btwifi_download_sdio+0x490>
   14f5c:	90000000 	adrp	x0, 0 <__cfi_check>
			14f5c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   14f60:	91000000 	add	x0, x0, #0x0
			14f60: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   14f64:	94000000 	bl	0 <printk>
			14f64: R_AARCH64_CALL26	printk
   14f68:	94000000 	bl	0 <dump_stack>
			14f68: R_AARCH64_CALL26	dump_stack
   14f6c:	90000008 	adrp	x8, 0 <__cfi_check>
			14f6c: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   14f70:	f9400108 	ldr	x8, [x8]
			14f70: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   14f74:	b4000068 	cbz	x8, 14f80 <pre_btwifi_download_sdio+0x498>
   14f78:	39400108 	ldrb	w8, [x8]
   14f7c:	35000068 	cbnz	w8, 14f88 <pre_btwifi_download_sdio+0x4a0>
   14f80:	52a80a1c 	mov	w28, #0x40500000            	// #1078984704
   14f84:	14000002 	b	14f8c <pre_btwifi_download_sdio+0x4a4>
   14f88:	2a1f03fc 	mov	w28, wzr
   14f8c:	90000008 	adrp	x8, 0 <__cfi_check>
			14f8c: R_AARCH64_ADR_PREL_PG_HI21	.bss
   14f90:	f9400108 	ldr	x8, [x8]
			14f90: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   14f94:	b4fffc08 	cbz	x8, 14f14 <pre_btwifi_download_sdio+0x42c>
   14f98:	f9403d08 	ldr	x8, [x8, #120]
   14f9c:	b4fffbc8 	cbz	x8, 14f14 <pre_btwifi_download_sdio+0x42c>
   14fa0:	90000009 	adrp	x9, 0 <__cfi_check>
			14fa0: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4e0ac
   14fa4:	91000129 	add	x9, x9, #0x0
			14fa4: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4e0ac
   14fa8:	cb090109 	sub	x9, x8, x9
   14fac:	93c90929 	ror	x9, x9, #2
   14fb0:	f100193f 	cmp	x9, #0x6
   14fb4:	540000e2 	b.cs	14fd0 <pre_btwifi_download_sdio+0x4e8>  // b.hs, b.nlast
   14fb8:	0b180380 	add	w0, w28, w24
   14fbc:	aa1303e1 	mov	x1, x19
   14fc0:	2a1b03e2 	mov	w2, w27
   14fc4:	d63f0100 	blr	x8
   14fc8:	36fffa60 	tbz	w0, #31, 14f14 <pre_btwifi_download_sdio+0x42c>
   14fcc:	140000d2 	b	15314 <pre_btwifi_download_sdio+0x82c>
   14fd0:	d2868aa0 	mov	x0, #0x3455                	// #13397
   14fd4:	f2bba1a0 	movk	x0, #0xdd0d, lsl #16
   14fd8:	f2ccd9e0 	movk	x0, #0x66cf, lsl #32
   14fdc:	f2f996c0 	movk	x0, #0xccb6, lsl #48
   14fe0:	aa0803e1 	mov	x1, x8
   14fe4:	f90007e8 	str	x8, [sp, #8]
   14fe8:	94000000 	bl	0 <__cfi_slowpath>
			14fe8: R_AARCH64_CALL26	__cfi_slowpath
   14fec:	f94007e8 	ldr	x8, [sp, #8]
   14ff0:	17fffff2 	b	14fb8 <pre_btwifi_download_sdio+0x4d0>
   14ff4:	5140a274 	sub	w20, w19, #0x28, lsl #12
   14ff8:	f9400388 	ldr	x8, [x28]
			14ff8: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   14ffc:	b4000228 	cbz	x8, 15040 <pre_btwifi_download_sdio+0x558>
   15000:	f9404d15 	ldr	x21, [x8, #152]
   15004:	b40001f5 	cbz	x21, 15040 <pre_btwifi_download_sdio+0x558>
   15008:	90000008 	adrp	x8, 0 <__cfi_check>
			15008: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4dfd4
   1500c:	91000108 	add	x8, x8, #0x0
			1500c: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4dfd4
   15010:	cb0802a8 	sub	x8, x21, x8
   15014:	93c80908 	ror	x8, x8, #2
   15018:	f100111f 	cmp	x8, #0x4
   1501c:	54003ea2 	b.cs	157f0 <pre_btwifi_download_sdio+0xd08>  // b.hs, b.nlast
   15020:	d10043a1 	sub	x1, x29, #0x10
   15024:	2a1403e0 	mov	w0, w20
   15028:	d63f02a0 	blr	x21
   1502c:	36f800a0 	tbz	w0, #31, 15040 <pre_btwifi_download_sdio+0x558>
   15030:	2a0003e2 	mov	w2, w0
   15034:	90000000 	adrp	x0, 0 <__cfi_check>
			15034: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2eb7
   15038:	91000000 	add	x0, x0, #0x0
			15038: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2eb7
   1503c:	14000033 	b	15108 <pre_btwifi_download_sdio+0x620>
   15040:	b85f03a2 	ldur	w2, [x29, #-16]
   15044:	90000000 	adrp	x0, 0 <__cfi_check>
			15044: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2de
   15048:	90000001 	adrp	x1, 0 <__cfi_check>
			15048: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe621
   1504c:	91000000 	add	x0, x0, #0x0
			1504c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2de
   15050:	91000021 	add	x1, x1, #0x0
			15050: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe621
   15054:	94000000 	bl	0 <printk>
			15054: R_AARCH64_CALL26	printk
   15058:	b85f03a9 	ldur	w9, [x29, #-16]
   1505c:	f9400368 	ldr	x8, [x27]
			1505c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15060:	121f7929 	and	w9, w9, #0xfffffffe
   15064:	b81f03a9 	stur	w9, [x29, #-16]
   15068:	b50000e8 	cbnz	x8, 15084 <pre_btwifi_download_sdio+0x59c>
   1506c:	90000000 	adrp	x0, 0 <__cfi_check>
			1506c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15070:	91000000 	add	x0, x0, #0x0
			15070: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15074:	94000000 	bl	0 <printk>
			15074: R_AARCH64_CALL26	printk
   15078:	94000000 	bl	0 <dump_stack>
			15078: R_AARCH64_CALL26	dump_stack
   1507c:	f9400368 	ldr	x8, [x27]
			1507c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15080:	b4000168 	cbz	x8, 150ac <pre_btwifi_download_sdio+0x5c4>
   15084:	39400109 	ldrb	w9, [x8]
   15088:	350001c9 	cbnz	w9, 150c0 <pre_btwifi_download_sdio+0x5d8>
   1508c:	39401d09 	ldrb	w9, [x8, #7]
   15090:	52905114 	mov	w20, #0x8288                	// #33416
   15094:	72a80114 	movk	w20, #0x4008, lsl #16
   15098:	350000e9 	cbnz	w9, 150b4 <pre_btwifi_download_sdio+0x5cc>
   1509c:	39401908 	ldrb	w8, [x8, #6]
   150a0:	52905114 	mov	w20, #0x8288                	// #33416
   150a4:	72a80114 	movk	w20, #0x4008, lsl #16
   150a8:	35000068 	cbnz	w8, 150b4 <pre_btwifi_download_sdio+0x5cc>
   150ac:	52800094 	mov	w20, #0x4                   	// #4
   150b0:	72a81274 	movk	w20, #0x4093, lsl #16
   150b4:	f9400388 	ldr	x8, [x28]
			150b4: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   150b8:	b50000a8 	cbnz	x8, 150cc <pre_btwifi_download_sdio+0x5e4>
   150bc:	14000017 	b	15118 <pre_btwifi_download_sdio+0x630>
   150c0:	5140a274 	sub	w20, w19, #0x28, lsl #12
   150c4:	f9400388 	ldr	x8, [x28]
			150c4: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   150c8:	b4000288 	cbz	x8, 15118 <pre_btwifi_download_sdio+0x630>
   150cc:	f9404915 	ldr	x21, [x8, #144]
   150d0:	b4000255 	cbz	x21, 15118 <pre_btwifi_download_sdio+0x630>
   150d4:	90000008 	adrp	x8, 0 <__cfi_check>
			150d4: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4dfd4
   150d8:	91000108 	add	x8, x8, #0x0
			150d8: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4dfd4
   150dc:	cb0802a8 	sub	x8, x21, x8
   150e0:	93c80908 	ror	x8, x8, #2
   150e4:	f100111f 	cmp	x8, #0x4
   150e8:	54003922 	b.cs	1580c <pre_btwifi_download_sdio+0xd24>  // b.hs, b.nlast
   150ec:	d10043a1 	sub	x1, x29, #0x10
   150f0:	2a1403e0 	mov	w0, w20
   150f4:	d63f02a0 	blr	x21
   150f8:	36f80100 	tbz	w0, #31, 15118 <pre_btwifi_download_sdio+0x630>
   150fc:	2a0003e2 	mov	w2, w0
   15100:	90000000 	adrp	x0, 0 <__cfi_check>
			15100: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x158a9
   15104:	91000000 	add	x0, x0, #0x0
			15104: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x158a9
   15108:	90000001 	adrp	x1, 0 <__cfi_check>
			15108: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe621
   1510c:	91000021 	add	x1, x1, #0x0
			1510c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe621
   15110:	94000000 	bl	0 <printk>
			15110: R_AARCH64_CALL26	printk
   15114:	17fffec3 	b	14c20 <pre_btwifi_download_sdio+0x138>
   15118:	94000000 	bl	0 <sched_clock>
			15118: R_AARCH64_CALL26	sched_clock
   1511c:	90000008 	adrp	x8, 0 <__cfi_check>
			1511c: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3520
   15120:	aa0003e1 	mov	x1, x0
   15124:	f9000100 	str	x0, [x8]
			15124: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3520
   15128:	90000000 	adrp	x0, 0 <__cfi_check>
			15128: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6233
   1512c:	91000000 	add	x0, x0, #0x0
			1512c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6233
   15130:	94000000 	bl	0 <printk>
			15130: R_AARCH64_CALL26	printk
   15134:	f9400368 	ldr	x8, [x27]
			15134: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15138:	b50000e8 	cbnz	x8, 15154 <pre_btwifi_download_sdio+0x66c>
   1513c:	90000000 	adrp	x0, 0 <__cfi_check>
			1513c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15140:	91000000 	add	x0, x0, #0x0
			15140: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15144:	94000000 	bl	0 <printk>
			15144: R_AARCH64_CALL26	printk
   15148:	94000000 	bl	0 <dump_stack>
			15148: R_AARCH64_CALL26	dump_stack
   1514c:	f9400368 	ldr	x8, [x27]
			1514c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15150:	b40000e8 	cbz	x8, 1516c <pre_btwifi_download_sdio+0x684>
   15154:	39400109 	ldrb	w9, [x8]
   15158:	35000149 	cbnz	w9, 15180 <pre_btwifi_download_sdio+0x698>
   1515c:	39401d09 	ldrb	w9, [x8, #7]
   15160:	350000a9 	cbnz	w9, 15174 <pre_btwifi_download_sdio+0x68c>
   15164:	39401908 	ldrb	w8, [x8, #6]
   15168:	35000068 	cbnz	w8, 15174 <pre_btwifi_download_sdio+0x68c>
   1516c:	52800093 	mov	w19, #0x4                   	// #4
   15170:	72a81273 	movk	w19, #0x4093, lsl #16
   15174:	f9400388 	ldr	x8, [x28]
			15174: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   15178:	b50000a8 	cbnz	x8, 1518c <pre_btwifi_download_sdio+0x6a4>
   1517c:	14000006 	b	15194 <pre_btwifi_download_sdio+0x6ac>
   15180:	5140a273 	sub	w19, w19, #0x28, lsl #12
   15184:	f9400388 	ldr	x8, [x28]
			15184: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   15188:	b4000068 	cbz	x8, 15194 <pre_btwifi_download_sdio+0x6ac>
   1518c:	f9404d14 	ldr	x20, [x8, #152]
   15190:	b50007b4 	cbnz	x20, 15284 <pre_btwifi_download_sdio+0x79c>
   15194:	2a1f03f3 	mov	w19, wzr
   15198:	b85f03a2 	ldur	w2, [x29, #-16]
   1519c:	90000000 	adrp	x0, 0 <__cfi_check>
			1519c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2f40
   151a0:	90000001 	adrp	x1, 0 <__cfi_check>
			151a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe621
   151a4:	91000000 	add	x0, x0, #0x0
			151a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2f40
   151a8:	91000021 	add	x1, x1, #0x0
			151a8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe621
   151ac:	94000000 	bl	0 <printk>
			151ac: R_AARCH64_CALL26	printk
   151b0:	35ffd393 	cbnz	w19, 14c20 <pre_btwifi_download_sdio+0x138>
   151b4:	f9400be8 	ldr	x8, [sp, #16]
   151b8:	529e1e37 	mov	w23, #0xf0f1                	// #61681
   151bc:	52817613 	mov	w19, #0xbb0                 	// #2992
   151c0:	528e761a 	mov	w26, #0x73b0                	// #29616
   151c4:	528bf418 	mov	w24, #0x5fa0                	// #24480
   151c8:	72be1e17 	movk	w23, #0xf0f0, lsl #16
   151cc:	72a80bf3 	movk	w19, #0x405f, lsl #16
   151d0:	72a80bda 	movk	w26, #0x405e, lsl #16
   151d4:	72a80a58 	movk	w24, #0x4052, lsl #16
   151d8:	b4000d68 	cbz	x8, 15384 <pre_btwifi_download_sdio+0x89c>
   151dc:	39400908 	ldrb	w8, [x8, #2]
   151e0:	35000d28 	cbnz	w8, 15384 <pre_btwifi_download_sdio+0x89c>
   151e4:	90000000 	adrp	x0, 0 <__cfi_check>
			151e4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x1040b
   151e8:	90000001 	adrp	x1, 0 <__cfi_check>
			151e8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xf1fb
   151ec:	91000000 	add	x0, x0, #0x0
			151ec: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x1040b
   151f0:	91000021 	add	x1, x1, #0x0
			151f0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xf1fb
   151f4:	94000000 	bl	0 <printk>
			151f4: R_AARCH64_CALL26	printk
   151f8:	90000008 	adrp	x8, 0 <__cfi_check>
			151f8: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   151fc:	f9400108 	ldr	x8, [x8]
			151fc: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   15200:	b9400508 	ldr	w8, [x8, #4]
   15204:	7100051f 	cmp	w8, #0x1
   15208:	54000ee0 	b.eq	153e4 <pre_btwifi_download_sdio+0x8fc>  // b.none
   1520c:	7100091f 	cmp	w8, #0x2
   15210:	54000f01 	b.ne	153f0 <pre_btwifi_download_sdio+0x908>  // b.any
   15214:	90000000 	adrp	x0, 0 <__cfi_check>
			15214: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x4507
   15218:	91000000 	add	x0, x0, #0x0
			15218: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x4507
   1521c:	94000000 	bl	0 <printk>
			1521c: R_AARCH64_CALL26	printk
   15220:	f9400368 	ldr	x8, [x27]
			15220: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15224:	b50000a8 	cbnz	x8, 15238 <pre_btwifi_download_sdio+0x750>
   15228:	90000000 	adrp	x0, 0 <__cfi_check>
			15228: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   1522c:	91000000 	add	x0, x0, #0x0
			1522c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15230:	94000000 	bl	0 <printk>
			15230: R_AARCH64_CALL26	printk
   15234:	94000000 	bl	0 <dump_stack>
			15234: R_AARCH64_CALL26	dump_stack
   15238:	90000008 	adrp	x8, 0 <__cfi_check>
			15238: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   1523c:	f9400108 	ldr	x8, [x8]
			1523c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   15240:	f9407500 	ldr	x0, [x8, #232]
   15244:	b4000d60 	cbz	x0, 153f0 <pre_btwifi_download_sdio+0x908>
   15248:	39431508 	ldrb	w8, [x8, #197]
   1524c:	35000d28 	cbnz	w8, 153f0 <pre_btwifi_download_sdio+0x908>
   15250:	94000000 	bl	0 <regulator_is_enabled>
			15250: R_AARCH64_CALL26	regulator_is_enabled
   15254:	34000ce0 	cbz	w0, 153f0 <pre_btwifi_download_sdio+0x908>
   15258:	90000000 	adrp	x0, 0 <__cfi_check>
			15258: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x5760
   1525c:	91000000 	add	x0, x0, #0x0
			1525c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x5760
   15260:	94000000 	bl	0 <printk>
			15260: R_AARCH64_CALL26	printk
   15264:	90000008 	adrp	x8, 0 <__cfi_check>
			15264: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   15268:	f9400108 	ldr	x8, [x8]
			15268: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   1526c:	f9407500 	ldr	x0, [x8, #232]
   15270:	94000000 	bl	0 <regulator_disable>
			15270: R_AARCH64_CALL26	regulator_disable
   15274:	34000be0 	cbz	w0, 153f0 <pre_btwifi_download_sdio+0x908>
   15278:	90000000 	adrp	x0, 0 <__cfi_check>
			15278: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xac84
   1527c:	91000000 	add	x0, x0, #0x0
			1527c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xac84
   15280:	1400005b 	b	153ec <pre_btwifi_download_sdio+0x904>
   15284:	90000008 	adrp	x8, 0 <__cfi_check>
			15284: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4dfd4
   15288:	91000108 	add	x8, x8, #0x0
			15288: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4dfd4
   1528c:	cb080288 	sub	x8, x20, x8
   15290:	93c80908 	ror	x8, x8, #2
   15294:	f100111f 	cmp	x8, #0x4
   15298:	54002c82 	b.cs	15828 <pre_btwifi_download_sdio+0xd40>  // b.hs, b.nlast
   1529c:	d10043a1 	sub	x1, x29, #0x10
   152a0:	2a1303e0 	mov	w0, w19
   152a4:	d63f0280 	blr	x20
   152a8:	2a0003f3 	mov	w19, w0
   152ac:	36fff760 	tbz	w0, #31, 15198 <pre_btwifi_download_sdio+0x6b0>
   152b0:	90000000 	adrp	x0, 0 <__cfi_check>
			152b0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x2eb7
   152b4:	90000001 	adrp	x1, 0 <__cfi_check>
			152b4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe621
   152b8:	91000000 	add	x0, x0, #0x0
			152b8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x2eb7
   152bc:	91000021 	add	x1, x1, #0x0
			152bc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe621
   152c0:	2a1303e2 	mov	w2, w19
   152c4:	94000000 	bl	0 <printk>
			152c4: R_AARCH64_CALL26	printk
   152c8:	17fffe56 	b	14c20 <pre_btwifi_download_sdio+0x138>
   152cc:	f94002c8 	ldr	x8, [x22]
			152cc: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   152d0:	aa1503e1 	mov	x1, x21
   152d4:	f9417100 	ldr	x0, [x8, #736]
   152d8:	94000000 	bl	814c <wcn_write_data_to_phy_addr>
			152d8: R_AARCH64_CALL26	wcn_write_data_to_phy_addr
   152dc:	f94002c8 	ldr	x8, [x22]
			152dc: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   152e0:	b94052a2 	ldr	w2, [x21, #80]
   152e4:	52800020 	mov	w0, #0x1                   	// #1
   152e8:	f9417101 	ldr	x1, [x8, #736]
   152ec:	94000000 	bl	238d4 <wcn_firmware_sec_verify>
			152ec: R_AARCH64_CALL26	wcn_firmware_sec_verify
   152f0:	36f80260 	tbz	w0, #31, 1533c <pre_btwifi_download_sdio+0x854>
   152f4:	90000000 	adrp	x0, 0 <__cfi_check>
			152f4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x94e4
   152f8:	90000001 	adrp	x1, 0 <__cfi_check>
			152f8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   152fc:	91000000 	add	x0, x0, #0x0
			152fc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x94e4
   15300:	91000021 	add	x1, x1, #0x0
			15300: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   15304:	94000000 	bl	0 <printk>
			15304: R_AARCH64_CALL26	printk
   15308:	f85f03a0 	ldur	x0, [x29, #-16]
   1530c:	94000000 	bl	0 <release_firmware>
			1530c: R_AARCH64_CALL26	release_firmware
   15310:	17fffe44 	b	14c20 <pre_btwifi_download_sdio+0x138>
   15314:	2a0003e2 	mov	w2, w0
   15318:	90000000 	adrp	x0, 0 <__cfi_check>
			15318: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xfbd9
   1531c:	90000001 	adrp	x1, 0 <__cfi_check>
			1531c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x119a3
   15320:	91000000 	add	x0, x0, #0x0
			15320: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xfbd9
   15324:	91000021 	add	x1, x1, #0x0
			15324: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x119a3
   15328:	94000000 	bl	0 <printk>
			15328: R_AARCH64_CALL26	printk
   1532c:	f85f03a0 	ldur	x0, [x29, #-16]
   15330:	94000000 	bl	0 <release_firmware>
			15330: R_AARCH64_CALL26	release_firmware
   15334:	9000001c 	adrp	x28, 0 <__cfi_check>
			15334: R_AARCH64_ADR_PREL_PG_HI21	.bss
   15338:	17fffe3a 	b	14c20 <pre_btwifi_download_sdio+0x138>
   1533c:	b9404eb6 	ldr	w22, [x21, #76]
   15340:	aa1603e0 	mov	x0, x22
   15344:	94000000 	bl	0 <vmalloc>
			15344: R_AARCH64_CALL26	vmalloc
   15348:	f85f03a8 	ldur	x8, [x29, #-16]
   1534c:	b50000c0 	cbnz	x0, 15364 <pre_btwifi_download_sdio+0x87c>
   15350:	aa0803e0 	mov	x0, x8
   15354:	94000000 	bl	0 <release_firmware>
			15354: R_AARCH64_CALL26	release_firmware
   15358:	90000000 	adrp	x0, 0 <__cfi_check>
			15358: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x141f8
   1535c:	91000000 	add	x0, x0, #0x0
			1535c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x141f8
   15360:	17fffe5c 	b	14cd0 <pre_btwifi_download_sdio+0x1e8>
   15364:	f9400508 	ldr	x8, [x8, #8]
   15368:	aa1603e2 	mov	x2, x22
   1536c:	aa0003f5 	mov	x21, x0
   15370:	b81ec3b4 	stur	w20, [x29, #-20]
   15374:	91080101 	add	x1, x8, #0x200
   15378:	f9000bf7 	str	x23, [sp, #16]
   1537c:	94000000 	bl	0 <memcpy>
			1537c: R_AARCH64_CALL26	memcpy
   15380:	17fffe64 	b	14d10 <pre_btwifi_download_sdio+0x228>
   15384:	90000000 	adrp	x0, 0 <__cfi_check>
			15384: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x15923
   15388:	91000000 	add	x0, x0, #0x0
			15388: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x15923
   1538c:	94000000 	bl	0 <printk>
			1538c: R_AARCH64_CALL26	printk
   15390:	f9400368 	ldr	x8, [x27]
			15390: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15394:	b4000dc8 	cbz	x8, 1554c <pre_btwifi_download_sdio+0xa64>
   15398:	9000001a 	adrp	x26, 0 <__cfi_check>
			15398: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   1539c:	f9400348 	ldr	x8, [x26]
			1539c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   153a0:	f9407500 	ldr	x0, [x8, #232]
   153a4:	b40017e0 	cbz	x0, 156a0 <pre_btwifi_download_sdio+0xbb8>
   153a8:	39431508 	ldrb	w8, [x8, #197]
   153ac:	350017a8 	cbnz	w8, 156a0 <pre_btwifi_download_sdio+0xbb8>
   153b0:	94000000 	bl	0 <regulator_is_enabled>
			153b0: R_AARCH64_CALL26	regulator_is_enabled
   153b4:	34001760 	cbz	w0, 156a0 <pre_btwifi_download_sdio+0xbb8>
   153b8:	90000000 	adrp	x0, 0 <__cfi_check>
			153b8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x5760
   153bc:	91000000 	add	x0, x0, #0x0
			153bc: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x5760
   153c0:	94000000 	bl	0 <printk>
			153c0: R_AARCH64_CALL26	printk
   153c4:	f9400348 	ldr	x8, [x26]
			153c4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   153c8:	f9407500 	ldr	x0, [x8, #232]
   153cc:	94000000 	bl	0 <regulator_disable>
			153cc: R_AARCH64_CALL26	regulator_disable
   153d0:	34001680 	cbz	w0, 156a0 <pre_btwifi_download_sdio+0xbb8>
   153d4:	90000000 	adrp	x0, 0 <__cfi_check>
			153d4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xac84
   153d8:	91000000 	add	x0, x0, #0x0
			153d8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xac84
   153dc:	94000000 	bl	0 <printk>
			153dc: R_AARCH64_CALL26	printk
   153e0:	140000b0 	b	156a0 <pre_btwifi_download_sdio+0xbb8>
   153e4:	90000000 	adrp	x0, 0 <__cfi_check>
			153e4: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x24ea
   153e8:	91000000 	add	x0, x0, #0x0
			153e8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x24ea
   153ec:	94000000 	bl	0 <printk>
			153ec: R_AARCH64_CALL26	printk
   153f0:	90000008 	adrp	x8, 0 <__cfi_check>
			153f0: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   153f4:	f9400108 	ldr	x8, [x8]
			153f4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   153f8:	b81f03bf 	stur	wzr, [x29, #-16]
   153fc:	90000000 	adrp	x0, 0 <__cfi_check>
			153fc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x8a58
   15400:	91000000 	add	x0, x0, #0x0
			15400: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x8a58
   15404:	79459901 	ldrh	w1, [x8, #716]
   15408:	94000000 	bl	0 <printk>
			15408: R_AARCH64_CALL26	printk
   1540c:	90000000 	adrp	x0, 0 <__cfi_check>
			1540c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x10ec4
   15410:	91000000 	add	x0, x0, #0x0
			15410: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x10ec4
   15414:	52800301 	mov	w1, #0x18                  	// #24
   15418:	94000000 	bl	0 <printk>
			15418: R_AARCH64_CALL26	printk
   1541c:	90000014 	adrp	x20, 0 <__cfi_check>
			1541c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15420:	90000019 	adrp	x25, 0 <__cfi_check>
			15420: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4dfd4
   15424:	5280085b 	mov	w27, #0x42                  	// #66
   15428:	91000294 	add	x20, x20, #0x0
			15428: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   1542c:	91000339 	add	x25, x25, #0x0
			1542c: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4dfd4
   15430:	90000008 	adrp	x8, 0 <__cfi_check>
			15430: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   15434:	f9400108 	ldr	x8, [x8]
			15434: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15438:	b4000408 	cbz	x8, 154b8 <pre_btwifi_download_sdio+0x9d0>
   1543c:	39401d09 	ldrb	w9, [x8, #7]
   15440:	52817615 	mov	w21, #0xbb0                 	// #2992
   15444:	72a80bf5 	movk	w21, #0x405f, lsl #16
   15448:	350000e9 	cbnz	w9, 15464 <pre_btwifi_download_sdio+0x97c>
   1544c:	39401908 	ldrb	w8, [x8, #6]
   15450:	528e7615 	mov	w21, #0x73b0                	// #29616
   15454:	72a80bd5 	movk	w21, #0x405e, lsl #16
   15458:	35000068 	cbnz	w8, 15464 <pre_btwifi_download_sdio+0x97c>
   1545c:	528bf415 	mov	w21, #0x5fa0                	// #24480
   15460:	72a80a55 	movk	w21, #0x4052, lsl #16
   15464:	f9400388 	ldr	x8, [x28]
			15464: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   15468:	b4000168 	cbz	x8, 15494 <pre_btwifi_download_sdio+0x9ac>
   1546c:	f9404d16 	ldr	x22, [x8, #152]
   15470:	b4000136 	cbz	x22, 15494 <pre_btwifi_download_sdio+0x9ac>
   15474:	cb1902c8 	sub	x8, x22, x25
   15478:	93c80908 	ror	x8, x8, #2
   1547c:	f100111f 	cmp	x8, #0x4
   15480:	540002a2 	b.cs	154d4 <pre_btwifi_download_sdio+0x9ec>  // b.hs, b.nlast
   15484:	d10043a1 	sub	x1, x29, #0x10
   15488:	2a1503e0 	mov	w0, w21
   1548c:	d63f02c0 	blr	x22
   15490:	37f80680 	tbnz	w0, #31, 15560 <pre_btwifi_download_sdio+0xa78>
   15494:	b85f03a8 	ldur	w8, [x29, #-16]
   15498:	6b17011f 	cmp	w8, w23
   1549c:	540002a0 	b.eq	154f0 <pre_btwifi_download_sdio+0xa08>  // b.none
   154a0:	52817700 	mov	w0, #0xbb8                 	// #3000
   154a4:	52827101 	mov	w1, #0x1388                	// #5000
   154a8:	94000000 	bl	0 <usleep_range>
			154a8: R_AARCH64_CALL26	usleep_range
   154ac:	7100077b 	subs	w27, w27, #0x1
   154b0:	54fffc01 	b.ne	15430 <pre_btwifi_download_sdio+0x948>  // b.any
   154b4:	14000022 	b	1553c <pre_btwifi_download_sdio+0xa54>
   154b8:	aa1403e0 	mov	x0, x20
   154bc:	94000000 	bl	0 <printk>
			154bc: R_AARCH64_CALL26	printk
   154c0:	94000000 	bl	0 <dump_stack>
			154c0: R_AARCH64_CALL26	dump_stack
   154c4:	90000008 	adrp	x8, 0 <__cfi_check>
			154c4: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   154c8:	f9400108 	ldr	x8, [x8]
			154c8: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   154cc:	b5fffb88 	cbnz	x8, 1543c <pre_btwifi_download_sdio+0x954>
   154d0:	17ffffe3 	b	1545c <pre_btwifi_download_sdio+0x974>
   154d4:	d2897820 	mov	x0, #0x4bc1                	// #19393
   154d8:	f2ba2b60 	movk	x0, #0xd15b, lsl #16
   154dc:	f2c4ad60 	movk	x0, #0x256b, lsl #32
   154e0:	f2efe160 	movk	x0, #0x7f0b, lsl #48
   154e4:	aa1603e1 	mov	x1, x22
   154e8:	94000000 	bl	0 <__cfi_slowpath>
			154e8: R_AARCH64_CALL26	__cfi_slowpath
   154ec:	17ffffe6 	b	15484 <pre_btwifi_download_sdio+0x99c>
   154f0:	90000008 	adrp	x8, 0 <__cfi_check>
			154f0: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   154f4:	f9400108 	ldr	x8, [x8]
			154f4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   154f8:	9000001b 	adrp	x27, 0 <__cfi_check>
			154f8: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   154fc:	79459909 	ldrh	w9, [x8, #716]
   15500:	79058109 	strh	w9, [x8, #704]
   15504:	f9400368 	ldr	x8, [x27]
			15504: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15508:	b50000e8 	cbnz	x8, 15524 <pre_btwifi_download_sdio+0xa3c>
   1550c:	90000000 	adrp	x0, 0 <__cfi_check>
			1550c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15510:	91000000 	add	x0, x0, #0x0
			15510: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15514:	94000000 	bl	0 <printk>
			15514: R_AARCH64_CALL26	printk
   15518:	94000000 	bl	0 <dump_stack>
			15518: R_AARCH64_CALL26	dump_stack
   1551c:	f9400368 	ldr	x8, [x27]
			1551c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15520:	b40000a8 	cbz	x8, 15534 <pre_btwifi_download_sdio+0xa4c>
   15524:	39401d09 	ldrb	w9, [x8, #7]
   15528:	350002e9 	cbnz	w9, 15584 <pre_btwifi_download_sdio+0xa9c>
   1552c:	39401909 	ldrb	w9, [x8, #6]
   15530:	350002e9 	cbnz	w9, 1558c <pre_btwifi_download_sdio+0xaa4>
   15534:	11006314 	add	w20, w24, #0x18
   15538:	14000016 	b	15590 <pre_btwifi_download_sdio+0xaa8>
   1553c:	b85f03a2 	ldur	w2, [x29, #-16]
   15540:	90000000 	adrp	x0, 0 <__cfi_check>
			15540: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xdaa4
   15544:	91000000 	add	x0, x0, #0x0
			15544: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xdaa4
   15548:	14000009 	b	1556c <pre_btwifi_download_sdio+0xa84>
   1554c:	90000000 	adrp	x0, 0 <__cfi_check>
			1554c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15550:	91000000 	add	x0, x0, #0x0
			15550: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15554:	94000000 	bl	0 <printk>
			15554: R_AARCH64_CALL26	printk
   15558:	94000000 	bl	0 <dump_stack>
			15558: R_AARCH64_CALL26	dump_stack
   1555c:	17ffff8f 	b	15398 <pre_btwifi_download_sdio+0x8b0>
   15560:	2a0003e2 	mov	w2, w0
   15564:	90000000 	adrp	x0, 0 <__cfi_check>
			15564: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe632
   15568:	91000000 	add	x0, x0, #0x0
			15568: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe632
   1556c:	90000001 	adrp	x1, 0 <__cfi_check>
			1556c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x3a0d
   15570:	91000021 	add	x1, x1, #0x0
			15570: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x3a0d
   15574:	94000000 	bl	0 <printk>
			15574: R_AARCH64_CALL26	printk
   15578:	9000001b 	adrp	x27, 0 <__cfi_check>
			15578: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   1557c:	9000001a 	adrp	x26, 0 <__cfi_check>
			1557c: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   15580:	14000047 	b	1569c <pre_btwifi_download_sdio+0xbb4>
   15584:	11006274 	add	w20, w19, #0x18
   15588:	14000002 	b	15590 <pre_btwifi_download_sdio+0xaa8>
   1558c:	11006354 	add	w20, w26, #0x18
   15590:	f9400389 	ldr	x9, [x28]
			15590: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   15594:	9000001a 	adrp	x26, 0 <__cfi_check>
			15594: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   15598:	b4000349 	cbz	x9, 15600 <pre_btwifi_download_sdio+0xb18>
   1559c:	f9403d35 	ldr	x21, [x9, #120]
   155a0:	b4000315 	cbz	x21, 15600 <pre_btwifi_download_sdio+0xb18>
   155a4:	f9400348 	ldr	x8, [x26]
			155a4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   155a8:	90000009 	adrp	x9, 0 <__cfi_check>
			155a8: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4e0ac
   155ac:	91000129 	add	x9, x9, #0x0
			155ac: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4e0ac
   155b0:	cb0902a9 	sub	x9, x21, x9
   155b4:	93c90929 	ror	x9, x9, #2
   155b8:	f100193f 	cmp	x9, #0x6
   155bc:	910b0116 	add	x22, x8, #0x2c0
   155c0:	54001422 	b.cs	15844 <pre_btwifi_download_sdio+0xd5c>  // b.hs, b.nlast
   155c4:	52800042 	mov	w2, #0x2                   	// #2
   155c8:	2a1403e0 	mov	w0, w20
   155cc:	aa1603e1 	mov	x1, x22
   155d0:	d63f02a0 	blr	x21
   155d4:	36f800e0 	tbz	w0, #31, 155f0 <pre_btwifi_download_sdio+0xb08>
   155d8:	2a0003e1 	mov	w1, w0
   155dc:	90000000 	adrp	x0, 0 <__cfi_check>
			155dc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x193c
   155e0:	91000000 	add	x0, x0, #0x0
			155e0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x193c
   155e4:	94000000 	bl	0 <printk>
			155e4: R_AARCH64_CALL26	printk
   155e8:	9000001c 	adrp	x28, 0 <__cfi_check>
			155e8: R_AARCH64_ADR_PREL_PG_HI21	.bss
   155ec:	17ffffe3 	b	15578 <pre_btwifi_download_sdio+0xa90>
   155f0:	9000001b 	adrp	x27, 0 <__cfi_check>
			155f0: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x3208
   155f4:	f9400368 	ldr	x8, [x27]
			155f4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   155f8:	9000001c 	adrp	x28, 0 <__cfi_check>
			155f8: R_AARCH64_ADR_PREL_PG_HI21	.bss
   155fc:	9000001a 	adrp	x26, 0 <__cfi_check>
			155fc: R_AARCH64_ADR_PREL_PG_HI21	.bss+0x37e8
   15600:	110006e9 	add	w9, w23, #0x1
   15604:	b81f03a9 	stur	w9, [x29, #-16]
   15608:	b50000e8 	cbnz	x8, 15624 <pre_btwifi_download_sdio+0xb3c>
   1560c:	90000000 	adrp	x0, 0 <__cfi_check>
			1560c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   15610:	91000000 	add	x0, x0, #0x0
			15610: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   15614:	94000000 	bl	0 <printk>
			15614: R_AARCH64_CALL26	printk
   15618:	94000000 	bl	0 <dump_stack>
			15618: R_AARCH64_CALL26	dump_stack
   1561c:	f9400368 	ldr	x8, [x27]
			1561c: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15620:	b40000e8 	cbz	x8, 1563c <pre_btwifi_download_sdio+0xb54>
   15624:	39401d09 	ldrb	w9, [x8, #7]
   15628:	350000e9 	cbnz	w9, 15644 <pre_btwifi_download_sdio+0xb5c>
   1562c:	39401908 	ldrb	w8, [x8, #6]
   15630:	528e7613 	mov	w19, #0x73b0                	// #29616
   15634:	72a80bd3 	movk	w19, #0x405e, lsl #16
   15638:	35000068 	cbnz	w8, 15644 <pre_btwifi_download_sdio+0xb5c>
   1563c:	528bf413 	mov	w19, #0x5fa0                	// #24480
   15640:	72a80a53 	movk	w19, #0x4052, lsl #16
   15644:	f9400388 	ldr	x8, [x28]
			15644: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   15648:	b4000208 	cbz	x8, 15688 <pre_btwifi_download_sdio+0xba0>
   1564c:	f9404914 	ldr	x20, [x8, #144]
   15650:	b40001d4 	cbz	x20, 15688 <pre_btwifi_download_sdio+0xba0>
   15654:	cb190288 	sub	x8, x20, x25
   15658:	93c80908 	ror	x8, x8, #2
   1565c:	f100111f 	cmp	x8, #0x4
   15660:	54001002 	b.cs	15860 <pre_btwifi_download_sdio+0xd78>  // b.hs, b.nlast
   15664:	d10043a1 	sub	x1, x29, #0x10
   15668:	2a1303e0 	mov	w0, w19
   1566c:	d63f0280 	blr	x20
   15670:	36f800c0 	tbz	w0, #31, 15688 <pre_btwifi_download_sdio+0xba0>
   15674:	2a0003e1 	mov	w1, w0
   15678:	90000000 	adrp	x0, 0 <__cfi_check>
			15678: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12e35
   1567c:	91000000 	add	x0, x0, #0x0
			1567c: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12e35
   15680:	94000000 	bl	0 <printk>
			15680: R_AARCH64_CALL26	printk
   15684:	14000006 	b	1569c <pre_btwifi_download_sdio+0xbb4>
   15688:	90000000 	adrp	x0, 0 <__cfi_check>
			15688: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x12e5e
   1568c:	90000001 	adrp	x1, 0 <__cfi_check>
			1568c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x3a0d
   15690:	91000000 	add	x0, x0, #0x0
			15690: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x12e5e
   15694:	91000021 	add	x1, x1, #0x0
			15694: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x3a0d
   15698:	94000000 	bl	0 <printk>
			15698: R_AARCH64_CALL26	printk
   1569c:	94000000 	bl	21240 <mem_pd_save_bin>
			1569c: R_AARCH64_CALL26	mem_pd_save_bin
   156a0:	90000013 	adrp	x19, 0 <__cfi_check>
			156a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x6177
   156a4:	90000018 	adrp	x24, 0 <__cfi_check>
			156a4: R_AARCH64_ADR_PREL_PG_HI21	.text+0x4e0ac
   156a8:	52801936 	mov	w22, #0xc9                  	// #201
   156ac:	91000273 	add	x19, x19, #0x0
			156ac: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x6177
   156b0:	91000318 	add	x24, x24, #0x0
			156b0: R_AARCH64_ADD_ABS_LO12_NC	.text+0x4e0ac
   156b4:	f9400368 	ldr	x8, [x27]
			156b4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   156b8:	b4000488 	cbz	x8, 15748 <pre_btwifi_download_sdio+0xc60>
   156bc:	39401d09 	ldrb	w9, [x8, #7]
   156c0:	52817614 	mov	w20, #0xbb0                 	// #2992
   156c4:	72a80bf4 	movk	w20, #0x405f, lsl #16
   156c8:	350000e9 	cbnz	w9, 156e4 <pre_btwifi_download_sdio+0xbfc>
   156cc:	39401908 	ldrb	w8, [x8, #6]
   156d0:	528e7614 	mov	w20, #0x73b0                	// #29616
   156d4:	72a80bd4 	movk	w20, #0x405e, lsl #16
   156d8:	35000068 	cbnz	w8, 156e4 <pre_btwifi_download_sdio+0xbfc>
   156dc:	528bf414 	mov	w20, #0x5fa0                	// #24480
   156e0:	72a80a54 	movk	w20, #0x4052, lsl #16
   156e4:	f9400388 	ldr	x8, [x28]
			156e4: R_AARCH64_LDST64_ABS_LO12_NC	.bss
   156e8:	b40001a8 	cbz	x8, 1571c <pre_btwifi_download_sdio+0xc34>
   156ec:	f9403915 	ldr	x21, [x8, #112]
   156f0:	b4000175 	cbz	x21, 1571c <pre_btwifi_download_sdio+0xc34>
   156f4:	f9400359 	ldr	x25, [x26]
			156f4: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   156f8:	cb1802a8 	sub	x8, x21, x24
   156fc:	93c80908 	ror	x8, x8, #2
   15700:	f100191f 	cmp	x8, #0x6
   15704:	540002e2 	b.cs	15760 <pre_btwifi_download_sdio+0xc78>  // b.hs, b.nlast
   15708:	910aa321 	add	x1, x25, #0x2a8
   1570c:	52800382 	mov	w2, #0x1c                  	// #28
   15710:	2a1403e0 	mov	w0, w20
   15714:	d63f02a0 	blr	x21
   15718:	37f804e0 	tbnz	w0, #31, 157b4 <pre_btwifi_download_sdio+0xccc>
   1571c:	52817700 	mov	w0, #0xbb8                 	// #3000
   15720:	52827101 	mov	w1, #0x1388                	// #5000
   15724:	94000000 	bl	0 <usleep_range>
			15724: R_AARCH64_CALL26	usleep_range
   15728:	f9400348 	ldr	x8, [x26]
			15728: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   1572c:	11003ae9 	add	w9, w23, #0xe
   15730:	b942a902 	ldr	w2, [x8, #680]
   15734:	6b09005f 	cmp	w2, w9
   15738:	54000220 	b.eq	1577c <pre_btwifi_download_sdio+0xc94>  // b.none
   1573c:	710006d6 	subs	w22, w22, #0x1
   15740:	54fffba1 	b.ne	156b4 <pre_btwifi_download_sdio+0xbcc>  // b.any
   15744:	14000015 	b	15798 <pre_btwifi_download_sdio+0xcb0>
   15748:	aa1303e0 	mov	x0, x19
   1574c:	94000000 	bl	0 <printk>
			1574c: R_AARCH64_CALL26	printk
   15750:	94000000 	bl	0 <dump_stack>
			15750: R_AARCH64_CALL26	dump_stack
   15754:	f9400368 	ldr	x8, [x27]
			15754: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x3208
   15758:	b5fffb28 	cbnz	x8, 156bc <pre_btwifi_download_sdio+0xbd4>
   1575c:	17ffffe0 	b	156dc <pre_btwifi_download_sdio+0xbf4>
   15760:	d2868aa0 	mov	x0, #0x3455                	// #13397
   15764:	f2bba1a0 	movk	x0, #0xdd0d, lsl #16
   15768:	f2ccd9e0 	movk	x0, #0x66cf, lsl #32
   1576c:	f2f996c0 	movk	x0, #0xccb6, lsl #48
   15770:	aa1503e1 	mov	x1, x21
   15774:	94000000 	bl	0 <__cfi_slowpath>
			15774: R_AARCH64_CALL26	__cfi_slowpath
   15778:	17ffffe4 	b	15708 <pre_btwifi_download_sdio+0xc20>
   1577c:	52800028 	mov	w8, #0x1                   	// #1
   15780:	90000009 	adrp	x9, 380c <at_cmd_prepare_buf+0xbc>
			15780: R_AARCH64_ADR_PREL_PG_HI21	flag_download_done
   15784:	39000128 	strb	w8, [x9]
			15784: R_AARCH64_LDST8_ABS_LO12_NC	flag_download_done
   15788:	f9400348 	ldr	x8, [x26]
			15788: R_AARCH64_LDST64_ABS_LO12_NC	.bss+0x37e8
   1578c:	91056100 	add	x0, x8, #0x158
   15790:	94000000 	bl	0 <complete>
			15790: R_AARCH64_CALL26	complete
   15794:	17fffd23 	b	14c20 <pre_btwifi_download_sdio+0x138>
   15798:	b942bd03 	ldr	w3, [x8, #700]
   1579c:	90000000 	adrp	x0, 0 <__cfi_check>
			1579c: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xcec
   157a0:	90000001 	adrp	x1, 0 <__cfi_check>
			157a0: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x716f
   157a4:	91000000 	add	x0, x0, #0x0
			157a4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xcec
   157a8:	91000021 	add	x1, x1, #0x0
			157a8: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x716f
   157ac:	94000000 	bl	0 <printk>
			157ac: R_AARCH64_CALL26	printk
   157b0:	17fffff6 	b	15788 <pre_btwifi_download_sdio+0xca0>
   157b4:	2a0003e2 	mov	w2, w0
   157b8:	90000000 	adrp	x0, 0 <__cfi_check>
			157b8: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0xe632
   157bc:	90000001 	adrp	x1, 0 <__cfi_check>
			157bc: R_AARCH64_ADR_PREL_PG_HI21	.rodata+0x716f
   157c0:	91000000 	add	x0, x0, #0x0
			157c0: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0xe632
   157c4:	91000021 	add	x1, x1, #0x0
			157c4: R_AARCH64_ADD_ABS_LO12_NC	.rodata+0x716f
   157c8:	94000000 	bl	0 <printk>
			157c8: R_AARCH64_CALL26	printk
   157cc:	17ffffef 	b	15788 <pre_btwifi_download_sdio+0xca0>
   157d0:	94000000 	bl	0 <__stack_chk_fail>
			157d0: R_AARCH64_CALL26	__stack_chk_fail
   157d4:	d28488a0 	mov	x0, #0x2445                	// #9285
   157d8:	f2a52480 	movk	x0, #0x2924, lsl #16
   157dc:	f2d487c0 	movk	x0, #0xa43e, lsl #32
   157e0:	f2e05660 	movk	x0, #0x2b3, lsl #48
   157e4:	aa1303e1 	mov	x1, x19
   157e8:	94000000 	bl	0 <__cfi_slowpath>
			157e8: R_AARCH64_CALL26	__cfi_slowpath
   157ec:	17fffd17 	b	14c48 <pre_btwifi_download_sdio+0x160>
   157f0:	d2897820 	mov	x0, #0x4bc1                	// #19393
   157f4:	f2ba2b60 	movk	x0, #0xd15b, lsl #16
   157f8:	f2c4ad60 	movk	x0, #0x256b, lsl #32
   157fc:	f2efe160 	movk	x0, #0x7f0b, lsl #48
   15800:	aa1503e1 	mov	x1, x21
   15804:	94000000 	bl	0 <__cfi_slowpath>
			15804: R_AARCH64_CALL26	__cfi_slowpath
   15808:	17fffe06 	b	15020 <pre_btwifi_download_sdio+0x538>
   1580c:	d2897820 	mov	x0, #0x4bc1                	// #19393
   15810:	f2ba2b60 	movk	x0, #0xd15b, lsl #16
   15814:	f2c4ad60 	movk	x0, #0x256b, lsl #32
   15818:	f2efe160 	movk	x0, #0x7f0b, lsl #48
   1581c:	aa1503e1 	mov	x1, x21
   15820:	94000000 	bl	0 <__cfi_slowpath>
			15820: R_AARCH64_CALL26	__cfi_slowpath
   15824:	17fffe32 	b	150ec <pre_btwifi_download_sdio+0x604>
   15828:	d2897820 	mov	x0, #0x4bc1                	// #19393
   1582c:	f2ba2b60 	movk	x0, #0xd15b, lsl #16
   15830:	f2c4ad60 	movk	x0, #0x256b, lsl #32
   15834:	f2efe160 	movk	x0, #0x7f0b, lsl #48
   15838:	aa1403e1 	mov	x1, x20
   1583c:	94000000 	bl	0 <__cfi_slowpath>
			1583c: R_AARCH64_CALL26	__cfi_slowpath
   15840:	17fffe97 	b	1529c <pre_btwifi_download_sdio+0x7b4>
   15844:	d2868aa0 	mov	x0, #0x3455                	// #13397
   15848:	f2bba1a0 	movk	x0, #0xdd0d, lsl #16
   1584c:	f2ccd9e0 	movk	x0, #0x66cf, lsl #32
   15850:	f2f996c0 	movk	x0, #0xccb6, lsl #48
   15854:	aa1503e1 	mov	x1, x21
   15858:	94000000 	bl	0 <__cfi_slowpath>
			15858: R_AARCH64_CALL26	__cfi_slowpath
   1585c:	17ffff5a 	b	155c4 <pre_btwifi_download_sdio+0xadc>
   15860:	d2897820 	mov	x0, #0x4bc1                	// #19393
   15864:	f2ba2b60 	movk	x0, #0xd15b, lsl #16
   15868:	f2c4ad60 	movk	x0, #0x256b, lsl #32
   1586c:	f2efe160 	movk	x0, #0x7f0b, lsl #48
   15870:	aa1403e1 	mov	x1, x20
   15874:	94000000 	bl	0 <__cfi_slowpath>
			15874: R_AARCH64_CALL26	__cfi_slowpath
   15878:	17ffff7b 	b	15664 <pre_btwifi_download_sdio+0xb7c>

Disassembly of section .init.text:

Disassembly of section .exit.text:
