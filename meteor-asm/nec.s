.thumb
    .syntax unified

    .global nec


    .text
    .thumb_func

    .equ GIPIO_BASE, 0x50000000
    .equ GPIOTE_BASE, 0x40006000
    .equ GPIOTE_EVENTS_IN_0, 0x100
    .equ GPIOTE_CONFIG_0,  0x510
    .equ GPIOTE_CONFIG_0_CONF, 0x30201
    .equ gtt, 9000

    nec:
        mov r3, #0
        ldr r2, =GPIOTE_BASE
        ldr r1, =0x20201
        str r1, [r2, #GPIOTE_CONFIG_0]

    on_pin_event:
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne wait_for_status_change
        beq on_pin_event

    wait_for_status_change:
        add r3, r3, #1
        mov r1, #0
        str r1, [r2, #GPIOTE_EVENTS_IN_0]
        bl prepare_timer
    wait_for_status_change_inner:
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne capture_time_inf
        b wait_for_status_change_inner

    prepare_timer:
        bl light_timer_reset
        bl start_timer
        b wait_for_status_change_inner

    capture_time_inf:
        @ cmp r3, #1
        @ beq ccc
        bl capture_time
        bl get_cc_1
        ldr r9, =gtt
        cmp r1, r9
        bgt yes
        b wait_for_status_change
        @ bl capture_time

    yes:
        mov r8, #55
        mov r10, r3
        b wait_for_status_change
    ccc:
        bl capture_time
        @ add r3, r3, #1
        b wait_for_status_change

    @ nec:
    @     ldr R0, =GIPIO_BASE // load the DIRSET register to R0
    @     mov r4, r0
    @     @ ldr R1, [R0] // load R0 contents to R1

    @     @ orr R1, #(1<<2) // set bit 2 of DIRSET to 1
    @     @ orr R1, #(1<<3) // set bit 3 of DIRSET to 1
    @     @ str R1, [R0, #0x518] // store the new value of R1 to R0, this will set microbit pin 0 and 1 to ouput

    @     ldr R1, [R0, #0x514]
    @     bic R1, #(1<<2)
    @     str R1, [R0, #0x514] // set pin 2 of micro bit to input

    @     // in order for the input pin to work one must enable the input buffer in the PIN_CNF[n] register
    @     // (where n is the pin number), one must also specify if the input will be pulldown or pullup to get
    @     // reproducible behavior (this is also configured in the PIN_CNF[n] register)
    @     ldr r1, [r0, #0x708]
    @     mov r1, #0x0
    @     str r1, [r0, #0x708] // enables pin 2 input buffer and configure pulldown resistor


    @     b take_time
    @     mov r8, #1

    @     bl reset_timer
    @     bx lr

    @ take_time:
    @     ldr r1, [r4, #510]
    @ take_time_inner:
    @     tst r8, #0
    @     bne loop2
    @     tst r1, #4
    @     beq take_time_inner
    @     bl capture_time
    @     sub r8, r8, #1
    @     b take_time_inner

    @ loop2:
    @     mov r5, #1
    @     b loop2


