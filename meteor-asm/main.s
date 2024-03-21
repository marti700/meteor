.thumb
    .syntax unified
    .global main

    .text
    .thumb_func

    .equ TWI_BASE, 0x40003000
    .equ STARTTX, 0x008
    .equ TASk_STOP, 0x014
    .equ SCL, 0x508
    .equ SDA,  0x50C
    .equ TXD, 0x51C
    .equ FREQUENCY,  0x524
    .equ ADDRESS,  0x588
    .equ ENABLE, 0x500
    .equ LED6_ON, 0x1F
    .equ TXDSENT, 0x11C
    .equ ERROR, 0X124

    main:
        ldr R0, =TWI_BASE // load the DIRSET register to R0
        // set SCL to 26 (this is pin 19 on the microbit)
        ldr R1, [R0, #SCL] // load R0 contents to R1
        mov r1, #0x1A
        @ bic r1, #(1<<31)
        @ bic r1, #(1<<5)
        @ @ bic r1, (1<<4)
        @ bic r1, #(1<<2)
        @ bic r1, #(1<<0)
        str r1, [r0, #SCL]

        //set sda to pin 0 of port 1 (this is pin 20 in the microbit)
        ldr R1, [R0, #SDA] // load R0 contents to R1
        mov r1, #0x20
        @ bic r1, #(1<<31)
        @ bic r1, #(1<<5)
        @ bic r1, #(1<<4)
        @ bic r1, #(1<<3)
        @ bic r1, #(1<<2)
        @ bic r1, #(1<<1)
        @ bic r1, #(1<<0)
        str r1, [r0, #SDA]

        // set frecuency to 100kbps
        mov r1, #0x01980000
        str r1, [r0, #FREQUENCY]

        // enable TWI
        mov r1, #5
        str r1, [r0, #ENABLE]

        // set the slave address and the write bit (0)
        mov r1, #0x40
        str r1, [r0, #ADDRESS]

        mov r1, #0
        str r1, [r0, #TXD]

        // start transmision
        mov r1, #1
        str r1, [r0, #STARTTX]

        mov r1, #0
        str r1, [r0, #TXDSENT]

        @ mov r1, #1
        @ str r1, [r0, #STARTTX]

        // set the address of the led6_on register
        mov r1, #LED6_ON
        str r1, [r0, #ADDRESS]

        // write 1 to the register
        mov r1, #0x10
        str r1, [r0, TXD]

        // start transmision
        mov r1, #1
        str r1, [r0, #STARTTX]


        b main
