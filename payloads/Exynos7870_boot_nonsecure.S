.text
.global _start

//Boot unsigned BL1 binaries.
//NOTE: This payload was designed to use the new exploit, so the "e2" parameter, not the old one!
_start:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1048, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    //disable secure boot in PMU register
    mov     x0, #0x0980
    movk    x0, #0x1048, lsl #16
    ldr     w1, [x0]
    bic     w1, w1, #0x10000 //bit 16: secure boot
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

    //disable secure boot in CPU register
    mov     w20, #0
    
    //clear cache
    dsb sy
    ic iallu
    dsb sy
    isb

    //jump back to loading BL1
    br x19
