    .thumb
    .syntax unified
    .global main

    .text
    .thumb_func

    .equ onesecond, 1000000
    .equ TIMER0_BASE, 0x40008000
    .equ GIPIO_BASE, 0x50000000
    .equ TIMER_PRESCALER, 4

    main:
        bl init_gpio
        bl reset_timer
        bl start_timer
        bl blink_loop

    init_gpio:
        ldr R0, =GIPIO_BASE // load the DIRSET register to R0
        ldr R1, [R0] // load R0 contents to R1
        orr R1, #(1<<2) // set bit 2 of DIRSET to 1
        str R1, [R0, #0x518] // store the new value of R1 to R0, this will set pin 2 to ouput
        bx lr

    reset_timer:
        ldr r0, =TIMER0_BASE
        @ do and r1, #(1<<0) instead?
        mov r1, #0
        str r1, [r0, #0x004] // stop timer
        str r1, [r0, #0x00C] // clear timer
        str r1, [r0, #0x140] // clear events

        ldr r1, =TIMER_PRESCALER
        str r1, [r0, #0x510]

        @ set caputure register to onesecond
        ldr r1, =onesecond
        str r1, [r0, #0x540]

        @ set bit mode
        mov r1, #3
        str r1, [r0, #0x508]

        bx lr
    
    start_timer:
        ldr r0, =TIMER0_BASE
        @ do and r1, #(1<<0) instead?
        mov r1, #1
        str r1, [r0, #0x000]

        bx lr
    
    blink_loop:
        @ ldr r2, =0x40008140
        @ ldr r3, =0x40008540
        @ ldr r4, =0x50000504
        ldr r1, [r0, #0x140]
        tst r1, #1
        beq blink_loop

        bl toggle_led
        bl reset_timer
        bl start_timer
        b blink_loop

    toggle_led:
        ldr R0, =GIPIO_BASE // load OUT register to R0
        ldr R1, [R0] // load contents of R0 to R1
        eor R1, #(1<<2) // toogle bit 2 of OUT register on/off
        str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
        bx lr

 