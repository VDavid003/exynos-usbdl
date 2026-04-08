.text
.global _start

//Dump bootrom, but reinit USB so that we don't have to deal with the USB setup we broke using the GET CONFIGURATION exploit
//For some reason we need to receive some dummy data before we can successfully send the bootrom..
_start:
    //set pshold
    mov     x0, #0x330c
    movk    x0, #0x1406, lsl #16
    mov     w1, #0x5300
    str     w1, [x0]

    //USB reinit function
    mov     x0, #0x00e0
    movk    x0, #0x0202, lsl #16
    mov     x3, #0x0
    ldr     w3, [x0]
    //Bootrom uses this address as a struct of some sort
    mov     x0, #0x1000
    movk    x0, #0x0202, lsl #16
    mov     x1, #300 //Some kind of delay, stock value
    mov     x2, #0x0 //speed: We assume 2.0 fullspeed
    blr     x3

    //USB receive function needed for some reason, we do a dummy receive then send
    mov     x0, #0x00dc
    movk    x0, #0x0202, lsl #16
    mov     x3, #0x0
    ldr     w3, [x0]
    //Receive address
    mov     x0, #0x4800
    movk    x0, #0x0202, lsl #16
    mov     x1, #0x3000
    blr     x3

    //Actually send bl
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
    movk    x1, #0x10c0, lsl #16
    str     w2, [x1]

    //depcmdpar0 (dwc3)
    mov     x1, #0xc838
    movk    x1, #0x10c0, lsl #16
    str     wzr, [x1]

    //depcmd (dwc3)
    mov     x1, #0xc83c //DEPCMD EP3
    movk    x1, #0x10c0, lsl #16
    mov     w2, #0x406 //STARTTRANSFER CMDACT
    str     w2, [x1]

    // infin loop lol
    b .
