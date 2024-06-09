    //This file have functions to decode an IR signal that follows the NEC protoccol

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


    // this function just write to r1 the value of the GPIOTE event
    // the goal is to know if a key was pressed. This will be used
    // on the other nodes to get to selection mode
    rc_pin_pulled_low:
        ldr r2, =GPIOTE_BASE
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        bx lr

    // sets up the GPIOTE to send events when signal on pin P0 of the microbit goes low
    // GPIOTE_CONFIG_0_CONF sets the configuration you can see the nrf52833 datasheet
    // for more details
    prepare_for_ir_transmission:
        mov r8, #0
        ldr r2, =GPIOTE_BASE
        ldr r1, =GPIOTE_CONFIG_0_CONF
        str r1, [r2, #GPIOTE_CONFIG_0]
        bx lr

    // this function is called when we want to listen on a controller key press
    // this will clean any values from r5 (where the key code is saved after decoding)
    // to make sure we are starting clean and will monitor the GPIOTE event on P0 pin
    // when the pin get low the event will be triggered and the wait_for_status_change function is called
    on_transmission_start:
        push {lr}
        mov r5, #0
        mov r6, #0
    on_transmission_start_inner:
        ldr r2, =GPIOTE_BASE
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne wait_for_status_change
        beq on_transmission_start_inner

    // this function is called by the on_transmission_start_inner function when an low pin event
    // is triggered. it first check if r8 is 32, this will mean that the message have been decoded
    // if this is the case the end_of_message function will be called to do clean up before returning
    // to the caller
    // if r8 value is not 32 then the P0 pin event is cleared and the timer is resseted using the
    // prepare_timer function then it enters the wait_for_status_change_inner to wait for the next
    // pin down event when that happends the capture_time_inf function will be called
    wait_for_status_change:
        cmp r8, #32
        beq end_of_message
        bl clear_pin_evt
        bl prepare_timer
    wait_for_status_change_inner:
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne capture_time_inf
        b wait_for_status_change_inner

    // rests the timer to 0, starts it and returns to control to wait_for_status_change_inner
    // to wait for the next pin down event
    prepare_timer:
        bl light_timer_reset
        bl start_timer
        b wait_for_status_change_inner

    // builds the pressed key code by capturing the time between pin low events
    // if the elapsed time is more than 9000 ms the transmition is going to be marked
    // as started by calling the mark_transmission_start function
    // if the elapsed time is less than 1600 ms 0 will be added to the code
    // if the elapsed time is more than 1600 ms 1 will be added to the code
    // to see why see the NEC protoccol specificaiton
    capture_time_inf:
        bl capture_time
        bl get_cc_1
        ldr r4, =NINE_SECONDS
        cmp r1, r4
        bgt mark_transmission_start
        cmp r1, #1600
        blt add_zero
        bgt add_one

    // clean r8 and r5. If the values in this registers registers are not 0 when the transmission starts
    // the decoded value will be erroneous
    mark_transmission_start:
        mov r8, #0
        mov r5, #0
        b wait_for_status_change

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
