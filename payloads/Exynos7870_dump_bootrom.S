.text
.global _start

//Heavily modified from 8890 bootrom dump payload I think
//Made it a lot more understandable and less dependent on random things

_start:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1048, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    mov     w1, #0x20000 // size
    mov     w0, #0x0 // address
    bl      usb_send

    mov     x0, #0
    br      x0 //reset

usb_send:
    stp     x29, x30, [sp,#0x10]!

    //only this part is size
    and     w1, w1, #0x00ffffff

    //custom trb ptr (just a random place in iram)
    mov     x2, #0x4800
    movk    x2, #0x0202, lsl #16

    //set up trb
    mov     w3, #0xc13
    stp     w1, w3, [x2,#8]
    stp     w0, wzr, [x2]

    //depcmdpar1 (dwc3)
    mov     x1, #0xc834
    movk    x1, #0x1360, lsl #16
    str     w2, [x1]

    //depcmdpar0 (dwc3)
    mov     x1, #0xc838
    movk    x1, #0x1360, lsl #16
    str     wzr, [x1]

    //depcmd (dwc3)
    mov     x1, #0xc83c //DEPCMD EP3
    movk    x1, #0x1360, lsl #16
    mov     w2, #0x406 //STARTTRANSFER CMDACT
    str     w2, [x1]

    //wait a second
    //this can safely be replaced with an infinite loop (b .) when porting to an other soc and you have no bootrom dump to get the address from
    //with infinite loop, stack (stp ldp at top/bottom) is not needed either if that helps
    mov     x0, #1
    mov     x1, #1000
    mov     x2, #0x1eb8
    blr     x2

    ldp     x29, x30, [sp],#0x10
    ret
