.thumb
    .syntax unified
    .global prepare_for_ir_transmission
    .global on_transmission_start
    .global rc_pin_pulled_low

    .text
    .thumb_func

    .equ GIPIO_BASE,                  0x50000000
    .equ GPIOTE_BASE,                 0x40006000
    .equ GPIOTE_EVENTS_IN_0,          0x100
    .equ GPIOTE_CONFIG_0,             0x510
    .equ GPIOTE_CONFIG_0_CONF,        0x20201
    .equ NINE_SECONDS,                9000

    rc_pin_pulled_low:
        ldr r2, =GPIOTE_BASE
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        bx lr


    prepare_for_ir_transmission:
        mov r8, #0
        ldr r2, =GPIOTE_BASE
        ldr r1, =GPIOTE_CONFIG_0_CONF
        str r1, [r2, #GPIOTE_CONFIG_0]
        bx lr

    on_transmission_start:
        push {lr}
        mov r5, #0
    on_transmission_start_inner:
        ldr r2, =GPIOTE_BASE
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne wait_for_status_change
        beq on_transmission_start_inner

    wait_for_status_change:
        cmp r8, #32
        beq end_of_message
        @ mov r1, #0
        @ str r1, [r2, #GPIOTE_EVENTS_IN_0]
        bl clear_pin_evt
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
        ldr r4, =NINE_SECONDS
        cmp r1, r4
        bgt wait_for_status_change
        cmp r1, #1600
        blt add_zero
        bgt add_one

    add_zero:
        lsl r5, 1
        orr r5, #(0<<0)
        add r8, r8, #1
        b wait_for_status_change
    add_one:
        lsl r5, 1
        orr r5, #(1<<0)
        add r8, r8, #1
        b wait_for_status_change

    clear_pin_evt:
        ldr r2, =GPIOTE_BASE
        mov r1, #0
        str r1, [r2, #GPIOTE_EVENTS_IN_0]
        bx lr

    end_of_message:
        bl clear_pin_evt
        mov r8, #0
        pop {lr}
        bx lr
