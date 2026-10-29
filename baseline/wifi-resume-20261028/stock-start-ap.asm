
/repo/baseline/wifi-resume-20261028/stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko:     file format elf64-littleaarch64


Disassembly of section .plt:

Disassembly of section .init.plt:

Disassembly of section .text.ftrace_trampoline:

Disassembly of section .text:

000000000001fa24 <sc2355_start_ap>:
   1fa24:	f800865e 	str	x30, [x18], #8
   1fa28:	a9bc7bfd 	stp	x29, x30, [sp, #-64]!
   1fa2c:	f9000bf7 	str	x23, [sp, #16]
   1fa30:	a90257f6 	stp	x22, x21, [sp, #32]
   1fa34:	a9034ff4 	stp	x20, x19, [sp, #48]
   1fa38:	910003fd 	mov	x29, sp
   1fa3c:	f940ec28 	ldr	x8, [x1, #472]
   1fa40:	f9667c09 	ldr	x9, [x0, #19704]
   1fa44:	2a0303f5 	mov	w21, w3
   1fa48:	aa0203f4 	mov	x20, x2
   1fa4c:	b9403d0a 	ldr	w10, [x8, #60]
   1fa50:	39408d28 	ldrb	w8, [x9, #35]
   1fa54:	aa0103f6 	mov	x22, x1
   1fa58:	aa0003f3 	mov	x19, x0
   1fa5c:	71000d5f 	cmp	w10, #0x3
   1fa60:	11000877 	add	w23, w3, #0x2
   1fa64:	54000081 	b.ne	1fa74 <sc2355_start_ap+0x50>  // b.any
   1fa68:	39408929 	ldrb	w9, [x9, #34]
   1fa6c:	6b09011f 	cmp	w8, w9
   1fa70:	1a893108 	csel	w8, w8, w9, cc	// cc = lo, ul, last
   1fa74:	b941f2c9 	ldr	w9, [x22, #496]
   1fa78:	7100093f 	cmp	w9, #0x2
   1fa7c:	54000121 	b.ne	1faa0 <sc2355_start_ap+0x7c>  // b.any
   1fa80:	f9423ec9 	ldr	x9, [x22, #1144]
   1fa84:	7100051f 	cmp	w8, #0x1
   1fa88:	540000c1 	b.ne	1faa0 <sc2355_start_ap+0x7c>  // b.any
   1fa8c:	9111e2c8 	add	x8, x22, #0x478
   1fa90:	eb09011f 	cmp	x8, x9
   1fa94:	54000060 	b.eq	1faa0 <sc2355_start_ap+0x7c>  // b.none
   1fa98:	aa1603e0 	mov	x0, x22
   1fa9c:	94000000 	bl	2c9d4 <clean_survey_info_list>
			1fa9c: R_AARCH64_CALL26	clean_survey_info_list
   1faa0:	52800223 	mov	w3, #0x11                  	// #17
   1faa4:	52800024 	mov	w4, #0x1                   	// #1
   1faa8:	52819805 	mov	w5, #0xcc0                 	// #3264
   1faac:	aa1303e0 	mov	x0, x19
   1fab0:	aa1603e1 	mov	x1, x22
   1fab4:	2a1703e2 	mov	w2, w23
   1fab8:	94000000 	bl	1c594 <sc2355_get_cmdbuf>
			1fab8: R_AARCH64_CALL26	sc2355_get_cmdbuf
   1fabc:	b40001c0 	cbz	x0, 1faf4 <sc2355_start_ap+0xd0>
   1fac0:	aa0003f6 	mov	x22, x0
   1fac4:	f9400c00 	ldr	x0, [x0, #24]
   1fac8:	92403ea2 	and	x2, x21, #0xffff
   1facc:	aa1403e1 	mov	x1, x20
   1fad0:	78002415 	strh	w21, [x0], #2
   1fad4:	94000000 	bl	0 <memcpy>
			1fad4: R_AARCH64_CALL26	memcpy
   1fad8:	52817704 	mov	w4, #0xbb8                 	// #3000
   1fadc:	aa1303e0 	mov	x0, x19
   1fae0:	aa1603e1 	mov	x1, x22
   1fae4:	aa1f03e2 	mov	x2, xzr
   1fae8:	aa1f03e3 	mov	x3, xzr
   1faec:	94000000 	bl	1c8e4 <sc2355_send_cmd_recv_rsp>
			1faec: R_AARCH64_CALL26	sc2355_send_cmd_recv_rsp
   1faf0:	14000002 	b	1faf8 <sc2355_start_ap+0xd4>
   1faf4:	12800160 	mov	w0, #0xfffffff4            	// #-12
   1faf8:	a9434ff4 	ldp	x20, x19, [sp, #48]
   1fafc:	a94257f6 	ldp	x22, x21, [sp, #32]
   1fb00:	f9400bf7 	ldr	x23, [sp, #16]
   1fb04:	a8c47bfd 	ldp	x29, x30, [sp], #64
   1fb08:	f85f8e5e 	ldr	x30, [x18, #-8]!
   1fb0c:	d65f03c0 	ret

Disassembly of section .init.text:

Disassembly of section .exit.text:
