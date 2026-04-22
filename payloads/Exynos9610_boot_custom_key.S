.text
.global _start

//Boot using a custom secure boot key.
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
_dst_ptr: .dword 0x02049000


_stage2:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1186, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    //set key ptr
    mov     x0, #0x006c
    movk    x0, #0x0202, lsl #16
    adr x1, key
    str     w1, [x0]

    //restore stack
    ldp x19, x20, [sp, #0x10]
    ldp x21, x29, [sp, #0x20]
    ldr x30, [sp, #0x30]
    add sp, sp, #0x40
    ldp x19, x20, [sp, #0x10]
    ldp x29, x30, [sp, #0x20]
    add sp, sp, #0x30
    ldp x19, x20, [sp]
    ldp x29, x30, [sp, #0x10]
    add sp, sp, #0x20
    ldp x19, x20, [sp]
    ldp x21, x29, [sp, #0x10]
    ldr x30, [sp, #0x20]
    add sp, sp, #0x30

    //clear cache
    dsb sy
    ic iallu
    dsb sy
    isb

    //re-run load bl1 from usb function by going back one instruction
    sub x30, x30, #4
    //return to the modified address
    ret

.align 4
key:
.include "inc/sha256key.S"
