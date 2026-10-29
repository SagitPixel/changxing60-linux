
/repo/baseline/wifi-resume-20261028/sprd_wlan_combo-native-msdu.ko:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000027c68 <sc2355_hif_fill_msdu_dscr>:
   27c68:	d503201f 	nop
   27c6c:	d503201f 	nop
   27c70:	d101c3ff 	sub	sp, sp, #0x70
   27c74:	a9017bfd 	stp	x29, x30, [sp, #16]
   27c78:	f90013fb 	str	x27, [sp, #32]
   27c7c:	a90367fa 	stp	x26, x25, [sp, #48]
   27c80:	a9045ff8 	stp	x24, x23, [sp, #64]
   27c84:	a90557f6 	stp	x22, x21, [sp, #80]
   27c88:	a9064ff4 	stp	x20, x19, [sp, #96]
   27c8c:	910043fd 	add	x29, sp, #0x10
   27c90:	f9406437 	ldr	x23, [x1, #200]
   27c94:	2a0203f5 	mov	w21, w2
   27c98:	aa0103f3 	mov	x19, x1
   27c9c:	aa0003f4 	mov	x20, x0
   27ca0:	52800099 	mov	w25, #0x4                   	// #4
   27ca4:	390073bf 	strb	wzr, [x29, #28]
   27ca8:	79401ae8 	ldrh	w8, [x23, #12]
   27cac:	7118211f 	cmp	w8, #0x608
   27cb0:	54000140 	b.eq	27cd8 <sc2355_hif_fill_msdu_dscr+0x70>  // b.none
   27cb4:	7136251f 	cmp	w8, #0xd89
   27cb8:	54000100 	b.eq	27cd8 <sc2355_hif_fill_msdu_dscr+0x70>  // b.none
   27cbc:	5298f109 	mov	w9, #0xc788                	// #51080
   27cc0:	aa1703e2 	mov	x2, x23
   27cc4:	6b09011f 	cmp	w8, w9
   27cc8:	540000a0 	b.eq	27cdc <sc2355_hif_fill_msdu_dscr+0x74>  // b.none
   27ccc:	72001ebf 	tst	w21, #0xff
   27cd0:	540010c0 	b.eq	27ee8 <sc2355_hif_fill_msdu_dscr+0x280>  // b.none
   27cd4:	2a1f03f9 	mov	w25, wzr
   27cd8:	aa1703e2 	mov	x2, x23
   27cdc:	f9446698 	ldr	x24, [x20, #2248]
   27ce0:	aa1403e1 	mov	x1, x20
   27ce4:	91002300 	add	x0, x24, #0x8
   27ce8:	94000000 	bl	278c8 <sc2355_find_lut_index>
   27cec:	12001c03 	and	w3, w0, #0xff
   27cf0:	2a0003f6 	mov	w22, w0
   27cf4:	7100147f 	cmp	w3, #0x5
   27cf8:	54000488 	b.hi	27d88 <sc2355_hif_fill_msdu_dscr+0x120>  // b.pmore
   27cfc:	b948e282 	ldr	w2, [x20, #2272]
   27d00:	7100285f 	cmp	w2, #0xa
   27d04:	54000248 	b.hi	27d4c <sc2355_hif_fill_msdu_dscr+0xe4>  // b.pmore
   27d08:	52800028 	mov	w8, #0x1                   	// #1
   27d0c:	52808449 	mov	w9, #0x422                 	// #1058
   27d10:	1ac22108 	lsl	w8, w8, w2
   27d14:	6a09011f 	tst	w8, w9
   27d18:	540001a0 	b.eq	27d4c <sc2355_hif_fill_msdu_dscr+0xe4>  // b.none
   27d1c:	90000008 	adrp	x8, 8a0 <sprd_cfg80211_del_iface+0x28>
   27d20:	b9400108 	ldr	w8, [x8]
   27d24:	36f81028 	tbz	w8, #31, 27f28 <sc2355_hif_fill_msdu_dscr+0x2c0>
   27d28:	aa1f03e0 	mov	x0, xzr
   27d2c:	aa1303e1 	mov	x1, x19
   27d30:	52800042 	mov	w2, #0x2                   	// #2
   27d34:	94000000 	bl	0 <sk_skb_reason_drop>
   27d38:	90000008 	adrp	x8, 8a0 <sprd_cfg80211_del_iface+0x28>
   27d3c:	b9400108 	ldr	w8, [x8]
   27d40:	36f80e48 	tbz	w8, #31, 27f08 <sc2355_hif_fill_msdu_dscr+0x2a0>
   27d44:	12800000 	mov	w0, #0xffffffff            	// #-1
   27d48:	14000060 	b	27ec8 <sc2355_hif_fill_msdu_dscr+0x260>
   27d4c:	f9406668 	ldr	x8, [x19, #200]
   27d50:	39400108 	ldrb	w8, [x8]
   27d54:	370001a8 	tbnz	w8, #0, 27d88 <sc2355_hif_fill_msdu_dscr+0x120>
   27d58:	f9446688 	ldr	x8, [x20, #2248]
   27d5c:	5288ac09 	mov	w9, #0x4560                	// #17760
   27d60:	b8696908 	ldr	w8, [x8, x9]
   27d64:	36fffe28 	tbz	w8, #31, 27d28 <sc2355_hif_fill_msdu_dscr+0xc0>
   27d68:	321e0048 	orr	w8, w2, #0x4
   27d6c:	7100191f 	cmp	w8, #0x6
   27d70:	54000f61 	b.ne	27f5c <sc2355_hif_fill_msdu_dscr+0x2f4>  // b.any
   27d74:	12001ec8 	and	w8, w22, #0xff
   27d78:	71000d1f 	cmp	w8, #0x3
   27d7c:	54000060 	b.eq	27d88 <sc2355_hif_fill_msdu_dscr+0x120>  // b.none
   27d80:	7100151f 	cmp	w8, #0x5
   27d84:	54000ec1 	b.ne	27f5c <sc2355_hif_fill_msdu_dscr+0x2f4>  // b.any
   27d88:	aa1303e0 	mov	x0, x19
   27d8c:	52800161 	mov	w1, #0xb                   	// #11
   27d90:	5280017b 	mov	w27, #0xb                   	// #11
   27d94:	94000000 	bl	0 <skb_push>
   27d98:	72001ebf 	tst	w21, #0xff
   27d9c:	f940667a 	ldr	x26, [x19, #200]
   27da0:	1a9f07e8 	cset	w8, ne	// ne = any
   27da4:	531f7908 	lsl	w8, w8, #1
   27da8:	f800135f 	stur	xzr, [x26, #1]
   27dac:	7800935f 	sturh	wzr, [x26, #9]
   27db0:	39000348 	strb	w8, [x26]
   27db4:	39639289 	ldrb	w9, [x20, #2276]
   27db8:	2a091508 	orr	w8, w8, w9, lsl #5
   27dbc:	90000009 	adrp	x9, 8 <sprd_load_fw>
   27dc0:	39000348 	strb	w8, [x26]
   27dc4:	7940e268 	ldrh	w8, [x19, #112]
   27dc8:	39400129 	ldrb	w9, [x9]
   27dcc:	3900075b 	strb	w27, [x26, #1]
   27dd0:	51002d08 	sub	w8, w8, #0xb
   27dd4:	78003348 	sturh	w8, [x26, #3]
   27dd8:	340000a9 	cbz	w9, 27dec <sc2355_hif_fill_msdu_dscr+0x184>
   27ddc:	b9403f08 	ldr	w8, [x24, #60]
   27de0:	7100091f 	cmp	w8, #0x2
   27de4:	54000041 	b.ne	27dec <sc2355_hif_fill_msdu_dscr+0x184>  // b.any
   27de8:	2a1f03f9 	mov	w25, wzr
   27dec:	39000b59 	strb	w25, [x26, #2]
   27df0:	39001b56 	strb	w22, [x26, #6]
   27df4:	b97dcf01 	ldr	w1, [x24, #15820]
   27df8:	7100043f 	cmp	w1, #0x1
   27dfc:	5400028b 	b.lt	27e4c <sc2355_hif_fill_msdu_dscr+0x1e4>  // b.tstop
   27e00:	aa1303e0 	mov	x0, x19
   27e04:	94000000 	bl	0 <skb_push>
   27e08:	f9406660 	ldr	x0, [x19, #200]
   27e0c:	d2c01008 	mov	x8, #0x8000000000          	// #549755813888
   27e10:	90000009 	adrp	x9, 0 <memstart_addr>
   27e14:	9000000a 	adrp	x10, 0 <kimage_voffset>
   27e18:	f9400129 	ldr	x9, [x9]
   27e1c:	b9bdcf02 	ldrsw	x2, [x24, #15820]
   27e20:	8b080008 	add	x8, x0, x8
   27e24:	f940014a 	ldr	x10, [x10]
   27e28:	910023e1 	add	x1, sp, #0x8
   27e2c:	d366fd0b 	lsr	x11, x8, #38
   27e30:	8b090108 	add	x8, x8, x9
   27e34:	cb0a0009 	sub	x9, x0, x10
   27e38:	f100017f 	cmp	x11, #0x0
   27e3c:	9a890108 	csel	x8, x8, x9, eq	// eq = none
   27e40:	b2590108 	orr	x8, x8, #0x8000000000
   27e44:	f90007e8 	str	x8, [sp, #8]
   27e48:	94000000 	bl	0 <memcpy>
   27e4c:	39420268 	ldrb	w8, [x19, #128]
   27e50:	52800c09 	mov	w9, #0x60                  	// #96
   27e54:	6a28013f 	bics	wzr, w9, w8
   27e58:	54000361 	b.ne	27ec4 <sc2355_hif_fill_msdu_dscr+0x25c>  // b.any
   27e5c:	39400b48 	ldrb	w8, [x26, #2]
   27e60:	529bb0cc 	mov	w12, #0xdd86                	// #56710
   27e64:	32000108 	orr	w8, w8, #0x1
   27e68:	39000b48 	strb	w8, [x26, #2]
   27e6c:	121e7908 	and	w8, w8, #0xfffffffd
   27e70:	79401ae9 	ldrh	w9, [x23, #12]
   27e74:	f940626a 	ldr	x10, [x19, #192]
   27e78:	79416a6b 	ldrh	w11, [x19, #180]
   27e7c:	6b0c013f 	cmp	w9, w12
   27e80:	52800129 	mov	w9, #0x9                   	// #9
   27e84:	528000cc 	mov	w12, #0x6                   	// #6
   27e88:	8b0b014a 	add	x10, x10, x11
   27e8c:	9a890189 	csel	x9, x12, x9, eq	// eq = none
   27e90:	38696943 	ldrb	w3, [x10, x9]
   27e94:	7100187f 	cmp	w3, #0x6
   27e98:	1a9f17e9 	cset	w9, eq	// eq = none
   27e9c:	2a090508 	orr	w8, w8, w9, lsl #1
   27ea0:	39000b48 	strb	w8, [x26, #2]
   27ea4:	90000008 	adrp	x8, 8a0 <sprd_cfg80211_del_iface+0x28>
   27ea8:	79416669 	ldrh	w9, [x19, #178]
   27eac:	79416e6a 	ldrh	w10, [x19, #182]
   27eb0:	b940010b 	ldr	w11, [x8]
   27eb4:	4b0a0128 	sub	w8, w9, w10
   27eb8:	7100117f 	cmp	w11, #0x4
   27ebc:	78009348 	sturh	w8, [x26, #9]
   27ec0:	5400040a 	b.ge	27f40 <sc2355_hif_fill_msdu_dscr+0x2d8>  // b.tcont
   27ec4:	2a1f03e0 	mov	w0, wzr
   27ec8:	a9464ff4 	ldp	x20, x19, [sp, #96]
   27ecc:	f94013fb 	ldr	x27, [sp, #32]
   27ed0:	a94557f6 	ldp	x22, x21, [sp, #80]
   27ed4:	a9445ff8 	ldp	x24, x23, [sp, #64]
   27ed8:	a94367fa 	ldp	x26, x25, [sp, #48]
   27edc:	a9417bfd 	ldp	x29, x30, [sp, #16]
   27ee0:	9101c3ff 	add	sp, sp, #0x70
   27ee4:	d65f03c0 	ret
   27ee8:	910073a1 	add	x1, x29, #0x1c
   27eec:	aa1303e0 	mov	x0, x19
   27ef0:	94000000 	bl	3b110 <sc2355_is_vowifi_pkt>
   27ef4:	52800088 	mov	w8, #0x4                   	// #4
   27ef8:	7200001f 	tst	w0, #0x1
   27efc:	f9406662 	ldr	x2, [x19, #200]
   27f00:	1a9f1119 	csel	w25, w8, wzr, ne	// ne = any
   27f04:	17ffff76 	b	27cdc <sc2355_hif_fill_msdu_dscr+0x74>
   27f08:	90000000 	adrp	x0, 0 <sprd_load_fw-0x8>
   27f0c:	91000000 	add	x0, x0, #0x0
   27f10:	90000001 	adrp	x1, 0 <sprd_load_fw-0x8>
   27f14:	91000021 	add	x1, x1, #0x0
   27f18:	5281baa2 	mov	w2, #0xdd5                 	// #3541
   27f1c:	94000000 	bl	0 <_printk>
   27f20:	12800000 	mov	w0, #0xffffffff            	// #-1
   27f24:	17ffffe9 	b	27ec8 <sc2355_hif_fill_msdu_dscr+0x260>
   27f28:	90000000 	adrp	x0, 0 <sprd_load_fw-0x8>
   27f2c:	91000000 	add	x0, x0, #0x0
   27f30:	90000001 	adrp	x1, 0 <sprd_load_fw-0x8>
   27f34:	91000021 	add	x1, x1, #0x0
   27f38:	94000000 	bl	0 <_printk>
   27f3c:	17ffff7b 	b	27d28 <sc2355_hif_fill_msdu_dscr+0xc0>
   27f40:	90000000 	adrp	x0, 0 <sprd_load_fw-0x8>
   27f44:	91000000 	add	x0, x0, #0x0
   27f48:	90000001 	adrp	x1, 0 <sprd_load_fw-0x8>
   27f4c:	91000021 	add	x1, x1, #0x0
   27f50:	12003d02 	and	w2, w8, #0xffff
   27f54:	94000000 	bl	0 <_printk>
   27f58:	17ffffdb 	b	27ec4 <sc2355_hif_fill_msdu_dscr+0x25c>
   27f5c:	90000008 	adrp	x8, 8a0 <sprd_cfg80211_del_iface+0x28>
   27f60:	b9400108 	ldr	w8, [x8]
   27f64:	37ffee28 	tbnz	w8, #31, 27d28 <sc2355_hif_fill_msdu_dscr+0xc0>
   27f68:	90000000 	adrp	x0, 0 <sprd_load_fw-0x8>
   27f6c:	91000000 	add	x0, x0, #0x0
   27f70:	17fffff0 	b	27f30 <sc2355_hif_fill_msdu_dscr+0x2c8>

Disassembly of section .init.text:

Disassembly of section .exit.text:
