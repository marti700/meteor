.thumb
    .syntax unified
    .global measure_distance
    .global init_gpio
    .global init_trigger
    .global wait_for_echo
    .global wait_echo_to_go_low
    .global check_distance
    .global led_on
    .global led_off


    .text
    .thumb_func

    .equ GIPIO_BASE, 0x50000000

    @ This assembly code is used to measure distances using the hs-sr04 ultrasonic
    @ sensor and it works as follows:

    @ 1. set pin 2 and 3 to output
    @ 2. set pin 4 to input
    @ 3. set pin 3 high (to engage the trigger pin)
    @ 4. wait 10_us
    @ 5. set pin 3 low (to disable the trigger pin)
    @ 6. waits for the echo pin to go high
    @ 7. measures the time the echo pin is high
    @ 8. check the distance

    measure_distance:
        push {lr}
        bl wait_80_ms
        bl init_gpio
        b init_trigger

    init_gpio:
        ldr R0, =GIPIO_BASE // load the DIRSET register to R0
        ldr R1, [R0] // load R0 contents to R1

        orr R1, #(1<<2) // set bit 2 of DIRSET to 1
        orr R1, #(1<<3) // set bit 3 of DIRSET to 1
        str R1, [R0, #0x518] // store the new value of R1 to R0, this will set microbit pin 0 and 1 to ouput

        ldr R1, [R0, #0x514]
        bic R1, #(1<<4)
        str R1, [R0, #0x514] // set pin 2 of micro bit to input

        // in order for the input pin to work one must enable the input buffer in the PIN_CNF[n] register
        // (where n is the pin number), one must also specify if the input will be pulldown or pullup to get
        // reproducible behavior (this is also configured in the PIN_CNF[n] register)
        ldr r1, [r0, #0x710]
        mov r1, #0x4
        str r1, [r0, #0x710] // enables pin 2 input buffer and configure pulldown resistor

        bx lr

    init_trigger:
        bl reset_timer
        ldr r0, =GIPIO_BASE
        // set trigger high
        ldr r1, [r0, #0x504]
        orr r1, #(1<<3)
        str r1, [r0, #0x504]
        bl start_timer
        bl wait_10_us
        // set trigger low
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x504]
        bic r1, #(1<<3)
        str r1, [r0, #0x504]
        bl reset_timer
        b wait_for_echo

    wait_for_echo:
        bl clear_cc3_event
        bl start_timer
    wait_for_echo_inner:
        /// THIS IS A TIMEOUT it's porpouse is to restart distance measuring
        //when no echo is recieved.
        ldr r2, =0x40008000
        ldr r3, [r2, #0x14C]
        tst r3, #1
        bne measure_distance
        // Timeout end

        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #(1<<4)
        beq wait_for_echo_inner
        bl reset_timer
        b wait_echo_to_go_low

    wait_echo_to_go_low:
        bl start_timer
    wait_echo_to_go_low_inner:
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #0x10
        bne wait_echo_to_go_low_inner

        bl capture_time // copy timer value to CC1 register
        pop {lr}
        bx lr

