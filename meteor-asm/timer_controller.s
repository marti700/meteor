// This file defines functions to handle timer 1 of the microbit
.thumb
    .syntax unified
    .global reset_timer
    .global wait_10_us
    .global capture_time
    .global get_cc_1
    .global wait_80_ms
    .global start_timer
    .global delay_ms
    .global light_timer_reset

    .text
    .thumb_func

    .equ eighty_ms, 800000
    .equ TIMER0_BASE, 0x40008000
    .equ TIMER_PRESCALER, 4
    .equ TASK_START, 0x000
    .equ TASK_STOP, 0x004
    .equ TASK_CLEAR, 0x00C
    .equ TASK_CAPTURE_1, 0x044
    .equ EVENT_COMPARE_0, 0x140
    .equ EVENT_COMPARE_2, 0x148
    .equ EVENT_COMPARE_3, 0x14C
    .equ MODE, 0x508
    .equ PRESCALER, 0x510
    .equ CC_0, 0x540
    .equ CC_1, 0x544
    .equ CC_2, 0x548
    .equ CC_3, 0x54C

    // rest timer to its initial state
    reset_timer:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #TASK_STOP] // stop timer
        str r1, [r0, #TASK_CLEAR] // clear timer

        mov r1, #0
        str r1, [r0, #EVENT_COMPARE_0] // clear 10_us event
        str r1, [r0, #EVENT_COMPARE_3] // clear 80 ms event

        @ set bit mode to 32 bits
        mov r1, #3
        str r1, [r0, #MODE]

        ldr r1, =TIMER_PRESCALER
        str r1, [r0, #PRESCALER]

        @ set caputure register 0 to 10 micro seconds
        mov r1, #10
        str r1, [r0, #CC_0]

        @ set capture register 3 to 80 ms
        ldr r1, =eighty_ms
        str r1, [r0, #CC_3]

        bx lr

    light_timer_reset:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #TASK_STOP] // stop timer
        str r1, [r0, #TASK_CLEAR] // clear timer
        bx lr

    wait_10_us:
        push {lr}
        ldr r1, [r0, #EVENT_COMPARE_0]
    wait_10_us_inner:
        tst r1, #(1<<0)
        bne wait_10_us_inner
        pop {lr}
        bx lr

    capture_time:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #TASK_CAPTURE_1]
        bx lr

    get_cc_1:
        ldr r0, =TIMER0_BASE
        ldr r1, [r0, #CC_1]
        bx lr

    wait_80_ms:
        push {lr}
        bl reset_timer
        ldr r1, [r0, #EVENT_COMPARE_3]
    wait_80_ms_inner:
        tst r1, #1
        bne wait_80_ms_inner
        pop {lr}
        bx lr


    start_timer:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #TASK_START]
        bx lr

     // perform a delay of the specified number of milli seconds
     delay_ms:
        push {lr}
        bl reset_timer
        mov r4, #1000
        mul r5, r5, r4
        str r5, [r0, #CC_2]
        bl start_timer
    delay_ms_inner:
        ldr r5, [r0, #EVENT_COMPARE_2]
        tst r5, #1
        beq delay_ms_inner
    clear_timer_event:
        mov r5, #0
        str r5, [r0, #EVENT_COMPARE_2]

        pop {lr}
        bx lr
