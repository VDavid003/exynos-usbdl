.text
.global _start
	//set pshold and do an infinite loop, nice for testing if payload runs
	mov x0, #0x330c
	movk x0, #0x1048, lsl #16
	mov w1, #0x5300
	str w1, [x0]
	b .
