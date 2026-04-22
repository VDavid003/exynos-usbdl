.text
.global _start

//Boot unsigned BL1 binaries.
_start:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1186, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    //disable secure boot in IRAM variable
    mov     x0, #0x0070
    movk    x0, #0x0202, lsl #16
    ldr     w1, [x0]
    bic     w1, w1, #0x4 //bit 2: secure boot
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

    //disable secure-boot in stack
    mov x0, #0
    str x0, [sp, #0x8]

    //clear cache
    dsb sy
    ic iallu
    dsb sy
    isb

    //re-run load bl1 from usb function by going back one instruction
    sub x30, x30, #4
    //return to the modified address
    ret
