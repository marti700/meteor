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

    // IMPORTANT STUFF
    // for some reason the reset button of the microbit needs to be pressed for this program to work
    // i don't know why but hopefully one of this days i will know XD

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
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #(1<<4)

        /// THIS IS A TIMEOUT its porpouse is to start measuring distance from the
        //beginning when no echo is recieved but apparently this is not necessary
        @ ldr r2, =TIMER0_BASE
        @ ldr r3, [r2, #0x14C]
        @ tst r3, #1
        @ beq measure_distance
        ///

        beq wait_for_echo
        bl start_timer
        b wait_echo_to_go_low

    wait_echo_to_go_low:
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #(1<<4)
        bne wait_echo_to_go_low

        bl capture_time // copy timer value to CC1 register
        b check_distance

    check_distance:
        bl get_cc_1 // puts CC1 register value to R1
        cmp r1, #290 //290 is 5cm
        ble led_on
        bgt led_off

    led_on:
        ldr R0, =GIPIO_BASE // load OUT register to R0
        ldr R1, [R0, #0x504] // load contents of R0 to R1
        orr R1, #(1<<2) // toogle bit 2 of OUT register on/off
        str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
        b measure_distance

    led_off:
        ldr R0, =GIPIO_BASE // load OUT register to R0
        ldr R1, [R0, #0x504] // load contents of R0 to R1
        and R1, #(0<<2) // toogle bit 2 of OUT register on/off
        str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
        b measure_distance
///
